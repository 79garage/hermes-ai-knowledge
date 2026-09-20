# AI-ACC System Inventory
> Generated: 2026-09-20 | Verification: STATIC_TRACED + CODEGRAPH

## Executive Summary

| Metric | Count |
|--------|-------|
| Sub-Repositories | 6 |
| Backend Handlers | 92 |
| Backend Services | 106 |
| Backend Repositories | 70 |
| Domain Models | 60+ |
| Frontend Pages (page.tsx) | 150+ |
| API Routes (main.go) | ~320 |
| Middleware | 8 |
| Database Migrations | 152+ |
| CodeGraph Nodes | 24,686 |
| CodeGraph Edges | 66,946 |

---

## Repository Map

### 1. ai-accounting-core (Backend API)
- **Path**: `D:/workspace/ai-acc/ai-accounting-core/`
- **Technology**: Go 1.25, Echo v4, PostgreSQL, sqlx
- **Responsibility**: Main accounting API — all business logic
- **Entry Point**: `node-app/services/api-core/cmd/api/main.go` (1,261 lines)
- **Port**: config-driven (default 8080)
- **Files**: 3,496 (excluding node_modules)
- **Key Structure**:
  ```
  node-app/services/api-core/
  ├── cmd/api/main.go           # Route registration + DI wiring
  ├── internal/
  │   ├── handler/              # 92 HTTP handlers
  │   ├── service/              # 106 business logic services
  │   ├── repository/           # 70 DB repositories
  │   ├── model/                # 60+ domain models
  │   ├── middleware/            # 8 middleware (JWT, RBAC, CORS, rate-limit, etc.)
  │   ├── migrate/              # Migration runner
  │   └── storage/              # File storage (local/MinIO)
  ├── db/
  │   ├── migrations/           # 152+ SQL migrations (compiled into binary)
  │   ├── schema.sql
  │   └── seed_data.sql
  ├── config/                   # App configuration
  └── scripts/
  ```
- **External Services**: LiteLLM Gateway (OCR/LLM), Qdrant (RAG KB), MinIO (storage), Control Plane API
- **Background Jobs**:
  - Report artifact cleanup (hourly)
  - Stranded OCR document reaper (5min)
  - AI model config sync poller (2min)

### 2. ai-accounting-web (Frontend)
- **Path**: `D:/workspace/ai-acc/ai-accounting-web/`
- **Technology**: Next.js (App Router), TypeScript, React
- **Responsibility**: Web UI for accounting system
- **Entry Point**: `src/app/layout.tsx` → `src/app/page.tsx`
- **Files**: 10,107 (including node_modules)
- **Key Structure**:
  ```
  src/app/
  ├── (auth)/                   # Login, signup, forgot-password, reset-password, verify-email
  ├── accounting/               # Monthly close
  ├── accounts/                 # Chart of Accounts (CRUD, import)
  ├── ai/                       # AI agents, tasks
  ├── assets/                   # Fixed assets, depreciation
  ├── bank/                     # Bank accounts, reconciliation, statements, transactions
  ├── documents/                # Document upload, review, OCR
  ├── journal/                  # Journal entries, recurring
  ├── migration/                # Data migration (Excel, Express, PEAK)
  ├── onboarding/               # User onboarding
  ├── payroll/                  # Employees, salary, OT, deductions, leaves, slips, SSF
  ├── products/                 # Products, categories, inventory, stock, warehouses
  ├── purchases/                # Suppliers, PO, GRN, invoices, payments, credit notes
  ├── reports/                  # All financial reports
  ├── review/                   # Document review
  ├── sales/                    # Customers, quotations, orders, invoices, receipts, billing, deliveries
  ├── security/                 # Security settings
  ├── settings/                 # Company, accounts, periods, roles, users, tax, templates
  ├── share/                    # Shared report links
  ├── system/                   # Audit logs
  ├── tax/                      # VAT (PP30/PP36), WHT, certificates, reports
  └── [static pages]/           # Privacy, terms, login, signup
  ```
- **Dev URL**: https://dev-acc-app.i-c-develop.com
- **Dev Credentials**: admin@icaccounting.co.th / ICaccount2026

### 3. acc-control-plane-api (Admin Backend)
- **Path**: `D:/workspace/ai-acc/acc-control-plane-api/`
- **Technology**: Go 1.25
- **Responsibility**: Multi-tenant management, billing, provisioning
- **Files**: 131
- **Key Structure**:
  ```
  internal/
  ├── auth/                     # Authentication
  ├── config/                   # Configuration
  ├── domain/                   # Domain models
  ├── repository/               # DB access
  ├── service/                  # Business logic
  └── transport/                # HTTP handlers
  ```

### 4. acc-control-plane-web (Admin Frontend)
- **Path**: `D:/workspace/ai-acc/acc-control-plane-web/`
- **Technology**: Vite + React + TypeScript
- **Responsibility**: Admin dashboard UI
- **Files**: 81 (excluding node_modules)
- **Key Structure**:
  ```
  src/
  ├── api/                      # API client
  ├── app/                      # App pages
  ├── components/               # UI components
  ├── contexts/                 # React contexts
  ├── i18n/                     # Internationalization
  ├── lib/                      # Utilities
  ├── routes/                   # Route definitions
  ├── store/                    # State management
  └── types.ts                  # Type definitions
  ```

