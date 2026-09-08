output "alb_dns_name" {
  description = "DNS del ALB - pegar en el navegador para ver la app"
  value       = aws_lb.web.dns_name
}

output "alb_arn" {
  value = aws_lb.web.arn
}

output "alb_arn_suffix" {
  value = aws_lb.web.arn_suffix
}

output "target_group_arn" {
  value = aws_lb_target_group.web.arn
}
