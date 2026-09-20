# AI-ACC Field Lineage
> Generated: 2026-09-20
> Source: Code analysis (CodeGraph + source)
> Confidence: HIGH

## Sales Invoice Field Lineage

### invoice_no
```
UI: /sales/invoices/new → Invoice No field
  ↓
Frontend: form state.invoice_no
  ↓
Request: POST /api/v1/sales/invoices { invoice_no }
  ↓
Handler: SalesHandler.Create → bind request
  ↓
Service: SalesService.Create → DocumentNumberService.Generate()
  ↓
Repository: SalesRepository.Create → INSERT
  ↓
DB: sales_invoices.invoice_no (VARCHAR(50), UNIQUE)
```

### customer_id
```
UI: /sales/invoices/new → Customer dropdown
  ↓
Frontend: Autocomplete → fetchApi('/api/v1/customers')
  ↓
Request: POST /api/v1/sales/invoices { customer_id }
  ↓
Handler: SalesHandler.Create → bind request
  ↓
Service: SalesService.Create → validate customer exists
  ↓
Repository: SalesRepository.Create → INSERT
  ↓
DB: sales_invoices.customer_id (BIGINT, FK → customers)
```

### subtotal
```
UI: Auto-calculated from line items
  ↓
Frontend: sum(line.amount)
  ↓
Request: POST /api/v1/sales/invoices { subtotal }
  ↓
Handler: SalesHandler.Create → bind request
  ↓
Service: SalesService.Create → recalculate
  ↓
Repository: SalesRepository.Create → INSERT
  ↓
DB: sales_invoices.subtotal (NUMERIC(19,4))
```

### status
```
UI: Badge display (draft/approved/cancelled)
  ↓
Frontend: Read from API response
  ↓
API: GET /api/v1/sales/invoices/:id → { status }
  ↓
Repository: SalesRepository.GetByID → SELECT
  ↓
DB: sales_invoices.status (VARCHAR(20), DEFAULT 'draft')
```

---

## Journal Entry Field Lineage

### entry_no
```
UI: /journal/new → Entry No field (auto-generated)
  ↓
Frontend: form state.entry_no
  ↓
Request: POST /api/v1/journal/entries { entry_no }
  ↓
Handler: JournalHandler.Create → bind request
  ↓
Service: JournalService.Create → DocumentNumberService.Generate()
  ↓
Repository: JournalRepository.Create → INSERT
  ↓
DB: journal_entries.entry_no (VARCHAR(50), UNIQUE)
```

### line.account_id
```
UI: /journal/new → Account dropdown
  ↓
Frontend: Autocomplete → fetchApi('/api/v1/accounts')
  ↓
Request: POST /api/v1/journal/entries { lines[{ account_id }] }
  ↓
Handler: JournalHandler.Create → bind request
  ↓
Service: JournalService.Create → validate account exists
  ↓
Repository: JournalRepository.CreateLines → INSERT
  ↓
DB: journal_lines.account_id (BIGINT, FK → accounts)
```

### line.debit / line.credit
```
UI: /journal/new → Debit/Credit input fields
  ↓
Frontend: form state.lines[].debit/credit
  ↓
Request: POST /api/v1/journal/entries { lines[{ debit, credit }] }
  ↓
Handler: JournalHandler.Create → bind request
  ↓
Service: JournalService.Create → validate balance (Dr = Cr)
  ↓
Repository: JournalRepository.CreateLines → INSERT
  ↓
DB: journal_lines.debit/credit (NUMERIC(19,4))
```

---

## Receipt Field Lineage

### amount
```
UI: /sales/receipts/new → Amount input
  ↓
Frontend: form state.amount
  ↓
Request: POST /api/v1/receipts { amount }
  ↓
Handler: ReceiptHandler.Create → bind request
  ↓
Service: ReceiptService.Create → validate > 0
  ↓
Repository: ReceiptRepository.Create → INSERT
  ↓
DB: receipts.amount (NUMERIC(19,4))
```

