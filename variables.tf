variable "packer_bastion_ami" {
  description = "ID of AMI created by Packer for Bastion Host"
  type        = string
  default     = "ami-01dcaea3a368849c9"
}

variable "allowed_cidr_blocks" {
  description = "A list of allowed CIDR blocks for the bastion security group"
  type        = list(string)
  default     = ["178.212.0.0/16"]
}

variable "aws_region" {
  description = "Region where resources are deployed"
  type        = string
  default     = "eu-central-1"
}

variable "ssh_key_name" {
  description = "Name of the SSH key pair for the bastion host"
  type        = string
  default     = "terraform-ssh-key"
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket accessible by the bastion role"
  type        = string
  default     = "arn:aws:s3:::init-sql-script"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "postgres"
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "Allocated RDS storage in GiB"
  type        = number
  default     = 5
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
