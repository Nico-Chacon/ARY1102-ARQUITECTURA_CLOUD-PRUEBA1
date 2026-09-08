variable "project_name" {
  description = "Nombre del proyecto (prefijo de todos los recursos)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR de la VPC (segun caso FreshBox: /22)"
  type        = string
}

variable "common_tags" {
  description = "Tags comunes obligatorios"
  type        = map(string)
  default     = {}
}
