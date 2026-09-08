output "alb_dns_name" {
  description = "DNS del ALB - pegar en el navegador para ver la app FreshBox"
  value       = module.loadbalancer.alb_dns_name
}

output "vpc_id" {
  value = module.networking.vpc_id
}

output "db_private_ip" {
  description = "IP privada de la EC2 MySQL (capa Data)"
  value       = module.database.db_private_ip
}

output "asg_name" {
  value = module.compute.asg_name
}

output "sns_topic_arn" {
  value = module.monitoring.sns_topic_arn
}

output "cloudtrail_bucket" {
  value = module.cloudtrail.log_bucket_name
}

output "ecr_repo_urls" {
  description = "URLs de los 5 repositorios ECR (para docker push)"
  value       = module.ecr.repo_urls
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
