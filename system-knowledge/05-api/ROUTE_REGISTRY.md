# AI-ACC Route Registry
> Generated: 2026-09-20 | Source: main.go | Routes: 468

## Route Summary by Module

| Module | Routes |
|--------|--------|
| accounting | 22 |
| accounts | 10 |
| ai | 5 |
| audit | 2 |
| auth | 9 |
| bank | 35 |
| billing | 18 |
| coa-templates | 3 |
| companies | 35 |
| control-plane | 1 |
| customers | 7 |
| dashboard | 2 |
| document-settings | 5 |
| documents | 11 |
| entitlement | 1 |
| fixed-assets | 11 |
| health | 1 |
| journal | 16 |
| media | 1 |
| ocr | 1 |
| office | 2 |
| onboarding | 4 |
| payroll | 34 |
| posting-templates | 1 |
| products | 14 |
| purchases | 44 |
| quotations | 6 |
| rbac | 8 |
| receipts | 6 |
| reports | 20 |
| sales | 23 |
| settings | 17 |
| stock | 19 |
| suppliers | 3 |
| support | 3 |
| system | 3 |
| tax | 42 |
| tenants | 12 |
| users | 11 |
| **TOTAL** | **468** |

---
## MOD-ACCOUNTING

| Method | Path |
|--------|------|
| POST | `/api/v1/accounting/periods/:id/close` |
| POST | `/api/v1/accounting/periods/:id/close-runs` |
| POST | `/api/v1/accounting/periods/:id/close-runs/approve` |
| POST | `/api/v1/accounting/periods/:id/close-runs/validate` |
| GET | `/api/v1/accounting/periods/:id/close-status` |
| POST | `/api/v1/accounting/periods/:id/exceptions` |
| POST | `/api/v1/accounting/periods/:id/exceptions/:exceptionId/approve` |
| GET | `/api/v1/accounting/periods/:id/explain` |
| POST | `/api/v1/accounting/periods/:id/reopen-requests` |
| POST | `/api/v1/accounting/periods/:id/reopen-requests/:requestId/approve` |
| POST | `/api/v1/accounting/periods/:id/reopen-requests/:requestId/reject` |
| POST | `/api/v1/accounting/periods/:id/subledger-reconciliations` |
| POST | `/api/v1/accounting/year-end/:id/confirm` |
| POST | `/api/v1/accounting/year-end/:id/reverse` |
| GET | `/api/v1/accounting/year-end/carry-forward` |
| POST | `/api/v1/accounting/year-end/carry-forward` |
| POST | `/api/v1/accounting/year-end/close` |
| GET | `/api/v1/accounting/year-end/closings` |
| GET | `/api/v1/accounting/year-end/closings/:id` |
| GET | `/api/v1/accounting/year-end/entries` |
| GET | `/api/v1/accounting/year-end/summary` |
| POST | `/api/v1/accounting/year-end/validate` |

---
## MOD-ACCOUNTS

| Method | Path |
|--------|------|
| GET | `/api/v1/accounts` |
| POST | `/api/v1/accounts` |
| DELETE | `/api/v1/accounts/:id` |
| GET | `/api/v1/accounts/:id` |
| PUT | `/api/v1/accounts/:id` |
| GET | `/api/v1/accounts/export` |
| POST | `/api/v1/accounts/import` |
| GET | `/api/v1/accounts/template` |
| GET | `/api/v1/reports/accounts-payable` |
| GET | `/api/v1/reports/accounts-receivable` |

---
## MOD-AI

| Method | Path |
|--------|------|
| GET | `/api/v1/ai-training/export` |
| GET | `/api/v1/ai/config` |
| GET | `/api/v1/ai/config/:key` |
| PUT | `/api/v1/ai/config/:key` |
| POST | `/api/v1/ai/insight` |

---
## MOD-AUDIT

| Method | Path |
|--------|------|
| GET | `/api/v1/audit/export` |
| GET | `/api/v1/audit/logs` |

---
## MOD-AUTH

