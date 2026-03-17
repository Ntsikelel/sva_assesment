output "sva_secret" {
  description = "Connect Web UI Name:  "
  value       = aws_ssm_parameter.sva_secret.name
}


output "alb_dns" { value = aws_lb.sva_lb.dns_name }