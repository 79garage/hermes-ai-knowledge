CREATE TABLE sales_invoices (
  id BIGSERIAL PRIMARY KEY,
  company_id BIGINT NOT NULL REFERENCES companies(id),
  customer_id BIGINT NOT NULL REFERENCES customers(id) ON DELETE RESTRICT,
  invoice_no VARCHAR(50) NOT NULL,
  UNIQUE (invoice_no)
);
CREATE UNIQUE INDEX ux_je ON journal_entries (company_id, entry_no);
