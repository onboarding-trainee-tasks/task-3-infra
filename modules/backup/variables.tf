variable "vault_name" {
  description = "Name of the AWS Backup vault"
  type        = string
}

variable "plan_name" {
  description = "Name of the AWS Backup plan"
  type        = string
}

variable "rule_name" {
  description = "Name of the backup rule"
  type        = string
}

variable "selection_name" {
  description = "Name of the AWS Backup resource selection"
  type        = string
}

variable "iam_role_arn" {
  description = "ARN of the IAM role used by AWS Backup"
  type        = string
}

variable "resource_arns" {
  description = "ARNs of resources protected by the backup plan"
  type        = list(string)
}

variable "schedule" {
  description = "AWS Backup schedule in cron format"
  type        = string
  default     = "cron(0 2 * * ? *)"
}

variable "start_window" {
  description = "Time in minutes before a backup job must start"
  type        = number
  default     = 60
}

variable "completion_window" {
  description = "Time in minutes before a backup job must complete"
  type        = number
  default     = 240
}

variable "delete_after_days" {
  description = "Number of days after which recovery points are deleted"
  type        = number
  default     = 35
}

variable "vault_tags" {
  description = "Tags assigned to the backup vault"
  type        = map(string)
  default     = {}
}

variable "plan_tags" {
  description = "Tags assigned to the backup plan"
  type        = map(string)
  default     = {}
}

variable "recovery_point_tags" {
  description = "Tags assigned to recovery points created by the plan"
  type        = map(string)
  default     = {}
}