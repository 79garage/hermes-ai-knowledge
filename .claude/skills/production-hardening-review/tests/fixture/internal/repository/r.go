package repository

func (r *R) Ins(ctx context.Context) error {
	_, err := r.db.ExecContext(ctx, `INSERT INTO journal_lines (company_id) VALUES ($1)`, 1)
	_, err = r.db.ExecContext(ctx, `INSERT INTO sales_invoices (company_id) VALUES ($1)`, 1)
	return err
}
