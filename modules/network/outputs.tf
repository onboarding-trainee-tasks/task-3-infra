output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "A list of public subnet IDs"
  value       = [for subnet in aws_subnet.this : subnet.id if subnet.tags["Type"] == "public"]
}

output "private_subnet_ids" {
  description = "A list of private subnet IDs"
  value       = [for subnet in aws_subnet.this : subnet.id if subnet.tags["Type"] == "private"]
}

output "database_subnet_ids" {
  description = "A list of database subnet IDs"
  value       = [for subnet in aws_subnet.this : subnet.id if subnet.tags["Type"] == "database"]
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "The ID of the private route table"
  value       = aws_route_table.private.id
}

output "database_route_table_id" {
  description = "The ID of the database route table"
  value       = aws_route_table.database.id
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = aws_nat_gateway.this.id
}

output "nat_public_ip" {
  description = "The public IP of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}