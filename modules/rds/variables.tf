variable subnet_ids {
  description = "List of subnet IDs for the RDS instance"
  type        = list(string)
}

variable security_group_ids {
  description = "List of security group IDs for the RDS instance"
  type        = list(string)
}

variable db_secret_id {
  description = "RDS secrets from AWS Secrets Manager"
  type        = any
}

variable db_name {
  description = "The name of the database to create"
  type        = string
}

variable instance_class {
  description = "The instance class for the RDS instance"
  type        = string
}

variable "allocated_storage" {
  description = "The allocated storage for the RDS instance in GB"
  type        = number
  default     = 5
}

variable "engine" {
  description = "The database engine to use for the RDS instance"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "The version of the database engine to use for the RDS instance"
  type        = string
  default     = "16"
}