| Method | Path |
|--------|------|
| POST | `/api/v1/api/v1/auth/forgot-password` |
| GET | `/api/v1/api/v1/auth/google/callback` |
| GET | `/api/v1/api/v1/auth/google/start` |
| POST | `/api/v1/api/v1/auth/ldap/login` |
| POST | `/api/v1/api/v1/auth/login` |
| GET | `/api/v1/api/v1/auth/methods` |
| POST | `/api/v1/api/v1/auth/reset-password` |
| POST | `/api/v1/api/v1/auth/verify-email` |
| GET | `/api/v1/auth/me` |

---
## MOD-BANK

| Method | Path |
|--------|------|
| GET | `/api/v1/bank/accounts` |
| POST | `/api/v1/bank/accounts` |
| GET | `/api/v1/bank/accounts/:id/gl-remap-impact` |
| POST | `/api/v1/bank/accounts/import` |
| GET | `/api/v1/bank/reconciliations` |
| POST | `/api/v1/bank/reconciliations` |
| GET | `/api/v1/bank/reconciliations/:id/ai-suggestions` |
| POST | `/api/v1/bank/reconciliations/:id/auto-match` |
| POST | `/api/v1/bank/reconciliations/:id/book-outstanding` |
| DELETE | `/api/v1/bank/reconciliations/:id/book-outstanding/:itemId` |
| POST | `/api/v1/bank/reconciliations/:id/carried-forward/resolve` |
| POST | `/api/v1/bank/reconciliations/:id/carry-forward` |
| POST | `/api/v1/bank/reconciliations/:id/direct-post` |
| GET | `/api/v1/bank/reconciliations/:id/history` |
| GET | `/api/v1/bank/reconciliations/:id/items` |
| POST | `/api/v1/bank/reconciliations/:id/items` |
| DELETE | `/api/v1/bank/reconciliations/:id/items/:itemId` |
| POST | `/api/v1/bank/reconciliations/:id/lock` |
| GET | `/api/v1/bank/reconciliations/:id/matches` |
| POST | `/api/v1/bank/reconciliations/:id/matches` |
| DELETE | `/api/v1/bank/reconciliations/:id/matches/:matchId` |
| GET | `/api/v1/bank/reconciliations/:id/suggestions` |
| GET | `/api/v1/bank/reconciliations/:id/summary` |
| POST | `/api/v1/bank/reconciliations/:id/unlock` |
| GET | `/api/v1/bank/reconciliations/:id/unreconciled` |
| GET | `/api/v1/bank/statement-imports` |
| GET | `/api/v1/bank/statements` |
| GET | `/api/v1/bank/statements/file/*` |
| POST | `/api/v1/bank/statements/import` |
| POST | `/api/v1/bank/statements/upload` |
| GET | `/api/v1/bank/transactions` |
| POST | `/api/v1/bank/transactions` |
| DELETE | `/api/v1/bank/transactions/:id` |
| PATCH | `/api/v1/bank/transactions/:id/notes` |
| POST | `/api/v1/bank/transactions/bulk-delete` |

---
## MOD-BILLING

| Method | Path |
|--------|------|
| POST | `/api/v1/billing/change-plan` |
| GET | `/api/v1/billing/invoices` |
| GET | `/api/v1/billing/payment-methods` |
| POST | `/api/v1/billing/payment-methods` |
| DELETE | `/api/v1/billing/payment-methods/:id` |
| POST | `/api/v1/billing/payment-methods/:id/default` |
| GET | `/api/v1/billing/payments` |
| GET | `/api/v1/billing/plan` |
| GET | `/api/v1/billing/plans` |
| GET | `/api/v1/sales/billing/aging` |
| GET | `/api/v1/sales/billing/documents` |
| POST | `/api/v1/sales/billing/documents` |
| DELETE | `/api/v1/sales/billing/documents/:id` |
| GET | `/api/v1/sales/billing/documents/:id` |
| PUT | `/api/v1/sales/billing/documents/:id` |
| GET | `/api/v1/sales/billing/documents/next-no` |
| GET | `/api/v1/sales/billing/statement/:customer_id` |
| GET | `/api/v1/sales/billing/unpaid-invoices` |

