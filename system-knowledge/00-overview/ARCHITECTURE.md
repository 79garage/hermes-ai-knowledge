# AI-ACC Architecture
> Generated: 2026-09-20 | Confidence: HIGH (static + CodeGraph)

## System Overview

AI-ACC is a Thai accounting software platform with:
- **Multi-tenant** architecture (company → tenant isolation)
- **OCR-powered** document processing (AI extraction)
- **Template-driven** posting engine (Dr/Cr patterns)
- **Full Thai tax compliance** (VAT PP30/PP36, WHT PND1/3/53, certificates)
- **Async report generation** (queue → worker → download)

## Technology Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| Backend API | Go + Echo v4 | Go 1.25 |
| Database | PostgreSQL | 16+ |
| Frontend | Next.js (App Router) | Latest |
| Admin Frontend | Vite + React | Latest |
| Admin Backend | Go + Echo v4 | Go 1.25 |
| Report Service | Go | Go 1.25 |
| ORM/Query | sqlx (raw SQL) | - |
| File Storage | Local FS / MinIO (S3) | - |
| AI Gateway | LiteLLM | - |
| RAG KB | Qdrant | - |
| Cache | Redis (control plane) | - |
| Auth | JWT + LDAP + Google OIDC | - |

## Architecture Pattern

### Layered Architecture (per module)
```
┌─────────────────────────────────────────┐
│              Frontend (Next.js)          │
│  page.tsx → component → hook → lib/api  │
└────────────────────┬────────────────────┘
                     │ HTTP/JSON
┌────────────────────▼────────────────────┐
│           Backend (Echo v4)              │
│  middleware → handler → service → repo   │
└────────────────────┬────────────────────┘
                     │ SQL
┌────────────────────▼────────────────────┐
│           PostgreSQL                     │
└─────────────────────────────────────────┘
```

### Cross-Service Communication
```
ai-accounting-web ──HTTP──▶ ai-accounting-core ──HTTP──▶ account-report-api
                                    │
                                    ├──HTTP──▶ acc-control-plane-api
                                    ├──HTTP──▶ LiteLLM Gateway (OCR/LLM)
                                    └──HTTP──▶ Qdrant (RAG)
```

### Background Processing
```
ai-accounting-core (main process):
  ├── Report artifact cleanup (hourly cron)
  ├── Stranded OCR reaper (5min cron)
  └── AI model config sync (2min poll)

account-report-api (separate process):
  ├── Report render queue worker
  └── Report artifact cleanup
```

## Key Design Decisions

### 1. Template-Driven Posting Engine
Instead of hardcoded Dr/Cr logic in Go, the system uses a **posting template catalog** (60+ templates in migration 152). Each financial event (sale, purchase, receipt, etc.) is matched to a template by `(event_type, conditions)` and rendered into journal lines.

**Flow**: Document → PostingEngine → PostingTemplate → JournalEntry

### 2. 3-Tier Posting Fallback
When creating journal entries, the system tries:
1. **PostingOverride** (reviewer-edited Dr/Cr) — highest priority
2. **PostingEngine** (template catalog) — default
3. **Simple GL** (hardcoded fallback) — if template missing

### 3. Document Review → Entity Auto-Post
When a document (OCR upload) is approved via `SubmitReview`:
1. Entity (sales_invoice/receipt/purchase_invoice) is created with status='draft'
2. `postCreatedEntityTx` auto-posts: status → creates JE using 3-tier pattern
3. All within one atomic transaction

### 4. Multi-Tenant Isolation
- Every table has `company_id` column
- Middleware checks `company_id` from JWT/session
- Control plane manages tenant → company mapping
- API key separates internal (service-to-service) from user-facing routes

### 5. RBAC System
- Role-based permissions stored in `tenant_role_permissions`
- Middleware chain: JWT → Module Access → Permission Check
- Permissions: `module.<name>.view`, `module.<name>.edit`, `bank.reconcile`, `period.close`, `journal.post`, `payroll.approve`, `settings.users.manage`, `settings.company.manage`

