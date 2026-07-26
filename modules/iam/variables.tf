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

variable "prometheus_efs_file_system_arn" {
  description = "EFS file system ARN available to Prometheus"
  type        = string
}

variable "prometheus_efs_access_point_arns" {
  description = "EFS access point ARNs available to Prometheus"
  type        = list(string)
}

variable "backup_role_name" {
  description = "IAM role name used by AWS Backup"
  type        = string
}