---
## MOD-COA-TEMPLATES

| Method | Path |
|--------|------|
| GET | `/api/v1/coa/templates` |
| POST | `/api/v1/coa/templates` |
| POST | `/api/v1/coa/templates/parse-import` |

---
## MOD-COMPANIES

| Method | Path |
|--------|------|
| GET | `/api/v1/accounting/companies/:companyId/close-policy` |
| PUT | `/api/v1/accounting/companies/:companyId/close-policy` |
| GET | `/api/v1/companies` |
| POST | `/api/v1/companies` |
| DELETE | `/api/v1/companies/:id` |
| GET | `/api/v1/companies/:id` |
| PUT | `/api/v1/companies/:id` |
| GET | `/api/v1/companies/:id/accounting-profile` |
| PUT | `/api/v1/companies/:id/accounting-profile` |
| DELETE | `/api/v1/companies/:id/coa-mappings` |
| GET | `/api/v1/companies/:id/coa-mappings` |
| POST | `/api/v1/companies/:id/coa-mappings` |
| POST | `/api/v1/companies/:id/coa-mappings/suggest` |
| POST | `/api/v1/companies/:id/coa/apply` |
| POST | `/api/v1/companies/:id/coa/save-as-template` |
| GET | `/api/v1/companies/:id/document-settings` |
| PUT | `/api/v1/companies/:id/document-settings` |
| GET | `/api/v1/companies/:id/line-item-account-rules` |
| POST | `/api/v1/companies/:id/line-item-account-rules` |
| DELETE | `/api/v1/companies/:id/line-item-account-rules/:ruleId` |
| GET | `/api/v1/companies/:id/line-item-account-rules/suggestions` |
| GET | `/api/v1/companies/:id/logo` |
| POST | `/api/v1/companies/:id/logo` |
| POST | `/api/v1/companies/:id/posting-recommendations` |
| GET | `/api/v1/companies/:id/posting-templates` |
| DELETE | `/api/v1/companies/:id/posting-templates/:code` |
| PUT | `/api/v1/companies/:id/posting-templates/:code` |
| GET | `/api/v1/companies/:id/purchase-posting-policy` |
| PUT | `/api/v1/companies/:id/purchase-posting-policy` |
| POST | `/api/v1/companies/:id/seed` |
| POST | `/api/v1/companies/:id/tax-advice` |
| GET | `/api/v1/companies/active-in-period` |
| GET | `/api/v1/control/tenants/:control_tenant_id/companies` |
| POST | `/api/v1/users/:id/companies` |
| DELETE | `/api/v1/users/:id/companies/:companyId` |

---
## MOD-CONTROL-PLANE

| Method | Path |
|--------|------|
| PUT | `/api/v1/control/tenant-mappings` |

---
## MOD-CUSTOMERS

| Method | Path |
|--------|------|
| GET | `/api/v1/customers` |
| POST | `/api/v1/customers` |
| DELETE | `/api/v1/customers/:id` |
| GET | `/api/v1/customers/:id` |
| PUT | `/api/v1/customers/:id` |
| POST | `/api/v1/customers/import` |
| GET | `/api/v1/customers/template` |

---
## MOD-DASHBOARD

| Method | Path |
|--------|------|
| GET | `/api/v1/dashboard/revenue` |
| GET | `/api/v1/dashboard/stats` |

---
## MOD-DOCUMENT-SETTINGS

| Method | Path |
|--------|------|
| GET | `/api/v1/document-workflows` |
| POST | `/api/v1/document-workflows` |
| GET | `/api/v1/document-workflows/:id` |
| POST | `/api/v1/document-workflows/:id/approve` |
| POST | `/api/v1/document-workflows/:id/reject` |

---
## MOD-DOCUMENTS