### bank_account_id
```
UI: /sales/receipts/new → Bank Account dropdown
  ↓
Frontend: Autocomplete → fetchApi('/api/v1/bank/accounts')
  ↓
Request: POST /api/v1/receipts { bank_account_id }
  ↓
Handler: ReceiptHandler.Create → bind request
  ↓
Service: ReceiptService.Create → validate bank account exists + GL mapping
  ↓
Repository: ReceiptRepository.Create → INSERT
  ↓
DB: receipts.bank_account_id (BIGINT, FK → bank_accounts)
```

---

## VAT Record Lineage

### tax_amount
```
UI: Auto-calculated (7% of taxable amount)
  ↓
Frontend: amount × 0.07
  ↓
Request: POST /api/v1/tax/vat { tax_amount }
  ↓
Handler: TaxHandler.CreateVat → bind request
  ↓
Service: TaxService.CreateVat → validate
  ↓
Repository: VatRecordRepository.Create → INSERT
  ↓
DB: vat_records.tax_amount (NUMERIC(19,4))
```

---

## Account Field Lineage

### code
```
UI: /accounts → Account Code input
  ↓
Frontend: form state.code
  ↓
Request: POST /api/v1/accounts { code }
  ↓
Handler: AccountHandler.Create → bind request
  ↓
Service: AccountService.Create → validate unique
  ↓
Repository: AccountRepository.Create → INSERT
  ↓
DB: accounts.code (VARCHAR(20), UNIQUE per company)
```

### type
```
UI: /accounts → Account Type dropdown
  ↓
Frontend: select state.type (asset/liability/equity/revenue/expense)
  ↓
Request: POST /api/v1/accounts { type }
  ↓
Handler: AccountHandler.Create → bind request
  ↓
Service: AccountService.Create → validate enum
  ↓
Repository: AccountRepository.Create → INSERT
  ↓
DB: accounts.type (VARCHAR(20), CHECK constraint)
```

---

## Document Number Lineage

### prefix
```
UI: /settings/document-numbers → Prefix input
  ↓
Frontend: form state.prefix
  ↓
Request: POST /api/v1/settings/document-numbers { prefix }
  ↓
Handler: DocumentNumberSettingsHandler.Create → bind request
  ↓
Service: DocumentNumberService.Create → validate
  ↓
Repository: DocumentNumberSettingsRepository.Create → INSERT
  ↓
DB: document_number_settings.prefix (VARCHAR(20))
```

### running_number
```
UI: Auto-incremented
  ↓
Service: DocumentNumberService.Generate() → increment
  ↓
Repository: DocumentNumberSettingsRepository.IncrementRunning → UPDATE
  ↓
DB: document_number_settings.running_number (INTEGER)
```

---

## Reversed Lineage (DB → UI)

### sales_invoices.approved_by
```
DB: sales_invoices.approved_by (BIGINT)
  ↓
Repository: SalesRepository.Post → UPDATE SET approved_by = $user_id
  ↓
Service: SalesService.Post → sets approved_by from context
  ↓
Handler: SalesHandler.Post → extracts user from JWT
  ↓
API: POST /api/v1/sales/invoices/:id/post
  ↓
UI: Not displayed (internal tracking)
```

### journal_entries.reversed_at
```
DB: journal_entries.reversed_at (TIMESTAMPTZ)
  ↓
Repository: JournalRepository.Reverse → UPDATE SET reversed_at = now()
  ↓
Service: JournalService.Reverse → sets reversed_at
  ↓
API: POST /api/v1/journal/entries/:id/reverse
  ↓
UI: Badge shows "reversed" status
```

---

## Orphan Fields (DB exists, UI/API origin unclear)

| Table | Column | Status |
|-------|--------|--------|
| accounts | statement_item | Used for financial statement mapping, not directly in UI |
| companies | short_name | May not be exposed in UI |
| customers | customer_type | individual/juristic, may be in advanced form |
| suppliers | branch_name | Added in migration 193, may be in UI |
| products | wht_rate | Added in migration 187, may be in product form |

---

## Unknown Origins (DB used but UI/API origin not traced)

| Table | Column | Usage | Resolution |
|-------|--------|-------|------------|
| vat_filings | filed_at | Tax filing timestamp | Check tax handler |
| wht_filings | filed_at | WHT filing timestamp | Check tax handler |
| period_close_checks | check_type | Close validation type | Check monthly close service |
| stock_layers | cost_method | FIFO/Moving Average | Check stock service |