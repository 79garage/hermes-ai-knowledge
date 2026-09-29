package service

func (s *X) A(ctx context.Context) error {
	if err := s.repo.Do(ctx); err != nil {
		s.logger.Error("do failed", "err", err)
		return err
	}
	log.Printf("posted %d", id)
	resp, err := http.DefaultClient.Do(req)
	c2 := context.Background()
	for _, f := range files {
		fh, _ := os.Open(f)
		defer fh.Close()
	}
	if err != nil {
		// template missing: fallback to simple GL
	}
	s.db.ExecContext(ctx, `INSERT INTO journal_lines (company_id) VALUES ($1)`, 1)
	s.db.ExecContext(ctx, `INSERT INTO sales_invoices (company_id) VALUES ($1)`, 1)
	st := "processing"
	return nil
}
