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

variable "task_role_arn" {
  description = "IAM role available to containers in the ECS task"
  type        = string
  default     = null
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

variable "node_exporter_image" {
  description = "ECR image URI for Node Exporter"
  type        = string
}

variable "node_exporter_port" {
  description = "Node Exporter container port"
  type        = number
}

variable "secret_variables" {
  description = "Secrets Manager values passed to the application container"
  type        = map(string)
  default     = {}
}

variable "health_check_grace_period_seconds" {
  description = "Time ECS ignores failed load balancer health checks after task startup"
  type        = number
  default     = 60
}

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "autoscaling_enabled" {
  description = "Whether ECS Service Auto Scaling is enabled"
  type        = bool
  default     = false
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of ECS tasks"
  type        = number
  default     = 1
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of ECS tasks"
  type        = number
  default     = 1
}

variable "autoscaling_cpu_target" {
  description = "Target average ECS service CPU utilization"
  type        = number
  default     = null

  validation {
    condition = (
      var.autoscaling_cpu_target == null
      || (
        var.autoscaling_cpu_target > 0
        && var.autoscaling_cpu_target <= 100
      )
    )

    error_message = (
      "autoscaling_cpu_target must be null or between 1 and 100."
    )
  }
}

variable "autoscaling_memory_target" {
  description = "Target average ECS service memory utilization"
  type        = number
  default     = null
}

variable "autoscaling_scale_out_cooldown" {
  description = "Seconds to wait after a scale-out activity"
  type        = number
  default     = 60
}

variable "autoscaling_scale_in_cooldown" {
  description = "Seconds to wait after a scale-in activity"
  type        = number
  default     = 300
}