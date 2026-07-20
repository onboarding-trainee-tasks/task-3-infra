variable "project" {
  description = "Project name"
  type        = string
}

variable "aws_region" {
  description = "Region where resources are deployed"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable sns_topic_name {
  description = "Name of the SNS Topic for CloudWatch"
  type = string
}

variable "web_instance_id" {
  description = "Web server EC2 instance ID"
  type        = string
}

variable "bastion_instance_id" {
  description = "Bastion EC2 instance ID"
  type        = string
}

variable "llm_asg_name" {
  description = "LLM Auto Scaling Group name"
  type        = string
}

variable "load_balancer_arn_suffix" {
  description = "ALB ARN suffix used as CloudWatch metric dimension"
  type        = string
}

variable "target_group_arn_suffix" {
  description = "Target Group ARN suffix used as CloudWatch metric dimension"
  type        = string
}

variable "db_instance_identifier" {
  description = "RDS PostgreSQL DB instance identifier"
  type        = string
  default     = null
}