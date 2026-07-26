resource "aws_backup_vault" "monitoring" {
  name = "${var.project}-${var.environment}-monitoring-vault"

  tags = {
    Project     = var.project
    Environment = var.environment
    Service     = "monitoring"
  }
}

resource "aws_backup_plan" "monitoring" {
  name = "${var.project}-${var.environment}-monitoring-backup"

  rule {
    rule_name         = "daily-efs-backup"
    target_vault_name = aws_backup_vault.monitoring.name

    schedule = "cron(0 2 * * ? *)"

    start_window      = 60
    completion_window = 240

    lifecycle {
      delete_after = 35
    }

    recovery_point_tags = {
      Project     = var.project
      Environment = var.environment
      Service     = "prometheus"
      Storage     = "efs"
    }
  }

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_backup_selection" "prometheus_efs" {
  name = "${var.project}-${var.environment}-prometheus-efs"

  plan_id      = aws_backup_plan.monitoring.id
  iam_role_arn = module.iam.backup_role_arn

  resources = [
    module.prometheus_efs.file_system_arn
  ]
}