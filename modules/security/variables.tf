variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR de la VPC (para restringir SSH interno)"
  type        = string
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "common_tags" {
  description = "Tags comunes obligatorios"
  type        = map(string)
  default     = {}
}
