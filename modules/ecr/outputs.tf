output "repo_urls" {
  description = "Mapa servicio -> URL del repositorio ECR"
  value       = { for k, r in aws_ecr_repository.repo : k => r.repository_url }
}

output "repo_names" {
  description = "Mapa servicio -> nombre del repositorio ECR"
  value       = { for k, r in aws_ecr_repository.repo : k => r.name }
}
