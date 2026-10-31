variable "namespace_name" {
  description = "Name of the private Cloud Map namespace"
  type        = string
}

variable "vpc_id" {
  description = "VPC associated with the private Cloud Map namespace"
  type        = string
}

variable "service_names" {
  description = "Names of services registered in Cloud Map"
  type        = set(string)
}