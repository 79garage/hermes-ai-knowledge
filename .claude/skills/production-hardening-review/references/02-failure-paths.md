# 2. Failure Path — orphaned state, partial failure, cleanup

Goal: for any write path, a failure at **any** step leaves the system in
either the full "before" state or the full "after" state — or in an explicit,
recoverable intermediate state that something reaps.

---

## Manual trace

Grep can't see ordering. For every write path in the diff
(handler → service → repo), answer:

1. **Boundary** — which writes are inside one tx? List writes outside it.
2. **Kill points** — if the process dies after step N, what exists? (row w/o lines, file w/o row, JE w/o source, status `processing` forever)
3. **External effects** — file/S3, HTTP (LiteLLM, report-api, control-plane), queue, email: before or after commit? Compensated on failure?
4. **Retry** — if the client/worker retries the whole call, is the result the same (idempotent) or doubled?
5. **Concurrency** — two identical requests at the same time: which constraint/lock makes one fail cleanly?

Any "don't know" is a finding candidate.

---

### FP-01 Multiple writes without a transaction — P1 (P0 if ledger)
```bash
bash scripts/scan.sh <repo> fail   # function-level: ≥2 writes && no tx marker
```
Manual equivalent:
```bash
rg -n --type go -P '\w+Repo\.(Create|Insert|Update|Delete|Upsert|Post|Mark|Set|Add|Link)\w*\(' internal/service
```
**Confirm if** one func performs ≥2 writes (header + lines, entity + JE + VAT)
through `s.db` / repos not bound to the same `*sqlx.Tx`.
**Fix:** one tx per use case; repos accept `sqlx.ExtContext` so the same
method works with db or tx; pattern already in `postCreatedEntityTx`.

### FP-02 Transaction lifecycle bugs — P0/P1
```bash
rg -n --type go -P '\.(Beginx|BeginTxx|BeginTx|Begin)\('
```
For each hit check:
- `defer tx.Rollback()` immediately after a successful Begin (Rollback after Commit is a no-op — safe).
- **Every** return path commits or rolls back (early `return nil` without Commit = silent loss; tx held → pool starvation).
- No `s.db.`/`r.db.` call **inside** the tx scope (reads stale data / writes escape the tx / self-deadlock on the row the tx locked).
- Commit error checked (EH-02).
- Nested helpers don't open their own tx (Postgres has no nested tx; use savepoints or pass tx).

### FP-03 External side effect inside/before the transaction — P1
```bash
rg -n --type go -P '(storage|Storage|minio|s3|S3)\.\w+\(|\.(PutObject|Upload|Save(File)?)\(|\.Enqueue\w*\(|http\.(Get|Post|NewRequest)|\.Do\(req|Publish\(|SendMail|Notify\w*\('
```
**Confirm if** it runs before `tx.Commit()` in the same func.
- File saved, then INSERT fails → **orphaned object** in MinIO/FS.
- Job enqueued, then commit fails → worker processes a row that doesn't exist (or reads it before commit → "not found").
- HTTP to report-api/LiteLLM inside tx → tx held open for seconds → lock contention.

**Fix (pick one, match repo convention):**
- Do external work **after** commit; on its failure, mark row `failed` (reaper retries).
- Or before tx + `defer` compensating delete when `err != nil`.
- For queues: transactional outbox (insert job row in same tx; worker polls).

### FP-04 No compensation / cleanup on error path — P1
```bash
rg -n --type go -l -P '\.(Save|Put\w*|Upload|Create(Temp|File)?|MkdirAll)\(' | xargs -r rg --files-without-match -P '\.(Remove|RemoveAll|Delete\w*|Cleanup)\('
```
**Confirm if** a func creates an external resource but no path deletes it on
failure. Also `os.CreateTemp` without `defer os.Remove`.
**Fix:** named return `err` + `defer func(){ if err != nil { _ = store.Delete(ctx, key) } }()`.

### FP-05 Intermediate status with no exit — P1
```bash
rg -n --type go -P "['\"](processing|pending|running|queued|in_progress|posting|generating)['\"]|Status(Processing|Pending|Running|Queued)"
```
**Confirm if** a new intermediate status is set but:
- the failure branch doesn't move it to `failed`, **and**
- no reaper covers it (compare with the stranded OCR reaper 5-min cron / report cleanup).
Then crash between "set processing" and "set done" → stuck forever; user can't retry.
**Fix:** failure → `failed` + `error_message`; reaper uses `updated_at < now() - interval` and is idempotent.

