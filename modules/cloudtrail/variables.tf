variable "project_name" {
  type = string
}

variable "account_id" {
  type = string
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
