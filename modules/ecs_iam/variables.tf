variable "role_name" {
  description = "Name of the ECS task execution role"
  type        = string
}

variable "secret_arns" {
  description = "Secrets available to ECS task definitions"
  type        = list(string)
}