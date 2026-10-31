output "ssh_command" {
  description = "SSH command for the bastion host"
  value       = "ssh -i C:\\Onboarding\\.ssh\\terraform-ssh-key.pem ubuntu@${module.bastion_instance.public_ip}"
}

output "open_webui_url" {
  description = "Public Open WebUI URL"

  value = ("http://${module.alb.public_load_balancer_dns_name}/")
}

output "grafana_url" {
  description = "Public Grafana URL"

  value = ("http://${module.alb.public_load_balancer_dns_name}/grafana/")
}

output "grafana_ecs_service_name" {
  description = "Grafana ECS service name"
  value       = module.grafana_service.service_name
}