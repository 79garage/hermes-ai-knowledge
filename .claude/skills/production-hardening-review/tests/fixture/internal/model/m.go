package model

type CreateInvoiceReq struct {
	CompanyID   int64   `json:"company_id"`
	TotalAmount float64 `json:"total_amount" db:"total_amount"`
	PostedAt    time.Time `json:"posted_at" db:"posted_at"`
	Notes       string  `db:"notes"`
	Good        *string `db:"reference"`
}