| Method | Path |
|--------|------|
| GET | `/api/v1/documents` |
| DELETE | `/api/v1/documents/:id` |
| GET | `/api/v1/documents/:id` |
| GET | `/api/v1/documents/:id/audit-logs` |
| POST | `/api/v1/documents/:id/classify` |
| POST | `/api/v1/documents/:id/retry-ocr` |
| GET | `/api/v1/documents/:id/review` |
| POST | `/api/v1/documents/:id/review` |
| POST | `/api/v1/documents/bulk-delete` |
| GET | `/api/v1/documents/file/*` |
| POST | `/api/v1/documents/upload` |

---
## MOD-ENTITLEMENT

| Method | Path |
|--------|------|
| GET | `/api/v1/entitlements` |

---
## MOD-FIXED-ASSETS

| Method | Path |
|--------|------|
| GET | `/api/v1/fixed-assets` |
| POST | `/api/v1/fixed-assets` |
| DELETE | `/api/v1/fixed-assets/:id` |
| GET | `/api/v1/fixed-assets/:id` |
| PUT | `/api/v1/fixed-assets/:id` |
| POST | `/api/v1/fixed-assets/:id/depreciate` |
| GET | `/api/v1/fixed-assets/:id/schedule` |
| POST | `/api/v1/fixed-assets/depreciation/:period/post-gl` |
| POST | `/api/v1/fixed-assets/depreciation/preview` |
| POST | `/api/v1/fixed-assets/depreciation/run` |
| POST | `/api/v1/fixed-assets/import` |

---
## MOD-HEALTH

| Method | Path |
|--------|------|
| GET | `/api/v1/health` |

---
## MOD-JOURNAL

| Method | Path |
|--------|------|
| GET | `/api/v1/journal/entries` |
| POST | `/api/v1/journal/entries` |
| DELETE | `/api/v1/journal/entries/:id` |
| GET | `/api/v1/journal/entries/:id` |
| PUT | `/api/v1/journal/entries/:id` |
| POST | `/api/v1/journal/entries/:id/cancel` |
| POST | `/api/v1/journal/entries/:id/post` |
| POST | `/api/v1/journal/entries/:id/reverse` |
| GET | `/api/v1/journal/entries/next-entry-no` |
| GET | `/api/v1/journal/recurring/instances` |
| GET | `/api/v1/journal/recurring/templates` |
| POST | `/api/v1/journal/recurring/templates` |
| GET | `/api/v1/journal/recurring/templates/:id` |
| PUT | `/api/v1/journal/recurring/templates/:id` |
| POST | `/api/v1/journal/recurring/templates/:id/generate` |
| GET | `/api/v1/journal/recurring/templates/next-template-no` |

---
## MOD-MEDIA

| Method | Path |
|--------|------|
| GET | `/api/v1/api/media/*` |

---
## MOD-OCR

| Method | Path |
|--------|------|
| POST | `/api/v1/ocr/extract` |

---
## MOD-OFFICE

| Method | Path |
|--------|------|
| GET | `/api/v1/office` |
| PUT | `/api/v1/office` |

---
## MOD-ONBOARDING

| Method | Path |
|--------|------|
| GET | `/api/v1/onboarding` |
| POST | `/api/v1/onboarding/dismiss` |
| POST | `/api/v1/onboarding/events` |
| PUT | `/api/v1/onboarding/preferences` |

---
## MOD-PAYROLL

