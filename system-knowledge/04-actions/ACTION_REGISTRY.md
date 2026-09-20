# AI-ACC Action Registry
> Generated: 2026-09-20
> Source: main.go routes + Screenshot analysis
> Confidence: HIGH

## Sales Actions

### ACTION-SALES-INVOICE-CREATE
- **Page**: /sales/invoices/new
- **Label**: สร้างใบแจ้งหนี้ (Create Invoice)
- **Method**: POST
- **Endpoint**: /api/v1/sales/invoices
- **Frontend Handler**: form submit
- **Backend Handler**: SalesHandler.Create
- **Service**: SalesService.Create
- **Validation**: Frontend + Backend
- **Side Effects**: Creates invoice + lines, generates document number
- **Confidence**: HIGH

### ACTION-SALES-INVOICE-POST
- **Page**: /sales/invoices/[id]
- **Label**: บันทึก (Post)
- **Method**: POST
- **Endpoint**: /api/v1/sales/invoices/:id/post
- **Frontend Handler**: button click
- **Backend Handler**: SalesHandler.Post
- **Service**: SalesService.Post
- **Permission**: None (uses module.sales.edit)
- **Validation**: Frontend + Backend
- **Side Effects**: Creates journal entry, VAT record, WHT record
- **State Change**: draft → approved
- **Confidence**: VERIFIED

### ACTION-SALES-INVOICE-CANCEL
- **Page**: /sales/invoices/[id]
- **Label**: ยกเลิก (Cancel)
- **Method**: DELETE
- **Endpoint**: /api/v1/sales/invoices/:id
- **Frontend Handler**: button click + confirmation
- **Backend Handler**: SalesHandler.Cancel
- **Service**: SalesService.Cancel
- **State Change**: draft → cancelled
- **Confidence**: HIGH

### ACTION-SALES-INVOICE-TAX-INVOICE
- **Page**: /sales/invoices/[id]
- **Label**: ออกใบกำกับภาษี (Issue Tax Invoice)
- **Method**: POST
- **Endpoint**: /api/v1/sales/invoices/:id/tax-invoice
- **Frontend Handler**: button click
- **Backend Handler**: SalesHandler.IssueTaxInvoice
- **Service**: SalesService.IssueTaxInvoice
- **Side Effects**: Reclassifies VAT 27113→27110, creates journal entry
- **Confidence**: VERIFIED

---

## Purchase Actions

### ACTION-PURCHASE-INVOICE-CREATE
- **Page**: /purchases/invoices/new
- **Label**: สร้างใบซื้อ (Create Purchase Invoice)
- **Method**: POST
- **Endpoint**: /api/v1/purchase/invoices
- **Backend Handler**: PurchaseInvoiceFlowHandler.Create
- **Service**: PurchaseInvoiceFlowService.Create
- **Confidence**: HIGH

### ACTION-PURCHASE-INVOICE-POST
- **Page**: /purchases/invoices/[id]
- **Label**: บันทึก (Post)
- **Method**: POST
- **Endpoint**: /api/v1/purchase/invoices/:id/post
- **Backend Handler**: PurchaseInvoiceFlowHandler.Post
- **Service**: PurchaseInvoiceFlowService.Post
- **Side Effects**: Creates journal entry, VAT record, GRN clearing
- **State Change**: draft → posted
- **Confidence**: HIGH

---

## Journal Actions

### ACTION-JOURNAL-CREATE
- **Page**: /journal/new
- **Label**: สร้าง Journal (Create Journal)
- **Method**: POST
- **Endpoint**: /api/v1/journal/entries
- **Backend Handler**: JournalHandler.Create
- **Service**: JournalService.Create
- **Validation**: Balance check (Dr = Cr)
- **Confidence**: HIGH

### ACTION-JOURNAL-POST
- **Page**: /journal/[id]
- **Label**: บันทึก (Post)
- **Method**: POST
- **Endpoint**: /api/v1/journal/entries/:id/post
- **Backend Handler**: JournalHandler.Post
- **Service**: JournalService.Post
- **Permission**: journal.post
- **State Change**: draft → posted
- **Confidence**: VERIFIED

### ACTION-JOURNAL-REVERSE
- **Page**: /journal/[id]
- **Label**: กลับรายการ (Reverse)
- **Method**: POST
- **Endpoint**: /api/v1/journal/entries/:id/reverse
- **Backend Handler**: JournalHandler.Reverse
- **Service**: JournalService.Reverse
- **Permission**: journal.post
- **Side Effects**: Creates reversing journal entry
- **State Change**: posted → reversed
- **Confidence**: VERIFIED

---

## Receipt Actions

### ACTION-RECEIPT-CREATE
- **Page**: /sales/receipts/new
- **Label**: สร้างใบเสร็จ (Create Receipt)
- **Method**: POST
- **Endpoint**: /api/v1/receipts
- **Backend Handler**: ReceiptHandler.Create
- **Service**: ReceiptService.Create
- **Validation**: Bank account required for transfer/cheque
- **Confidence**: HIGH

