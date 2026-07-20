resource "aws_launch_template" "this" {
  instance_type          = var.instance_type
  image_id               = var.image_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name

  # user_data = filebase64(var.user_data)
}

resource "aws_autoscaling_group" "this" {
  name             = "my-asg"
  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }
  
  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 300
    }

    triggers = ["launch_template"]
  }

  vpc_zone_identifier       = var.vpc_zone_identifier
  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period
  force_delete              = true

  tag {
    key                 = "Name"
    value               = "my-asg-instance"
    propagate_at_launch = true
  }
  tag {
    key                 = "Role"
    value               = "llm"
    propagate_at_launch = true
  }
  tag {
    key                 = "InstanceGroup"
    value               = "my-asg"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "this" {
  autoscaling_group_name = aws_autoscaling_group.this.name
  lb_target_group_arn    = var.lb_target_group_arn
}

resource "aws_autoscaling_policy" "cpu_scale_up" {
  name                   = "cpu_scale-up"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.this.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = var.autoscaling_target_value
  }
}
