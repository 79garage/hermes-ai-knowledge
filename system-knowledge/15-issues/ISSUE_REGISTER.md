# AI-ACC Issue Register
> Generated: 2026-09-20

## Issues Found During Static Analysis

### ISSUE-001: float64 in Go Models (Rounding Risk)
- **Severity**: HIGH
- **Module**: All financial modules
- **Description**: Architecture specifies shopspring/decimal for precise arithmetic, but Go models use `float64` for monetary amounts (NUMERIC(19,4) in DB)
- **Expected**: All monetary fields should use `shopspring/decimal` or `string` for JSON
- **Actual**: `float64` used throughout model structs
- **Impact**: Floating-point rounding errors in financial calculations (e.g., 0.1 + 0.2 ≠ 0.3)
- **Affected Components**: All services handling monetary amounts
- **Evidence**: Model struct definitions in `internal/model/`
- **Confidence**: HIGH

### ISSUE-002: Dual Purchase Invoice Paths
- **Severity**: MEDIUM
- **Module**: Purchases
- **Description**: Legacy `/purchases/invoices` and new `/purchase/invoices` coexist
- **Expected**: Single canonical path
- **Actual**: Two separate handler/service/repository chains
- **Impact**: Confusion about which path to use; potential data inconsistency
- **Affected Components**: `purchase.go` (legacy) vs `purchase_invoice_flow.go` (new)
- **Evidence**: main.go route registration (lines 923-929 vs 893-900)
- **Confidence**: VERIFIED

### ISSUE-003: Stock Frontend Pages Partial
- **Severity**: MEDIUM
- **Module**: Inventory
- **Description**: Backend stock API is complete but frontend pages may be incomplete
- **Expected**: Full CRUD UI for stock management
- **Actual**: Some page.tsx files exist but completeness unknown
- **Impact**: Users may not be able to use stock features via UI
- **Affected Components**: `products/inventory/`, `products/warehouses/`, etc.
- **Evidence**: File existence check
- **Confidence**: MEDIUM

### ISSUE-004: Document Number CheckExists Gaps
- **Severity**: MEDIUM
- **Module**: Settings
- **Description**: `CheckExists` switch statement may not cover all doc_types, causing duplicate document numbers
- **Expected**: Every registered doc_type has a CheckExists case
- **Actual**: Some doc_types may fall through to default (returns false)
- **Impact**: Duplicate document numbers possible
- **Affected Components**: `internal/service/document_number.go`
- **Evidence**: Skill documentation pitfall
- **Confidence**: HIGH

### ISSUE-005: Entry_no Uniqueness for Tax Invoice Reclassify
- **Severity**: MEDIUM
- **Module**: Tax/Sales
- **Description**: Journal entry numbers for reclassify entries must include invoice ID to avoid duplicate key violations
- **Expected**: Unique entry_no per reclassification
- **Actual**: Pattern `JE-TI-<invoiceID>-<taxInvoiceNo>` required
- **Impact**: Database constraint violation on multiple tax invoices
- **Affected Components**: `internal/service/sales.go` IssueTaxInvoice
- **Evidence**: E2E test pitfall documentation
- **Confidence**: HIGH

### ISSUE-006: API Returns items: null Not items: []
- **Severity**: LOW
- **Module**: All
- **Description**: Many list endpoints return `{ data: { items: null, total_count: 0 } }` when empty
- **Expected**: `{ data: { items: [], total_count: 0 } }`
- **Actual**: `items: null` instead of empty array
- **Impact**: Frontend code using `??` operator fails (null ?? data evaluates to data object)
- **Affected Components**: All list endpoints
- **Evidence**: E2E test pitfall documentation
- **Confidence**: HIGH

### ISSUE-007: Migrations Compiled Into Binary
- **Severity**: LOW
- **Module**: Infrastructure
- **Description**: Migrations are embedded in the Go binary, cannot be modified without rebuild
- **Expected**: Migrations as external files for hot-fix capability
- **Actual**: Compiled into binary via embed
- **Impact**: Cannot apply emergency migration without full deploy
- **Affected Components**: `internal/migrate/`, `db/migrations.go`
- **Evidence**: main.go comment
- **Confidence**: VERIFIED

### ISSUE-008: Bank Reconciliation Routes Previously Missing Permissions
- **Severity**: CRITICAL (FIXED)
- **Module**: Bank
- **Description**: Bank reconciliation routes shipped with no permission checks — any authenticated user could post journal entries from reconciliation screen
- **Expected**: `bank.reconcile` and `period.close` permission enforcement
- **Actual**: Fixed by adding middleware
- **Impact**: Was a privilege escalation vulnerability
- **Affected Components**: Bank reconciliation routes in main.go
- **Evidence**: main.go comment (line 637-647)
- **Confidence**: VERIFIED

### ISSUE-009: Payroll Approval Routes Previously Missing Permissions
- **Severity**: CRITICAL (FIXED)
- **Module**: Payroll
- **Description**: Payroll approval routes had no permission checks — any account could approve payroll and post salary entries
- **Expected**: `payroll.approve` permission enforcement
- **Actual**: Fixed by adding middleware
- **Impact**: Was a privilege escalation vulnerability
- **Affected Components**: Payroll routes in main.go
- **Evidence**: main.go comment (lines 1028-1033)
- **Confidence**: VERIFIED

### ISSUE-010: supplier_type Must Be 'juristic' or 'individual'
- **Severity**: LOW
- **Module**: Purchases
- **Description**: Supplier API rejects 'company' as supplier_type — must use 'juristic' or 'individual'
- **Expected**: Consistent enum values
- **Actual**: 'company' rejected with VALIDATION_ERROR
- **Impact**: API confusion for developers
- **Affected Components**: Supplier service/handler
- **Evidence**: E2E test pitfall
- **Confidence**: HIGH
