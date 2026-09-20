
# AI-ACC State Machines
> Generated: 2026-09-20 | Confidence: HIGH (code-traced)

## Sales Invoice
```mermaid
stateDiagram-v2
    [*] --> draft: Create
    draft --> approved: Post (auto from document review)
    draft --> cancelled: Cancel
    approved --> [*]: Active (can create receipts)
```
- **draft → approved**: `POST /sales/invoices/:id/post` → SalesService.Post → PostingEngine → JournalEntry
- **draft → cancelled**: `DELETE /sales/invoices/:id` → SalesService.Cancel
- **Note**: Status stays 'approved' after full receipt (no 'paid' status)

## Purchase Invoice (New Flow)
```mermaid
stateDiagram-v2
    [*] --> draft: Create
    draft --> posted: Post
    draft --> cancelled: Cancel
    posted --> [*]: Active
```
- **draft → posted**: `POST /purchase/invoices/:id/post` → PurchaseInvoiceFlowService.Post
- **draft → cancelled**: `POST /purchase/invoices/:id/cancel`

## Journal Entry
```mermaid
stateDiagram-v2
    [*] --> draft: Create
    draft --> posted: Post
    draft --> cancelled: Cancel/Delete
    posted --> reversed: Reverse
    posted --> [*]: Active
    reversed --> [*]: Corrected
```
- **draft → posted**: `POST /journal/entries/:id/post` (requires `journal.post` permission)
- **posted → reversed**: `POST /journal/entries/:id/reverse` (requires `journal.post` permission)
- **draft → cancelled**: `DELETE /journal/entries/:id` or `POST /journal/entries/:id/cancel`

## Receipt
```mermaid
stateDiagram-v2
    [*] --> draft: Create
    draft --> posted: Post
    draft --> cancelled: Cancel
    posted --> [*]: Active
```
- **draft → posted**: `POST /receipts/:id/post` → ReceiptService.Post → PostingEngine → JournalEntry

## Credit/Debit Note (Sales)
```mermaid
stateDiagram-v2
    [*] --> draft: Create
    draft --> posted: Post
    posted --> [*]: Active
```

## Purchase Order
```mermaid
stateDiagram-v2
    [*] --> draft: Create
    draft --> approved: Approve
    draft --> cancelled: Cancel
    approved --> [*]: Active (can create GRN)
```

## GRN (Goods Received Note)
```mermaid
stateDiagram-v2
    [*] --> draft: Create
    draft --> confirmed: Confirm
    draft --> cancelled: Cancel
    confirmed --> [*]: Active (can create purchase invoice)
```

## Quotation
```mermaid
stateDiagram-v2
    [*] --> draft: Create
    draft --> approved: Approve
    draft --> cancelled: Cancel
    approved --> [*]: Active (can create sales order)
```

## Delivery Order
```mermaid
stateDiagram-v2
    [*] --> draft: Create
    draft --> confirmed: Confirm
    confirmed --> [*]: Delivered
```

## Billing Document
```mermaid
stateDiagram-v2
    [*] --> draft: Create
    draft --> confirmed: Confirm
    draft --> cancelled: Cancel
    confirmed --> [*]: Active
```

## Document (OCR Upload)
```mermaid
stateDiagram-v2
    [*] --> uploaded: Upload
    uploaded --> processing: OCR Start
    processing --> extracted: OCR Complete
    processing --> error: OCR Fail
    extracted --> reviewed: SubmitReview
    reviewed --> approved: Auto-post entity
    error --> processing: RetryOCR
    approved --> [*]: Done
```

## Fixed Asset
```mermaid
stateDiagram-v2
    [*] --> active: Create
    active --> depreciating: Depreciate
    active --> disposed: Dispose
    depreciating --> disposed: Dispose
    disposed --> [*]: Archived
```

## Payroll Record
```mermaid
stateDiagram-v2
    [*] --> draft: CreateBatch
    draft --> calculated: Calculate
    calculated --> approved: Approve
    approved --> paid: Pay
    approved --> [*]: Active
    paid --> [*]: Completed
```

## Period Close
```mermaid
stateDiagram-v2
    [*] --> open: Period Created
    open --> closing: Start Close Run
    closing --> validated: Validate
    validated --> closed: Approve/Close
    closed --> open: Reopen (with approval)
    open --> locked: Lock
    locked --> open: Unlock
```

## Bank Reconciliation
```mermaid
stateDiagram-v2
    [*] --> draft: Create
    draft --> reconciling: Add Items
    reconciling --> reconciled: Match/Carry Forward
    reconciled --> locked: Lock (period.close)
    locked --> reconciled: Unlock
```

## WHT Filing
```mermaid
stateDiagram-v2
    [*] --> draft: Save
    draft --> submitted: Submit
    submitted --> filed: File
    filed --> [*]: Completed
```

## PP30 (VAT Return)
```mermaid
stateDiagram-v2
    [*] --> draft: Save
    draft --> submitted: Submit
    submitted --> filed: File
    submitted --> settled: Settle
    draft --> carried_forward: CarryForward
```

## Year-End Closing
```mermaid
stateDiagram-v2
    [*] --> draft: Prepare
    draft --> validated: Validate
    validated --> confirmed: Confirm
    confirmed --> reversed: Reverse
    confirmed --> [*]: Closed
```

## Tenant Status
```mermaid
stateDiagram-v2
    [*] --> active: Provision
    active --> suspended: Suspend
    suspended --> active: Reactivate
    active --> deleted: Delete
```
