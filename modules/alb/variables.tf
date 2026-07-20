variable "security_group_id" {
  description = "Security group ID to associate with the ALB"
  type        = list(string)
}

variable "subnet_ids" {
  description = "List of subnet IDs to associate with the ALB"
  type        = list(string)
}

variable "vpc_id" {
  description = "The ID of the VPC where the ALB will be created"
  type        = string
}

variable "lb_target_group_name" {
  description = "The name of the target group"
  type        = string
  default     = "my-target-group"
}

variable "health_check_path" {
  description = "The path for health checks"
  type        = string
  default     = "/"
}

variable "interval" {
  description = "The interval for health checks"
  type        = number
  default     = 30
}

variable "timeout" {
  description = "The timeout for health checks"
  type        = number
  default     = 5
}

variable "healthy_threshold" {
  description = "The number of consecutive successful health checks required before considering an instance healthy"
  type        = number
  default     = 2
}

variable "unhealthy_threshold" {
  description = "The number of consecutive failed health checks required before considering an instance unhealthy"
  type        = number
  default     = 2
}

variable "matcher" {
  description = "The HTTP response codes to use when checking for a successful response from a target"
  type        = string
  default     = "200-299"
}

variable "target_group_port" {
  description = "The port on which the target group is listening"
  type        = number
  default     = 11434
}

variable "target_group_protocol" {
  description = "The protocol to use for routing traffic to the targets"
  type        = string
  default     = "HTTP"
}

variable "lb_listener_port" {
  description = "The port on which the load balancer is listening"
  type        = number
  default     = 80
}

