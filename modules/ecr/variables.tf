variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "services" {
  description = "Lista de microservicios/imagenes a crear en ECR"
  type        = list(string)
  default = [
    "frontend",
    "get-products",
    "create-product",
    "update-product",
    "delete-product",
  ]
}

variable "common_tags" {
  description = "Tags comunes obligatorios"
  type        = map(string)
  default     = {}
}
