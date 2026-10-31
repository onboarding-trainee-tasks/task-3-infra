variable "vpc_id" {
  description = "The ID of the VPC where the security group will be created"
  type        = string
}

variable "security_groups" {
  description = "A map of security groups to create"
  type = map(object({
    name                    = string
    tcp_ingress_ports       = list(number)
    udp_ingress_ports       = list(number)
    allowed_cidr_blocks     = list(string)
    allowed_security_groups = list(string)
  }))
}