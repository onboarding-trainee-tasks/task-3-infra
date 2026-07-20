data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_secretsmanager_secret" "rds_secrets" {
  arn = "arn:aws:secretsmanager:eu-central-1:583955898731:secret:Task-1-RDS-Secrets-JXWRuA"
}

data "aws_secretsmanager_secret_version" "rds_secrets_version" {
  secret_id = data.aws_secretsmanager_secret.rds_secrets.id
}

data "aws_secretsmanager_secret" "smtp_secrets" {
  arn = "arn:aws:secretsmanager:eu-central-1:583955898731:secret:alertmanager/smtp-1ogmjJ"
}