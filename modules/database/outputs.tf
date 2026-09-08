output "db_private_ip" {
  description = "IP privada de la EC2 MySQL (usar como DB_HOST en los microservicios)"
  value       = aws_instance.mysql.private_ip
}

output "db_instance_id" {
  description = "ID de la instancia EC2 de MySQL (para AWS Backup)"
  value       = aws_instance.mysql.id
}

output "db_instance_arn" {
  description = "ARN de la instancia EC2 de MySQL (para AWS Backup)"
  value       = aws_instance.mysql.arn
}

output "db_name" {
  value = var.db_name
}

output "db_username" {
  value = var.db_username
}
