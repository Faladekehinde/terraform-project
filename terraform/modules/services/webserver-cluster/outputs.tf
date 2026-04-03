# modules/webserver-cluster/outputs.tf
output "module_version" {
  value = "v0.0.2"  # change to match the module version
}

output "subnet_ids" {
  value = { for name, subnet in aws_subnet.subnets : name => subnet.id }
}

output "alb_dns_name" {
  value       = aws_lb.alb.dns_name
  description = "DNS name of the Application Load Balancer"
}