### 5. account-report-api (Report Service)
- **Path**: `D:/workspace/ai-acc/account-report-api/account-report-api/`
- **Technology**: Go
- **Responsibility**: Async report generation (PDF/Excel), import templates
- **Files**: 62
- **Key Structure**:
  ```
  internal/
  ├── config/                   # Configuration
  ├── database/                 # DB connection
  ├── docbuild/                 # Document building (GRN etc.)
  ├── exporter/                 # CSV/XLSX/PDF export
  ├── handler/                  # HTTP handlers (report_run, import_template)
  ├── middleware/               # Auth middleware
  ├── model/                    # Report run models
  └── payload/                  # Request/response payloads
  ```
- **Workers**: Report renderer, cleanup

### 6. ai-accounting-landing (Marketing Site)
- **Path**: `D:/workspace/ai-acc/ai-accounting-landing/`
- **Technology**: Next.js
- **Responsibility**: Marketing/landing page
- **Files**: 2,544

---

## Architecture Pattern

```
┌─────────────────┐     ┌──────────────────┐
│  ai-accounting  │     │  acc-control     │
│  -web (Next.js) │────▶│  -plane-api (Go) │
└────────┬────────┘     └────────┬─────────┘
         │                       │
         ▼                       ▼
┌─────────────────┐     ┌──────────────────┐
│  ai-accounting  │◀───▶│  Control Plane   │
│  -core (Go API) │     │  DB (PostgreSQL) │
└────────┬────────┘     └──────────────────┘
         │
         ▼
┌─────────────────┐     ┌──────────────────┐
│  PostgreSQL     │     │  account-report  │
│  (Main DB)      │◀───▶│  -api (Go)       │
└─────────────────┘     └────────┬─────────┘
                                 │
                                 ▼
                        ┌──────────────────┐
                        │  LiteLLM Gateway │
                        │  (OCR/LLM)       │
                        └──────────────────┘
```

## External Dependencies

| Service | Purpose | Protocol |
|---------|---------|----------|
| PostgreSQL | Main database | SQL |
| LiteLLM Gateway | OCR extraction, LLM assistant | HTTP |
| Qdrant | RAG knowledge base (legal KB) | HTTP |
| MinIO | File storage (documents, reports) | S3 |
| Google OIDC | Social login | OAuth2 |
| LDAP | Enterprise auth | LDAP |
| Control Plane API | Tenant management, billing | HTTP |

---

## Module Classification

| Module | Backend Handlers | Frontend Pages | Status |
|--------|-----------------|----------------|--------|
| Auth & Users | auth, user, onboarding | login, signup, forgot-password, settings/users | ACTIVE |
| Company & Tenants | company, tenant, office, control_tenant_mapping | settings/companies, settings/company, settings/office | ACTIVE |
| Chart of Accounts | account, coa_template, coa_mapping | accounts/* | ACTIVE |
| Sales | sales, sales_order, quotation, receipt, credit_debit_note, billing, delivery_order | sales/* | ACTIVE |
| Purchases | purchase, purchase_order, purchase_invoice_flow, purchase_payment, grn, vendor_credit_debit_note | purchases/* | ACTIVE |
| Journal | journal, recurring_journal | journal/* | ACTIVE |
| Tax/VAT | tax, tax_config, vat_filing, pp36_filing | tax/* | ACTIVE |
| Tax/WHT | tax (wht), wht_certificate, wht50tvi, wht_export | tax/wht/* | ACTIVE |
| Bank | bank (accounts, transactions, reconciliation, statements) | bank/* | ACTIVE |
| Fixed Assets | fixed_asset | assets/*, fixed-assets | ACTIVE |
| Payroll | employee, payroll, salary_structure, deduction, leave | payroll/* | ACTIVE |
| Stock/Inventory | stock, warehouse, stock_transfer, stock_count, landed_cost | products/inventory, products/warehouses, etc. | PARTIAL (backend complete, frontend partial) |
| Documents/OCR | document, document_workflow, ocr | documents/* | ACTIVE |
| Reports | report, stat_report, report_run | reports/* | ACTIVE |
| Dashboard | dashboard | / (home) | ACTIVE |
| Settings | setup, document_number_settings, posting_template, system_config, tax_config, ai_config | settings/* | ACTIVE |
| Billing/Subscription | billing, entitlement | settings/billing | ACTIVE |
| Year-End | year_end_closing | reports/year-end | ACTIVE |
| Monthly Close | monthly_close | accounting/monthly-close | ACTIVE |
| Migration | (document service) | migration/* | ACTIVE |
| AI | llm_assistant, posting_advisor, tax_advisor, classification | ai/* | ACTIVE |
| Audit | audit_log, audit_export | system/audit-logs | ACTIVE |
