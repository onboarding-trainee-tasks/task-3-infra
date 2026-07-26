output "file_system_id" {
  value = aws_efs_file_system.this.id
}

output "file_system_arn" {
  value = aws_efs_file_system.this.arn
}

output "access_point_ids" {
  value = {
    for az, access_point in aws_efs_access_point.this :
    az => access_point.id
  }
}

output "access_point_arns" {
  value = {
    for az, access_point in aws_efs_access_point.this :
    az => access_point.arn
  }
}

output "mount_target_ids" {
  value = {
    for az, mount_target in aws_efs_mount_target.this :
    az => mount_target.id
  }
}