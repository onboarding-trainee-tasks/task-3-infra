variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket available to the bastion"
  type        = string
}

variable "iam_name" {
  description = "Base name of the bastion IAM resources"
  type        = string
  default     = "EC2-Profile"
}

variable "secret_arns" {
  description = "Secrets available to the bastion instance"
  type        = list(string)
  default     = []
}

variable "ecs_execution_role_name" {
  description = "Name of the ECS task execution role"
  type        = string
}

variable "ecs_secret_arns" {
  description = "Secrets available to ECS task definitions"
  type        = list(string)
  default     = []
}

variable "grafana_task_role_name" {
  description = "Name of the Grafana ECS task role"
  type        = string
}

variable "prometheus_task_role_name" {
  description = "Name of the Prometheus ECS task role"
  type        = string
}