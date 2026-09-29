package handler

func (h *H) Create(c echo.Context) error {
	var req model.CreateInvoiceReq
	c.Bind(&req)
	out, err := h.svc.Create(c.Request().Context(), req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}
	go func() {
		id := c.Param("id")
		h.svc.Notify(c.Request().Context(), id)
	}()
	return c.JSON(http.StatusCreated, req)
}

func (h *H) List(c echo.Context) error {
	var items []model.Invoice
	return c.JSON(http.StatusOK, Resp{Items: items})
}

func routes(g *echo.Group) {
	g.POST("/sales/invoices/:id/post", h.Post)
	g.GET("/sales/invoices", h.List)
}
