resource "aws_appautoscaling_target" "this" {
  count = var.autoscaling_enabled ? 1 : 0

  min_capacity = var.autoscaling_min_capacity
  max_capacity = var.autoscaling_max_capacity

  resource_id = (
    "service/${var.cluster_name}/${aws_ecs_service.this.name}"
  )

  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu" {
  count              = (var.autoscaling_enabled && var.autoscaling_cpu_target != null) ? 1 : 0
  name               = "${var.service_name}-cpu-target-tracking"
  policy_type        = "TargetTrackingScaling"
  resource_id        = (aws_appautoscaling_target.this[0].resource_id)
  scalable_dimension = (aws_appautoscaling_target.this[0].scalable_dimension)
  service_namespace  = (aws_appautoscaling_target.this[0].service_namespace)

  target_tracking_scaling_policy_configuration {
    target_value = var.autoscaling_cpu_target

    scale_out_cooldown = (var.autoscaling_scale_out_cooldown)
    scale_in_cooldown  = (var.autoscaling_scale_in_cooldown)

    predefined_metric_specification {
      predefined_metric_type = ("ECSServiceAverageCPUUtilization")
    }
  }
}

resource "aws_appautoscaling_policy" "memory" {
  count              = (var.autoscaling_enabled && var.autoscaling_memory_target != null) ? 1 : 0
  name               = "${var.service_name}-memory-target-tracking"
  policy_type        = "TargetTrackingScaling"
  resource_id        = (aws_appautoscaling_target.this[0].resource_id)
  scalable_dimension = (aws_appautoscaling_target.this[0].scalable_dimension)
  service_namespace  = (aws_appautoscaling_target.this[0].service_namespace)

  target_tracking_scaling_policy_configuration {
    target_value = var.autoscaling_memory_target

    scale_out_cooldown = (var.autoscaling_scale_out_cooldown)

    scale_in_cooldown = (var.autoscaling_scale_in_cooldown)

    predefined_metric_specification {
      predefined_metric_type = ("ECSServiceAverageMemoryUtilization")
    }
  }
}