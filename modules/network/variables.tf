variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "subnets" {
  description = "A map of public subnets with their CIDR blocks and availability zones"
  type = map(object({
    cidr = string
    type = string
  }))
}

variable "azs" {
  description = "A list of availability zones"
  type        = list(string)
}