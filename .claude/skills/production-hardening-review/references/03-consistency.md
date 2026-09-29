# 3. Consistency — API vs DB, validation mismatch

Goal: the API contract, Go types, validation rules, and DB schema agree.
Where they disagree, the **DB wins at runtime** — and the client sees a 500.

Migrations location varies; set `MIG` first:
```bash
MIG=$(rg --files -g '*.sql' | xargs -r dirname | sort | uniq -c | sort -rn | head -1 | awk '{print $2}')
```

---

### CO-01 nil slice serialized as `null` — P2 (ISSUE-006)
```bash
rg -n --type go -P '^\s*var\s+\w+\s+\[\]\*?[\w.]+\s*$'
rg -n --type go -P '(Items|Data|Lines|Rows)\s*:\s*\w+\s*[,}]'
```
**Confirm if** the slice reaches a JSON response and may be empty
(`sqlx.Select` on zero rows leaves a nil slice). Frontend `items ?? []`
breaks on `null`-vs-object patterns.
**Fix:** `items := make([]T, 0)` before Select, or normalize in the shared list-response constructor (one place, not per handler).

### CO-02 Bind without validation / Bind error ignored — P1
```bash
rg -n --type go -P 'c\.Bind\(' 
rg -n --type go -l 'c\.Bind\(' | xargs -r rg --files-without-match 'c\.Validate\(|\.Validate\(\)'
rg -n --type go -P '^\s*(_\s*=\s*)?c\.Bind\('                              # error dropped
```
**Confirm if** a handler Binds then goes to service with no validation step.
Zero values pass silently: missing `amount` → `0`, missing date → `0001-01-01`.
**Fix:** `if err := c.Bind(&req); err != nil { return 400 }` then `c.Validate(&req)`;
use pointers (`*decimal.Decimal`, `*string`) where "absent" ≠ "zero".

### CO-03 Server-owned fields bindable from client — P0/P1
```bash
rg -n --type go -P '(json|form|query)\s*:\s*"(company_id|tenant_id|created_by|approved_by|status|posted_at|entry_no|invoice_no|journal_entry_id|total_amount|subtotal|vat_amount)"'
```
**Confirm if** that struct is used as a **request** (Bind target). Echo
`Bind` fills path+query+body: client can set `company_id` (tenant hop),
`status` (skip workflow), or totals (mismatch with lines).
**Fix:** separate request DTO without those fields; set them server-side
from JWT/context and recompute totals from lines.

### CO-04 Go type vs column type — P0 money, P1 others
```bash
rg -n --type go -P '\bfloat(32|64)\b[^\n]*(db|json):"\w*(amount|total|price|rate|balance|debit|credit|vat|wht|cost|qty|quantity)\w*"'   # ISSUE-001
rg -n --type go -P '\s(string|int\d*|float64|bool|time\.Time)\s+`[^`]*db:"\w*(_at|_date|_by|_id|note|notes|reference|description)"'   # non-pointer for likely-nullable
```
**Confirm** nullability in migrations. Non-pointer Go field + nullable column
= `converting NULL to string is unsupported` — only on real data with NULLs,
never in tests with full fixtures.
**Fix:** `*T` / `sql.Null*` for nullable; `decimal.Decimal` for NUMERIC; JSON money as string.

### CO-05 Validation rules drift between layers — P2
```bash
rg -n -o -P '\w+\s+VARCHAR\(\d+\)' "$MIG" | sort -u        # DB lengths
rg -n --type go -o -P 'validate:"[^"]*max=\d+[^"]*"'         # Go lengths
rg -n -P 'CHECK\s*\(\s*\w+\s+IN\s*\(' "$MIG"                  # DB enums
rg -n --type go -o -P 'oneof=[^"]+'                           # Go enums
```
**Confirm if** Go allows what DB rejects (→ 500 with driver message) or
DB allows what Go rejects (other writers bypass). Enum vocabularies must match
exactly across frontend/Go/DB (ISSUE-010 `supplier_type`: `company` vs `juristic`).
**Fix:** define enum once in Go (`const` + `Valid()`), mirror in DB CHECK, generate FE types.

### CO-06 `switch` with silent `default` — P1 (ISSUE-004)
```bash
rg -n --type go -U -P 'default:\s*\n\s*return\s+(false|nil|""|0|\w+\{\})\s*(,\s*nil)?\s*\n'
```
**Confirm if** the switch is over doc_type / status / event_type / account
type. New enum value added → falls into default → "not exists" → duplicates,
or "no template" → fallback.
**Fix:** `default: return false, fmt.Errorf("unsupported doc_type %q", t)`; add a
test iterating **all** registered values.

### CO-07 DB errors not mapped to HTTP status — P2
```bash
rg -n --type go -l -P '23505|23503|23502|23514|UniqueViolation|ForeignKeyViolation|pgconn\.PgError|pq\.Error' || echo "NO PG ERROR MAPPING FOUND"
rg -n --type go -P 'errors\.Is\([^)]*ErrNoRows' | wc -l
```
**Expected mapping:** `sql.ErrNoRows`→404 · 23505 unique→409 · 23503 FK→409/422 ·
23502 not-null / 23514 check / 22P02 bad input→422 · 40001/40P01 serialization/deadlock→retry or 409 · `context.Canceled`→499/no log.
**Confirm if** constraint violations surface as 500 (and page on-call).
**Fix:** one `mapDBError(err) error` in the repo layer returning domain errors.

### CO-08 Same table written from multiple code paths — P1 (ISSUE-002)
```bash
rg -n --type go -o -P '(?i)INSERT\s+INTO\s+\w+' | awk -F: '{print tolower($NF)}' | sort | uniq -c | sort -rn
rg -n --type go -l -P '(?i)INSERT\s+INTO\s+purchase_invoices\b'
```
**Confirm if** a table is inserted from >1 service and the paths differ in
validation, numbering, or side effects (VAT record, GRN clearing).
**Fix:** single write service; legacy path delegates to it.

### CO-09 Response built from request, not from DB — P2
```bash
rg -n --type go -P 'c\.JSON\([^,]+,\s*(&?req|input|body|payload|params)\b'
```
**Confirm if** Create/Update returns the request struct: missing generated
id, doc number, computed totals, defaults, `updated_at` → frontend caches wrong state.
**Fix:** `RETURNING *` or re-read by id inside the tx.

### CO-10 Time zone / date boundaries — P1 for tax periods
```bash
rg -n --type go -P 'time\.Now\(\)(?!\.In\()' -g '!**/*_test.go'
rg -n --type go -P 'time\.Parse\("2006-01-02"'                 # parses as UTC
rg -n --type go -P '\.Truncate\(24\s*\*\s*time\.Hour\)'          # UTC midnight
```
**Confirm if** the value determines document date, VAT/WHT period, or
period-close cutoff. Bangkok is UTC+7: a doc created 00:30 on the 1st local
is the previous month in UTC → wrong PP30/PND period.
**Fix:** `time.ParseInLocation(layout, s, bkk)`; store `DATE` for business
dates; derive "today" from company TZ, not server TZ.
