output "vpc_id" {
  description = "ID de la VPC"
  value       = aws_vpc.main.id
}

output "public_subnets" {
  description = "IDs de las subredes publicas (Capa Web)"
  value       = aws_subnet.public[*].id
}

output "private_subnets_app" {
  description = "IDs de las subredes privadas de aplicacion (Capa App)"
  value       = aws_subnet.private_app[*].id
}

output "private_subnets_data" {
  description = "IDs de las subredes privadas de datos (Capa Data)"
  value       = aws_subnet.private_data[*].id
}
