# AI-ACC Database Map
> Generated: 2026-09-20 | Tables: 117 | Source: migrations + schema.sql

## Auth & Users (4 tables)

- `email_verification_tokens`
- `password_reset_tokens`
- `user_companies`
- `users`

## Companies & Tenants (3 tables)

- `companies`
- `control_tenant_mappings`
- `tenants`

## Chart of Accounts (5 tables)

- `accounts`
- `coa_template_accounts`
- `coa_templates`
- `coa_verified_mappings`
- `opening_balances`

## Sales (13 tables)

- `billing_document_lines`
- `billing_documents`
- `credit_debit_notes`
- `customers`
- `delivery_order_lines`
- `delivery_orders`
- `quotation_lines`
- `quotations`
- `receipts`
- `sales_invoice_lines`
- `sales_invoices`
- `sales_order_lines`
- `sales_orders`

## Purchases (11 tables)

- `grn`
- `grn_lines`
- `platform_vendor_templates`
- `purchase_invoice_lines`
- `purchase_invoices`
- `purchase_order_lines`
- `purchase_orders`
- `purchase_payments`
- `suppliers`
- `vendor_credit_debit_notes`
- `vendors`

## Journal & Accounting (16 tables)

- `accounting_periods`
- `carry_forward_records`
- `closing_entries`
- `closing_entry_lines`
- `journal_entries`
- `journal_lines`
- `period_close_checks`
- `period_close_exceptions`
- `period_close_runs`
- `period_close_snapshots`
- `period_reopen_requests`
- `recurring_journal_instances`
- `recurring_journal_lines`
- `recurring_journal_templates`
- `subledger_reconciliations`
- `year_end_closing`

## Tax (7 tables)

- `pp36_filings`
- `tax_configs`
- `vat_filings`
- `vat_records`
- `wht_certificates`
- `wht_filings`
- `wht_records`

## Bank (6 tables)

- `bank_accounts`
- `bank_reconciliation_items`
- `bank_reconciliation_matches`
- `bank_reconciliations`
- `bank_statement_imports`
- `bank_transactions`

## Fixed Assets (3 tables)

- `asset_disposals`
- `depreciation_entries`
- `fixed_assets`

## Payroll (5 tables)

- `deductions`
- `employee_payroll_inputs`
- `employees`
- `payroll_records`
- `salary_structures`

## Stock/Inventory (14 tables)

- `invoice_line_stock_allocations`
- `landed_cost_allocations`
- `landed_costs`
- `stock_adjustment_lines`
- `stock_adjustments`
- `stock_count_lines`
- `stock_counts`
- `stock_layers`
- `stock_moves`
- `stock_opening_batch_lines`
- `stock_opening_batches`
- `stock_transfer_lines`
- `stock_transfers`
- `warehouses`

## Documents/OCR (6 tables)

- `document_number_sequences`
- `document_number_settings`
- `documents`
- `ocr_results`
- `review_events`
- `review_sessions`

## Settings (7 tables)

- `ai_configs`
- `business_type_template_sets`
- `line_item_account_rules`
- `posting_overrides`
- `posting_template_lines`
- `posting_templates`
- `system_configs`

## Audit (4 tables)

- `audit_events`
- `audit_retention_policies`
- `operation_errors`
- `role_audit_events`

## AI (1 tables)

- `ai_training_samples`

## Other (12 tables)

- `company_accounting_profiles`
- `company_close_policies`
- `if`
- `product_categories`
- `products`
- `report_runs`
- `role_permissions`
- `tenant_role_permissions`
- `tenant_roles`
- `units`
- `user_onboarding_events`
- `user_onboarding_profiles`

---
**Total: 117 tables**

## Complete Table List (Alphabetical)

1. `accounting_periods`
2. `accounts`
3. `ai_configs`
4. `ai_training_samples`
5. `asset_disposals`
6. `audit_events`
7. `audit_retention_policies`
8. `bank_accounts`
9. `bank_reconciliation_items`
10. `bank_reconciliation_matches`
11. `bank_reconciliations`
12. `bank_statement_imports`
13. `bank_transactions`
14. `billing_document_lines`
15. `billing_documents`
16. `business_type_template_sets`
17. `carry_forward_records`
18. `closing_entries`
19. `closing_entry_lines`
20. `coa_template_accounts`
21. `coa_templates`
22. `coa_verified_mappings`
23. `companies`
24. `company_accounting_profiles`
25. `company_close_policies`
26. `control_tenant_mappings`
27. `credit_debit_notes`
28. `customers`
29. `deductions`
30. `delivery_order_lines`
31. `delivery_orders`
32. `depreciation_entries`
33. `document_number_sequences`
34. `document_number_settings`
35. `documents`
36. `email_verification_tokens`
37. `employee_payroll_inputs`
38. `employees`
39. `fixed_assets`
40. `grn`
41. `grn_lines`
42. `if`
43. `invoice_line_stock_allocations`
44. `journal_entries`
45. `journal_lines`
46. `landed_cost_allocations`
47. `landed_costs`
48. `line_item_account_rules`
49. `ocr_results`
50. `opening_balances`
51. `operation_errors`
52. `password_reset_tokens`
53. `payroll_records`
54. `period_close_checks`
55. `period_close_exceptions`
56. `period_close_runs`
57. `period_close_snapshots`
58. `period_reopen_requests`
59. `platform_vendor_templates`
60. `posting_overrides`
61. `posting_template_lines`
62. `posting_templates`
63. `pp36_filings`
64. `product_categories`
65. `products`
66. `purchase_invoice_lines`
67. `purchase_invoices`
68. `purchase_order_lines`
69. `purchase_orders`
70. `purchase_payments`
71. `quotation_lines`
72. `quotations`
73. `receipts`
74. `recurring_journal_instances`
75. `recurring_journal_lines`
76. `recurring_journal_templates`
77. `report_runs`
78. `review_events`
79. `review_sessions`
80. `role_audit_events`
81. `role_permissions`
82. `salary_structures`
83. `sales_invoice_lines`
84. `sales_invoices`
85. `sales_order_lines`
86. `sales_orders`
87. `stock_adjustment_lines`
88. `stock_adjustments`
89. `stock_count_lines`
90. `stock_counts`
91. `stock_layers`
92. `stock_moves`
93. `stock_opening_batch_lines`
94. `stock_opening_batches`
95. `stock_transfer_lines`
96. `stock_transfers`
97. `subledger_reconciliations`
98. `suppliers`
99. `system_configs`
100. `tax_configs`
101. `tenant_role_permissions`
102. `tenant_roles`
103. `tenants`
104. `units`
105. `user_companies`
106. `user_onboarding_events`
107. `user_onboarding_profiles`
108. `users`
109. `vat_filings`
110. `vat_records`
111. `vendor_credit_debit_notes`
112. `vendors`
113. `warehouses`
114. `wht_certificates`
115. `wht_filings`
116. `wht_records`
117. `year_end_closing`