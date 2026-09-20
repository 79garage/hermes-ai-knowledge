# AI-ACC Field Registry
> Generated: 2026-09-20
> Source: Screenshot analysis + Source code
> Confidence: HIGH (runtime + code)

## Dashboard Fields

### PAGE-DASHBOARD
| Field ID | Label | Type | Source | Notes |
|----------|-------|------|--------|-------|
| FIELD-DASH-DRAFT-COUNT | เอกสารทั้งหมด (Draft Documents) | metric | API | Count of draft documents |
| FIELD-DASH-OVERDUE | เลยกำหนด (Overdue) | metric | API | Count of overdue items |
| FIELD-DASH-TODAY | งานในวันนี้ (Today's Tasks) | metric | API | Count of today's tasks |
| FIELD-DASH-PROCESSED | ผู้เข้าไปแล้ว (Processed) | metric | API | Processed/Total ratio |
| FIELD-DASH-TOTAL-SALES | ใบเสร็จรับเงินปี 2569 (Total Sales) | currency | API | ฿19,066,882.06 |
| FIELD-DASH-COLLECTED | รับเงินลูกค้า (Collected) | currency | API | ฿2,801,358.01 (14.7%) |
| FIELD-DASH-OUTSTANDING | ค้างชำระทั้งหมด (Outstanding) | currency | API | ฿16,524,843.35 |

---

## Settings Fields

### PAGE-SETTINGS-COMPANIES
| Field ID | Label | Type | Source | Notes |
|----------|-------|------|--------|-------|
| FIELD-COMP-TOTAL | บัญชีทั้งหมด (Total Accounts) | metric | API | 192/10 |
| FIELD-COMP-ACTIVE | บัญชีที่ใช้งาน (Active Accounts) | metric | API | 192 |
| FIELD-COMP-OVERAGE | บัญชีที่ใช้งานมากกว่า (Overage) | metric | API | 182 |
| FIELD-COMP-CLOSED | บัญชีปิดบัญชี (Closed) | metric | API | 0 |

### PAGE-SETTINGS-USERS
| Field ID | Label | Type | Source | Notes |
|----------|-------|------|--------|-------|
| FIELD-USR-TOTAL | ผู้ใช้ทั้งหมด (Total Users) | metric | API | 1/10 |
| FIELD-USR-ACTIVE | ผู้ใช้ที่ทำงาน (Active) | metric | API | 1 |
| FIELD-USR-GROUPS | กลุ่มของสิทธิ์ (Permission Groups) | metric | API | 9 |
| FIELD-USR-SUSPENDED | บัญชีที่ระงับ (Suspended) | metric | API | 4 |
| FIELD-USR-NAME | ชื่อ (Name) | text | API | กิตติพงศ์ วงศ์มงคล |
| FIELD-USR-EMAIL | อีเมล (Email) | email | API | admin@icaccounting.co.th |
| FIELD-USR-ROLE | บัญชี (Role) | select | API | ผู้ดูแลระบบหลัก |
| FIELD-USR-STATUS | สถานะ (Status) | badge | API | ใช้งาน (Active) |

### PAGE-SETTINGS-ROLES
| Field ID | Label | Type | Source | Notes |
|----------|-------|------|--------|-------|
| FIELD-ROLE-NAME | บทบาท (Role Name) | text | API | 4 roles defined |
| FIELD-ROLE-MEMBERS | จำนวนสมาชิก (Members) | metric | API | 0-1 per role |
| FIELD-ROLE-PERMISSION | สิทธิ์ (Permission) | checkbox | API | Per module per role |

---

## Sales Fields (from code analysis)

### PAGE-SALES-INVOICES
| Field ID | Label | Type | Required | API Field | DB Column | Notes |
|----------|-------|------|----------|-----------|-----------|-------|
| FIELD-SINV-NO | เลขที่ใบแจ้งหนี้ (Invoice No) | text | generated | invoice_no | invoice_no | Auto-generated |
| FIELD-SINV-DATE | วันที่ (Date) | date | ✅ | date | date | |
| FIELD-SINV-DUE-DATE | วันครบกำหนด (Due Date) | date | - | due_date | due_date | |
| FIELD-SINV-CUSTOMER | ลูกค้า (Customer) | select | ✅ | customer_id | customer_id | FK to customers |
| FIELD-SINV-SUBTOTAL | ยอดรวม (Subtotal) | currency | auto | subtotal | subtotal | Calculated |
| FIELD-SINV-VAT | ภาษีมูลค่าเพิ่ม (VAT) | currency | auto | vat_amount | vat_amount | 7% of subtotal |
| FIELD-SINV-TOTAL | ยอดรวมทั้งสิ้น (Total) | currency | auto | total_amount | total_amount | subtotal + vat |
| FIELD-SINV-STATUS | สถานะ (Status) | badge | auto | status | status | draft/approved/cancelled |
| FIELD-SINV-NOTES | หมายเหตุ (Notes) | textarea | - | notes | notes | |
| FIELD-SINV-LINE-DESC | รายการ (Description) | text | ✅ | description | description | Line item |
| FIELD-SINV-LINE-QTY | จำนวน (Quantity) | number | ✅ | quantity | quantity | |
| FIELD-SINV-LINE-PRICE | ราคา (Unit Price) | currency | ✅ | unit_price | unit_price | |
| FIELD-SINV-LINE-AMT | จำนวนเงิน (Amount) | currency | auto | amount | amount | qty × price |
| FIELD-SINV-LINE-VAT-RATE | อัตรา VAT (VAT Rate) | number | auto | vat_rate | vat_rate | Default 7% |
| FIELD-SINV-LINE-WHT-RATE | อัตรา WHT (WHT Rate) | number | - | wht_rate | wht_rate | 0-5% |

### PAGE-SALES-CUSTOMERS
| Field ID | Label | Type | Required | API Field | DB Column | Notes |
|----------|-------|------|----------|-----------|-----------|-------|
| FIELD-CUST-NAME | ชื่อลูกค้า (Name) | text | ✅ | name | name | |
| FIELD-CUST-TAX-ID | เลขประจำตัวผู้เสียภาษี (Tax ID) | text | - | tax_id | tax_id | 13 digits |
| FIELD-CUST-ADDRESS | ที่อยู่ (Address) | textarea | - | address | address | |
| FIELD-CUST-PHONE | โทรศัพท์ (Phone) | text | - | phone | phone | |
| FIELD-CUST-EMAIL | อีเมล (Email) | email | - | email | email | |
| FIELD-CUST-TYPE | ประเภท (Type) | select | - | customer_type | customer_type | individual/juristic |
| FIELD-CUST-BRANCH | สาขา (Branch) | text | - | branch_code | branch_code | |

---

## Purchase Fields (from code analysis)

### PAGE-PURCHASE-INVOICES
| Field ID | Label | Type | Required | API Field | DB Column | Notes |
|----------|-------|------|----------|-----------|-----------|-------|
| FIELD-PINV-NO | เลขที่ใบซื้อ (Invoice No) | text | generated | invoice_no | invoice_no | Auto-generated |
| FIELD-PINV-DATE | วันที่ (Date) | date | ✅ | date | date | |
| FIELD-PINV-SUPPLIER | ซัพพลายเออร์ (Supplier) | select | ✅ | supplier_id | supplier_id | FK to suppliers |
| FIELD-PINV-SUBTOTAL | ยอดรวม (Subtotal) | currency | auto | subtotal | subtotal | |
| FIELD-PINV-VAT | ภาษีซื้อ (Input VAT) | currency | auto | vat_amount | vat_amount | |
| FIELD-PINV-TOTAL | ยอดรวมทั้งสิ้น (Total) | currency | auto | total_amount | total_amount | |
| FIELD-PINV-STATUS | สถานะ (Status) | badge | auto | status | status | draft/posted/cancelled |

---

## Journal Fields (from code analysis)

### PAGE-JOURNAL-ENTRIES
| Field ID | Label | Type | Required | API Field | DB Column | Notes |
|----------|-------|------|----------|-----------|-----------|-------|
| FIELD-JRN-NO | เลขที่ Journal (Entry No) | text | generated | entry_no | entry_no | Auto-generated |
| FIELD-JRN-DATE | วันที่ (Date) | date | ✅ | date | date | |
| FIELD-JRN-DESC | รายละเอียด (Description) | text | ✅ | description | description | |
| FIELD-JRN-STATUS | สถานะ (Status) | badge | auto | status | status | draft/posted/cancelled/reversed |
| FIELD-JRN-LINE-ACCT | บัญชี (Account) | select | ✅ | account_id | account_id | FK to accounts |
| FIELD-JRN-LINE-DEBIT | เดบิต (Debit) | currency | conditional | debit | debit | Must be > 0 if debit |
| FIELD-JRN-LINE-CREDIT | เครดิต (Credit) | currency | conditional | credit | credit | Must be > 0 if credit |

---

## Tax Fields (from code analysis)

### PAGE-TAX-VAT
| Field ID | Label | Type | Required | API Field | DB Column | Notes |
|----------|-------|------|----------|-----------|-----------|-------|
| FIELD-VAT-PERIOD | งวด (Period) | text | ✅ | period | period | YYYY-MM format |
| FIELD-VAT-TYPE | ประเภท (Type) | select | ✅ | type | type | input/output |
| FIELD-VAT-AMOUNT | จำนวนเงิน (Amount) | currency | ✅ | amount | amount | |
| FIELD-VAT-TAX | ภาษี (Tax) | currency | ✅ | tax_amount | tax_amount | 7% |
| FIELD-VAT-REF | อ้างอิง (Reference) | text | - | reference | reference | Invoice no |
| FIELD-VAT-STATUS | สถานะ (Status) | badge | auto | status | status | draft/posted/filed |

---

## Bank Fields (from code analysis)

### PAGE-BANK-ACCOUNTS
| Field ID | Label | Type | Required | API Field | DB Column | Notes |
|----------|-------|------|----------|-----------|-----------|-------|
| FIELD-BANK-NAME | ธนาคาร (Bank Name) | text | ✅ | bank_name | bank_name | |
| FIELD-BANK-ACCT-NO | เลขที่บัญชี (Account No) | text | ✅ | account_no | account_no | |
| FIELD-BANK-ACCT-NAME | ชื่อบัญชี (Account Name) | text | ✅ | account_name | account_name | |
| FIELD-BANK-TYPE | ประเภท (Type) | select | ✅ | account_type | account_type | savings/current |
| FIELD-BANK-BALANCE | ยอดคงเหลือ (Balance) | currency | auto | opening_balance | opening_balance | |

---

## Payroll Fields (from code analysis)

### PAGE-PAYROLL-EMPLOYEES
| Field ID | Label | Type | Required | API Field | DB Column | Notes |
|----------|-------|------|----------|-----------|-----------|-------|
| FIELD-EMP-NAME | ชื่อพนักงาน (Name) | text | ✅ | name | name | |
| FIELD-EMP-POSITION | ตำแหน่ง (Position) | text | ✅ | position | position | |
| FIELD-EMP-SALARY | เงินเดือน (Salary) | currency | ✅ | base_salary | base_salary | |
| FIELD-EMP-START | วันเริ่มงาน (Start Date) | date | ✅ | start_date | start_date | |
| FIELD-EMP-STATUS | สถานะ (Status) | badge | auto | status | status | active/inactive |

---

## Field Confidence Levels

| Level | Count | Description |
|-------|-------|-------------|
| VERIFIED | 40+ | Fields confirmed via screenshots |
| HIGH | 100+ | Fields traced from code + API |
| MEDIUM | 200+ | Fields inferred from model definitions |
| UNKNOWN | 500+ | Fields not yet inventoried (requires page-by-page analysis) |