resource "aws_lb" "public" {
  name               = var.public_lb_name
  internal           = false
  load_balancer_type = "application"

  security_groups = var.public_security_group_ids
  subnets         = var.public_subnet_ids

  tags = merge(var.tags, {
    Name = var.public_lb_name
  })
}

resource "aws_lb_target_group" "open_webui" {
  name        = var.open_webui_target_group_name
  port        = var.open_webui_target_group_port
  protocol    = var.open_webui_target_group_protocol
  vpc_id      = var.vpc_id
  target_type = var.target_type

  health_check {
    path     = var.open_webui_health_check_path
    protocol = var.open_webui_target_group_protocol
    matcher  = var.health_check_matcher

    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
  }

  tags = merge(var.tags, {
    Name = var.open_webui_target_group_name
  })
}

resource "aws_lb_target_group" "grafana" {
  name        = var.grafana_target_group_name
  port        = var.grafana_target_group_port
  protocol    = var.grafana_target_group_protocol
  vpc_id      = var.vpc_id
  target_type = var.target_type

  health_check {
    path     = var.grafana_health_check_path
    protocol = var.grafana_target_group_protocol
    matcher  = var.health_check_matcher

    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
  }

  tags = merge(var.tags, {
    Name = var.grafana_target_group_name
  })
}

resource "aws_lb_listener" "public" {
  load_balancer_arn = aws_lb.public.arn
  port              = var.public_listener_port
  protocol          = var.public_listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.open_webui.arn
  }
}

resource "aws_lb_listener_rule" "grafana" {
  listener_arn = aws_lb_listener.public.arn
  priority     = var.grafana_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana.arn
  }

  condition {
    path_pattern {
      values = var.grafana_path_patterns
    }
  }
}

resource "aws_lb" "ollama" {
  name               = var.ollama_lb_name
  internal           = true
  load_balancer_type = "application"

  security_groups = var.ollama_security_group_ids
  subnets         = var.ollama_subnet_ids

  tags = merge(var.tags, {
    Name = var.ollama_lb_name
  })
}

resource "aws_lb_target_group" "ollama" {
  name        = var.ollama_target_group_name
  port        = var.ollama_target_group_port
  protocol    = var.ollama_target_group_protocol
  vpc_id      = var.vpc_id
  target_type = var.target_type

  health_check {
    path     = var.ollama_health_check_path
    protocol = var.ollama_target_group_protocol
    matcher  = var.health_check_matcher

    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
  }

  tags = merge(var.tags, {
    Name = var.ollama_target_group_name
  })
}

resource "aws_lb_listener" "ollama" {
  load_balancer_arn = aws_lb.ollama.arn
  port              = var.ollama_listener_port
  protocol          = var.ollama_listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ollama.arn
  }
}

resource "aws_lb_target_group" "prometheus" {
  name        = var.prometheus_target_group_name
  port        = var.prometheus_target_group_port
  protocol    = var.prometheus_target_group_protocol
  vpc_id      = var.vpc_id
  target_type = var.target_type

  health_check {
    path     = var.prometheus_health_check_path
    protocol = var.prometheus_target_group_protocol
    matcher  = var.health_check_matcher

    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
  }

  tags = merge(var.tags, {
    Name = var.prometheus_target_group_name
  })
}

resource "aws_lb_listener" "prometheus" {
  load_balancer_arn = aws_lb.ollama.arn
  port              = var.prometheus_listener_port
  protocol          = var.prometheus_listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prometheus.arn
  }
}

resource "aws_lb_target_group" "alertmanager" {
  name        = var.alertmanager_target_group_name
  port        = var.alertmanager_target_group_port
  protocol    = var.alertmanager_target_group_protocol
  vpc_id      = var.vpc_id
  target_type = var.target_type

  health_check {
    path     = var.alertmanager_health_check_path
    protocol = var.alertmanager_target_group_protocol
    matcher  = var.health_check_matcher

    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
  }

  tags = merge(var.tags, {
    Name = var.alertmanager_target_group_name
  })
}

resource "aws_lb_listener" "alertmanager" {
  load_balancer_arn = aws_lb.ollama.arn
  port              = var.alertmanager_listener_port
  protocol          = var.alertmanager_listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alertmanager.arn
  }
}