output "alb_dns_name" {
  value       = aws_lb.alb.dns_name
  description = "Load balancer URL"
}

output "asg_name" {
  value       = aws_autoscaling_group.asg.name
  description = "Auto Scaling Group name"
}