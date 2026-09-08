variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "db_subnet_id" {
  description = "ID de la subred privada Data (AZ1a) donde va la EC2 MySQL"
  type        = string
}

variable "db_sg_id" {
  description = "ID del Security Group de la EC2 MySQL"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia (segun caso: t4g.small, ARM Graviton)"
  type        = string
  default     = "t4g.small"
}

variable "ami_id" {
  description = "AMI personalizada (opcional, vacio = Amazon Linux 2023 ARM mas reciente)"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "Key Pair EC2 (opcional, para SSH de respaldo)"
  type        = string
  default     = ""
}

variable "db_root_password" {
  description = "Password root de MySQL"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "Usuario de aplicacion para MySQL"
  type        = string
  default     = "alumno"
}

variable "db_password" {
  description = "Password del usuario de aplicacion"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Nombre de la base de datos (debe coincidir con init.sql: freshbox)"
  type        = string
  default     = "freshbox"
}

variable "common_tags" {
  description = "Tags comunes obligatorios"
  type        = map(string)
  default     = {}
}
