variable "name" {
  description = "Name of the EFS file system"
  type        = string
}

variable "subnet_ids_by_az" {
  description = "Subnet IDs keyed by Availability Zone"
  type        = map(string)
}

variable "security_group_ids" {
  description = "Security groups attached to EFS mount targets"
  type        = list(string)
}

variable "partitions" {
  description = "Logical EFS partitions implemented as access points"

  type = map(object({
    path        = string
    uid         = number
    gid         = number
    permissions = string
  }))
}

variable "tags" {
  description = "Tags assigned to EFS resources"
  type        = map(string)
  default     = {}
}