output "namespace_id" {
  value = aws_service_discovery_private_dns_namespace.this.id
}

output "namespace_arn" {
  value = aws_service_discovery_private_dns_namespace.this.arn
}

output "service_arns" {
  value = {
    for name, service in aws_service_discovery_service.this :
    name => service.arn
  }
}