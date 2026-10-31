output "iam_instance_profile_name" {
  description = "Name of the bastion IAM instance profile"
  value       = aws_iam_instance_profile.this.name
}

output "ecs_execution_role_arn" {
  description = "ECS task execution role ARN"
  value       = aws_iam_role.ecs_execution.arn
}

output "grafana_task_role_arn" {
  description = "Grafana ECS task role ARN"
  value       = aws_iam_role.grafana_task.arn
}

output "prometheus_task_role_arn" {
  description = "Prometheus ECS task role ARN"
  value       = aws_iam_role.prometheus_task.arn
}

output "backup_role_arn" {
  value = aws_iam_role.backup.arn
}