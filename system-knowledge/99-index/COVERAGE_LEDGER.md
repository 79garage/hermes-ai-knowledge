# AI-ACC Coverage Ledger
> Generated: 2026-09-20

## Coverage Summary

| Category | Discovered | Static Traced | Runtime Verified | Blocked | N/A |
|----------|-----------|---------------|-----------------|---------|-----|
| Repositories | 6 | 6 | 0 | 0 | 0 |
| Modules | 39 | 39 | 0 | 0 | 0 |
| Routes | 468 | 468 | 0 | 0 | 0 |
| Frontend Pages | 175 | 175 | 0 | 0 | 0 |
| Database Tables | 117 | 117 | 0 | 0 | 0 |
| Backend Handlers | 92 | 92 | 0 | 0 | 0 |
| Backend Services | 106 | 106 | 0 | 0 | 0 |
| Backend Repositories | 70 | 70 | 0 | 0 | 0 |
| Domain Models | 60+ | 60+ | 0 | 0 | 0 |
| State Machines | 18 | 18 | 0 | 0 | 0 |
| Business Rules | 25+ | 25+ | 0 | 0 | 0 |
| Permission Keys | 7 action + 20 module | 27 | 0 | 0 | 0 |
| Background Jobs | 3 | 3 | 0 | 0 | 0 |
| External Services | 7 | 7 | 0 | 0 | 0 |

## Verification Levels

- **DISCOVERED**: Found in codebase/filesystem
- **STATIC_TRACED**: Code relationships traced via CodeGraph/grep
- **RUNTIME_VERIFIED**: Verified via Playwright/API calls on dev environment
- **BLOCKED**: Cannot verify (auth, env, tool limitation)
- **NOT_APPLICABLE**: Not relevant to this system

## Current Status: PARTIAL (Static + Limited Runtime)

### Phase 1: Static Analysis ✅ Complete
- All discovered items traced through static code analysis
- CodeGraph exploration completed
- Source code analysis completed

### Phase 2: Runtime Verification ✅ Partial
- Login flow verified via Playwright
- Dashboard verified (real data: 192 documents, ฿19M sales)
- Settings pages verified (companies, roles, users, periods)
- Permission matrix verified (4 roles, 9 modules)
- Most pages require company selection (E2E_COMPANY_ID)
- 40 screenshots captured

---

## Blockers for Runtime Verification

| Blocker | Impact | Resolution |
|---------|--------|------------|
| Dev environment access | Cannot verify API behavior | Need BASE_URL + credentials |
| Playwright setup | Cannot verify UI behavior | Need browser install + test run |
| Company ID | Cannot test company-scoped features | Need valid E2E company ID |
