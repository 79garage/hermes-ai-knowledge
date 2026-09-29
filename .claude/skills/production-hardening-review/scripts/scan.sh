#!/usr/bin/env bash
# production-hardening-review scanner — candidate finder, NOT a verdict.
# Every hit must be triaged with the matching references/*.md "Confirm if" rule.
#
# Usage:
#   scan.sh [repo-root] [all|err|fail|cons|data]
# Env:
#   CHANGED_ONLY=<file>   newline-separated list of .go files to limit the Go scan (e.g. git diff --name-only)
#   MIG=<dir>             migrations dir (default: auto-detect dir with most *.sql files)
#   MAX_HITS=<n>          hits printed per check (default 30; counts are always exact)
set -uo pipefail

ROOT="${1:-.}"
CAT="${2:-all}"
MAX_HITS="${MAX_HITS:-30}"

command -v rg >/dev/null || { echo "ripgrep (rg) is required" >&2; exit 2; }
cd "$ROOT" || { echo "cannot cd to $ROOT" >&2; exit 2; }

case "$CAT" in all|err|fail|cons|data) ;; *) echo "category must be all|err|fail|cons|data" >&2; exit 2;; esac

GO_GLOBS=(-g '*.go' -g '!*_test.go' -g '!**/vendor/**' -g '!**/mock/**' -g '!**/mocks/**' -g '!**/*_mock.go' -g '!**/*.pb.go' -g '!**/testdata/**')

