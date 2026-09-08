variable "project_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "asg_name" {
  type = string
}

variable "alb_arn_suffix" {
  type = string
}

variable "db_instance_id" {
  type = string
}

variable "email_sns" {
  type = string
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
