variable "public_lb_name" {
  description = "Name of the public Application Load Balancer"
  type        = string
}

variable "public_security_group_ids" {
  description = "Security groups associated with the public ALB"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the public ALB"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID where target groups are created"
  type        = string
}

variable "public_listener_port" {
  description = "Listener port of the public ALB"
  type        = number
}

variable "public_listener_protocol" {
  description = "Listener protocol of the public ALB"
  type        = string
}

variable "open_webui_target_group_name" {
  description = "Name of the Open WebUI target group"
  type        = string
}

variable "open_webui_target_group_port" {
  description = "Port of the Open WebUI target group"
  type        = number
}

variable "open_webui_target_group_protocol" {
  description = "Protocol of the Open WebUI target group"
  type        = string
}

variable "open_webui_health_check_path" {
  description = "Health check path for Open WebUI"
  type        = string
}

variable "grafana_target_group_name" {
  description = "Name of the Grafana target group"
  type        = string
}

variable "grafana_target_group_port" {
  description = "Port of the Grafana target group"
  type        = number
}

variable "grafana_target_group_protocol" {
  description = "Protocol of the Grafana target group"
  type        = string
}

variable "grafana_health_check_path" {
  description = "Health check path for Grafana"
  type        = string
}

variable "grafana_rule_priority" {
  description = "Priority of the Grafana path rule"
  type        = number
}

variable "grafana_path_patterns" {
  description = "URL path patterns routed to Grafana"
  type        = list(string)
}

variable "ollama_lb_name" {
  description = "Name of the internal Ollama ALB"
  type        = string
}

variable "ollama_security_group_ids" {
  description = "Security groups associated with the internal Ollama ALB"
  type        = list(string)
}

variable "ollama_subnet_ids" {
  description = "Private subnet IDs for the internal Ollama ALB"
  type        = list(string)
}

variable "ollama_listener_port" {
  description = "Listener port of the internal Ollama ALB"
  type        = number
}

variable "ollama_listener_protocol" {
  description = "Listener protocol of the internal Ollama ALB"
  type        = string
}

variable "ollama_target_group_name" {
  description = "Name of the Ollama target group"
  type        = string
}

variable "ollama_target_group_port" {
  description = "Port of the Ollama target group"
  type        = number
}

variable "ollama_target_group_protocol" {
  description = "Protocol of the Ollama target group"
  type        = string
}

variable "ollama_health_check_path" {
  description = "Health check path for Ollama"
  type        = string
}

variable "target_type" {
  description = "Target group target type. Fargate requires ip"
  type        = string
}

variable "health_check_interval" {
  type = number
}

variable "health_check_timeout" {
  type = number
}

variable "healthy_threshold" {
  type = number
}

variable "unhealthy_threshold" {
  type = number
}

variable "health_check_matcher" {
  type = string
}

variable "tags" {
  description = "Tags applied to ALB resources"
  type        = map(string)
  default     = {}
}
