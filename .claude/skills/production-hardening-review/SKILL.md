---
name: production-hardening-review
description: Code-review checklist for Go backends (Echo v4 + sqlx + PostgreSQL) that hunts the edge cases tests don't cover — discarded/silent errors, log noise, partial failures and orphaned state, API-vs-DB validation mismatch, duplicates and incomplete rows. Every check is a grep/rg pattern plus triage rule and fix pattern. Use when reviewing a Go backend PR or diff, hardening a service before release, auditing a handler/service/repository chain, or when the user says "production hardening", "edge case review", "failure path", "orphaned data", "silent fail", "partial failure", "data integrity" — even if they don't name this skill.
---

# Production Hardening Review (Go · Echo v4 · sqlx · PostgreSQL)

Tests prove the happy path. This review targets what breaks in production:
**errors nobody sees, work that half-happens, layers that disagree, and rows
that shouldn't exist.** Each check is a scan pattern → triage → fix.

Stack assumptions (AI-ACC): `handler → service → repository`, sqlx raw SQL,
multi-tenant by `company_id`, template-driven posting, background workers
(OCR reaper, report queue). Adjust paths via `SCAN_ROOT` if the layout differs.

## Workflow

1. **Scope** — review the diff first, the whole package second.
   ```bash
   git diff --name-only origin/main...HEAD -- '*.go' > /tmp/changed.txt
   ```
2. **Scan** — run the scanner (all categories, or one of `err|fail|cons|data`):
   ```bash
   bash .claude/skills/production-hardening-review/scripts/scan.sh <repo-root> [category]
   # only changed files:
   CHANGED_ONLY=/tmp/changed.txt bash .../scan.sh <repo-root>
   ```
   Hits are **candidates, not findings**. The scanner is intentionally noisy.
3. **Triage** — for each hit open the category reference and apply its
   "Confirm if" rule. Discard hits that fail the rule; don't report them.
4. **Trace failure paths manually** — grep can't see ordering. For every
   write path in the diff, answer the 5 questions in
   [references/02-failure-paths.md](references/02-failure-paths.md#manual-trace).
5. **Report** — use the output format below. Rank by severity.

## Categories

| # | Category | Reference | Checks |
|---|----------|-----------|--------|
| 1 | Error handling — discard, silent fail, log noise | [01-error-handling.md](references/01-error-handling.md) | EH-01 … EH-12 |
| 2 | Failure path — orphaned state, partial failure, cleanup | [02-failure-paths.md](references/02-failure-paths.md) | FP-01 … FP-11 |
| 3 | Consistency — API vs DB, validation mismatch | [03-consistency.md](references/03-consistency.md) | CO-01 … CO-10 |
| 4 | Data integrity — duplicate, orphaned rows, incomplete state | [04-data-integrity.md](references/04-data-integrity.md) | DI-01 … DI-12 |

Load only the reference for the category you're triaging.

**Scanner coverage:** `scan.sh` automates every check except the ones that
need schema/route knowledge — **CO-05, DI-08, DI-09, DI-12** (run their `rg`
commands from the reference by hand) and the **manual trace** (step 4).
FP-08/FP-09/DI-01/DI-04 hits are inventory lists: trace each one.
Scanner regression test: `bash .claude/skills/production-hardening-review/tests/run.sh`.

## Severity

| Level | Meaning | Examples |
|-------|---------|----------|
| **P0** | Money/ledger wrong, cross-tenant leak, data loss | unbalanced JE committed, missing `company_id` filter, `tx.Commit()` error ignored |
| **P1** | Orphaned/duplicate state, stuck workflow, silent failure | entity posted but no JE, double-submit creates 2 invoices, doc stuck `processing` |
| **P2** | Wrong error to client, validation drift, lost diagnostics | 500 instead of 404/409, `items: null`, error logged without `company_id` |
| **P3** | Log noise, style that hides future bugs | log-and-return duplicates, `%v` instead of `%w` |

## Output format

```markdown
## Production Hardening Review — <scope>

**Summary:** P0: n · P1: n · P2: n · P3: n  (scanned: <files>, candidates: <n>, confirmed: <n>)

### [P1] FP-03 Side effect before commit — internal/service/document.go:212
**What:** `storage.Save` runs before `tx.Commit`; commit failure leaves an orphaned file.
**Scenario:** DB constraint violation on INSERT documents → file stays in MinIO, no row references it.
**Fix:** Save after commit, or register cleanup `defer` that deletes the object when `err != nil`.
**Test to add:** Force repo INSERT error → assert storage has no object.
```

Rules for findings:
- Every finding needs a **concrete failure scenario** (input/state → wrong result). No scenario → drop it.
- Cite `file:line`. Quote at most 3 lines of code.
- Propose the **smallest** fix that matches existing patterns in the repo (search for how the codebase already does it before inventing).
- Suggest one test that would have caught it.
- Group identical hits: "EH-01 ×14 in `internal/repository/*` — see list" instead of 14 findings.

## Known AI-ACC hot spots (check these first when touched)

| Area | Why | Checks |
|------|-----|--------|
| `DocumentNumberService` / `CheckExists` | switch default returns `false` → duplicate doc numbers (ISSUE-004) | DI-03, CO-06 |
| Tax invoice reclassify `entry_no` | must embed invoice ID or unique violation (ISSUE-005) | DI-02 |
| List endpoints | `items: null` instead of `[]` (ISSUE-006) | CO-01 |
| Monetary fields | `float64` vs `NUMERIC(19,4)` (ISSUE-001) | CO-04 |
| `SubmitReview` → `postCreatedEntityTx` | entity + JE + VAT must be one tx | FP-01, FP-02, DI-05 |
| Document upload → OCR queue | file saved before row / queue enqueue outside tx | FP-03, FP-05 |
| Posting 3-tier fallback | silent fallback to Simple GL hides template gaps | EH-06 |
| Period close | posting into closed period, race with close run | DI-09, FP-08 |
| Dual purchase paths (ISSUE-002) | validation/side effects differ between legacy and new flow | CO-08 |

## Scope limits

- This skill finds **robustness** defects. For authz/RBAC/injection use `/security-review`; for style use `/simplify`.
- Grep cannot prove absence of a bug. A clean scan + clean manual trace is the bar, not a clean scan alone.
- Don't fix during the review unless asked; report first.
