# AI-ACC Validation Matrix
> Generated: 2026-09-20
> Source: Code analysis + E2E test evidence
> Confidence: HIGH

## Validation Architecture

### Three-Layer Validation
1. **Frontend**: React form validation (client-side)
2. **Backend**: Go handler/service validation (server-side)
3. **Database**: PostgreSQL constraints (data integrity)

---

## Sales Invoice Validation

| Field | Frontend | Backend | Database | Notes |
|-------|----------|---------|----------|-------|
| invoice_no | required | required | UNIQUE | Auto-generated |
| date | required | required | NOT NULL | |
| due_date | optional | optional | nullable | |
| customer_id | required | required | FK → customers | |
| subtotal | auto-calc | auto-calc | NUMERIC(19,4) | |
| vat_amount | auto-calc | auto-calc | NUMERIC(19,4) | |
| total_amount | auto-calc | auto-calc | NUMERIC(19,4) | |
| status | auto | auto | VARCHAR(20) | draft/approved/cancelled |
| notes | optional | optional | nullable | |
| line.description | required | required | TEXT | |
| line.quantity | required, > 0 | required, > 0 | NUMERIC(19,4) | |
| line.unit_price | required, >= 0 | required, >= 0 | NUMERIC(19,4) | |
| line.amount | auto-calc | auto-calc | NUMERIC(19,4) | qty × price |
| line.vat_rate | default 7% | default 7% | NUMERIC(5,2) | |
| line.wht_rate | optional | optional | NUMERIC(5,2) | 0-5% |

---

## Journal Entry Validation

| Field | Frontend | Backend | Database | Notes |
|-------|----------|---------|----------|-------|
| entry_no | required | required | UNIQUE | Auto-generated |
| date | required | required | NOT NULL | |
| description | required | required | TEXT | |
| status | auto | auto | VARCHAR(20) | draft/posted/cancelled/reversed |
| line.account_id | required | required | FK → accounts | |
| line.debit | conditional | conditional | NUMERIC(19,4) | Must be > 0 if debit |
| line.credit | conditional | conditional | NUMERIC(19,4) | Must be > 0 if credit |

### Balance Validation
- **Frontend**: Warns if Dr ≠ Cr
- **Backend**: Rejects if Dr ≠ Cr
- **Database**: No constraint (relies on application)

---

## Receipt Validation

| Field | Frontend | Backend | Database | Notes |
|-------|----------|---------|----------|-------|
| receipt_no | required | required | UNIQUE | Auto-generated |
| date | required | required | NOT NULL | |
| customer_id | required | required | FK → customers | |
| invoice_id | optional | optional | FK → sales_invoices | |
| amount | required, > 0 | required, > 0 | NUMERIC(19,4) | |
| payment_method | required | required | VARCHAR(50) | cash/transfer/cheque |
| bank_account_id | conditional | conditional | FK → bank_accounts | Required for transfer/cheque |
| reference | optional | optional | VARCHAR(100) | |

### Payment Method Validation
- **cash**: No bank_account_id needed
- **transfer**: bank_account_id required + GL mapping
- **cheque**: bank_account_id required + GL mapping

---

## Purchase Invoice Validation

| Field | Frontend | Backend | Database | Notes |
|-------|----------|---------|----------|-------|
| invoice_no | required | required | UNIQUE | Auto-generated |
| date | required | required | NOT NULL | |
| supplier_id | required | required | FK → suppliers | |
| subtotal | auto-calc | auto-calc | NUMERIC(19,4) | |
| vat_amount | auto-calc | auto-calc | NUMERIC(19,4) | |
| total_amount | auto-calc | auto-calc | NUMERIC(19,4) | |
| status | auto | auto | VARCHAR(20) | draft/posted/cancelled |

---

## Customer Validation

| Field | Frontend | Backend | Database | Notes |
|-------|----------|---------|----------|-------|
| name | required | required | VARCHAR(255) | |
| tax_id | optional | optional | VARCHAR(13) | 13 digits |
| address | optional | optional | TEXT | |
| phone | optional | optional | VARCHAR(20) | |
| email | optional | optional | VARCHAR(255) | |
| customer_type | optional | optional | VARCHAR(50) | individual/juristic |
| branch_code | optional | optional | VARCHAR(10) | |

---

## Supplier Validation

| Field | Frontend | Backend | Database | Notes |
|-------|----------|---------|----------|-------|
| name | required | required | VARCHAR(255) | |
| tax_id | optional | optional | VARCHAR(13) | 13 digits |
| supplier_type | required | required | VARCHAR(50) | **Must be 'juristic' or 'individual'** (not 'company') |
| address | optional | optional | TEXT | |
| phone | optional | optional | VARCHAR(20) | |
| email | optional | optional | VARCHAR(255) | |

---

## Bank Account Validation

| Field | Frontend | Backend | Database | Notes |
|-------|----------|---------|----------|-------|
| bank_name | required | required | VARCHAR(255) | |
| account_no | required | required | VARCHAR(50) | Normalized (digits only) |
| account_name | required | required | VARCHAR(255) | |
| account_type | required | required | VARCHAR(50) | savings/current |
| opening_balance | optional | optional | NUMERIC(19,4) | |

---

## Employee Validation

| Field | Frontend | Backend | Database | Notes |
|-------|----------|---------|----------|-------|
| name | required | required | VARCHAR(255) | |
| position | required | required | VARCHAR(255) | |
| base_salary | required, > 0 | required, > 0 | NUMERIC(19,4) | |
| start_date | required | required | DATE | |
| status | auto | auto | VARCHAR(50) | active/inactive |

---

## Cross-Field Validation

| Rule | Frontend | Backend | Description |
|------|----------|---------|-------------|
| Journal Balance | ✅ Warn | ✅ Reject | Dr must equal Cr |
| Receipt Bank Account | ✅ Show | ✅ Reject | Bank required for transfer/cheque |
| Post Draft Only | ✅ Hide | ✅ Reject | Can only post draft documents |
| Cancel Draft Only | ✅ Hide | ✅ Reject | Can only cancel draft documents |
| Period Close Check | ✅ Show | ✅ Reject | Must pass all checks before close |

---

## Validation Gaps Found

| Gap | Severity | Description |
|-----|----------|-------------|
| float64 precision | HIGH | Frontend uses number, backend uses float64, DB uses NUMERIC(19,4) — rounding risk |
| Supplier type enum | LOW | Backend rejects 'company' but frontend may allow it |
| items: null vs [] | LOW | API returns null for empty lists, frontend must handle |