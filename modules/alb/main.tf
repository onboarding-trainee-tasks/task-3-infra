resource "aws_lb" "this" {
  name               = "my-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = var.security_group_id
  subnets            = var.subnet_ids

  tags = {
    Name = "my-alb"
  }
}

resource "aws_lb_target_group" "this" {
  name     = var.lb_target_group_name
  port     = var.target_group_port
  protocol = var.target_group_protocol
  vpc_id   = var.vpc_id

  health_check {
    path                = var.health_check_path
    interval            = var.interval
    timeout             = var.timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    matcher             = var.matcher
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.lb_listener_port
  protocol          = var.target_group_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}