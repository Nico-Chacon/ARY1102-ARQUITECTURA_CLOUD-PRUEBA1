output "monthly_budget_name" {
  value = var.enable_budgets ? aws_budgets_budget.monthly_total[0].name : null
}
