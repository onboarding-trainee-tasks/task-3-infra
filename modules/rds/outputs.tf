output "db_id" {
  description = "The RDS instance ID"
  value       = aws_db_instance.this.id
}

output "db_endpoint" {
  description = "The RDS instance endpoint"
  value       = aws_db_instance.this.endpoint
}

output "db_host" {
  description = "RDS hostname"
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "RDS port"
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "The RDS instance name"
  value       = aws_db_instance.this.db_name
}

output "db_instance_identifier" {
  value = aws_db_instance.this.identifier
}