| Method | Path |
|--------|------|
| GET | `/api/v1/payroll/deductions` |
| POST | `/api/v1/payroll/deductions` |
| DELETE | `/api/v1/payroll/deductions/:id` |
| GET | `/api/v1/payroll/deductions/:id` |
| PUT | `/api/v1/payroll/deductions/:id` |
| GET | `/api/v1/payroll/employees` |
| POST | `/api/v1/payroll/employees` |
| POST | `/api/v1/payroll/employees/import` |
| GET | `/api/v1/payroll/inputs` |
| POST | `/api/v1/payroll/inputs` |
| GET | `/api/v1/payroll/inputs/:employee_id` |
| POST | `/api/v1/payroll/inputs/bulk` |
| GET | `/api/v1/payroll/leaves` |
| POST | `/api/v1/payroll/leaves` |
| GET | `/api/v1/payroll/leaves/:id` |
| POST | `/api/v1/payroll/leaves/:id/approve` |
| POST | `/api/v1/payroll/leaves/:id/reject` |
| POST | `/api/v1/payroll/periods/:period/post-gl` |
| GET | `/api/v1/payroll/records` |
| POST | `/api/v1/payroll/records` |
| GET | `/api/v1/payroll/records/:id` |
| POST | `/api/v1/payroll/records/:id/approve` |
| POST | `/api/v1/payroll/records/:id/calculate` |
| POST | `/api/v1/payroll/records/:id/pay` |
| GET | `/api/v1/payroll/salary-structures` |
| POST | `/api/v1/payroll/salary-structures` |
| DELETE | `/api/v1/payroll/salary-structures/:id` |
| GET | `/api/v1/payroll/salary-structures/:id` |
| PUT | `/api/v1/payroll/salary-structures/:id` |
| GET | `/api/v1/payroll/slips/:month` |
| GET | `/api/v1/payroll/slips/:month/:employee_id` |
| GET | `/api/v1/payroll/slips/:month/:employee_id/print` |
| POST | `/api/v1/payroll/ssf-remit` |
| GET | `/api/v1/payroll/summary` |

---
## MOD-POSTING-TEMPLATES

| Method | Path |
|--------|------|
| POST | `/api/v1/posting-templates/preview` |

---
## MOD-PRODUCTS

| Method | Path |
|--------|------|
| GET | `/api/v1/products` |
| POST | `/api/v1/products` |
| DELETE | `/api/v1/products/:id` |
| GET | `/api/v1/products/:id` |
| PUT | `/api/v1/products/:id` |
| GET | `/api/v1/products/categories` |
| POST | `/api/v1/products/categories` |
| DELETE | `/api/v1/products/categories/:id` |
| GET | `/api/v1/products/categories/:id` |
| PUT | `/api/v1/products/categories/:id` |
| POST | `/api/v1/products/import` |
| GET | `/api/v1/products/template` |
| GET | `/api/v1/units` |
| POST | `/api/v1/units` |

---
## MOD-PURCHASES

| Method | Path |
|--------|------|
| GET | `/api/v1/purchase/grn` |
| POST | `/api/v1/purchase/grn` |
| GET | `/api/v1/purchase/grn/:id` |
| PUT | `/api/v1/purchase/grn/:id` |
| POST | `/api/v1/purchase/grn/:id/cancel` |
| POST | `/api/v1/purchase/grn/:id/confirm` |
| GET | `/api/v1/purchase/grn/clearing-balances` |
| GET | `/api/v1/purchase/grn/next-grn-no` |
| GET | `/api/v1/purchase/invoices` |
| POST | `/api/v1/purchase/invoices` |
| GET | `/api/v1/purchase/invoices/:id` |
| PUT | `/api/v1/purchase/invoices/:id` |
| POST | `/api/v1/purchase/invoices/:id/cancel` |
| POST | `/api/v1/purchase/invoices/:id/post` |
| GET | `/api/v1/purchase/invoices/next-no` |
| POST | `/api/v1/purchase/invoices/validate-match` |
| GET | `/api/v1/purchase/orders` |
| POST | `/api/v1/purchase/orders` |
| GET | `/api/v1/purchase/orders/:id` |
| PUT | `/api/v1/purchase/orders/:id` |
| POST | `/api/v1/purchase/orders/:id/approve` |
| POST | `/api/v1/purchase/orders/:id/cancel` |
| GET | `/api/v1/purchase/orders/next-po-no` |
| GET | `/api/v1/purchase/payments` |
| POST | `/api/v1/purchase/payments` |
| GET | `/api/v1/purchase/payments/:id` |
| PUT | `/api/v1/purchase/payments/:id` |
| POST | `/api/v1/purchase/payments/:id/approve` |
| POST | `/api/v1/purchase/payments/:id/cancel` |
| POST | `/api/v1/purchase/payments/:id/complete` |
| GET | `/api/v1/purchase/payments/next-pay-no` |
| GET | `/api/v1/purchases/credit-debit-notes` |
| POST | `/api/v1/purchases/credit-debit-notes` |
| GET | `/api/v1/purchases/credit-debit-notes/:id` |
| PUT | `/api/v1/purchases/credit-debit-notes/:id` |
| POST | `/api/v1/purchases/credit-debit-notes/:id/post` |
| GET | `/api/v1/purchases/invoices` |
| POST | `/api/v1/purchases/invoices` |
| DELETE | `/api/v1/purchases/invoices/:id` |
| GET | `/api/v1/purchases/invoices/:id` |
| PUT | `/api/v1/purchases/invoices/:id` |
| POST | `/api/v1/purchases/invoices/:id/post` |
| GET | `/api/v1/purchases/platform-templates` |
| POST | `/api/v1/purchases/platform-templates` |

