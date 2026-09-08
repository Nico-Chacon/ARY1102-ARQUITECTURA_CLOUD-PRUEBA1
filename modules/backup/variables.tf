variable "project_name" {
  type = string
}

variable "db_instance_arn" {
  description = "ARN de la EC2 MySQL a respaldar"
  type        = string
}

variable "backup_iam_role_arn" {
  description = "ARN del rol IAM que usara AWS Backup (LabRole en AWS Academy)"
  type        = string
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
