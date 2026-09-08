output "alb_sg_id" {
  description = "ID del Security Group del ALB"
  value       = aws_security_group.alb.id
}

output "app_sg_id" {
  description = "ID del Security Group de las EC2 App"
  value       = aws_security_group.app.id
}

output "db_sg_id" {
  description = "ID del Security Group de la EC2 MySQL"
  value       = aws_security_group.db.id
}
