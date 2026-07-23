output "public_load_balancer_arn" {
  value = aws_lb.public.arn
}

output "public_load_balancer_dns_name" {
  value = aws_lb.public.dns_name
}

output "public_load_balancer_arn_suffix" {
  value = aws_lb.public.arn_suffix
}

output "public_listener_arn" {
  value = aws_lb_listener.public.arn
}

output "open_webui_target_group_arn" {
  value = aws_lb_target_group.open_webui.arn
}

output "open_webui_target_group_arn_suffix" {
  value = aws_lb_target_group.open_webui.arn_suffix
}

output "grafana_target_group_arn" {
  value = aws_lb_target_group.grafana.arn
}

output "grafana_target_group_arn_suffix" {
  value = aws_lb_target_group.grafana.arn_suffix
}

output "ollama_target_group_arn" {
  value = aws_lb_target_group.ollama.arn
}

output "ollama_target_group_arn_suffix" {
  value = aws_lb_target_group.ollama.arn_suffix
}

output "prometheus_target_group_arn" {
  description = "Prometheus target group ARN"
  value       = aws_lb_target_group.prometheus.arn
}

output "alertmanager_target_group_arn" {
  description = "Alertmanager target group ARN"
  value       = aws_lb_target_group.alertmanager.arn
}

output "internal_load_balancer_dns_name" {
  description = "Shared internal load balancer DNS name"
  value       = aws_lb.internal.dns_name
}

output "internal_load_balancer_arn" {
  description = "Shared internal load balancer ARN"
  value       = aws_lb.internal.arn
}

output "internal_load_balancer_arn_suffix" {
  description = "Shared internal load balancer ARN suffix"
  value       = aws_lb.internal.arn_suffix
}