# Paths for Go checks
GO_PATHS=(.)
if [[ -n "${CHANGED_ONLY:-}" ]]; then
  mapfile -t GO_PATHS < <(grep -E '\.go$' "$CHANGED_ONLY" | grep -vE '_test\.go$' | while read -r f; do [[ -f "$f" ]] && echo "$f"; done)
  if [[ ${#GO_PATHS[@]} -eq 0 ]]; then echo "CHANGED_ONLY has no existing non-test .go files"; exit 0; fi
fi

# Migrations dir
if [[ -z "${MIG:-}" ]]; then
  MIG=$(rg --files -g '*.sql' -g '!**/vendor/**' 2>/dev/null | xargs -r -n1 dirname | sort | uniq -c | sort -rn | awk 'NR==1{print $2}')
fi

# emit() often runs in a pipeline subshell, so the summary goes through a file, not variables.
SUMMARY_FILE=$(mktemp)
trap 'rm -f "$SUMMARY_FILE"' EXIT

emit() { # id sev title <hits-on-stdin>
  local id="$1" sev="$2" title="$3" out n
  out=$(cat)
  [[ -z "$out" ]] && return 0
  n=$(printf '%s\n' "$out" | grep -c '')
  printf '%-6s %-3s %4d  %s\n' "$id" "$sev" "$n" "$title" >> "$SUMMARY_FILE"
  printf '\n== %s [%s] %s — %d candidate(s)\n' "$id" "$sev" "$title" "$n"
  printf '%s\n' "$out" | head -n "$MAX_HITS"
  (( n > MAX_HITS )) && printf '   … %d more (MAX_HITS=%d)\n' "$((n - MAX_HITS))" "$MAX_HITS"
  return 0
}

# Multiline (-U) matches print one line per matched line; keep only the first line of each consecutive run.
collapse() {
  if [[ "$1" == yes ]]; then
    awk -F: '{ if ($1 == pf && $2 == pl + 1) { pl = $2; next } pf = $1; pl = $2; print }'
  else
    cat
  fi
}
is_multiline() { local a; for a in "$@"; do [[ "$a" == -U || "$a" == --multiline ]] && { echo yes; return; }; done; echo no; }

# go ID SEV TITLE rg-args...   (pattern last)
go_check() {
  local id="$1" sev="$2" title="$3"; shift 3
  emit "$id" "$sev" "$title" < <(rg -n --no-heading --color never "${GO_GLOBS[@]}" "$@" -- "${GO_PATHS[@]}" 2>/dev/null | collapse "$(is_multiline "$@")")
}

sql_check() {
  local id="$1" sev="$2" title="$3"; shift 3
  [[ -z "$MIG" ]] && return 0
  emit "$id" "$sev" "$title" < <(rg -n --no-heading --color never -g '*.sql' "$@" -- "$MIG" 2>/dev/null | collapse "$(is_multiline "$@")")
}

# Function-level analysis (ordering-aware). Emits: CHECK<TAB>file:line<TAB>message
func_scan() {
  local files
  mapfile -t files < <(rg --files "${GO_GLOBS[@]}" -- "${GO_PATHS[@]}" 2>/dev/null)
  [[ ${#files[@]} -eq 0 ]] && return 0
  awk '
    function reset() { fname=""; fline=0; writes=0; hasTx=0; begin=0; rb=0; commit=0; dbInTx=""; se=""; }
    function flush() {
      if (fname == "") return
      if (writes >= 2 && !hasTx)       printf "FP-01\t%s:%d\t%s: %d writes, no tx marker\n", FILENAME, fline, fname, writes
      if (begin && !rb)                printf "FP-02\t%s:%d\t%s: Begin without Rollback (defer tx.Rollback missing)\n", FILENAME, fline, fname
      if (begin && !commit)            printf "FP-02\t%s:%d\t%s: Begin without Commit in same func (verify ownership)\n", FILENAME, fline, fname
      if (dbInTx != "")                printf "FP-02\t%s\t%s: non-tx db handle used after Begin\n", dbInTx, fname
      if (se != "")                    printf "FP-03\t%s\t%s: external side effect before Commit\n", se, fname
    }
    FNR == 1 { flush(); reset() }
    /^func / { flush(); reset(); fname=$0; sub(/[ \t]*\{[ \t]*$/, "", fname); sub(/^func /, "", fname); fline=FNR; next }
    fname == "" { next }
    /^}/ { flush(); reset(); next }
    /^[ \t]*\/\// { next }
    /\.(Beginx|BeginTxx|BeginTx|Begin)\(/            { begin=1; hasTx=1 }
    /WithTx|RunInTx|InTx\(|\btx\b|\bTx\b|sqlx\.Tx/   { hasTx=1 }
    /Rollback\(/                                      { rb=1 }
    /\.Commit\(/                                      { commit=FNR }
    /Repo\.(Create|Insert|Update|Delete|Upsert|Post|Mark|Set|Add|Link)[A-Za-z]*\(|\.(Exec|ExecContext|NamedExec|NamedExecContext)\(/ { writes++ }
    begin && !commit && !/\.(Beginx|BeginTxx|BeginTx|Begin)\(/ && /(^|[^A-Za-z_])(s|r|h|svc|repo)\.(db|DB)\./ { if (dbInTx == "") dbInTx = FILENAME ":" FNR }
    begin && !commit && /([Ss]torage|[Mm]inio|[Ss]3)\.[A-Za-z]+\(|\.(PutObject|Upload|SaveFile)\(|\.Enqueue[A-Za-z]*\(|http\.(Get|Post|NewRequest)|\.Do\(req|Publish\(|SendMail|Notify[A-Za-z]*\(/ { if (se == "") se = FILENAME ":" FNR }
    END { flush() }
  ' "${files[@]}"
}

echo "production-hardening-review scan — root: $(pwd)  category: $CAT  migrations: ${MIG:-<none found>}"
[[ -n "${CHANGED_ONLY:-}" ]] && echo "limited to ${#GO_PATHS[@]} changed file(s)"

# ───────────────────────── 1. Error handling ─────────────────────────
if [[ "$CAT" == all || "$CAT" == err ]]; then
  go_check EH-01 P1 "blank-identifier discard" -P '^\s*_\s*=\s*[\w.]+\(|^\s*\w+\s*,\s*_\s*:?=\s*[\w.]+\('
  go_check EH-02 P0 "bare call to error-returning method" -P '^\s*(\w+\.)*(Commit|Exec|ExecContext|NamedExec|NamedExecContext|Encode|Flush|Sync|Remove|RemoveAll|Rename|Put\w*|Delete\w*|Save\w*|Enqueue\w*|Publish\w*)\([^)]*\)\s*$'
  go_check EH-03 P1 "echo response not returned" -P '^\s*c\.(JSON|JSONPretty|String|NoContent|Blob|Stream|Attachment|File|Redirect|HTML)\('
  go_check EH-04 P1 "error branch returns nil / logs and continues" -U -P 'if err != nil \{\s*\n\s*return\s+(nil|\w+\{\}|""|0|false)?\s*(,\s*nil)?\s*\n\s*\}|if err != nil \{\s*\n\s*[\w.]*(log|Log|logger|slog)\w*[.(][^\n]*\n\s*\}'
  go_check EH-05 P2 "sentinel error compared with ==" -P 'err\s*[!=]=\s*(sql\.ErrNoRows|pgx\.ErrNoRows|context\.(Canceled|DeadlineExceeded)|io\.EOF|\w+\.Err\w+)'
  go_check EH-06 P1 "silent fallback / best-effort" -i -P '\bfall ?back\b|best.?effort|ignor\w* (the )?err|degrad'
  go_check EH-07 P3 "error wrapped without %w" -P 'fmt\.Errorf\([^)]*%(v|s)[^)]*\berr\b|errors\.New\(\s*err\.Error\(\)'
  go_check EH-08 P3 "log-and-return (duplicate logging)" -U -P '(log|logger|slog|Logger\(\))\.\w+\([^\n]*\berr\b[^\n]*\n\s*return[^\n]*\berr\b'
  go_check EH-09 P2 "unstructured log / log.Fatal outside main" -g '!**/main.go' -g '!**/cmd/**' -P '\blog\.(Print|Printf|Println|Fatal\w*)\(|\bfmt\.Print(f|ln)?\('
  go_check EH-10 P2 "internal error text sent to client" -P '(c\.JSON|echo\.NewHTTPError)\([^\n]*err\.Error\(\)'
  go_check EH-11 P1 "panic / goroutine outside Recover" -g '!**/main.go' -P '^\s*panic\(|^\s*go\s+(func\b|[\w.]+\()'
  # EH-12: files iterating rows without rows.Err()
  rg -l --color never "${GO_GLOBS[@]}" '\.Next\(\)' -- "${GO_PATHS[@]}" 2>/dev/null \
    | xargs -r rg --files-without-match --color never '\.Err\(\)' 2>/dev/null \
    | xargs -r rg -n --with-filename --no-heading --color never 'for\s+\w+\.Next\(\)' 2>/dev/null \
    | emit EH-12 P1 "rows.Next loop in file with no rows.Err() check"
fi

# ───────────────────────── 2. Failure paths ─────────────────────────
if [[ "$CAT" == all || "$CAT" == fail ]]; then
  FS=$(func_scan)
  for id in FP-01 FP-02 FP-03; do
    case $id in
      FP-01) sev=P1; t="multiple writes, no transaction" ;;
      FP-02) sev=P0; t="transaction lifecycle" ;;
      FP-03) sev=P1; t="external side effect before commit" ;;
    esac
    printf '%s\n' "$FS" | awk -F'\t' -v id="$id" '$1==id {print $2": "$3}' | emit "$id" "$sev" "$t"
  done
  rg -l --color never "${GO_GLOBS[@]}" -P '\.(PutObject|Upload|SaveFile|CreateTemp)\(|([Ss]torage|[Mm]inio)\.\w*(Save|Put|Upload)\w*\(' -- "${GO_PATHS[@]}" 2>/dev/null \
    | xargs -r rg --files-without-match --color never -P '\.(Remove|RemoveAll|Delete\w*|Cleanup)\(' 2>/dev/null \
    | sed 's/$/: creates external resource, no delete path in file/' \
    | emit FP-04 P1 "no compensation on error path"
  go_check FP-05 P1 "intermediate status (verify failure exit + reaper)" -P "['\"](processing|pending|running|queued|in_progress|posting|generating)['\"]|Status(Processing|Pending|Running|Queued|InProgress)\b"
  go_check FP-06 P1 "goroutine captures echo.Context / request ctx" -U --multiline-dotall -P 'go func\([^)]*\)\s*\{(?:(?!\n\}).){0,600}?\b(c\.(Get|Param|QueryParam|FormValue|Request|Bind|Set)\b|c\.Request\(\)\.Context\(\))'
  go_check FP-07 P1 "UPDATE status without status guard in WHERE" -U -P '(?is)UPDATE\s+\w+\s+SET\s+[^`;]*?\bstatus\s*=[^`;]*?WHERE(?:(?!\bstatus\b)[^`;])*?[`;]'
  go_check FP-08 P1 "period/lock checks (verify inside posting tx)" -i -P '\bis_closed\b|IsClosed|PeriodClosed|CheckPeriod|EnsurePeriodOpen|\blocked_at\b'
  go_check FP-09 P1 "retry loops (verify idempotency)" -i -P '\bretr(y|ies)\b|backoff|for\s+\w+\s*:=\s*0;\s*\w+\s*<\s*(max\w*|\d+);'
  go_check FP-10 P2 "defer in loop / dropped cancel" -U --multiline-dotall -P '\bfor\b[^{\n]*\{(?:(?!\n\t?\}).){0,400}?\bdefer\b|\b_\s*:?=\s*context\.With(Timeout|Cancel|Deadline)\(|,\s*_\s*:?=\s*context\.With(Timeout|Cancel|Deadline)\('
  go_check FP-11 P1 "no timeout / detached context" -g '!**/main.go' -g '!**/cmd/**' -P 'http\.DefaultClient|&http\.Client\{\s*\}|http\.(Get|Post|Head)\(|context\.(Background|TODO)\(\)'
fi

# ───────────────────────── 3. Consistency ─────────────────────────
if [[ "$CAT" == all || "$CAT" == cons ]]; then
  go_check CO-01 P2 "nil slice may serialize as null" -P '^\s*var\s+\w+\s+\[\]\*?[\w.]+\s*$'
  rg -l --color never "${GO_GLOBS[@]}" 'c\.Bind\(' -- "${GO_PATHS[@]}" 2>/dev/null \
    | xargs -r rg --files-without-match --color never -P 'c\.Validate\(|\.Validate\(\)' 2>/dev/null \
    | sed 's/$/: c.Bind without any Validate call in file/' \
    | emit CO-02 P1 "bind without validation"
  go_check CO-02b P1 "c.Bind error dropped" -P '^\s*(_\s*=\s*)?c\.Bind\('
  go_check CO-03 P1 "server-owned field bindable (verify request DTO)" -P '(json|form|query):"(company_id|tenant_id|created_by|approved_by|status|posted_at|entry_no|invoice_no|journal_entry_id|total_amount|subtotal|vat_amount)[",]'
  go_check CO-04 P0 "float for money" -P '\bfloat(32|64)\b[^\n]*(db|json):"\w*(amount|total|price|rate|balance|debit|credit|vat|wht|cost|qty|quantity)\w*"'
  go_check CO-04b P1 "non-pointer field for likely-nullable column" -P '\s(string|int\d*|float64|bool|time\.Time)\s+`[^`]*db:"\w*(_at|_date|_by|note|notes|reference|remark)"'
  go_check CO-06 P1 "switch default silently returns zero value" -U -P 'default:\s*\n\s*return\s+(false|nil|""|0|\w+\{\})\s*(,\s*nil)?\s*\n'
  if ! rg -q "${GO_GLOBS[@]}" -P '23505|23503|UniqueViolation|ForeignKeyViolation|pgconn\.PgError|pq\.Error' -- . 2>/dev/null; then
    echo "no pg error-code mapping found anywhere in repo" | emit CO-07 P2 "DB constraint errors not mapped to HTTP status"
  fi
  rg -o -N --no-heading --color never "${GO_GLOBS[@]}" -i -P 'INSERT\s+INTO\s+\w+' -- . 2>/dev/null \
    | awk -F: '{f=$1; t=tolower($NF); sub(/.*into[ \t]+/,"",t); if (!seen[t SUBSEP f]++) {n[t]++; files[t]=files[t] " " f}} END {for (t in n) if (n[t]>1) printf "%s: inserted from %d files:%s\n", t, n[t], files[t]}' \
    | sort | emit CO-08 P1 "same table inserted from multiple files"
  go_check CO-09 P2 "response echoes request instead of DB state" -P 'c\.JSON\([^,]+,\s*&?(req|input|body|payload|params)\b'
  go_check CO-10 P1 "timezone-naive date handling" -P 'time\.Parse\("2006-01-02"|\.Truncate\(24\s*\*\s*time\.Hour\)|time\.Now\(\)\.Format\('
fi

# ───────────────────────── 4. Data integrity ─────────────────────────
if [[ "$CAT" == all || "$CAT" == data ]]; then
  go_check DI-01 P1 "check-then-insert (verify UNIQUE backs it)" -P '\.(Exists|CheckExists|FindBy\w+|GetBy(No|Code|Name|Number|Ref)\w*)\('
  sql_check DI-02 P1 "unique constraint without company_id" -i -P 'UNIQUE\s*\((?![^)]*company_id)[^)]*\)|CREATE\s+UNIQUE\s+INDEX[^\n]*\((?![^)]*company_id)[^)]*\)'
  go_check DI-03 P0 "number derived from existing rows (race)" -i -P 'MAX\(\s*\w*(no|number|seq)\w*\s*\)|COUNT\(\*\)\s*\+\s*1|len\(\w+\)\s*\+\s*1|last\w*(No|Number)\s*\+\s*1'
  go_check DI-04 P0 "state-transition routes (trace idempotency)" -P '\.(POST|PUT|PATCH)\("[^"]*/(post|approve|submit|review|confirm|reverse|void|cancel|close|lock|depreciate|reconcile)\w*"'
  sql_check DI-05 P1 "FK without ON DELETE policy" -i -P 'REFERENCES\s+\w+\s*\(\s*\w+\s*\)(?!\s*(ON\s+DELETE|DEFERRABLE))'
  go_check DI-05b P1 "hard delete of document/ledger tables" -i -P 'DELETE\s+FROM\s+(\w*invoices?|receipts?|journal_(entries|lines)|documents|\w*orders?|grn\w*|payroll\w*)\b'
  go_check DI-06 P0 "SQL with WHERE but no company_id (verify table is tenant-owned)" -U --multiline-dotall -P '(?is)`\s*(SELECT|UPDATE|DELETE)\b(?:(?!`).)*?\bWHERE\b(?:(?!company_id)(?!`).)*`'
  go_check DI-07 P2 "Exec result discarded (RowsAffected unchecked)" -P '^\s*_\s*,\s*err\s*:?=\s*[\w.]+\.(Exec|ExecContext|NamedExec|NamedExecContext)\('
  go_check DI-10 P0 "float money arithmetic" -P '\bfloat(32|64)\(|decimal\.NewFromFloat\(|\*\s*0\.07\b'
  rg -n --no-heading --color never "${GO_GLOBS[@]}" -i -P 'INSERT\s+INTO\s+journal_(entries|lines)\b|UPDATE\s+journal_(entries|lines)\s+SET' -- . 2>/dev/null \
    | awk -F: '{c[$1]++} END {if (length(c) > 1) for (f in c) printf "%s: %d journal write(s)\n", f, c[f]}' \
    | sort | emit DI-11 P0 "journal rows written from multiple files"
fi

echo
echo "────────────────────────── summary ──────────────────────────"
if [[ ! -s "$SUMMARY_FILE" ]]; then
  echo "no candidates. (manual trace in references/02-failure-paths.md is still required)"
else
  printf 'ID     SEV hits  check\n'
  cat "$SUMMARY_FILE"
  echo "total candidates: $(awk '{s += $3} END {print s}' "$SUMMARY_FILE") — triage each with references/*.md before reporting"
fi
