resource "aws_backup_vault" "this" {
  name = var.vault_name

  tags = var.vault_tags
}

resource "aws_backup_plan" "this" {
  name = var.plan_name

  rule {
    rule_name         = var.rule_name
    target_vault_name = aws_backup_vault.this.name

    schedule = var.schedule

    start_window      = var.start_window
    completion_window = var.completion_window

    lifecycle {
      delete_after = var.delete_after_days
    }

    recovery_point_tags = var.recovery_point_tags
  }

  tags = var.plan_tags
}

resource "aws_backup_selection" "this" {
  name = var.selection_name

  plan_id      = aws_backup_plan.this.id
  iam_role_arn = var.iam_role_arn
  resources    = var.resource_arns
}