---
## MOD-QUOTATIONS

| Method | Path |
|--------|------|
| GET | `/api/v1/quotations` |
| POST | `/api/v1/quotations` |
| DELETE | `/api/v1/quotations/:id` |
| GET | `/api/v1/quotations/:id` |
| PUT | `/api/v1/quotations/:id` |
| PUT | `/api/v1/quotations/:id/approve` |

---
## MOD-RBAC

| Method | Path |
|--------|------|
| GET | `/api/v1/permissions/me` |
| GET | `/api/v1/roles` |
| POST | `/api/v1/roles` |
| DELETE | `/api/v1/roles/:key` |
| PUT | `/api/v1/roles/:key` |
| PUT | `/api/v1/roles/:role/permissions/:key` |
| GET | `/api/v1/roles/audit` |
| GET | `/api/v1/roles/permissions` |

---
## MOD-RECEIPTS

| Method | Path |
|--------|------|
| GET | `/api/v1/receipts` |
| POST | `/api/v1/receipts` |
| GET | `/api/v1/receipts/:id` |
| PUT | `/api/v1/receipts/:id` |
| POST | `/api/v1/receipts/:id/cancel` |
| POST | `/api/v1/receipts/:id/post` |

---
## MOD-REPORTS

| Method | Path |
|--------|------|
| GET | `/api/v1/reports/aging` |
| GET | `/api/v1/reports/balance-sheet` |
| GET | `/api/v1/reports/balance-sheet/export/csv` |
| GET | `/api/v1/reports/cash-flow` |
| GET | `/api/v1/reports/general-ledger` |
| GET | `/api/v1/reports/inventory` |
| GET | `/api/v1/reports/profit-loss` |
| GET | `/api/v1/reports/profit-loss/export/csv` |
| GET | `/api/v1/reports/purchase-tax` |
| GET | `/api/v1/reports/runs` |
| POST | `/api/v1/reports/runs` |
| GET | `/api/v1/reports/runs/:token` |
| GET | `/api/v1/reports/runs/:token/download` |
| GET | `/api/v1/reports/sales-tax` |
| GET | `/api/v1/reports/stat/general-ledger` |
| GET | `/api/v1/reports/stock-on-hand` |
| GET | `/api/v1/reports/tax-summary` |
| GET | `/api/v1/reports/trial-balance` |
| GET | `/api/v1/reports/trial-balance/export/csv` |
| GET | `/api/v1/reports/wht-summary` |

---
## MOD-SALES

