package service

func (s *InvoiceService) PostGood(ctx context.Context, companyID, id int64) (err error) {
	tx, err := s.db.BeginTxx(ctx, nil)
	if err != nil {
		return fmt.Errorf("begin: %w", err)
	}
	defer func() { _ = tx.Rollback() }()
	res, err := tx.ExecContext(ctx, `UPDATE sales_invoices SET status = 'posted' WHERE id = $1 AND company_id = $2 AND status = 'draft'`, id, companyID)
	if err != nil {
		return fmt.Errorf("update: %w", err)
	}
	if n, _ := res.RowsAffected(); n == 0 {
		return ErrConflict
	}
	if errors.Is(err, sql.ErrNoRows) {
		return ErrNotFound
	}
	if err := tx.Commit(); err != nil {
		return fmt.Errorf("commit: %w", err)
	}
	return nil
}
