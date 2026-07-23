variable "role_name" {
  description = "Name of the ECS task execution role"
  type        = string
}

variable "secret_arns" {
  description = "Secrets available to ECS task definitions"
  type        = list(string)
}

variable "grafana_task_role_name" {
  description = "Name of the Grafana ECS task role"
  type        = string
}