locals {
  use_template = length(var.user_data_vars) > 0
}


resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.ssh_key_name

  root_block_device {
    volume_size = var.volume_size
  }

  tags = {
    Name = "${var.instance_name}"
    Role = "${var.instance_name}"
  }

  iam_instance_profile = var.iam_instance_profile

  user_data = var.user_data == null ? null : (
    local.use_template
    ? templatefile(var.user_data, var.user_data_vars)
    : file(var.user_data)
  )
}