### ACTION-RECEIPT-POST
- **Page**: /sales/receipts/[id]
- **Label**: บันทึก (Post)
- **Method**: POST
- **Endpoint**: /api/v1/receipts/:id/post
- **Backend Handler**: ReceiptHandler.Post
- **Service**: ReceiptService.Post
- **Side Effects**: Creates journal entry
- **State Change**: draft → posted
- **Confidence**: HIGH

---

## Tax Actions

### ACTION-VAT-CREATE
- **Page**: /tax/vat
- **Label**: สร้าง VAT (Create VAT Record)
- **Method**: POST
- **Endpoint**: /api/v1/tax/vat
- **Backend Handler**: TaxHandler.CreateVat
- **Confidence**: HIGH

### ACTION-PP30-SUBMIT
- **Page**: /tax/pp30
- **Label**: ยื่นแบบ (Submit)
- **Method**: POST
- **Endpoint**: /api/v1/tax/pp30/:period/submit
- **Backend Handler**: TaxHandler.SubmitPP30
- **State Change**: draft → submitted
- **Confidence**: HIGH

### ACTION-PP30-FILE
- **Page**: /tax/pp30
- **Label**: ยื่น (File)
- **Method**: POST
- **Endpoint**: /api/v1/tax/pp30/:period/file
- **Backend Handler**: TaxHandler.FilePP30
- **State Change**: submitted → filed
- **Confidence**: HIGH

---

## Bank Actions

### ACTION-BANK-RECONCILE
- **Page**: /bank/reconciliation/[id]
- **Label**: กระทบยอด (Reconcile)
- **Method**: POST
- **Endpoint**: /api/v1/bank/reconciliations/:id/items
- **Backend Handler**: BankAccountHandler.CreateReconciliationItem
- **Permission**: bank.reconcile
- **Confidence**: VERIFIED

### ACTION-BANK-DIRECT-POST
- **Page**: /bank/reconciliation/[id]
- **Label**: บันทึกตรง (Direct Post)
- **Method**: POST
- **Endpoint**: /api/v1/bank/reconciliations/:id/direct-post
- **Backend Handler**: BankAccountHandler.DirectPost
- **Permissions**: bank.reconcile + bank.direct_post
- **Side Effects**: Creates journal entry directly from reconciliation
- **Confidence**: VERIFIED

---

## Payroll Actions

### ACTION-PAYROLL-APPROVE
- **Page**: /payroll/records/[id]
- **Label**: อนุมัติ (Approve)
- **Method**: POST
- **Endpoint**: /api/v1/payroll/records/:id/approve
- **Backend Handler**: PayrollHandler.Approve
- **Permission**: payroll.approve
- **State Change**: calculated → approved
- **Confidence**: VERIFIED

### ACTION-PAYROLL-PAY
- **Page**: /payroll/records/[id]
- **Label**: จ่ายเงิน (Pay)
- **Method**: POST
- **Endpoint**: /api/v1/payroll/records/:id/pay
- **Backend Handler**: PayrollHandler.Pay
- **Permission**: payroll.approve
- **State Change**: approved → paid
- **Confidence**: VERIFIED

---

## Period Close Actions

### ACTION-PERIOD-CLOSE
- **Page**: /accounting/monthly-close
- **Label**: ปิดงวด (Close Period)
- **Method**: POST
- **Endpoint**: /api/v1/setup/periods/:id/close
- **Backend Handler**: MonthlyCloseHandler.Close
- **Permission**: period.close
- **Validation**: Draft documents check, bank reconciliation check
- **State Change**: open → closed
- **Confidence**: VERIFIED

### ACTION-PERIOD-REOPEN
- **Page**: /accounting/monthly-close
- **Label**: เปิดงวด (Reopen Period)
- **Method**: POST
- **Endpoint**: /api/v1/accounting/periods/:id/reopen-requests
- **Backend Handler**: MonthlyCloseHandler.RequestReopen
- **Permission**: period.close
- **State Change**: closed → open (with approval)
- **Confidence**: VERIFIED

---

## Document Actions

### ACTION-DOC-UPLOAD
- **Page**: /documents/upload
- **Label**: อัปโหลด (Upload)
- **Method**: POST
- **Endpoint**: /api/v1/documents/upload
- **Backend Handler**: DocumentHandler.Upload
- **Side Effects**: Triggers OCR processing
- **Confidence**: HIGH

### ACTION-DOC-REVIEW
- **Page**: /documents/[id]
- **Label**: ตรวจสอบ (Review)
- **Method**: POST
- **Endpoint**: /api/v1/documents/:id/review
- **Backend Handler**: DocumentHandler.SubmitReview
- **Side Effects**: Creates entity + auto-posts journal entry
- **Confidence**: VERIFIED