### FP-06 Goroutine captures Echo context or request ctx — P1 (Echo-specific)
```bash
rg -n --type go -U -P 'go func\([^)]*\)\s*\{(?:(?!\n\}).){0,600}?\b(c\.(Get|Param|QueryParam|FormValue|Request|Bind|Set)|c\.Request\(\)\.Context\(\))' --multiline-dotall
```
**Confirm if** the goroutine outlives the handler.
- `echo.Context` is **pooled and reused** after the handler returns → reads another request's data (data race, cross-tenant).
- `c.Request().Context()` is cancelled when the response is written → background work aborts randomly with `context canceled`.
**Fix:** copy needed values before `go`; use `context.WithoutCancel(ctx)` (Go 1.21+) plus own timeout.

### FP-07 Check-then-act race on status — P1
```bash
# UPDATE ... SET status without a status guard in WHERE
rg -n --type go -U -P '(?is)UPDATE\s+\w+\s+SET\s+[^`;]*?\bstatus\s*=[^`;]*?WHERE(?:(?!\bstatus\b)[^`;])*?[`;]'
```
**Confirm if** code reads status (`if inv.Status != "draft"`), then updates by
id only. Two concurrent "Post" requests both pass the check → **two journal
entries** for one invoice.
**Fix:** `UPDATE … SET status='posted' WHERE id=$1 AND company_id=$2 AND status='draft'` and
treat `RowsAffected()==0` as conflict (409); or `SELECT … FOR UPDATE` at tx start.

### FP-08 Period/lock state checked outside the posting tx — P1
```bash
rg -n --type go -i -P 'is_closed|IsClosed|PeriodClosed|CheckPeriod|EnsurePeriodOpen|locked_at'
```
**Confirm if** the period-open check happens before `Begin` or in a separate
query without lock → period close run can commit in between → posting lands
in a closed period.
**Fix:** check inside the posting tx with `FOR SHARE` on the `accounting_periods` row (close takes `FOR UPDATE`).

### FP-09 Retry of non-idempotent work — P1
```bash
rg -n --type go -i -P 'retry|backoff|attempt\s*[<:]=?|for\s+i\s*:=\s*0;\s*i\s*<\s*(max|\d)'
```
**Confirm if** the retried block includes an INSERT, a JE post, or an external
call with side effects, and there's no idempotency key / unique guard.
Timeout ≠ failure: the first attempt may have succeeded.
**Fix:** idempotency key column + unique index; retry only reads or guarded writes.

### FP-10 Resource cleanup bugs — P2
```bash
rg -n --type go -U -P 'for\b[^{\n]*\{(?:(?!\n\t?\}).)*?\bdefer\b' --multiline-dotall   # defer in loop
rg -n --type go -P 'context\.With(Timeout|Cancel|Deadline)\(' | rg -v 'cancel\b|defer'   # cancel dropped
rg -n --type go -P '\bresp\s*,\s*err\s*:?=\s*[\w.]*\.(Do|Get|Post)\('                 # verify defer resp.Body.Close()
```
**Confirm** defers inside loops (files/rows held until func end), dropped
`cancel` funcs (ctx leak; `go vet` lostcancel), HTTP bodies not closed (conn leak).

### FP-11 Unbounded waits on dependencies — P1
```bash
rg -n --type go -P 'http\.DefaultClient|&http\.Client\{\s*\}|http\.(Get|Post|Head)\(|context\.(Background|TODO)\(\)' -g '!**/main.go' -g '!**/cmd/**'
```
**Confirm if** calls to LiteLLM / report-api / control-plane / Qdrant have no
timeout, or DB calls in request path use `context.Background()` (ignores
client disconnect and server timeout). One slow dependency → all handler
goroutines + DB conns pinned → outage.
**Fix:** `http.Client{Timeout: …}` per dependency; pass `c.Request().Context()`;
set `statement_timeout` / `idle_in_transaction_session_timeout` on the pool.
