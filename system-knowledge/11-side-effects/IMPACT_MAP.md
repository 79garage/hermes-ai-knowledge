# AI-ACC Impact Map
> Generated: 2026-09-20
> Source: CodeGraph + Code analysis
> Confidence: HIGH

## SalesService.Post() Impact

```
SalesService.Post()
├── DIRECT
│   ├── sales_invoices.status → 'approved'
│   ├── journal_entries (CREATE)
│   ├── journal_lines (CREATE)
│   ├── vat_records (CREATE if VAT)
│   └── wht_records (CREATE if WHT)
├── INDIRECT
│   ├── general_ledger (UPDATE balances)
│   ├── trial_balance (READ from GL)
│   ├── profit_loss (READ from GL)
│   ├── balance_sheet (READ from GL)
│   ├── accounts_receivable (UPDATE)
│   ├── dashboard (UPDATE stats)
│   └── sales/invoices page (status change)
├── REPORTS
│   ├── /reports/trial-balance
│   ├── /reports/profit-loss
│   ├── /reports/balance-sheet
│   ├── /reports/general-ledger
│   ├── /reports/aging
│   ├── /reports/sales-tax
│   └── /reports/tax-summary
└── TESTS
    ├── sales-flow.spec.ts
    ├── invoice-vat-flow.spec.ts
    ├── supported-cases.spec.ts
    └── comprehensive-business-cycle.spec.ts
```

---

## JournalService.Post() Impact

```
JournalService.Post()
├── DIRECT
│   ├── journal_entries.status → 'posted'
│   └── journal_lines (ACTIVATE)
├── INDIRECT
│   ├── general_ledger (UPDATE all accounts)
│   ├── trial_balance (UPDATE)
│   ├── profit_loss (UPDATE)
│   ├── balance_sheet (UPDATE)
│   └── dashboard (UPDATE stats)
├── REPORTS
│   ├── /reports/trial-balance
│   ├── /reports/profit-loss
│   ├── /reports/balance-sheet
│   ├── /reports/general-ledger
│   └── /reports/cash-flow
└── TESTS
    ├── journal-flow.spec.ts
    └── accounting-cases.spec.ts
```

---

## PostingEngine.Render() Impact

```
PostingEngine.Render()
├── DIRECT
│   └── journal_lines (GENERATE from template)
├── DEPENDENCIES
│   ├── posting_templates (READ)
│   ├── posting_template_lines (READ)
│   ├── accounts (READ for mapping)
│   └── bank_accounts (READ for bank GL)
├── USED BY
│   ├── SalesService.Post()
│   ├── ReceiptService.Post()
│   ├── PurchaseInvoiceFlowService.Post()
│   ├── PurchasePaymentService.Post()
│   ├── CreditDebitNoteService.Post()
│   ├── VendorCreditDebitNoteService.Post()
│   ├── PayrollService.PostPeriodToGL()
│   ├── FixedAssetService.Depreciate()
│   └── DocumentService.SubmitReview()
└── FALLBACK
    └── Simple GL (hardcoded in each service)
```

---

## DocumentService.SubmitReview() Impact

```
DocumentService.SubmitReview()
├── DIRECT
│   ├── documents.status → 'reviewed'
│   ├── sales_invoices OR receipts OR purchase_invoices (CREATE)
│   ├── journal_entries (AUTO-POST)
│   ├── journal_lines (CREATE)
│   ├── vat_records (CREATE if applicable)
│   └── posting_overrides (READ if reviewer edited)
├── INDIRECT
│   ├── general_ledger (UPDATE)
│   ├── dashboard (UPDATE stats)
│   └── document review page (status change)
└── TESTS
    └── tax-invoice-flow.spec.ts
```

---

## CompanyService.Create() Impact

```
CompanyService.Create()
├── DIRECT
│   ├── companies (CREATE)
│   ├── accounts (CREATE from COA template)
│   ├── document_number_settings (CREATE defaults)
│   ├── company_accounting_profiles (CREATE)
│   └── control_tenant_mappings (CREATE link)
├── INDIRECT
│   ├── All modules (new company available)
│   ├── Settings pages (company listed)
│   └── Company selector (company appears)
└── TESTS
    └── coa-template.spec.ts
```

---

## MonthlyCloseService.Close() Impact

```
MonthlyCloseService.Close()
├── DIRECT
│   ├── accounting_periods.is_closed → true
│   ├── period_close_runs (CREATE)
│   ├── period_close_snapshots (CREATE)
│   └── closing_entries (CREATE if year-end)
├── VALIDATION
│   ├── Draft documents check
│   ├── Bank reconciliation check
│   ├── Subledger reconciliation check
│   └── Exception check
├── INDIRECT
│   ├── All modules (posting blocked for closed period)
│   ├── Bank reconciliation (locked)
│   └── Reports (period locked)
└── TESTS
    ├── monthly-close.spec.ts
    └── year-end-close.spec.ts
```

---

## Critical Shared Services

### DocumentNumberService
```
DocumentNumberService.Generate()
├── USED BY
│   ├── SalesService
│   ├── PurchaseService
│   ├── PurchaseOrderService
│   ├── PurchaseInvoiceFlowService
│   ├── PurchasePaymentService
│   ├── ReceiptService
│   ├── QuotationService
│   ├── SalesOrderService
│   ├── CreditDebitNoteService
│   ├── VendorCreditDebitNoteService
│   ├── GRNService
│   ├── DeliveryOrderService
│   ├── BillingDocumentService
│   ├── SupplierService
│   └── CompanyService (seed)
├── DEPENDENCIES
│   ├── document_number_settings (READ)
│   └── document_number_sequences (READ/WRITE)
└── IMPACT
    └── All document creation flows
```

### AccountService
```
AccountService
├── USED BY
│   ├── All posting services
│   ├── COA template service
│   ├── Report service
│   ├── Bank account service
│   └── Import/export templates
├── DEPENDENCIES
│   └── accounts (READ)
└── IMPACT
    └── All accounting operations
```

---

## Regression Test Recommendations

### After SalesService changes:
- `sales-flow.spec.ts`
- `invoice-vat-flow.spec.ts`
- `supported-cases.spec.ts`
- `comprehensive-business-cycle.spec.ts`
- `accounting-cases.spec.ts`

### After JournalService changes:
- `journal-flow.spec.ts`
- `accounting-cases.spec.ts`
- All specs that post documents

### After PostingEngine changes:
- ALL specs (posting affects all financial documents)

### After DocumentNumberService changes:
- ALL specs (document numbers affect all documents)

### After Period Close changes:
- `monthly-close.spec.ts`
- `year-end-close.spec.ts`

### After RBAC changes:
- `cross-tenant-isolation.spec.ts`
- All specs (permission changes affect all operations)