# 4. Data Integrity — duplicate, orphaned rows, incomplete state

Goal: invariants are enforced by **the database**, not only by Go code.
App-level checks are optimizations; constraints are the guarantee.

---

### DI-01 Check-then-insert duplicates — P1
```bash
rg -n --type go -P '\.(Exists|CheckExists|FindBy\w+|GetBy(No|Code|Name|Number|Ref)\w*|Count\w*)\(' internal/service
```
**Confirm if** followed by an insert and no UNIQUE index backs it. Under
concurrency (double-click, client retry, 2 pods) both checks pass.
**Fix:** UNIQUE index + handle 23505 → 409, or `INSERT … ON CONFLICT DO NOTHING RETURNING id`.

### DI-02 Unique constraint scope wrong — P1
```bash
rg -n -i -P 'UNIQUE\s*\((?![^)]*company_id)[^)]*\)|CREATE\s+UNIQUE\s+INDEX[^;]*\((?![^)]*company_id)[^)]*\)' "$MIG"
rg -n -i -P 'CREATE\s+UNIQUE\s+INDEX(?![^;]*WHERE)[^;]*;' "$MIG"     # non-partial unique on soft-delete tables
```
**Confirm if** a tenant-owned business key (`invoice_no`, `entry_no`,
`code`, `tax_id`) is unique **globally** (tenant B blocked by tenant A;
existence leak), or unique without `WHERE deleted_at IS NULL` on a soft-delete
table (can't recreate a deleted code).
Generated keys must embed enough to be unique (ISSUE-005:
`JE-TI-<invoiceID>-<taxInvoiceNo>`).
**Fix:** `UNIQUE (company_id, invoice_no)`; partial index for soft delete.

### DI-03 Racy number generation — P0 for tax documents
```bash
rg -n --type go -i -P 'MAX\(\s*\w*(no|number|seq)\w*\s*\)|COUNT\(\*\)\s*\+\s*1|len\(\w+\)\s*\+\s*1|last\w*(No|Number)\s*\+\s*1'
```
**Confirm if** the next number is derived from existing rows. Two concurrent
creates get the same number; or a rolled-back tx leaves a gap (Thai tax
invoices must be sequential — gaps need an audit trail).
**Fix:** counter row `UPDATE doc_sequences SET next=next+1 WHERE company_id=$1 AND doc_type=$2 RETURNING next` **inside** the same tx as the document insert; `CheckExists` covers every doc_type (CO-06).

### DI-04 Non-idempotent state transitions — P0 for posting
```bash
rg -n --type go -P '\.(POST|PUT|PATCH)\("[^"]*/(post|approve|submit|review|confirm|reverse|void|cancel|close|lock|depreciate|reconcile)\w*"'
```
For each route, trace to the write and confirm **both**:
- guarded transition (`WHERE status = 'draft'` + RowsAffected check — FP-07), **and**
- DB guard for the side effect: at most one active JE per source, e.g. `UNIQUE (company_id, source_type, source_id) WHERE status <> 'reversed'` (verify real column names in schema).
Second call must return 409 or the same result — never a second JE/VAT/WHT record.

### DI-05 Parent/child written or deleted non-atomically — P1
```bash
rg -n -i -P 'REFERENCES\s+\w+\s*\(\s*\w+\s*\)(?!\s*(ON\s+DELETE|DEFERRABLE))' "$MIG"   # FK without ON DELETE policy
rg -n --type go -i -P 'DELETE\s+FROM\s+(\w*invoices?|receipts?|journal_entries|documents|\w*orders?|grn\w*|payroll\w*)\b'
```
**Confirm if**
- header + lines inserted outside one tx (FP-01) → header with no lines, totals ≠ Σ lines;
- hard delete of a parent leaves children (lines, vat_records, wht_records, attachments, stored files) — or FK blocks delete → 500;
- delete of a **posted** document is possible at all (should be reverse/cancel only).
**Fix:** explicit `ON DELETE CASCADE` for owned children, `RESTRICT` for referenced masters; posted docs immutable.

### DI-06 Query without tenant filter — P0
```bash
rg -n --type go -U -P '(?is)`\s*(SELECT|UPDATE|DELETE)\b(?:(?!`).)*?\bWHERE\b(?:(?!company_id)(?!`).)*`' --multiline-dotall
```
**Confirm if** a tenant-owned table is read/updated/deleted by `id` alone.
Guessable IDs → cross-tenant read/write. Also JOINs: the joined table must
match `company_id` too.
**Ignore** global tables (users, tenants, posting template catalog, system config).
**Fix:** every repo method takes `companyID` and puts it in WHERE; consider RLS as backstop.

### DI-07 Update/Delete result not checked — P2 (P1 in posting flow)
```bash
rg -n --type go -P '^\s*_\s*,\s*err\s*:?=\s*[\w.]+\.(Exec|ExecContext|NamedExec|NamedExecContext)\('
```
**Confirm if** the statement is UPDATE/DELETE by id/status. 0 rows affected
(wrong tenant, already posted, deleted) → returns 200 "success" but nothing changed.
**Fix:** `n, _ := res.RowsAffected(); if n == 0 { return ErrNotFoundOrConflict }`.

### DI-08 Incomplete state reachable — P1
Status and its required data must move together. Grep status setters:
```bash
rg -n --type go -P "status\s*=\s*['\"]?(posted|approved|reviewed|confirmed|closed|locked)['\"]?"
```
**Confirm if** the status write can commit without its companion data
(posted without `journal_entry_id`; reviewed without entity; closed without snapshot).
**Fix:** same tx; add DB CHECK where cheap, e.g.
`CHECK (status <> 'posted' OR journal_entry_id IS NOT NULL)` (verify column names).

**Detection SQL** — run read-only on staging/replica. Column names below are
**templates**; confirm against the real schema first (they are not in
`system-knowledge/07-database/DATABASE_MAP.md`).
```sql
-- posted/approved documents with no journal entry
SELECT 'sales_invoices' t, id, company_id FROM sales_invoices
 WHERE status IN ('approved','posted') AND journal_entry_id IS NULL;
-- unbalanced posted journal entries (DB has no constraint — app-only)
SELECT je.id, je.company_id, SUM(jl.debit) dr, SUM(jl.credit) cr
  FROM journal_entries je JOIN journal_lines jl ON jl.journal_entry_id = je.id
 WHERE je.status = 'posted' GROUP BY je.id, je.company_id
HAVING SUM(jl.debit) <> SUM(jl.credit);
-- journal entries with no lines
SELECT je.id FROM journal_entries je
 WHERE NOT EXISTS (SELECT 1 FROM journal_lines jl WHERE jl.journal_entry_id = je.id);
-- duplicate document numbers per tenant
SELECT company_id, invoice_no, COUNT(*) FROM sales_invoices
 GROUP BY 1,2 HAVING COUNT(*) > 1;
-- documents stuck in processing
SELECT id, company_id, updated_at FROM documents
 WHERE status = 'processing' AND updated_at < now() - interval '30 minutes';
-- header total != sum(lines)
SELECT si.id FROM sales_invoices si JOIN sales_invoice_lines l ON l.invoice_id = si.id
 GROUP BY si.id, si.subtotal HAVING si.subtotal <> SUM(l.amount);
-- postings dated inside a closed period
SELECT je.id, je.date FROM journal_entries je JOIN accounting_periods p
    ON p.company_id = je.company_id AND je.date BETWEEN p.start_date AND p.end_date
 WHERE p.is_closed AND je.created_at > p.closed_at;
```

### DI-09 Posting into closed period not enforced everywhere — P0
```bash
rg -n --type go -l -P '\.(Post|PostJournal|CreateJournal\w*|Reverse)\w*\(' internal/service \
  | xargs -r rg --files-without-match -i 'is_closed|IsClosed|PeriodClosed|CheckPeriod|EnsurePeriodOpen'
```
**Confirm if** a service creates/posts JEs (sales, receipt, purchase, payroll,
depreciation, stock COGS, bank reconcile) without the period guard — or the
guard lives in only one path of the 3-tier fallback.
**Fix:** enforce in `JournalService` (single choke point) + FP-08 locking.

### DI-10 Money arithmetic & rounding — P0
```bash
rg -n --type go -P '\bfloat(32|64)\(|math\.Round\(|\*\s*0\.07\b|/\s*100(\.0)?\b'
rg -n --type go -P 'decimal\.NewFromFloat\('
```
**Confirm if** amounts are computed in float, rounded at different stages
(per line vs total) than the DB/report, or VAT computed as `x*0.07` in float.
**Fix:** `shopspring/decimal` end-to-end, `.Round(2)` at a defined step
(document the rule), `NewFromString` for input.

### DI-11 Ledger written outside the journal choke point — P0
```bash
rg -n --type go -i -P 'INSERT\s+INTO\s+journal_(entries|lines)\b' | awk -F: '{print $1}' | sort | uniq -c
rg -n --type go -i -P 'UPDATE\s+journal_(entries|lines)\s+SET'
```
**Confirm if** anything besides the journal repository writes journal rows,
or posted lines are UPDATEd in place (should reverse + repost). Bypass = no
balance check, no period check, no audit.

### DI-12 Soft-delete filter missing — P2
```bash
rg -n -i -P '\b(\w+)\b[^\n]*deleted_at' "$MIG" | head      # which tables soft-delete
rg -n --type go -U -P '(?is)`\s*SELECT\b(?:(?!`).)*?\bFROM\s+(customers|suppliers|products|accounts)\b(?:(?!deleted_at)(?!`).)*`' --multiline-dotall
```
**Confirm if** the table actually has `deleted_at` and the query is for
active records (lists, lookups, FK validation). Deleted customer reappears in
dropdown / can be invoiced. Adjust the table list to the real soft-delete set.
