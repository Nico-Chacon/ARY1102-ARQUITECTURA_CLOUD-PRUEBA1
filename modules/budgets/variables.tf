variable "project_name" {
  type = string
}

variable "enable_budgets" {
  type    = bool
  default = true
}

variable "monthly_budget_usd" {
  type    = string
  default = "100"
}

variable "ec2_budget_usd" {
  type    = string
  default = "60"
}

variable "sns_topic_arn" {
  type = string
}
