variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket to allow access to"
  type        = string
}

variable "iam_name" {
  description = "The name of the IAM resources"
  type        = string
  default     = "EC2-Profile"
}

variable "secret_arns" {
  description = "Secrets that the EC2 instance can read"
  type        = list(string)
  default     = []
}