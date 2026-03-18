output "sva_secret" {
  description = "Connect Web UI Name:  "
  value       = aws_ssm_parameter.sva_secret.name
}


output "alb_dns" {
  description = "load Balancer DNS address URL :  "
  value       = aws_lb.sva_lb.dns_name
}

output "sva_ubuntu_ami_id" {
  description = "Latest Ubuntu 22.04 image for Web UI Server:  "
  value       = data.aws_ami.sva_ubuntu.id
}