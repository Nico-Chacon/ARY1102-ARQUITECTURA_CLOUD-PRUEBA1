variable "aws_region" {
  description = "Region de AWS"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre del proyecto (prefijo de todos los recursos)"
  type        = string
  default     = "chacon-freshbox"
}

variable "owner_name" {
  description = "Tu nombre/apellido (tag Owner)"
  type        = string
  default     = "Chacon"
}

variable "vpc_cidr" {
  description = "CIDR de la VPC (segun caso FreshBox: /22)"
  type        = string
  default     = "10.0.0.0/22"
}

variable "ami_id" {
  description = "AMI personalizada (dejar vacio para usar Amazon Linux 2023 ARM64 mas reciente)"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "Nombre del Key Pair EC2 (crealo en la consola AWS antes del apply, opcional)"
  type        = string
  default     = "chacon-freshbox-key"
}

variable "instance_type" {
  description = "Tipo de instancia EC2 (App y Data). Segun el caso: t4g.small"
  type        = string
  default     = "t4g.small"
}

# ---- Base de datos (EC2 MySQL) ----
variable "db_root_password" {
  description = "Password root de MySQL (pasar vía TF_VAR_db_root_password / secret, NUNCA commitear)"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Password del usuario de aplicacion MySQL (pasar vía TF_VAR_db_password / secret)"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Nombre de la base de datos (debe coincidir con app/db/init.sql)"
  type        = string
  default     = "freshbox"
}

variable "db_username" {
  description = "Usuario de aplicacion de MySQL"
  type        = string
  default     = "alumno"
}

# ---- Notificaciones / gobierno ----
variable "email_sns" {
  description = "Correo para notificaciones SNS (Budgets + CloudWatch)"
  type        = string
}

variable "backup_iam_role_arn" {
  description = "ARN del rol IAM para AWS Backup (usa LabRole de AWS Academy)"
  type        = string
  default     = ""
}

# ---- Control financiero ----
variable "monthly_budget_usd" {
  type    = string
  default = "100"
}

variable "ec2_budget_usd" {
  type    = string
  default = "60"
}

variable "enable_budgets" {
  description = "Poner en false si tu cuenta de Academy no permite AWS Budgets"
  type        = bool
  default     = true
}