### 6. Async Report Generation
Heavy reports (PDF/Excel) go through:
1. `POST /reports/runs` → enqueue job
2. `GET /reports/runs/:token` → poll status
3. `GET /reports/runs/:token/download` → download artifact

## Data Flow Patterns

### Sales Invoice Flow
```
Frontend: /sales/invoices/new → POST /api/v1/sales/invoices
  → SalesHandler.Create
    → SalesService.Create
      → DocumentNumberService.Generate
      → INSERT sales_invoices + lines
      → status = 'draft'

Frontend: POST /api/v1/sales/invoices/:id/post
  → SalesHandler.Post
    → SalesService.Post
      → PostingEngine.Render (or fallback)
      → JournalService.Create + Post
      → VatRecordService.Create (if VAT)
      → WhtRecordService.Create (if WHT)
      → status = 'posted'
```

### Purchase Invoice Flow (New)
```
Frontend: /purchases/invoices/new → POST /api/v1/purchase/invoices
  → PurchaseInvoiceFlowHandler.Create
    → PurchaseInvoiceFlowService.Create
      → INSERT purchase_invoices + lines
      → status = 'draft'

POST /api/v1/purchase/invoices/:id/post
  → PurchaseInvoiceFlowService.Post
    → GRN clearing (if linked to GRN)
    → PostingEngine.Render
    → JournalService.Create + Post
    → VatRecordService.Create
```

### Document OCR Flow
```
Frontend: POST /api/v1/documents/upload
  → DocumentHandler.Upload
    → storage.Save(file)
    → OCRQueue.Enqueue
      → OCRClient.Extract (async)
        → LiteLLM Gateway
        → Parse response
        → Store ocr_results
    → status = 'processing'

Frontend: GET /api/v1/documents/:id/review
  → DocumentHandler.LoadReview
    → Return OCR extracted data

Frontend: POST /api/v1/documents/:id/review
  → DocumentHandler.SubmitReview
    → Create entity (invoice/receipt/purchase)
    → postCreatedEntityTx (auto-post)
    → status = 'reviewed'
```

## Security Architecture

### Authentication
- **JWT**: Primary auth for API (bearer token)
- **LDAP**: Enterprise directory integration
- **Google OIDC**: Social login (redirect flow)
- **API Key**: Internal service-to-service (`/api/v1/internal/*`)

### Authorization Chain
```
Request → CORS → JWT Auth → Subscription Check → Module Access → Permission Check → Handler
```

### Middleware Stack (in order)
1. `CORS` — cross-origin policy
2. `Logger` — request logging
3. `Recover` — panic recovery
4. `JWTAuth` — token validation + user context
5. `RequireActiveSubscription` — billing gate (reads pass through)
6. `OperationErrorLogger` — record 5xx per tenant
7. `RequireModuleAccess` — module-level permission
8. `RequirePermission` — action-level permission (per route)

## File Structure Convention

### Backend (Go)
```
handler/     — HTTP request/response, validation, error mapping
service/     — business logic, transactions, cross-repo orchestration
repository/  — SQL queries, data mapping
model/       — struct definitions (request, response, domain)
middleware/  — request pipeline (auth, RBAC, rate-limit)
```

### Frontend (Next.js)
```
app/         — route pages (App Router)
components/  — reusable UI components
hooks/       — custom React hooks
lib/         — utility functions, API client
types/       — TypeScript type definitions
contexts/    — React context providers
generated/   — auto-generated types (Prisma)
```

## Known Architecture Issues

| Issue | Severity | Description |
|-------|----------|-------------|
| float64 in models | HIGH | Architecture specifies shopspring/decimal but models use float64 — rounding risk |
| Dual purchase paths | MEDIUM | `/purchases/invoices` (legacy) + `/purchase/invoices` (new flow) coexist |
| Migrations compiled | LOW | Migrations embedded in binary — cannot modify without rebuild |
| Stock frontend partial | MEDIUM | Backend complete but frontend pages may be incomplete |
