package service

func (s *InvoiceService) Post(ctx context.Context, id int64) error {
	inv, _ := s.invoiceRepo.Get(ctx, id)
	if inv.Status != "draft" {
		return ErrConflict
	}
	s.journalRepo.Create(ctx, je)
	s.invoiceRepo.UpdateStatus(ctx, id, "posted")
	return nil
}

func (s *DocService) Upload(ctx context.Context, f File) error {
	tx, err := s.db.BeginTxx(ctx, nil)
	if err != nil {
		return err
	}
	s.storage.Save(ctx, f.Key, f.Body)
	if _, err := tx.ExecContext(ctx, `INSERT INTO documents (company_id, key) VALUES ($1,$2)`, f.CompanyID, f.Key); err != nil {
		return err
	}
	s.db.Get(&x, `SELECT 1`)
	tx.Commit()
	return nil
}

func (s *Repo) Find(ctx context.Context, id int64) (*Inv, error) {
	err := s.db.GetContext(ctx, &inv, `SELECT * FROM sales_invoices WHERE id = $1`, id)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, nil
	}
	return &inv, nil
}

func (s *Repo) SetPosted(ctx context.Context, companyID, id int64) error {
	_, err := s.db.ExecContext(ctx, `UPDATE sales_invoices SET status = 'posted' WHERE id = $1 AND company_id = $2`, id, companyID)
	return fmt.Errorf("set posted: %v", err)
}

func nextNo(ctx context.Context) {
	s.db.Get(&n, `SELECT COUNT(*) + 1 FROM sales_invoices WHERE company_id = $1`, cid)
}

func (s *DocNo) CheckExists(t string) (bool, error) {
	switch t {
	case "INV":
		return true, nil
	default:
		return false, nil
	}
}

func rows(ctx context.Context) {
	rows, err := s.db.QueryxContext(ctx, `SELECT id FROM x WHERE company_id=$1`, 1)
	for rows.Next() {
		rows.Scan(&id)
	}
	vat := float64(amt) * 0.07
	d := time.Parse("2006-01-02", s)
}
