variable "packer_bastion_ami" {
  description = "ID of AMI created by Packer for Bastion Host"
  type        = string
  default     = "ami-01dcaea3a368849c9"
}

variable "packer_llm_ami" {
  description = "ID of AMI created by Packer for LLM Hosts"
  type        = string
  default     = "ami-031e1b98dc35b8aaa"
}

variable "packer_web_server_ami" {
  description = "ID of AMI created by Packer for Web Server"
  type        = string
  default     = "ami-0fbbd30e2c7115049"
}

variable "allowed_cidr_blocks" {
  description = "A list of allowed CIDR blocks for the security group"
  type        = list(string)
  default     = ["178.212.0.0/16"]
}

variable "aws_region" {
  description = "Region where resources are deployed"
  type        = string
  default     = "eu-central-1"
}

variable "ssh_key_name" {
  description = "Name of the SSH key pair for EC2 instances"
  type        = string
  default     = "terraform-ssh-key"
}

variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket to allow access to"
  type        = string
  default     = "arn:aws:s3:::init-sql-script"
}

variable "db_name" {
  description = "The name of the database to create"
  type        = string
  default     = "postgres"
}

variable "min_instance_count" {
  description = "The minimum number of instances for the Auto Scaling group"
  type        = number
  default     = 2
}

variable "max_instance_count" {
  description = "The maximum number of instances for the Auto Scaling group"
  type        = number
  default     = 3
}

variable "desired_instance_count" {
  description = "The desired number of instances for the Auto Scaling group"
  type        = number
  default     = 2
}

variable "rds_instance_class" {
  description = "The instance class for the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "The allocated storage for the RDS instance in GB"
  type        = number
  default     = 5
}

variable "autoscaling_policy_value" {
  description = "Target value for the metric"
  type        = number
  default     = 80
}

variable "sns_topic_name" {
  description = "Name of the SNS Topic for CloudWatch"
  type        = string
  default     = "task-2-alerts"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "llm"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "test"
}
