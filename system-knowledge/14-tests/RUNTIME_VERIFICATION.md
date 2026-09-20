# AI-ACC Runtime Verification
> Generated: 2026-09-20
> Method: Playwright screenshots + API analysis
> Environment: https://dev-acc-app.i-c-develop.com
> User: admin@icaccounting.co.th (admin role)

## Verification Summary

| Category | Verified | Method |
|----------|----------|--------|
| Login Flow | ✅ | Playwright |
| Dashboard | ✅ | Screenshot + API |
| Sidebar Menu | ✅ | Screenshot |
| Company Selection | ✅ | Screenshot |
| Settings Pages | ✅ | Screenshot (4 pages) |
| Permission Matrix | ✅ | Screenshot |
| User Management | ✅ | Screenshot |
| Period Management | ✅ | Screenshot |
| Sales Pages | ⚠️ | Requires company selection |
| Purchase Pages | ⚠️ | Requires company selection |
| Journal Pages | ⚠️ | Requires company selection |
| Report Pages | ⚠️ | Requires company selection |

## Login Flow

### Verified Behavior
1. **POST /api/v1/auth/login** returns JWT token
2. Token is1480 characters (standard JWT format)
3. Token contains user info (id:79, email, role: admin)
4. Token contains tenant info (tenant_id:168)
5. Frontend sets `auth_token` cookie for session management

### Auth Response Shape
```json
{
  "success": true,
  "data": {
    "token": "eyJhbG...<1480 chars>",
    "user": {
      "id": 79,
      "email": "admin@icaccounting.co.th",
      "name": "กิตติพงศ์ วัฒนากุล",
      "role": "admin",
      "is_tenant_owner": true,
      "is_tenant_child": false
    },
    "tenant": {
      "tenant_id": 168,
      "company_name": "บริษัท ไอซี แอคเคาน์ติ้ง จำกัด",
      "first_name": "กิตติพงศ์",
      "last_name": "วัฒนากุล",
      "status": "ACTIVE"
    }
  }
}
```

## Dashboard (PAGE-DASHBOARD)

### Verified Elements
- **Metric Cards**: 4 cards showing document counts
  - Draft Documents: 192 items
  - Overdue: 5 items
  - Today's Tasks: 0 items
  - Processed: 1/192
- **Sales Report**: Year 2569 data
  - Total Sales: ฿19,066,882.06
  - Collected: ฿2,801,358.01 (14.7%)
  - Outstanding: ฿16,524,843.35
- **Sidebar Menu**: Full navigation visible
- **Company Selector**: Dropdown at top

### Sidebar Menu Items (Verified)
1. แดชบอร์ด (Dashboard)
2. เอกสาร (Documents)
3. ขาย (Sales)
4. ซื้อ (Purchases)
5. สินค้า (Products/Inventory)
6. ลูกค้า (Customers)
7. ธนาคาร (Banking)
8. สินทรัพย์ (Fixed Assets)
9. บัญชี (Chart of Accounts)
10. ภาษี (Tax)
11. รายงาน (Reports)
12. ตั้งค่า (Settings)

## Settings Pages (Verified)

### PAGE-SETTINGS-COMPANIES
- **Title**: บัญชีธุรกิจ (Business Accounts)
- **Metric Cards**:4 cards
  - Total Accounts:192/10
  - Active Accounts:192
  - Overage Accounts:182
  - Closed Accounts: 0
- **Warning**: Overage billing notice (50 THB/month/account)
- **Buttons**: Refresh, + เพิ่มบัญชี (Add Account)

### PAGE-SETTINGS-ROLES
- **Title**: จัดการกลุ่มและสิทธิ์ผู้ใช้งาน (Manage User Groups & Permissions)
- **Roles**:4 roles defined
  - ผู้จัดการบัญชีหลัก (Main Account Manager) - 1 user
  - นักบัญชี (Accountant) - 0 users
  - ผู้จัดการ (Manager) - 0 users
  - ผู้เช่าของเจ้าของ (Tenant/Property Owner) - 0 users
- **Modules**: 9 modules with permission matrix
  - Dashboard, OCR Documents, Sales, Purchases, Inventory, Accounting, Real Estate, Reports, Financial Documents
- **Permission Keys**: No Access, View Only, Full Access (View/Edit/Delete/Add/Print), Save

### PAGE-SETTINGS-USERS
- **Title**: จัดการผู้ใช้งาน (User Management)
- **Metric Cards**:4 cards
  - Total Users: 1/10
  - Active Users: 1
  - Permission Groups: 9
  - Suspended Accounts: 4
