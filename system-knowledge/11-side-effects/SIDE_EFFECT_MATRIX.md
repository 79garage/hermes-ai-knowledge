# AI-ACC Side Effect Matrix
> Generated: 2026-09-20
> Source: Code analysis (CodeGraph + source)
> Confidence: HIGH

## Sales Invoice Post

| Effect Type | Target | Description |
|-------------|--------|-------------|
| DIRECT | sales_invoices | status: draft → approved |
| DIRECT | journal_entries | Creates journal entry (Dr AR, Cr Revenue, Cr VAT) |
| DIRECT | journal_lines | Creates Dr/Cr lines |
| DIRECT | vat_records | Creates VAT output record (if VAT registered) |
| INDIRECT | general_ledger | Journal entry affects GL balances |
| INDIRECT | trial_balance | Updated via GL |
| INDIRECT | profit_loss | Revenue recognized |
| INDIRECT | balance_sheet | AR increased |
| INDIRECT | dashboard | Stats updated |
| ASYNC | stock_moves | If stock enabled, creates COGS movement |

---

## Receipt Post

| Effect Type | Target | Description |
|-------------|--------|-------------|
| DIRECT | receipts | status: draft → posted |
| DIRECT | journal_entries | Creates journal entry (Dr Bank/Cash, Cr AR) |
| DIRECT | journal_lines | Creates Dr/Cr lines |
| INDIRECT | general_ledger | Journal entry affects GL balances |
| INDIRECT | accounts_receivable | AR reduced |
| INDIRECT | dashboard | Stats updated |

---

## Purchase Invoice Post

| Effect Type | Target | Description |
|-------------|--------|-------------|
| DIRECT | purchase_invoices | status: draft → posted |
| DIRECT | journal_entries | Creates journal entry (Dr Expense, Cr AP, Dr VAT) |
| DIRECT | journal_lines | Creates Dr/Cr lines |
| DIRECT | vat_records | Creates VAT input record |
| INDIRECT | general_ledger | Journal entry affects GL balances |
| INDIRECT | accounts_payable | AP increased |
| INDIRECT | dashboard | Stats updated |
| ASYNC | grn | If linked to GRN, clears GRN clearing account |

---

## Journal Entry Post

| Effect Type | Target | Description |
|-------------|--------|-------------|
| DIRECT | journal_entries | status: draft → posted |
| DIRECT | journal_lines | Lines become effective |
| INDIRECT | general_ledger | All accounts affected |
| INDIRECT | trial_balance | Updated via GL |
| INDIRECT | profit_loss | Revenue/expense recognized |
| INDIRECT | balance_sheet | Asset/liability/equity affected |
| INDIRECT | dashboard | Stats updated |

---

## Document Review (OCR)

| Effect Type | Target | Description |
|-------------|--------|-------------|
| DIRECT | documents | status → reviewed |
| DIRECT | sales_invoices OR receipts OR purchase_invoices | Creates entity |
| DIRECT | journal_entries | Auto-posts journal entry |
| DIRECT | journal_lines | Creates Dr/Cr lines |
| DIRECT | vat_records | Creates VAT record (if applicable) |
| INDIRECT | general_ledger | All GL effects of created entity |
| ASYNC | ocr_results | OCR processing status updated |

---

## Period Close

| Effect Type | Target | Description |
|-------------|--------|-------------|
| DIRECT | accounting_periods | is_closed = true |
| DIRECT | period_close_runs | Creates close run record |
| DIRECT | period_close_snapshots | Creates balance snapshot |
| INDIRECT | all_draft_documents | Blocks further posting |
| INDIRECT | bank_reconciliations | Locks reconciliation |

---

## Payroll Approve

| Effect Type | Target | Description |
|-------------|--------|-------------|
| DIRECT | payroll_records | status → approved |
| INDIRECT | employee_records | Salary data confirmed |

---

## Payroll Post to GL

| Effect Type | Target | Description |
|-------------|--------|-------------|
| DIRECT | journal_entries | Creates salary journal entries |
| DIRECT | journal_lines | Dr Salary Expense, Cr Cash/Bank, Cr Deductions |
| DIRECT | wht_records | Creates WHT record for PND1 |
| INDIRECT | general_ledger | Salary expenses recognized |
| INDIRECT | tax_records | WHT obligation created |

---

## GRN Confirm

| Effect Type | Target | Description |
|-------------|--------|-------------|
| DIRECT | grn | status: draft → confirmed |
| DIRECT | stock_moves | Creates stock movement (inbound) |
| DIRECT | stock_layers | Creates/updates cost layers |
| INDIRECT | inventory | Stock quantity increased |
| INDIRECT | purchase_order | PO fulfillment tracked |

---

## Delivery Order Confirm

| Effect Type | Target | Description |
|-------------|--------|-------------|
| DIRECT | delivery_orders | status: draft → confirmed |
| DIRECT | stock_moves | Creates stock movement (outbound) |
| INDIRECT | inventory | Stock quantity decreased |
| ASYNC | journal_entries | If stock-to-GL enabled, creates COGS entry |

---

## Fixed Asset Depreciate

| Effect Type | Target | Description |
|-------------|--------|-------------|
| DIRECT | fixed_assets | accumulated_depreciation updated |
| DIRECT | depreciation_entries | Creates depreciation record |
| INDIRECT | journal_entries | If PostGL, creates depreciation JE |
| INDIRECT | general_ledger | Depreciation expense recognized |

---

## Bank Reconciliation Lock

| Effect Type | Target | Description |
|-------------|--------|-------------|
| DIRECT | bank_reconciliations | locked_at set |
| DIRECT | bank_reconciliation_items | Items finalized |
| INDIRECT | period_close | Enables period close |

---

## Cross-Module Side Effects

| Action | Direct | Indirect | Async | Pages Affected | Reports Affected |
|--------|--------|----------|-------|----------------|------------------|
| Sales Post | 3 tables | GL, TB, P&L, BS | Stock | Sales, Journal, Dashboard | All reports |
| Receipt Post | 2 tables | GL, AR | - | Receipts, Journal, Dashboard | AR, Cash Flow |
| Purchase Post | 3 tables | GL, AP, Stock | GRN clearing | Purchases, Journal, Dashboard | All reports |
| Journal Post | 2 tables | GL, TB, P&L, BS | - | Journal, Dashboard | All reports |
| Period Close | 3 tables | All modules | - | All modules | All reports |
| Payroll GL | 3 tables | GL, WHT | - | Payroll, Journal | P&L, WHT report |