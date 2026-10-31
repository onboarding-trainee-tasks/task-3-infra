resource "aws_service_discovery_private_dns_namespace" "this" {
  name        = var.namespace_name
  description = "Private namespace for ECS service discovery"
  vpc         = var.vpc_id

  tags = {
    Name = var.namespace_name
  }
}

resource "aws_service_discovery_service" "this" {
  for_each = var.service_names

  name = each.value

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id

    routing_policy = "MULTIVALUE"

    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  tags = {
    Name = each.value
  }
}