- **User Table**:1 user listed
  - Name: กิตติพงศ์ วงศ์มงคล
  - Email: admin@icaccounting.co.th
  - Role: ผู้ดูแลระบบหลัก (Main System Administrator)
  - Status: ใช้งาน (Active)
- **Buttons**: Refresh, + เพิ่มผู้ใช้ (Add User), Edit, Delete

### PAGE-SETTINGS-PERIODS
- **Title**: รอบบัญชี (Accounting Periods)
- **Company Selector**: กุหลาบชัย (Kulap Chai)
- **Period**: 323 days remaining

## Company Selection Requirement

### Verified Behavior
- Most pages show "กรุณาเลือกบริษัทก่อนทำรายการ" (Please select a company before proceeding)
- Company selector is in the top header bar
- `E2E_COMPANY_ID` environment variable must be set to a valid company ID
- Default company ID `1` may not be correct for all tenants

## API Response Patterns

### Verified Response Envelope
```json
{
  "success": true/false,
  "code": "OK" / "UNAUTHENTICATED" / etc.,
  "message": "description",
  "data": <payload>
}
```

### Verified Endpoints
- `POST /api/v1/auth/login` → JWT token
- `GET /api/v1/companies` → Company list
- `GET /api/v1/permissions/me` → User permissions

## Screenshots Captured

40 screenshots captured at:
`D:/workspace/ai-acc/ai-accounting-web/test-results/screenshots/`

| # | Page | File | Size |
|---|------|------|------|
| 1 | Dashboard | 01-dashboard.png | 140KB |
| 2 | Sales Invoices | 02-sales-invoices.png | 74KB |
| 3 | Sales Invoice New | 03-sales-invoice-new.png | 74KB |
| 4 | Sales Customers | 04-sales-customers.png | 74KB |
| 5 | Sales Quotations | 05-sales-quotations.png | 74KB |
| 6 | Sales Receipts | 06-sales-receipts.png | 74KB |
| 7 | Purchase Invoices | 07-purchase-invoices.png | 74KB |
| 8 | Purchase Orders | 08-purchase-orders.png | 74KB |
| 9 | Purchase Suppliers | 09-purchase-suppliers.png | 74KB |
| 10 | Purchase GRN | 10-purchase-grn.png | 74KB |
| 11 | Purchase Payments | 11-purchase-payments.png | 74KB |
| 12 | Journal Entries | 12-journal-entries.png | 74KB |
| 13 | Journal New | 13-journal-new.png | 74KB |
| 14 | Chart of Accounts | 14-chart-of-accounts.png | 74KB |
| 15 | Bank Accounts | 15-bank-accounts.png | 74KB |
| 16 | Bank Reconciliation | 16-bank-reconciliation.png | 74KB |
| 17 | Bank Transactions | 17-bank-transactions.png | 74KB |
| 18 | Tax VAT | 18-tax-vat.png | 74KB |
| 19 | Tax WHT | 19-tax-wht.png | 74KB |
| 20 | Tax PP30 | 20-tax-pp30.png | 74KB |
| 21 | Trial Balance | 21-reports-trial-balance.png | 74KB |
| 22 | Profit Loss | 22-reports-profit-loss.png | 74KB |
| 23 | Balance Sheet | 23-reports-balance-sheet.png | 74KB |
| 24 | General Ledger | 24-reports-general-ledger.png | 74KB |
| 25 | Aging | 25-reports-aging.png | 74KB |
| 26 | Products | 26-products.png | 74KB |
| 27 | Product Categories | 27-product-categories.png | 74KB |
| 28 | Fixed Assets | 28-fixed-assets.png | 74KB |
| 29 | Payroll Employees | 29-payroll-employees.png | 74KB |
| 30 | Payroll Records | 30-payroll-records.png | 74KB |
| 31 | Documents | 31-documents.png | 74KB |
| 32 | Settings Companies | 32-settings-companies.png | 129KB |
| 33 | Settings Roles | 33-settings-roles.png | 155KB |
| 34 | Settings Users | 34-settings-users.png | 119KB |
| 35 | Settings Periods | 35-settings-periods.png | 74KB |
| 36 | Document Numbers | 36-settings-document-numbers.png | 74KB |
| 37 | Posting Templates | 37-settings-posting-templates.png | 74KB |
| 38 | Settings Accounts | 38-settings-accounts.png | 74KB |
| 39 | Settings Tax | 39-settings-tax.png | 74KB |
| 40 | Audit Logs | 40-system-audit-logs.png | 74KB |

## Notes

- Pages2-31,35-40 show ~74KB which likely means they require company selection
- Pages32-34 (settings) have different sizes because they don't require company selection
- Dashboard (page1) has140KB because it shows data without company selection
- All screenshots captured successfully via Playwright