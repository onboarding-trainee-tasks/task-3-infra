output "ssh_command" {
  description = "SSH command for the bastion host"
  value       = "ssh -i C:\\Onboarding\\.ssh\\terraform-ssh-key.pem ubuntu@${module.bastion_instance.public_ip}"
}

output "grafana_url" {
  description = "Public Grafana URL"

  value = ("http://${module.alb.public_load_balancer_dns_name}/grafana/")
}

output "ollama_internal_url" {
  description = "Internal Ollama load balancer URL"
  value       = ("http://${module.alb.ollama_load_balancer_dns_name}:11434")
}

output "grafana_ecs_service_name" {
  description = "Grafana ECS service name"
  value       = module.grafana_service.service_name
}

# output "cloud_map_namespace_id" {
#   description = "Cloud Map private namespace ID"
#   value       = module.service_discovery.namespace_id
# }