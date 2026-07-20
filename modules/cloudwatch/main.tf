data "aws_sns_topic" "alerts" {
  name = var.sns_topic_name
}

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  alarm_name = "[${var.project}]-[${var.environment}]-[elb]-[high]-[host-count]"

  namespace   = "AWS/ApplicationELB"
  metric_name = "UnHealthyHostCount"

  comparison_operator = "GreaterThanThreshold"
  threshold           = 0

  evaluation_periods = 1
  period             = 60
  statistic          = "Maximum"

  dimensions = {
    LoadBalancer = var.load_balancer_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  alarm_actions = [
    data.aws_sns_topic.alerts.arn
  ]

  ok_actions = [
    data.aws_sns_topic.alerts.arn
  ]

  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "alb_target_4xx" {
  alarm_name = "[${var.project}]-[${var.environment}]-[elb]-[medium]-[4xx-errors]"

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_Target_4XX_Count"

  comparison_operator = "GreaterThanThreshold"
  threshold           = 10

  evaluation_periods = 1
  period             = 300
  statistic          = "Sum"

  dimensions = {
    LoadBalancer = var.load_balancer_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  alarm_actions = [
    data.aws_sns_topic.alerts.arn
  ]

  ok_actions = [
    data.aws_sns_topic.alerts.arn
  ]

  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "alb_target_5xx" {
  alarm_name = "[${var.project}]-[${var.environment}]-[elb]-[medium]-[5xx-errors]"

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_Target_5XX_Count"

  comparison_operator = "GreaterThanThreshold"
  threshold           = 5

  evaluation_periods = 1
  period             = 300
  statistic          = "Sum"

  dimensions = {
    LoadBalancer = var.load_balancer_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  alarm_actions = [
    data.aws_sns_topic.alerts.arn
  ]

  ok_actions = [
    data.aws_sns_topic.alerts.arn
  ]

  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "db_high_cpu" {
  alarm_name = "[${var.project}]-[${var.environment}]-[db]-[high]-[cpu]"

  namespace   = "AWS/RDS"
  metric_name = "CPUUtilization"

  comparison_operator = "GreaterThanThreshold"
  threshold           = 80

  evaluation_periods = 2
  period             = 300
  statistic          = "Average"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }

  alarm_actions = [
    data.aws_sns_topic.alerts.arn
  ]

  ok_actions = [
    data.aws_sns_topic.alerts.arn
  ]

  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "db_low_memory" {
  alarm_name = "[${var.project}]-[${var.environment}]-[db]-[high]-[memory]"

  namespace   = "AWS/RDS"
  metric_name = "FreeableMemory"

  comparison_operator = "LessThanThreshold"

  threshold = 536870912 # 512 MiB

  evaluation_periods = 2
  period             = 300
  statistic          = "Average"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }

  alarm_actions = [
    data.aws_sns_topic.alerts.arn
  ]

  ok_actions = [
    data.aws_sns_topic.alerts.arn
  ]

  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "db_low_storage" {
  alarm_name = "[${var.project}]-[${var.environment}]-[db]-[high]-[storage]"

  namespace   = "AWS/RDS"
  metric_name = "FreeStorageSpace"

  comparison_operator = "LessThanThreshold"

  threshold = 5368709120 # 5 GiB

  evaluation_periods = 1
  period             = 300
  statistic          = "Average"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }

  alarm_actions = [
    data.aws_sns_topic.alerts.arn
  ]

  ok_actions = [
    data.aws_sns_topic.alerts.arn
  ]

  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "web_status_check_failed" {
  alarm_name = "[${var.project}]-[${var.environment}]-[ec2]-[web]-[status-check-failed]"

  namespace   = "AWS/EC2"
  metric_name = "StatusCheckFailed"

  comparison_operator = "GreaterThanThreshold"
  threshold           = 0

  evaluation_periods = 1
  period             = 60
  statistic          = "Maximum"

  dimensions = {
    InstanceId = var.web_instance_id
  }

  alarm_actions = [
    data.aws_sns_topic.alerts.arn
  ]

  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "bastion_status_check_failed" {
  alarm_name = "[${var.project}]-[${var.environment}]-[ec2]-[bastion]-[status-check-failed]"

  namespace   = "AWS/EC2"
  metric_name = "StatusCheckFailed"

  comparison_operator = "GreaterThanThreshold"
  threshold           = 0

  evaluation_periods = 1
  period             = 60
  statistic          = "Maximum"

  dimensions = {
    InstanceId = var.bastion_instance_id
  }

  alarm_actions = [
    data.aws_sns_topic.alerts.arn
  ]

  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "llm_status_check_failed" {
  alarm_name = "[${var.project}]-[${var.environment}]-[ec2]-[llm]-[status-check-failed]"

  namespace   = "AWS/EC2"
  metric_name = "StatusCheckFailed"

  comparison_operator = "GreaterThanThreshold"
  threshold           = 0

  evaluation_periods = 1
  period             = 60
  statistic          = "Maximum"

  dimensions = {
    AutoScalingGroupName = var.llm_asg_name
  }

  alarm_actions = [
    data.aws_sns_topic.alerts.arn
  ]

  treat_missing_data = "notBreaching"
}