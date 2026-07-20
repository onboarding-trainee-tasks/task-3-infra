resource "aws_security_group" "this" {
  for_each = var.security_groups
  vpc_id = var.vpc_id
  name = each.key

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = each.value.name
  }
}

locals {
  tcp_rules = flatten([
    for sg_name, sg in var.security_groups : [
      for port in sg.tcp_ingress_ports : [
        for cidr in sg.allowed_cidr_blocks : {
          sg_name    = sg_name
          name       = sg.name
          protocol   = "tcp"
          port       = port
          cidr       = cidr
        }
      ]
    ]
  ])
  udp_rules = flatten([
    for sg_name, sg in var.security_groups : [
      for port in sg.udp_ingress_ports : [
        for cidr in sg.allowed_cidr_blocks : {
          sg_name    = sg_name
          name       = sg.name
          protocol   = "udp"
          port       = port
          cidr       = cidr
        }
      ]
    ]
  ])
  
  sg_rules_map = {
    for idx, rule in concat(local.tcp_rules, local.udp_rules) :
    "${rule.sg_name}-${rule.protocol}-${rule.port}-${rule.cidr}" => rule
  }
}

locals {
  tcp_sg_rules = flatten([
    for sg_name, sg in var.security_groups : [
      for port in sg.tcp_ingress_ports : [
        for source_sg in sg.allowed_security_groups : {
          sg_name        = sg_name
          name           = sg.name
          protocol       = "tcp"
          port           = port
          source_sg_name = source_sg
        }
      ]
    ]
  ])
  udp_sg_rules = flatten([
    for sg_name, sg in var.security_groups : [
      for port in sg.udp_ingress_ports : [
        for source_sg in sg.allowed_security_groups : {
          sg_name        = sg_name
          name           = sg.name
          protocol       = "udp"
          port           = port
          source_sg_name = source_sg
        }
      ]
    ]
  ])
  
  sg_from_sg_rules_map = {
    for idx, rule in concat(local.tcp_sg_rules, local.udp_sg_rules) :
    "${rule.sg_name}-${rule.protocol}-${rule.port}-${rule.source_sg_name}" => rule
  }
}

resource "aws_vpc_security_group_ingress_rule" "allowed_cidr" {
  for_each = local.sg_rules_map

  security_group_id = aws_security_group.this[each.value.sg_name].id
  ip_protocol       = each.value.protocol
  from_port         = each.value.port
  to_port           = each.value.port
  cidr_ipv4         = each.value.cidr
}

resource "aws_vpc_security_group_ingress_rule" "allowed_sg" {
  for_each = local.sg_from_sg_rules_map

  security_group_id            = aws_security_group.this[each.value.sg_name].id
  ip_protocol                  = each.value.protocol
  from_port                    = each.value.port
  to_port                      = each.value.port
  referenced_security_group_id = aws_security_group.this[each.value.source_sg_name].id
}