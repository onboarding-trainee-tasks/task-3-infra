module "network" {
  source   = "./modules/network"
  vpc_cidr = "10.10.0.0/16"

  azs = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  subnets = {
    public_subnet_1 = {
      cidr = "10.10.1.0/24"
      type = "public"
    }
    public_subnet_2 = {
      cidr = "10.10.2.0/24"
      type = "public"
    }
    private_subnet_1 = {
      cidr = "10.10.3.0/24"
      type = "private"
    }
    private_subnet_2 = {
      cidr = "10.10.4.0/24"
      type = "private"
    }
    database_subnet_1 = {
      cidr = "10.10.5.0/24"
      type = "database"
    }
    database_subnet_2 = {
      cidr = "10.10.6.0/24"
      type = "database"
    }
  }
}

module "security_group" {
  source = "./modules/security_group"
  vpc_id = module.network.vpc_id

  security_groups = {
    bastion_sg = {
      name                    = "bastion_sg"
      tcp_ingress_ports       = [22]
      udp_ingress_ports       = []
      allowed_cidr_blocks     = var.allowed_cidr_blocks
      allowed_security_groups = []
    }
    alb_sg = {
      name                    = "alb_sg"
      tcp_ingress_ports       = [80]
      udp_ingress_ports       = []
      allowed_cidr_blocks     = []
      allowed_security_groups = ["bastion_sg", "web_sg"]
    }
    ollama_sg = {
      name                    = "ollama_sg"
      tcp_ingress_ports       = [22, 11434] # 11434 for Ollama
      udp_ingress_ports       = []
      allowed_cidr_blocks     = []
      allowed_security_groups = ["bastion_sg", "web_sg", "alb_sg"]
    }
    database_sg = {
      name                    = "database_sg"
      tcp_ingress_ports       = [5432]
      udp_ingress_ports       = []
      allowed_cidr_blocks     = []
      allowed_security_groups = ["ollama_sg", "bastion_sg", "web_sg"]
    }
    web_sg = {
      name                    = "web_sg"
      tcp_ingress_ports       = [3000, 5000, 9090] # 3000 for Open Web UI, 5000 for Grafana, 9090 for Prometheus
      udp_ingress_ports       = []
      allowed_cidr_blocks     = ["0.0.0.0/0"]
      allowed_security_groups = []
    }
    web_sg_ssh = {
      name                    = "web_sg_ssg"
      tcp_ingress_ports       = [22]
      udp_ingress_ports       = []
      allowed_cidr_blocks     = []
      allowed_security_groups = ["bastion_sg"]
    }
    monitoring_sg = {
      name                    = "monitoring_sg"
      tcp_ingress_ports       = [9100]
      udp_ingress_ports       = []
      allowed_cidr_blocks     = []
      allowed_security_groups = ["bastion_sg", "ollama_sg", "web_sg"]
    }
  }
}

module "rds" {
  source             = "./modules/rds"
  subnet_ids         = module.network.database_subnet_ids
  security_group_ids = [module.security_group.sg_ids["database_sg"]]
  db_secret_id       = data.aws_secretsmanager_secret_version.rds_secrets_version
  db_name            = var.db_name
  instance_class     = var.rds_instance_class
  allocated_storage  = var.rds_allocated_storage
}

module "iam" {
  source        = "./modules/iam"
  s3_bucket_arn = var.s3_bucket_arn

  secret_arns = [
    data.aws_secretsmanager_secret.rds_secrets.arn
  ]
}

module "bastion_instance" {
  source               = "./modules/instance"
  instance_name        = "bastion"
  instance_type        = "t3.micro"
  volume_size          = 8
  subnet_id            = module.network.public_subnet_ids[1] # second public subnet for bastion
  ssh_key_name         = var.ssh_key_name
  security_group_ids   = [module.security_group.sg_ids["bastion_sg"], module.security_group.sg_ids["monitoring_sg"]]
  ami_id               = var.packer_bastion_ami
  iam_instance_profile = module.iam.iam_instance_profile_name