| Method | Path |
|--------|------|
| GET | `/api/v1/sales/billing` |
| GET | `/api/v1/sales/credit-debit-notes` |
| POST | `/api/v1/sales/credit-debit-notes` |
| GET | `/api/v1/sales/credit-debit-notes/:id` |
| PUT | `/api/v1/sales/credit-debit-notes/:id` |
| POST | `/api/v1/sales/credit-debit-notes/:id/post` |
| GET | `/api/v1/sales/deliveries` |
| POST | `/api/v1/sales/deliveries` |
| GET | `/api/v1/sales/deliveries/:id` |
| PUT | `/api/v1/sales/deliveries/:id` |
| POST | `/api/v1/sales/deliveries/:id/confirm` |
| GET | `/api/v1/sales/invoices` |
| POST | `/api/v1/sales/invoices` |
| DELETE | `/api/v1/sales/invoices/:id` |
| GET | `/api/v1/sales/invoices/:id` |
| PUT | `/api/v1/sales/invoices/:id` |
| POST | `/api/v1/sales/invoices/:id/post` |
| POST | `/api/v1/sales/invoices/:id/tax-invoice` |
| GET | `/api/v1/sales/invoices/next-no` |
| GET | `/api/v1/sales/orders` |
| POST | `/api/v1/sales/orders` |
| GET | `/api/v1/sales/orders/:id` |
| PUT | `/api/v1/sales/orders/:id` |

---
## MOD-SETTINGS

| Method | Path |
|--------|------|
| GET | `/api/v1/settings/document-numbers` |
| POST | `/api/v1/settings/document-numbers` |
| DELETE | `/api/v1/settings/document-numbers/:id` |
| GET | `/api/v1/settings/document-numbers/:id` |
| PUT | `/api/v1/settings/document-numbers/:id` |
| GET | `/api/v1/settings/document-numbers/generate` |
| GET | `/api/v1/settings/document-numbers/preview` |
| POST | `/api/v1/settings/document-numbers/reset` |
| GET | `/api/v1/setup/opening-balances` |
| POST | `/api/v1/setup/opening-balances` |
| POST | `/api/v1/setup/opening-balances/init` |
| GET | `/api/v1/setup/periods` |
| POST | `/api/v1/setup/periods` |
| POST | `/api/v1/setup/periods/:id/close` |
| POST | `/api/v1/setup/periods/:id/lock` |
| POST | `/api/v1/setup/periods/:id/unlock` |
| GET | `/api/v1/setup/periods/:id/usage` |

---
## MOD-STOCK

| Method | Path |
|--------|------|
| GET | `/api/v1/landed-costs` |
| POST | `/api/v1/landed-costs` |
| GET | `/api/v1/stock/adjustments` |
| POST | `/api/v1/stock/adjustments` |
| GET | `/api/v1/stock/counts` |
| POST | `/api/v1/stock/counts` |
| GET | `/api/v1/stock/counts/:id` |
| POST | `/api/v1/stock/counts/:id/post` |
| GET | `/api/v1/stock/movements` |
| POST | `/api/v1/stock/opening-balance` |
| GET | `/api/v1/stock/opening-balance/reconciliation` |
| GET | `/api/v1/stock/reconciliation` |
| GET | `/api/v1/stock/reservations` |
| GET | `/api/v1/stock/transfers` |
| POST | `/api/v1/stock/transfers` |
| GET | `/api/v1/stock/transfers/:id` |
| GET | `/api/v1/warehouses` |
| POST | `/api/v1/warehouses` |
| PUT | `/api/v1/warehouses/:id` |

---
## MOD-SUPPLIERS

| Method | Path |
|--------|------|
| GET | `/api/v1/suppliers` |
| POST | `/api/v1/suppliers` |
| POST | `/api/v1/suppliers/import` |

---
## MOD-SUPPORT

| Method | Path |
|--------|------|
| GET | `/api/v1/control/support-attachments` |
| GET | `/api/v1/support-tickets/file/*` |
| POST | `/api/v1/support/tickets` |

---
## MOD-SYSTEM

| Method | Path |
|--------|------|
| GET | `/api/v1/system/config` |
| GET | `/api/v1/system/config/:key` |
| PUT | `/api/v1/system/config/:key` |

---
## MOD-TAX

