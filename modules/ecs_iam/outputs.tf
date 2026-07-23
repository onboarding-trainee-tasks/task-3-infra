output "execution_role_arn" {
  value = aws_iam_role.execution.arn
}

output "grafana_task_role_arn" {
  description = "Grafana ECS task role ARN"
  value       = aws_iam_role.grafana_task.arn
}