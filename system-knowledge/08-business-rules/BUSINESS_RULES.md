# AI-ACC Business Rules
> Generated: 2026-09-20 | Confidence: HIGH (code-traced)

## Posting Engine Rules

### RULE-POST-001: Template-Driven Journal Posting
- **Module**: Journal/Accounting
- **Trigger**: Any financial document post (sales, purchase, receipt, payment, etc.)
- **Logic**: PostingEngine matches (event_type, conditions) → PostingTemplate → JournalLines
- **Fallback**: If no template found, use hardcoded Go logic (pre-engine path)
- **Override**: Reviewer-edited Dr/Cr in posting_overrides table takes highest priority
- **Source**: `internal/service/posting_engine.go`
- **Confidence**: VERIFIED

### RULE-POST-002: 3-Tier Posting Priority
- **Module**: Journal/Accounting
- **Priority**: 1. PostingOverride > 2. PostingEngine (template) > 3. Simple GL (hardcoded)
- **Source**: `internal/service/document_service.go` postCreatedEntityTx
- **Confidence**: VERIFIED

---

## Sales Rules

### RULE-SALES-001: Sales Invoice Posting Creates Journal Entry
- **Module**: Sales
- **Trigger**: `POST /sales/invoices/:id/post`
- **Logic**: Creates journal entry with revenue credit, AR debit, VAT if applicable
- **Side Effects**: Creates VAT record if VAT registered, creates WHT record if WHT applicable
- **Source**: `internal/service/sales.go` Post()
- **Confidence**: VERIFIED

### RULE-SALES-002: Sales Invoice Status Stays 'approved' After Receipt
- **Module**: Sales
- **Logic**: Invoice status does NOT change to 'paid' after full receipt. Payment tracking is via receipts.
- **Source**: E2E test evidence + service code
- **Confidence**: VERIFIED

### RULE-SALES-003: Tax Invoice Reclassification
- **Module**: Sales/Tax
- **Trigger**: `POST /sales/invoices/:id/tax-invoice`
- **Logic**: Reclassifies VAT from 27113 (ภาษีซื้อยังไม่ถึงกำหนด) to 27110 (ภาษีขาย)
- **Side Effects**: Creates reclassification journal entry
- **Source**: `internal/service/sales.go` IssueTaxInvoice()
- **Confidence**: VERIFIED

### RULE-SALES-004: Credit Note Debits Revenue Account
- **Module**: Sales
- **Logic**: ใบลดหนี้ขาย debits 41300 (รับคืน) not 41110 (revenue)
- **Source**: Migration 152 posting template fix
- **Confidence**: VERIFIED

---

## Purchase Rules

### RULE-PURCHASE-001: GRN Clearing Account
- **Module**: Purchases
- **Logic**: Purchase invoice linked to GRN clears the GRN clearing account
- **Source**: `internal/service/purchase_invoice_flow.go` WithGRNClearing()
- **Confidence**: HIGH

### RULE-PURCHASE-002: Purchase Debit Note Credits Return Account
- **Module**: Purchases
- **Logic**: ใบลดหนี้ซื้อ credits 51113 (ส่งคืน) not 51100 (header)
- **Source**: Migration 152 posting template fix
- **Confidence**: VERIFIED

### RULE-PURCHASE-003: Dual Purchase Invoice Paths
- **Module**: Purchases
- **Logic**: Legacy `/purchases/invoices` and new `/purchase/invoices` coexist. New flow supports GRN integration.
- **Source**: main.go route registration
- **Confidence**: VERIFIED

---

## Receipt/Payment Rules

### RULE-RECEIPT-001: Bank Account Required for Non-Cash Payments
- **Module**: Sales/Receipts
- **Trigger**: `POST /receipts` with payment_method='transfer' or 'cheque'
- **Logic**: Validates bank_account_id is set and bank account has GL mapping
- **Error**: "กรุณาระบุบัญชีธนาคารสำหรับการรับชำระแบบโอนหรือเช็ค"
- **Source**: `internal/service/receipt.go`
- **Confidence**: VERIFIED

### RULE-RECEIPT-002: Cash Payment Auto-Resolves Account
- **Module**: Sales/Receipts
- **Logic**: payment_method='cash' does NOT need bank_account_id — backend auto-resolves cash account
- **Source**: E2E test evidence
- **Confidence**: VERIFIED

---

## Tax Rules

### RULE-TAX-001: VAT Registration Check
- **Module**: Tax
- **Logic**: VAT records only created when company has VAT registration (tax_id set)
- **Source**: `internal/service/sales.go` Post()
- **Confidence**: HIGH

### RULE-TAX-002: PP30 Filing Workflow
- **Module**: Tax
- **States**: draft → submitted → filed
- **Actions**: Save, Submit, File, Settle, CarryForward
- **Source**: main.go routes + tax handler
- **Confidence**: VERIFIED

