locals {
  infrastructure_widgets = [
    # ALB Healthy Hosts

    {
      type   = "metric"
      x      = 0
      y      = 0
      width  = 6
      height = 4

      properties = {
        title  = "ALB Healthy Hosts"
        view   = "singleValue"
        region = var.aws_region
        period = 60
        stat   = "Minimum"

        metrics = [
          [
            "AWS/ApplicationELB",
            "HealthyHostCount",
            "LoadBalancer",
            var.load_balancer_arn_suffix,
            "TargetGroup",
            var.target_group_arn_suffix,
            {
              label = "Healthy Hosts"
            }
          ]
        ]
      }
    },

    # ALB Unhealthy Hosts

    {
      type   = "metric"
      x      = 6
      y      = 0
      width  = 6
      height = 4

      properties = {
        title  = "ALB Unhealthy Hosts"
        view   = "singleValue"
        region = var.aws_region
        period = 60
        stat   = "Maximum"

        metrics = [
          [
            "AWS/ApplicationELB",
            "UnHealthyHostCount",
            "LoadBalancer",
            var.load_balancer_arn_suffix,
            "TargetGroup",
            var.target_group_arn_suffix,
            {
              label = "Unhealthy Hosts"
            }
          ]
        ]
      }
    },

    # ALB Target Response Time

    {
      type   = "metric"
      x      = 12
      y      = 0
      width  = 12
      height = 6

      properties = {
        title   = "ALB Target Response Time"
        view    = "timeSeries"
        region  = var.aws_region
        period  = 60
        stat    = "Average"
        stacked = false

        metrics = [
          [
            "AWS/ApplicationELB",
            "TargetResponseTime",
            "LoadBalancer",
            var.load_balancer_arn_suffix,
            "TargetGroup",
            var.target_group_arn_suffix,
            {
              label = "Target Response Time"
            }
          ]
        ]
      }
    },

    # ALB 4xx Errors

    {
      type   = "metric"
      x      = 0
      y      = 6
      width  = 12
      height = 6

      properties = {
        title   = "ALB 4xx Errors"
        view    = "timeSeries"
        region  = var.aws_region
        period  = 300
        stat    = "Sum"
        stacked = false

        metrics = [
          [
            "AWS/ApplicationELB",
            "HTTPCode_ELB_4XX_Count",
            "LoadBalancer",
            var.load_balancer_arn_suffix,
            {
              label = "ALB 4xx"
            }
          ],
          [
            "AWS/ApplicationELB",
            "HTTPCode_Target_4XX_Count",
            "LoadBalancer",
            var.load_balancer_arn_suffix,
            "TargetGroup",
            var.target_group_arn_suffix,
            {
              label = "Target 4xx"
            }
          ]
        ]
      }
    },

    # ALB 5xx Errors

    {
      type   = "metric"
      x      = 12
      y      = 6
      width  = 12
      height = 6

      properties = {
        title   = "ALB 5xx Errors"
        view    = "timeSeries"
        region  = var.aws_region
        period  = 300
        stat    = "Sum"
        stacked = false

        metrics = [
          [
            "AWS/ApplicationELB",
            "HTTPCode_ELB_5XX_Count",
            "LoadBalancer",
            var.load_balancer_arn_suffix,
            {
              label = "ALB 5xx"
            }
          ],
          [
            "AWS/ApplicationELB",
            "HTTPCode_Target_5XX_Count",
            "LoadBalancer",
            var.load_balancer_arn_suffix,
            "TargetGroup",
            var.target_group_arn_suffix,
            {
              label = "Target 5xx"
            }
          ]
        ]
      }
    },

    # EC2 Status Checks

    {
      type   = "metric"
      x      = 0
      y      = 12
      width  = 24
      height = 6

      properties = {
        title   = "EC2 Status Check Failed"
        view    = "timeSeries"
        region  = var.aws_region
        period  = 60
        stat    = "Maximum"
        stacked = false

        metrics = [
          [
            "AWS/EC2",
            "StatusCheckFailed",
            "InstanceId",
            var.web_instance_id,
            {
              label = "Web Server"
            }
          ],
          [
            "AWS/EC2",
            "StatusCheckFailed",
            "InstanceId",
            var.bastion_instance_id,
            {
              label = "Bastion"
            }
          ],
          [
            "AWS/EC2",
            "StatusCheckFailed",
            "AutoScalingGroupName",
            var.llm_asg_name,
            {
              label = "LLM ASG"
            }
          ]
        ]
      }
    },

    # EC2 CPU Utilization

    {
      type   = "metric"
      x      = 0
      y      = 18
      width  = 24
      height = 6

      properties = {
        title   = "EC2 CPU Utilization"
        view    = "timeSeries"
        region  = var.aws_region
        period  = 300
        stat    = "Average"
        stacked = false

        yAxis = {
          left = {
            min   = 0
            max   = 100
            label = "Percent"
          }
        }

        metrics = [
          [
            "AWS/EC2",
            "CPUUtilization",
            "InstanceId",
            var.web_instance_id,
            {
              label = "Web Server"
            }
          ],
          [
            "AWS/EC2",
            "CPUUtilization",
            "InstanceId",
            var.bastion_instance_id,
            {
              label = "Bastion"
            }
          ],
          [
            "AWS/EC2",
            "CPUUtilization",
            "AutoScalingGroupName",
            var.llm_asg_name,
            {
              label = "LLM ASG"
            }
          ]
        ]
      }
    },

    # EC2 Network In / Out

    {
      type   = "metric"
      x      = 0
      y      = 24
      width  = 24
      height = 6

      properties = {
        title   = "EC2 Network In / Out"
        view    = "timeSeries"
        region  = var.aws_region
        period  = 300
        stat    = "Sum"
        stacked = false

        yAxis = {
          left = {
            label = "Bytes"
          }
        }

        metrics = [
          [
            "AWS/EC2",
            "NetworkIn",
            "InstanceId",
            var.web_instance_id,
            {
              label = "Web Network In"
            }
          ],
          [
            "AWS/EC2",
            "NetworkOut",
            "InstanceId",
            var.web_instance_id,
            {
              label = "Web Network Out"
            }
          ],
          [
            "AWS/EC2",
            "NetworkIn",
            "InstanceId",
            var.bastion_instance_id,
            {
              label = "Bastion Network In"
            }
          ],
          [
            "AWS/EC2",
            "NetworkOut",
            "InstanceId",
            var.bastion_instance_id,
            {
              label = "Bastion Network Out"
            }
          ],
          [
            "AWS/EC2",
            "NetworkIn",
            "AutoScalingGroupName",
            var.llm_asg_name,
            {
              label = "LLM ASG Network In"
            }
          ],
          [
            "AWS/EC2",
            "NetworkOut",
            "AutoScalingGroupName",
            var.llm_asg_name,
            {
              label = "LLM ASG Network Out"
            }
          ]
        ]
      }
    }
  ]
  rds_widgets = [
    for widget in [

      # RDS CPU Utilization

      {
        type   = "metric"
        x      = 0
        y      = 30
        width  = 12
        height = 6

        properties = {
          title   = "RDS CPU Utilization"
          view    = "timeSeries"
          region  = var.aws_region
          period  = 300
          stat    = "Average"
          stacked = false

          yAxis = {
            left = {
              min   = 0
              max   = 100
              label = "Percent"
            }
          }

          metrics = [
            [
              "AWS/RDS",
              "CPUUtilization",
              "DBInstanceIdentifier",
              var.db_instance_identifier,
              {
                label = "CPU Utilization"
              }
            ]
          ]
        }
      },

      # RDS Freeable Memory

      {
        type   = "metric"
        x      = 12
        y      = 30
        width  = 12
        height = 6

        properties = {
          title   = "RDS Freeable Memory"
          view    = "timeSeries"
          region  = var.aws_region
          period  = 300
          stat    = "Average"
          stacked = false

          yAxis = {
            left = {
              label = "Bytes"
            }
          }

          metrics = [
            [
              "AWS/RDS",
              "FreeableMemory",
              "DBInstanceIdentifier",
              var.db_instance_identifier,
              {
                label = "Freeable Memory"
              }
            ]
          ]
        }
      },

      # RDS Free Storage Space

      {
        type   = "metric"
        x      = 0
        y      = 36
        width  = 12
        height = 6

        properties = {
          title   = "RDS Free Storage Space"
          view    = "timeSeries"
          region  = var.aws_region
          period  = 300
          stat    = "Average"
          stacked = false

          yAxis = {
            left = {
              label = "Bytes"
            }
          }

          metrics = [
            [
              "AWS/RDS",
              "FreeStorageSpace",
              "DBInstanceIdentifier",
              var.db_instance_identifier,
              {
                label = "Free Storage Space"
              }
            ]
          ]
        }
      },

      # RDS Database Connections

      {
        type   = "metric"
        x      = 12
        y      = 36
        width  = 12
        height = 6

        properties = {
          title   = "RDS Database Connections"
          view    = "timeSeries"
          region  = var.aws_region
          period  = 300
          stat    = "Average"
          stacked = false

          metrics = [
            [
              "AWS/RDS",
              "DatabaseConnections",
              "DBInstanceIdentifier",
              var.db_instance_identifier,
              {
                label = "Database Connections"
              }
            ]
          ]
        }
      }
    ] : widget
    if var.db_instance_identifier != null && trimspace(var.db_instance_identifier) != ""
  ]
}

resource "aws_cloudwatch_dashboard" "infrastructure" {
  dashboard_name = "${var.project}-${var.environment}-infrastructure"

  dashboard_body = jsonencode({
    widgets = concat(
      local.infrastructure_widgets,
      local.rds_widgets
    )
  })
}