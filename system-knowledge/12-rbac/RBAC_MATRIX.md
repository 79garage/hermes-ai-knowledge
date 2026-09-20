# AI-ACC RBAC Matrix
> Generated: 2026-09-20 | Confidence: HIGH (code-traced from middleware)

## Permission System Architecture

### Two-Layer Permission Model
1. **Module Access** — Controls visibility of entire modules (menu + API)
   - `module.<name>.view` — Read access to module
   - `module.<name>.edit` — Write access to module
2. **Action Permissions** — Controls specific dangerous actions within modules

### Module Access Middleware
Applied globally via `RequireModuleAccess()` middleware. Maps route prefixes to modules:

| Route Prefix | Module | SharedRead | ReadOnly |
|-------------|--------|------------|----------|
| documents, document-workflows, ocr | documents | - | - |
| sales, quotations, receipts | sales | - | - |
| customers | sales | ✅ | - |
| purchase, purchases | purchases | - | - |
| suppliers | purchases | ✅ | - |
| stock, landed-costs | inventory | - | - |
| warehouses, products, units | inventory | ✅ | - |
| payroll | payroll | - | - |
| bank | bank | - | - |
| journal, accounting | journal | - | - |
| accounts | journal | ✅ | - |
| fixed-assets | assets | - | - |
| tax, wht | tax | - | - |
| reports | reports | - | ✅ |

### Unmapped Prefixes (No Module Access Control)
These routes are accessible to all authenticated users:
- `auth`, `users`, `permissions`, `roles`
- `entitlements`, `billing`
- `companies`, `office`, `settings`, `setup`
- `coa`, `posting-templates`
- `onboarding`
- `tenants`
- `dashboard`

---

## Action Permissions

| Permission Key | Used On | Description |
|---------------|---------|-------------|
| `bank.reconcile` | Bank reconciliation write operations | Create/update/delete reconciliation items, matches, carry-forward |
| `bank.direct_post` | Bank reconciliation direct posting | Post journal entries directly from reconciliation screen |
| `period.close` | Period close/reopen operations | Close periods, lock reconciliations, approve reopen requests |
| `journal.post` | Journal entry posting/reversing | Post draft journals, reverse posted journals |
| `payroll.approve` | Payroll approval/payment | Approve payroll runs, mark as paid, post to GL, SSF remit |
| `settings.company.manage` | Company settings | Update/delete companies, seed defaults, upload logos, manage policies |
| `settings.users.manage` | User management | CRUD users, assign companies, manage roles/permissions |

---

## Module Access Keys

Each module has two permission keys:
- `module.<name>.view` — GET requests
- `module.<name>.edit` — POST/PUT/DELETE requests

| Module | View Key | Edit Key |
|--------|----------|----------|
| documents | `module.documents.view` | `module.documents.edit` |
| sales | `module.sales.view` | `module.sales.edit` |
| purchases | `module.purchases.view` | `module.purchases.edit` |
| inventory | `module.inventory.view` | `module.inventory.edit` |
| payroll | `module.payroll.view` | `module.payroll.edit` |
| bank | `module.bank.view` | `module.bank.edit` |
| journal | `module.journal.view` | `module.journal.edit` |
| assets | `module.assets.view` | `module.assets.edit` |
| tax | `module.tax.view` | `module.tax.edit` |
| reports | `module.reports.view` | N/A (ReadOnly) |

---

## Admin Role

The `admin` role bypasses module access checks:
```go
if role == service.RoleAdminOnlyRole {
    return next(c) // always passes
}
```

---

## Role Management

### System Roles (seeded)
- `admin` — Full access, bypasses module checks
- `user` — Default role, access determined by permission matrix

### Custom Roles
- Stored in `tenant_roles` table
- Per-tenant overrides in `tenant_role_permissions`
- CRUD via `/roles` API
- Audit trail in `role_audit_events`

---

## Permission Check Flow

```
Request → JWT Auth (extract role)
  → RequireActiveSubscription (billing gate)
  → RequireModuleAccess (module.view/edit)
    → IsAllowed(tenantID, role, key)
      → Check tenant_role_permissions (override)
      → Fallback to role_permissions (default)
  → RequirePermission (action-specific)
    → IsAllowed(tenantID, role, key)
```

---

## Security Findings

### CRITICAL
- Bank reconciliation routes originally had NO permission checks — fixed by adding `bank.reconcile` and `period.close` middleware
- Payroll approval routes originally had NO permission checks — fixed by adding `payroll.approve` middleware

### HIGH
- Module access middleware is the backend enforcement for menu visibility — without it, hidden menus could still be accessed via direct API calls
- `SharedRead` flag allows all roles to read master data (customers, suppliers, products) even if their module access is restricted

### MEDIUM
- `settings.company.manage` and `settings.users.manage` are standalone permissions not tied to module access — they gate destructive operations across modules

---

## Tenant Isolation

- Every data query includes `company_id` filter
- `ControlTenantID` extracted from JWT context
- Internal API routes use separate API key authentication
- Control plane manages tenant → company mapping

---

## Evidence

| Finding | Source | Confidence |
|---------|--------|------------|
| Permission keys | main.go RequirePermission calls | VERIFIED |
| Module rules | module_permission.go ModuleRules | VERIFIED |
| Admin bypass | module_permission.go RoleAdminOnlyRole | VERIFIED |
| SharedRead behavior | module_permission.go SharedRead flag | VERIFIED |
| Tenant isolation | middleware/jwt_auth.go + repository queries | HIGH |
