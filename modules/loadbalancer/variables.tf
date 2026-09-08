variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}

variable "public_subnets" {
  description = "IDs de las subredes publicas"
  type        = list(string)
}

variable "alb_sg_id" {
  description = "ID del Security Group del ALB"
  type        = string
}

variable "common_tags" {
  description = "Tags comunes obligatorios"
  type        = map(string)
  default     = {}
}
