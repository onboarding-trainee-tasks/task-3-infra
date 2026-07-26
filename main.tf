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
      tcp_ingress_ports       = [22, 9100]
      udp_ingress_ports       = []
      allowed_cidr_blocks     = var.allowed_cidr_blocks
      allowed_security_groups = ["ecs_tasks_sg"]
    }

    alb_sg = {
      name                    = "alb_sg"
      tcp_ingress_ports       = [80]
      udp_ingress_ports       = []
      allowed_cidr_blocks     = ["0.0.0.0/0"]
      allowed_security_groups = []
    }

    internal_alb_sg = {
      name                    = "internal_alb_sg"
      tcp_ingress_ports       = [11434, 9090, 9093]
      udp_ingress_ports       = []
      allowed_cidr_blocks     = []
      allowed_security_groups = ["ecs_tasks_sg"]
    }

    ecs_tasks_sg = {
      name = "ecs_tasks_sg"
      tcp_ingress_ports = [
        3000, # Grafana
        8080, # Open WebUI
        9090, # Prometheus
        9093, # Alertmanager
        9100, # Node Exporter
        11434 # Ollama
      ]
      udp_ingress_ports       = []
      allowed_cidr_blocks     = []
      allowed_security_groups = ["alb_sg", "internal_alb_sg", "ecs_tasks_sg"]
    }

    efs_sg = {
      name                = "efs_sg"
      tcp_ingress_ports   = [2049]
      udp_ingress_ports   = []
      allowed_cidr_blocks = []

      allowed_security_groups = [
        "ecs_tasks_sg"
      ]
    }

    database_sg = {
      name                    = "database_sg"
      tcp_ingress_ports       = [5432]
      udp_ingress_ports       = []
      allowed_cidr_blocks     = []
      allowed_security_groups = ["bastion_sg", "ecs_tasks_sg"]
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

module "prometheus_efs" {
  source = "./modules/efs"

  name = "${var.project}-${var.environment}-prometheus-efs"

  subnet_ids_by_az = (
    module.network.private_subnet_ids_by_az
  )

  security_group_ids = [
    module.security_group.sg_ids["efs_sg"]
  ]

  partitions = {
    "eu-central-1a" = {
      path        = "/prometheus/partition-1"
      uid         = 65534
      gid         = 65534
      permissions = "0755"
    }

    "eu-central-1b" = {
      path        = "/prometheus/partition-2"
      uid         = 65534
      gid         = 65534
      permissions = "0755"
    }
  }

  tags = {
    Project     = var.project
    Environment = var.environment
    Service     = "prometheus"
  }
}

module "iam" {
  source        = "./modules/iam"
  s3_bucket_arn = var.s3_bucket_arn

  secret_arns = [data.aws_secretsmanager_secret.rds_secrets.arn]

  ecs_execution_role_name = ("${var.project}-${var.environment}-ecs-execution-role")

  ecs_secret_arns = [
    data.aws_secretsmanager_secret.rds_secrets.arn,
    data.aws_secretsmanager_secret.smtp_secrets.arn
  ]

  grafana_task_role_name = ("${var.project}-${var.environment}-grafana-task-role")

  prometheus_task_role_name = (
    "${var.project}-${var.environment}-prometheus-task-role"
  )

  prometheus_efs_file_system_arn = (module.prometheus_efs.file_system_arn)

  prometheus_efs_access_point_arns = values(module.prometheus_efs.access_point_arns)

  backup_role_name = ("${var.project}-${var.environment}-backup-role")
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

  user_data = "./scripts/bastion.sh"

  user_data_vars = {
    AWS_REGION    = var.aws_region
    DB_SECRET_ARN = data.aws_secretsmanager_secret.rds_secrets.arn
    DB_HOST       = module.rds.db_host
    DB_PORT       = module.rds.db_port
    DB_NAME       = module.rds.db_name
  }
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

module "alb" {
  source = "./modules/alb"

  public_lb_name = "${var.project}-${var.environment}-alb"

  public_security_group_ids = [module.security_group.sg_ids["alb_sg"]]

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

  internal_lb_name            = ("${var.project}-${var.environment}-internal-alb")
  internal_security_group_ids = [module.security_group.sg_ids["internal_alb_sg"]]
  internal_subnet_ids         = module.network.private_subnet_ids

  ollama_target_group_name     = "${var.project}-${var.environment}-ollama-tg"
  ollama_target_group_port     = 11434
  ollama_target_group_protocol = "HTTP"
  ollama_health_check_path     = "/api/tags"
  ollama_listener_port         = 11434
  ollama_listener_protocol     = "HTTP"

  prometheus_target_group_name     = "${var.project}-${var.environment}-prom-tg"
  prometheus_target_group_port     = 9090
  prometheus_target_group_protocol = "HTTP"
  prometheus_health_check_path     = "/-/healthy"
  prometheus_listener_port         = 9090
  prometheus_listener_protocol     = "HTTP"

  alertmanager_target_group_name     = "${var.project}-${var.environment}-alert-tg"
  alertmanager_target_group_port     = 9093
  alertmanager_target_group_protocol = "HTTP"
  alertmanager_health_check_path     = "/-/healthy"
  alertmanager_listener_port         = 9093
  alertmanager_listener_protocol     = "HTTP"

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
  cluster_name = module.ecs_cluster.cluster_name

  image = "583955898731.dkr.ecr.eu-central-1.amazonaws.com/grafana:${var.image_tag}"

  node_exporter_image = (
    "583955898731.dkr.ecr.eu-central-1.amazonaws.com/node-exporter:v1.12.1"
  )

  container_port     = 3000
  node_exporter_port = 9100

  cpu           = 256
  memory        = 1024
  desired_count = 1

  subnet_ids = module.network.private_subnet_ids

  security_group_ids = [module.security_group.sg_ids["ecs_tasks_sg"]]

  execution_role_arn = module.iam.ecs_execution_role_arn
  task_role_arn      = module.iam.grafana_task_role_arn

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

module "prometheus_service" {
  source = "./modules/ecs_service"

  service_name = "prometheus"
  cluster_id   = module.ecs_cluster.cluster_id
  cluster_name = module.ecs_cluster.cluster_name

  image = "public.ecr.aws/l8p0g0w4/prometheus:${var.image_tag}"

  node_exporter_image = (
    "583955898731.dkr.ecr.eu-central-1.amazonaws.com/node-exporter:v1.12.1"
  )

  container_port     = 9090
  node_exporter_port = 9100

  cpu           = 512
  memory        = 1024
  desired_count = 2

  subnet_ids         = module.network.private_subnet_ids
  security_group_ids = [module.security_group.sg_ids["ecs_tasks_sg"]]

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  execution_role_arn = module.iam.ecs_execution_role_arn
  task_role_arn      = module.iam.prometheus_task_role_arn

  efs_volumes = {
    prometheus_partition_1 = {
      file_system_id  = module.prometheus_efs.file_system_id
      access_point_id = module.prometheus_efs.access_point_ids["eu-central-1a"]
      container_path  = "/mnt/prometheus/partition-1"
    }

    prometheus_partition_2 = {
      file_system_id  = module.prometheus_efs.file_system_id
      access_point_id = module.prometheus_efs.access_point_ids["eu-central-1b"]
      container_path  = "/mnt/prometheus/partition-2"
    }
  }

  environment_variables = {
    PROMETHEUS_AZ_1           = "eu-central-1a"
    PROMETHEUS_AZ_2           = "eu-central-1b"
    PROMETHEUS_STORAGE_PATH_1 = "/mnt/prometheus/partition-1"
    PROMETHEUS_STORAGE_PATH_2 = "/mnt/prometheus/partition-2"
    PROMETHEUS_RETENTION_TIME = "15d"
  }

  target_group_arn = module.alb.prometheus_target_group_arn
  registry_arn     = module.service_discovery.service_arns["prometheus"]
  aws_region       = var.aws_region
}

module "alertmanager_service" {
  source = "./modules/ecs_service"

  service_name = "alertmanager"
  cluster_id   = module.ecs_cluster.cluster_id
  cluster_name = module.ecs_cluster.cluster_name

  image = "public.ecr.aws/l8p0g0w4/alertmanager:${var.image_tag}"

  node_exporter_image = "583955898731.dkr.ecr.eu-central-1.amazonaws.com/node-exporter:v1.12.1"

  container_port     = 9093
  node_exporter_port = 9100

  cpu           = 512
  memory        = 1024
  desired_count = 1

  subnet_ids = module.network.private_subnet_ids

  security_group_ids = [module.security_group.sg_ids["ecs_tasks_sg"]]

  execution_role_arn = module.iam.ecs_execution_role_arn

  target_group_arn = module.alb.alertmanager_target_group_arn

  registry_arn = module.service_discovery.service_arns["alertmanager"]

  secret_variables = {
    SMTP_PASSWORD = (
      "${data.aws_secretsmanager_secret.smtp_secrets.arn}:smtp_password::"
    )
  }
  aws_region = var.aws_region
}

module "ollama_service" {
  source = "./modules/ecs_service"

  service_name = "ollama"
  cluster_id   = module.ecs_cluster.cluster_id
  cluster_name = module.ecs_cluster.cluster_name

  image = "public.ecr.aws/l8p0g0w4/ollama-tinyllama:${var.image_tag}"

  node_exporter_image = "583955898731.dkr.ecr.eu-central-1.amazonaws.com/node-exporter:v1.12.1"

  container_port     = 11434
  node_exporter_port = 9100

  cpu           = 1024
  memory        = 2048
  desired_count = 2

  autoscaling_enabled            = true
  autoscaling_min_capacity       = 2
  autoscaling_max_capacity       = 4
  autoscaling_cpu_target         = 70
  autoscaling_scale_out_cooldown = 120
  autoscaling_scale_in_cooldown  = 600

  subnet_ids = module.network.private_subnet_ids

  security_group_ids = [module.security_group.sg_ids["ecs_tasks_sg"]]

  execution_role_arn = module.iam.ecs_execution_role_arn

  target_group_arn = module.alb.ollama_target_group_arn

  registry_arn = module.service_discovery.service_arns["ollama"]

  aws_region = var.aws_region

  health_check_grace_period_seconds = 120

  environment_variables = {
    OLLAMA_HOST   = "0.0.0.0:11434"
    OLLAMA_MODELS = "/root/.ollama/models"
  }
}

module "open_webui_service" {
  source = "./modules/ecs_service"

  service_name = "open-webui"
  cluster_id   = module.ecs_cluster.cluster_id
  cluster_name = module.ecs_cluster.cluster_name

  image = "public.ecr.aws/l8p0g0w4/open-webui:0.10.2-slim"

  node_exporter_image = "583955898731.dkr.ecr.eu-central-1.amazonaws.com/node-exporter:v1.12.1"

  container_port     = 8080
  node_exporter_port = 9100

  cpu                               = 512
  memory                            = 2048
  desired_count                     = 1
  health_check_grace_period_seconds = 300

  autoscaling_enabled            = true
  autoscaling_min_capacity       = 1
  autoscaling_max_capacity       = 3
  autoscaling_cpu_target         = 60
  autoscaling_memory_target      = 70
  autoscaling_scale_out_cooldown = 60
  autoscaling_scale_in_cooldown  = 300

  subnet_ids = module.network.private_subnet_ids

  security_group_ids = [module.security_group.sg_ids["ecs_tasks_sg"]]

  execution_role_arn = module.iam.ecs_execution_role_arn

  target_group_arn = module.alb.open_webui_target_group_arn

  registry_arn = module.service_discovery.service_arns["open-webui"]

  aws_region = var.aws_region

  environment_variables = {
    DATABASE_TYPE = "postgresql"
    DATABASE_HOST = module.rds.db_host
    DATABASE_PORT = tostring(module.rds.db_port)
    DATABASE_NAME = module.rds.db_name

    OLLAMA_BASE_URL = ("http://${module.alb.internal_load_balancer_dns_name}:11434")

    VECTOR_DB                 = "pgvector"
    PGVECTOR_CREATE_EXTENSION = "false"
  }

  secret_variables = {
    DATABASE_USER = "${data.aws_secretsmanager_secret.rds_secrets.arn}:db_username::"

    DATABASE_PASSWORD = "${data.aws_secretsmanager_secret.rds_secrets.arn}:db_password::"
  }
}
