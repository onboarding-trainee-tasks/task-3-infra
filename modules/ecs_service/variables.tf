variable "service_name" {
  description = "ECS service and task family name"
  type        = string
}

variable "cluster_id" {
  description = "ECS cluster ID"
  type        = string
}

variable "image" {
  description = "Container image URI"
  type        = string
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
}

variable "cpu" {
  description = "Fargate task CPU units"
  type        = string
}

variable "memory" {
  description = "Fargate task memory in MiB"
  type        = string
}

variable "desired_count" {
  description = "Number of tasks in the ECS service"
  type        = number
}

variable "subnet_ids" {
  description = "Private subnet IDs for Fargate tasks"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups attached to task ENIs"
  type        = list(string)
}

variable "execution_role_arn" {
  description = "ECS task execution role ARN"
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group ARN"
  type        = string
}

variable "registry_arn" {
  description = "Cloud Map service ARN"
  type        = string
}

variable "aws_region" {
  description = "AWS region used by the awslogs driver"
  type        = string
}

variable "environment_variables" {
  description = "Plain container environment variables"
  type        = map(string)
  default     = {}
}