| Method | Path |
|--------|------|
| GET | `/api/v1/tax/config` |
| POST | `/api/v1/tax/config` |
| DELETE | `/api/v1/tax/config/:id` |
| GET | `/api/v1/tax/config/:id` |
| PUT | `/api/v1/tax/config/:id` |
| GET | `/api/v1/tax/export/txt/:form_type/:period` |
| GET | `/api/v1/tax/pp30/:period` |
| POST | `/api/v1/tax/pp30/:period` |
| PUT | `/api/v1/tax/pp30/:period` |
| POST | `/api/v1/tax/pp30/:period/carry-forward` |
| POST | `/api/v1/tax/pp30/:period/file` |
| POST | `/api/v1/tax/pp30/:period/settle` |
| POST | `/api/v1/tax/pp30/:period/submit` |
| GET | `/api/v1/tax/pp36/:period` |
| POST | `/api/v1/tax/pp36/:period` |
| PUT | `/api/v1/tax/pp36/:period` |
| POST | `/api/v1/tax/pp36/:period/file` |
| POST | `/api/v1/tax/pp36/:period/submit` |
| GET | `/api/v1/tax/vat` |
| POST | `/api/v1/tax/vat` |
| POST | `/api/v1/tax/vat/:id/post` |
| GET | `/api/v1/tax/vat/calculate` |
| GET | `/api/v1/tax/vat/export/excel` |
| GET | `/api/v1/tax/vat/export/pdf` |
| GET | `/api/v1/tax/vat/summary` |
| GET | `/api/v1/tax/wht` |
| POST | `/api/v1/tax/wht` |
| POST | `/api/v1/tax/wht/50tvi` |
| POST | `/api/v1/tax/wht/50tvi/bulk` |
| POST | `/api/v1/tax/wht/50tvi/preview` |
| POST | `/api/v1/tax/wht/:id/file` |
| GET | `/api/v1/tax/wht/:id/print` |
| GET | `/api/v1/tax/wht/export/:form_type/:period` |
| GET | `/api/v1/tax/wht/filing/:form_type/:period` |
| POST | `/api/v1/tax/wht/filing/:form_type/:period` |
| POST | `/api/v1/tax/wht/filing/:form_type/:period/file` |
| POST | `/api/v1/tax/wht/filing/:form_type/:period/submit` |
| GET | `/api/v1/wht/certificates` |
| POST | `/api/v1/wht/certificates` |
| DELETE | `/api/v1/wht/certificates/:id` |
| GET | `/api/v1/wht/certificates/:id` |
| PUT | `/api/v1/wht/certificates/:id` |

---
## MOD-TENANTS

| Method | Path |
|--------|------|
| GET | `/api/v1/control/tenants/:control_tenant_id/audit-events` |
| GET | `/api/v1/control/tenants/:control_tenant_id/document-errors` |
| POST | `/api/v1/control/tenants/:control_tenant_id/email-verified` |
| PUT | `/api/v1/control/tenants/:control_tenant_id/link-user` |
| GET | `/api/v1/control/tenants/:control_tenant_id/operation-errors` |
| PUT | `/api/v1/control/tenants/:control_tenant_id/status` |
| POST | `/api/v1/control/tenants/provision` |
| GET | `/api/v1/tenants` |
| POST | `/api/v1/tenants` |
| DELETE | `/api/v1/tenants/:id` |
| GET | `/api/v1/tenants/:id` |
| PUT | `/api/v1/tenants/:id` |

---
## MOD-USERS

| Method | Path |
|--------|------|
| GET | `/api/v1/control/tenants/:control_tenant_id/users` |
| POST | `/api/v1/control/tenants/:control_tenant_id/users/:user_id/reset-password` |
| GET | `/api/v1/users` |
| POST | `/api/v1/users` |
| DELETE | `/api/v1/users/:id` |
| GET | `/api/v1/users/:id` |
| PUT | `/api/v1/users/:id` |
| POST | `/api/v1/users/me/email/send-verification` |
| PUT | `/api/v1/users/me/password` |
| GET | `/api/v1/users/me/profile` |
| PUT | `/api/v1/users/me/profile` |
