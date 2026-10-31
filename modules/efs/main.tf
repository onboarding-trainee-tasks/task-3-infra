resource "aws_efs_file_system" "this" {
  creation_token = var.name

  encrypted        = true
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

resource "aws_efs_mount_target" "this" {
  for_each = var.subnet_ids_by_az

  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = each.value
  security_groups = var.security_group_ids
}

resource "aws_efs_access_point" "this" {
  for_each = var.partitions

  file_system_id = aws_efs_file_system.this.id

  posix_user {
    uid = each.value.uid
    gid = each.value.gid
  }

  root_directory {
    path = each.value.path

    creation_info {
      owner_uid   = each.value.uid
      owner_gid   = each.value.gid
      permissions = each.value.permissions
    }
  }

  tags = merge(
    var.tags,
    {
      Name             = "${var.name}-${each.key}"
      AvailabilityZone = each.key
      Partition        = each.value.path
    }
  )
}

resource "aws_efs_file_system_policy" "this" {
  file_system_id = aws_efs_file_system.this.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "DenyUnencryptedTransport"
        Effect = "Deny"

        Principal = "*"

        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess"
        ]

        Resource = aws_efs_file_system.this.arn

        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        Sid    = "DenyMountWithoutAccessPoint"
        Effect = "Deny"

        Principal = "*"

        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess"
        ]

        Resource = aws_efs_file_system.this.arn

        Condition = {
          Null = {
            "elasticfilesystem:AccessPointArn" = "true"
          }
        }
      }
    ]
  })
}