### RULE-TAX-003: WHT Record Creation
- **Module**: Tax
- **Logic**: WHT records created when invoice line has wht_rate > 0
- **Forms**: PND1 (employment), PND3 (individual), PND53 (corporate)
- **Source**: `internal/service/sales.go`, `internal/service/purchase_payment.go`
- **Confidence**: HIGH

---

## Period Close Rules

### RULE-CLOSE-001: Draft Document Check
- **Module**: Accounting
- **Trigger**: Period close validation
- **Logic**: Checks for draft journal entries, unreconciled bank accounts, draft invoices
- **Source**: `internal/service/close_check_context.go`
- **Confidence**: VERIFIED

### RULE-CLOSE-002: Bank Reconciliation Required
- **Module**: Accounting/Bank
- **Logic**: Period cannot close if bank accounts have unreconciled statements
- **Source**: `internal/service/close_check_context.go`
- **Confidence**: VERIFIED

### RULE-CLOSE-003: Reopen Requires Approval
- **Module**: Accounting
- **Logic**: Closed period reopen requires approval workflow (request → approve/reject)
- **Source**: main.go routes for reopen requests
- **Confidence**: VERIFIED

---

## Document Number Rules

### RULE-DOCNUM-001: Auto-Generated Document Numbers
- **Module**: Settings
- **Logic**: Document numbers generated from template (prefix + running number + format)
- **Format**: `NNNN` = 4 digits, `NNNNNN` = 6 digits. NOT `{running:6}`.
- **Uniqueness**: Checked via `CheckExists` per doc_type
- **Source**: `internal/service/document_number.go`
- **Confidence**: VERIFIED

### RULE-DOCNUM-002: Period-Based Running Numbers
- **Module**: Settings
- **Logic**: Running numbers can reset yearly or monthly
- **Source**: `document_number_settings` table `period_mode` column
- **Confidence**: HIGH

---

## Stock/Inventory Rules

### RULE-STOCK-001: FIFO/Moving Average Costing
- **Module**: Inventory
- **Logic**: Stock layers track cost via FIFO or moving average method
- **Source**: `internal/service/stock_costing.go`
- **Confidence**: HIGH

### RULE-STOCK-002: Delivery Order Creates Stock Movement
- **Module**: Inventory/Sales
- **Logic**: Confirming a delivery order creates stock movement and optionally posts COGS
- **Source**: `internal/service/delivery_stock_posting.go`
- **Confidence**: HIGH

---

## Payroll Rules

### RULE-PAYROLL-001: Payroll Approval Requires Permission
- **Module**: Payroll
- **Permission**: `payroll.approve`
- **Actions**: Approve, Pay, PostPeriodToGL, SSFRemit
- **Source**: main.go middleware
- **Confidence**: VERIFIED

### RULE-PAYROLL-002: Payroll GL Posting
- **Module**: Payroll/Accounting
- **Logic**: Posting payroll to GL creates journal entries for salary expenses, deductions, SSO
- **Source**: `internal/service/payroll.go` PostPeriodToGL
- **Confidence**: HIGH

---

## Fixed Asset Rules

### RULE-ASSET-001: Depreciation Batch Processing
- **Module**: Fixed Assets
- **Logic**: RunDepreciationBatch calculates depreciation for all active assets in a period
- **Post-GL**: PostDepreciationForPeriod creates journal entries
- **Source**: main.go routes + fixed_asset service
- **Confidence**: HIGH

---

## OCR/Document Rules

### RULE-OCR-001: OCR Queue Bounded Processing
- **Module**: Documents
- **Logic**: OCR requests queued with concurrency limit (OCRMaxConcurrency) and per-company limit
- **Overflow**: 429 Too Many Requests when queue full
- **Source**: `internal/service/ocr_queue.go`
- **Confidence**: VERIFIED

### RULE-OCR-002: Auto-Post on Document Review
- **Module**: Documents
- **Trigger**: `POST /documents/:id/review` (SubmitReview)
- **Logic**: Creates entity (invoice/receipt/purchase) AND auto-posts journal entry in single transaction
- **Source**: `internal/service/document_service.go` postCreatedEntityTx
- **Confidence**: VERIFIED

---

## Bank Reconciliation Rules

### RULE-BANK-001: Reconciliation Lock Requires Period Close Permission
- **Module**: Bank
- **Permission**: `period.close`
- **Source**: main.go middleware
- **Confidence**: VERIFIED

### RULE-BANK-002: Direct Post Requires Both Permissions
- **Module**: Bank
- **Permissions**: `bank.reconcile` AND `bank.direct_post`
- **Source**: main.go route with dual middleware
- **Confidence**: VERIFIED

---

## Multi-Tenant Rules

### RULE-TENANT-001: Company ID Isolation
- **Module**: All
- **Logic**: Every data query filters by company_id from JWT context
- **Source**: All repository files
- **Confidence**: HIGH

### RULE-TENANT-002: Subscription Gate
- **Module**: Billing
- **Logic**: Expired subscription allows reads but blocks writes (except /billing routes)
- **Source**: `entitlementH.RequireActiveSubscription()`
- **Confidence**: VERIFIED
