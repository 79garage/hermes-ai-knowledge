# 1. Error Handling — discard, silent fail, log noise

Goal: every error is either **handled** (decision made), **returned with
context** (`%w`), or **logged once at the boundary** — never dropped, never
logged three times.

All commands assume repo root; add `-g '!**/*_test.go' -g '!**/mock*/**'` to
skip tests/mocks (the scanner does this for you).

---

### EH-01 Blank-identifier discard `_ =` / `x, _ :=` — P1
```bash
rg -n --type go '^\s*_\s*=\s*[\w.]+\(' 
rg -n --type go -P '^\s*\w+\s*,\s*_\s*:?=\s*[\w.]+\(' 
```
**Confirm if** the discarded value is an `error` from I/O, DB, JSON, strconv,
decimal parsing, or `time.Parse`. `x, _ := strconv.Atoi(c.Param("id"))` → id=0
→ query runs with `id = 0` → 404 at best, wrong row at worst.
**Ignore** `_ = tx.Rollback()` inside a deferred cleanup, and `_, _ = fmt.Fprint(os.Stderr…)`.
**Fix:** check it; for params use a helper that returns 400 (`parseIDParam(c, "id")`).

### EH-02 Bare call to an error-returning method — P0 for Commit, P1 otherwise
```bash
rg -n --type go -P '^\s*(\w+\.)*(Commit|Exec|ExecContext|NamedExec|NamedExecContext|Encode|Flush|Sync|Remove|RemoveAll|Rename|Put\w*|Delete\w*|Save\w*|Enqueue\w*|Publish\w*)\([^)]*\)\s*$'
```
**Confirm if** the return value is `error` (or `(T, error)`) and the line is
not `defer`. `tx.Commit()` unchecked = client gets 200, data never persisted.
**Fix:** `if err := tx.Commit(); err != nil { return fmt.Errorf("commit: %w", err) }`.

### EH-03 Echo response not returned — P1 (Echo-specific)
```bash
rg -n --type go -P '^\s*c\.(JSON|JSONPretty|String|NoContent|Blob|Stream|Attachment|File|Redirect|HTML)\('
```
**Confirm if** the line is not preceded by `return`/`err =`. The handler keeps
running after writing a response → second write ("response already committed"),
or side effects happen after an error response was sent.
**Fix:** `return c.JSON(...)`.

### EH-04 Error checked but swallowed — P1
```bash
# returns nil error from inside an err branch
rg -n --type go -U -P 'if err != nil \{\s*\n\s*return\s+(nil|\w+\{\}|""|0|false)?\s*(,\s*nil)?\s*\n\s*\}'
# logs then continues (no return / no continue)
rg -n --type go -U -P 'if err != nil \{\s*\n\s*[\w.]*(log|Log|logger|slog)\w*[.(][^\n]*\n\s*\}'
```
**Confirm if** the caller can't distinguish "not found / empty" from "DB down".
Classic: `if err != nil { return nil, nil }` in a repo → service treats outage
as "no record" → creates a duplicate.
**Allowed** only when the branch is explicitly `errors.Is(err, sql.ErrNoRows)`.

### EH-05 Sentinel compared with `==` — P2
```bash
rg -n --type go -P 'err\s*[!=]=\s*(sql\.ErrNoRows|pgx\.ErrNoRows|context\.(Canceled|DeadlineExceeded)|io\.EOF|\w+\.Err\w+)'
```
**Confirm if** anything between origin and check wraps the error (`%w`).
Once wrapped, `==` is false → 404 becomes 500.
**Fix:** `errors.Is(err, sql.ErrNoRows)`; typed: `errors.As(err, &pgErr)`.

### EH-06 Silent fallback / degraded mode without signal — P1
```bash
rg -n --type go -i 'fallback|fall back|best.?effort|ignore.*err|degrad'
```
**Confirm if** a failure (e.g. PostingEngine template missing) quietly switches
to another path (Simple GL) with no log/metric and no marker on the record.
Accounting impact: wrong accounts posted with 200 OK.
**Fix:** log at WARN with `company_id`, `event_type`, record the tier used on
the JE (`posting_source`), emit a counter. Decide explicitly if fallback should
be an error in production.

### EH-07 Wrapping breaks the chain — P3 (P2 if a caller uses errors.Is)
```bash
rg -n --type go -P 'fmt\.Errorf\([^)]*%(v|s)[^)]*\berr\b'
rg -n --type go 'errors\.New\(\s*err\.Error\(\)'
```
**Fix:** `%w`. One `%w` per Errorf unless you intend multi-wrap (Go 1.20+).

### EH-08 Log-and-return (duplicate logs = noise) — P3
```bash
rg -n --type go -U -P '(log|logger|slog|Logger\(\))\.\w+\([^\n]*\berr\b[^\n]*\n\s*return[^\n]*\berr\b'
```
**Confirm if** the same error will be logged again by `OperationErrorLogger`
or the handler. One error → one log line, at the boundary.
**Fix:** return wrapped; log only in handler/middleware/worker loop.

### EH-09 Log line without tenant/request context — P2
```bash
rg -n --type go -P '\blog\.(Print|Printf|Println|Fatal\w*)\(|fmt\.Print(f|ln)?\(' -g '!**/cmd/**' -g '!**/main.go'
```
**Confirm if** in handler/service/worker code. Without `company_id`,
`request_id`, `entity_id` you can't trace a production incident.
Also flag `log.Fatal` outside `main` (kills the process, skips defers).
**Fix:** structured logger from context (`slog` with request attrs).

### EH-10 Internal error leaked to client / wrong status — P2 (P1 if SQL/paths leak)
```bash
rg -n --type go -P '(c\.JSON|echo\.NewHTTPError)\([^\n]*err\.Error\(\)'
rg -n --type go -P 'StatusInternalServerError[^\n]*(valid|required|invalid|not found)' -i
```
**Confirm if** raw DB/driver text (`pq: duplicate key value violates…`,
file paths, SQL) reaches the response, or a client error returns 500.
**Fix:** map domain errors → status + stable error code (`VALIDATION_ERROR`,
`CONFLICT`, `NOT_FOUND`); log the raw error server-side.

### EH-11 Panics and goroutines outside Recover — P1
```bash
rg -n --type go -P '^\s*panic\(' -g '!**/main.go'
rg -n --type go -P '^\s*go\s+(func\b|[\w.]+\()'
```
**Confirm if** a goroutine has no `defer func(){ if r := recover()…}` —
Echo's `Recover` middleware only covers the request goroutine; a panic in a
worker/background goroutine **kills the whole API process**.
Also: goroutine result errors dropped (no errgroup/channel).
**Fix:** `errgroup.WithContext`, or a `safeGo(fn)` helper that recovers + logs.

### EH-12 Iteration errors ignored (`rows.Err`, scan) — P1
```bash
rg -n --type go -l '\.Next\(\)' | xargs -r rg --files-without-match 'rows\.Err\(\)|\.Err\(\)'
rg -n --type go -P '\.(Query|QueryContext|Queryx|QueryxContext)\(' 
```
**Confirm if** a `for rows.Next()` loop has no `rows.Err()` check after it
(network drop mid-stream → silently truncated report/ledger), or `rows` isn't
`defer rows.Close()`d (connection leak → pool exhaustion).
**Prefer** `sqlx.SelectContext` which handles both.