  user_data = "./scripts/bastion.sh"

  user_data_vars = {
    AWS_REGION    = var.aws_region
    DB_SECRET_ARN = data.aws_secretsmanager_secret.rds_secrets.arn
    DB_HOST       = module.rds.db_host
    DB_PORT       = module.rds.db_port
    DB_NAME       = module.rds.db_name
  }
}

resource "aws_iam_role" "monitoring" {
  name        = "Monitoring-Role"
  description = "IAM role for Monitoring"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_policy" "monitoring_ec2_sd" {
  name        = "Monitoring-Policy"
  description = "IAM policy for Monitoring"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "MonitoringAWSAccess"
        Effect = "Allow"

        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeAvailabilityZones",

          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "cloudwatch:DescribeAlarms",

          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ]

        Resource = "*"
      },
      {
        Sid    = "ReadApplicationSecrets"
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue"
        ]

        Resource = [
          data.aws_secretsmanager_secret.rds_secrets.arn,
          data.aws_secretsmanager_secret.smtp_secrets.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "monitoring_ec2_sd" {
  role       = aws_iam_role.monitoring.name
  policy_arn = aws_iam_policy.monitoring_ec2_sd.arn
}

resource "aws_iam_instance_profile" "monitoring" {
  name = "Monitoring-Profile"
  role = aws_iam_role.monitoring.name
}

module "web_server_instance" {
  source               = "./modules/instance"
  instance_name        = "web-server"
  instance_type        = "t3.small"
  volume_size          = 30
  subnet_id            = module.network.public_subnet_ids[0]
  ssh_key_name         = var.ssh_key_name
  security_group_ids   = [module.security_group.sg_ids["web_sg"], module.security_group.sg_ids["web_sg_ssh"], module.security_group.sg_ids["monitoring_sg"]]
  ami_id               = var.packer_web_server_ami
  iam_instance_profile = aws_iam_instance_profile.monitoring.name

  user_data = "./scripts/web-server.sh"

  user_data_vars = {
    AWS_REGION = var.aws_region
    DB_SECRET_ARN = data.aws_secretsmanager_secret.rds_secrets.arn
    SMTP_SECRET_ARN = data.aws_secretsmanager_secret.smtp_secrets.arn
    DB_HOST = module.rds.db_host
    DB_PORT = module.rds.db_port
    DB_NAME = module.rds.db_name
    DNS_NAME = module.alb.load_balancer_dns_name
  }
}

module "alb" {
  source            = "./modules/alb"
  security_group_id = [module.security_group.sg_ids["alb_sg"]]
  subnet_ids        = module.network.public_subnet_ids
  vpc_id            = module.network.vpc_id
}

module "asg" {
  source              = "./modules/asg"
  image_id            = var.packer_llm_ami
  instance_type       = "t3.small"
  vpc_zone_identifier = module.network.private_subnet_ids

  min_size                 = var.min_instance_count
  max_size                 = var.max_instance_count
  desired_capacity         = var.desired_instance_count
  autoscaling_target_value = var.autoscaling_policy_value

  lb_target_group_arn = module.alb.target_group_arn
  security_group_ids  = [module.security_group.sg_ids["ollama_sg"], module.security_group.sg_ids["monitoring_sg"]]
  key_name            = var.ssh_key_name
}

module "cloudwatch" {
  source = "./modules/cloudwatch"

  project     = var.project
  aws_region  = "eu-central-1"
  environment = var.environment

  sns_topic_name = var.sns_topic_name

  web_instance_id     = module.web_server_instance.instance_id
  bastion_instance_id = module.bastion_instance.instance_id

  llm_asg_name = module.asg.autoscaling_group_name

  load_balancer_arn_suffix = module.alb.load_balancer_arn_suffix
  target_group_arn_suffix  = module.alb.target_group_arn_suffix

  db_instance_identifier = module.rds.db_instance_identifier
}
