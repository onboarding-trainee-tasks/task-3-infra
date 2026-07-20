output "load_balancer_arn" {
  description = "The ARN of the load balancer"
  value       = aws_lb.this.arn
}

output "target_group_arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.this.arn
}

output "load_balancer_dns_name" {
  description = "DNS-record of the load balancer"
  value       = aws_lb.this.dns_name
}

output "load_balancer_arn_suffix" {
  value = aws_lb.this.arn_suffix
}

output "target_group_arn_suffix" {
  value = aws_lb_target_group.this.arn_suffix
}