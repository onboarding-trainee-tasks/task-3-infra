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
      allowed_cidr_blocks     = ["0.0.0.0/0"]
      allowed_security_groups = []
    }

    open_webui_sg = {
      name                    = "open_webui_sg"
      tcp_ingress_ports       = [5000]
      udp_ingress_ports       = []
      allowed_cidr_blocks     = []
      allowed_security_groups = ["alb_sg"]
    }

    grafana_sg = {
      name                    = "grafana_sg"
      tcp_ingress_ports       = [3000]
      udp_ingress_ports       = []
      allowed_cidr_blocks     = []
      allowed_security_groups = ["alb_sg"]
    }

    ollama_alb_sg = {
      name                    = "ollama_alb_sg"
      tcp_ingress_ports       = [11434]
      udp_ingress_ports       = []
      allowed_cidr_blocks     = []
      allowed_security_groups = ["open_webui_sg"]
    }

    ollama_sg = {
      name                    = "ollama_sg"
      tcp_ingress_ports       = [11434]
      udp_ingress_ports       = []
      allowed_cidr_blocks     = []
      allowed_security_groups = ["ollama_alb_sg"]
    }

    database_sg = {
      name                    = "database_sg"
      tcp_ingress_ports       = [5432]
      udp_ingress_ports       = []
      allowed_cidr_blocks     = []
      allowed_security_groups = ["bastion_sg", "open_webui_sg"]
    }
  }
}

# module "rds" {
#   source             = "./modules/rds"
#   subnet_ids         = module.network.database_subnet_ids
#   security_group_ids = [module.security_group.sg_ids["database_sg"]]
#   db_secret_id       = data.aws_secretsmanager_secret_version.rds_secrets_version
#   db_name            = var.db_name
#   instance_class     = var.rds_instance_class
#   allocated_storage  = var.rds_allocated_storage
# }

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
  subnet_id            = module.network.public_subnet_ids[1]
  ssh_key_name         = var.ssh_key_name
  security_group_ids   = [module.security_group.sg_ids["bastion_sg"]]
  ami_id               = var.packer_bastion_ami
  iam_instance_profile = module.iam.iam_instance_profile_name

  # user_data = "./scripts/bastion.sh"

  # user_data_vars = {
  #   AWS_REGION    = var.aws_region
  #   DB_SECRET_ARN = data.aws_secretsmanager_secret.rds_secrets.arn
  #   DB_HOST       = module.rds.db_host
  #   DB_PORT       = module.rds.db_port
  #   DB_NAME       = module.rds.db_name
  # }
}

module "ecs_cluster" {
  source = "./modules/ecs_cluster"

  name = "${var.project}-${var.environment}-cluster"
}

module "service_discovery" {
  source = "./modules/service_discovery"

  namespace_name = "llm.local"
  vpc_id         = module.network.vpc_id

  service_names = [
    "open-webui",
    "ollama",
    "prometheus",
    "grafana",
    "alertmanager"
  ]
}

module "ecs_iam" {
  source = "./modules/ecs_iam"

  role_name = "${var.project}-${var.environment}-ecs-execution-role"
}

module "alb" {
  source = "./modules/alb"

  public_lb_name = "${var.project}-${var.environment}-alb"

  public_security_group_ids = [
    module.security_group.sg_ids["alb_sg"]
  ]

  public_subnet_ids = module.network.public_subnet_ids
  vpc_id            = module.network.vpc_id

  public_listener_port     = 80
  public_listener_protocol = "HTTP"

  open_webui_target_group_name     = "${var.project}-${var.environment}-webui-tg"
  open_webui_target_group_port     = 8080
  open_webui_target_group_protocol = "HTTP"
  open_webui_health_check_path     = "/health"

  grafana_target_group_name     = "${var.project}-${var.environment}-grafana-tg"
  grafana_target_group_port     = 3000
  grafana_target_group_protocol = "HTTP"
  grafana_health_check_path     = "/api/health"

  grafana_rule_priority = 10
  grafana_path_patterns = ["/grafana", "/grafana/*"]

  ollama_lb_name = "${var.project}-${var.environment}-ollama-alb"

  ollama_security_group_ids = [
    module.security_group.sg_ids["ollama_alb_sg"]
  ]

  ollama_subnet_ids = module.network.private_subnet_ids

  ollama_listener_port     = 11434
  ollama_listener_protocol = "HTTP"

  ollama_target_group_name     = "${var.project}-${var.environment}-ollama-tg"
  ollama_target_group_port     = 11434
  ollama_target_group_protocol = "HTTP"
  ollama_health_check_path     = "/api/tags"

  target_type = "ip"

  health_check_interval = 30
  health_check_timeout  = 5
  healthy_threshold     = 2
  unhealthy_threshold   = 2
  health_check_matcher  = "200-399"

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

module "grafana_service" {
  source = "./modules/ecs_service"

  service_name = "grafana"
  cluster_id   = module.ecs_cluster.cluster_id

  image          = "grafana/grafana:latest"
  container_port = 3000

  cpu           = "256"
  memory        = "512"
  desired_count = 1

  subnet_ids = module.network.private_subnet_ids

  security_group_ids = [
    module.security_group.sg_ids["grafana_sg"]
  ]

  execution_role_arn = module.ecs_iam.execution_role_arn

  target_group_arn = module.alb.grafana_target_group_arn

  registry_arn = (
    module.service_discovery.service_arns["grafana"]
  )

  aws_region = var.aws_region

  environment_variables = {
    GF_SERVER_ROOT_URL = (
      "http://${module.alb.public_load_balancer_dns_name}/grafana/"
    )

    GF_SERVER_SERVE_FROM_SUB_PATH = "true"
  }
}
