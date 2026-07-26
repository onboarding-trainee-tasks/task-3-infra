# Bastion EC2 role
resource "aws_iam_role" "this" {
  name        = "${var.iam_name}-Role"
  description = "IAM role for the bastion EC2 instance"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "this" {
  name        = "${var.iam_name}-Policy"
  description = "IAM policy for the bastion EC2 instance"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ListInitSqlBucket"
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = var.s3_bucket_arn
      },
      {
        Sid    = "ReadInitSqlObjects"
        Effect = "Allow"

        Action = [
          "s3:GetObject"
        ]

        Resource = "${var.s3_bucket_arn}/*"
      },
      {
        Sid    = "ReadBastionSecrets"
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue"
        ]

        Resource = var.secret_arns
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.iam_name}-Profile"
  role = aws_iam_role.this.name
}

# ECS task execution role
resource "aws_iam_role" "ecs_execution" {
  name = var.ecs_execution_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role = aws_iam_role.ecs_execution.name

  policy_arn = (
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  )
}

resource "aws_iam_role_policy" "ecs_secrets" {
  name = "${var.ecs_execution_role_name}-secrets"
  role = aws_iam_role.ecs_execution.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ReadEcsSecrets"
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue"
        ]

        Resource = var.ecs_secret_arns
      }
    ]
  })
}

# Grafana task role
resource "aws_iam_role" "grafana_task" {
  name = var.grafana_task_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "grafana_cloudwatch" {
  name = "${var.grafana_task_role_name}-cloudwatch"
  role = aws_iam_role.grafana_task.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ReadCloudWatchMetrics"
        Effect = "Allow"

        Action = [
          "cloudwatch:DescribeAlarmsForMetric",
          "cloudwatch:DescribeAlarmHistory",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetInsightRuleReport"
        ]

        Resource = "*"
      },
      {
        Sid    = "ReadCloudWatchLogs"
        Effect = "Allow"

        Action = [
          "logs:DescribeLogGroups",
          "logs:GetLogGroupFields",
          "logs:StartQuery",
          "logs:StopQuery",
          "logs:GetQueryResults",
          "logs:GetLogEvents"
        ]

        Resource = "*"
      },
      {
        Sid    = "ReadEC2Metadata"
        Effect = "Allow"

        Action = [
          "ec2:DescribeTags",
          "ec2:DescribeInstances",
          "ec2:DescribeRegions"
        ]

        Resource = "*"
      },
      {
        Sid    = "ReadResourceTags"
        Effect = "Allow"

        Action = [
          "tag:GetResources"
        ]

        Resource = "*"
      }
    ]
  })
}

# Prometheus task role
resource "aws_iam_role" "prometheus_task" {
  name = var.prometheus_task_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "prometheus_ec2_discovery" {
  name = "${var.prometheus_task_role_name}-ec2-discovery"
  role = aws_iam_role.prometheus_task.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "DiscoverEC2Instances"
        Effect = "Allow"

        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeAvailabilityZones"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "prometheus_efs" {
  name = "${var.prometheus_task_role_name}-efs"
  role = aws_iam_role.prometheus_task.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "MountPrometheusEFS"
        Effect = "Allow"

        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite"
        ]

        Resource = var.prometheus_efs_file_system_arn

        Condition = {
          StringEquals = {
            "elasticfilesystem:AccessPointArn" = (
              var.prometheus_efs_access_point_arns
            )
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "backup" {
  name = var.backup_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "backup.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "backup" {
  role = aws_iam_role.backup.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "restore" {
  role = aws_iam_role.backup.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}