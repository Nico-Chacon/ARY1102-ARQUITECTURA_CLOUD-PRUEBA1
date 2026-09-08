variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_app_subnets" {
  description = "IDs de las subredes privadas App (Multi-AZ)"
  type        = list(string)
}

variable "target_group_arn" {
  type = string
}

variable "app_sg_id" {
  type = string
}

variable "instance_type" {
  description = "Tipo de instancia (segun caso: t4g.small, ARM Graviton)"
  type        = string
  default     = "t4g.small"
}

variable "ami_id" {
  type    = string
  default = ""
}

variable "key_name" {
  type    = string
  default = ""
}

variable "aws_region" {
  type = string
}

variable "account_id" {
  type = string
}

variable "db_host" {
  description = "IP privada de la EC2 MySQL"
  type        = string
}

variable "db_user" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_name" {
  type = string
}

variable "ecr_repo_urls" {
  description = "Mapa servicio -> URL del repo ECR (viene del modulo ecr)"
  type        = map(string)
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
