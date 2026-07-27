# Onboarding task 3 - ECS (infra)

This repository deploys the application and monitoring stack to AWS ECS Fargate.
Custom images are built by the separate images repository.

## Implementation Features

* ECS Fargate services for Grafana, Prometheus, Alertmanager, Ollama and Open WebUI
* Public and internal Application Load Balancers
* AWS Cloud Map service discovery
* Prometheus persistent storage on EFS
* AWS Backup for RDS and EFS
* Jenkins pipeline for Terraform plan, apply and destroy

## External dependencies

The following items must already exist:

1. **AWS credentials**

   Jenkins expects:

   ```text
   aws-access-key-id
   aws-secret-access-key
   ```

2. **Terraform state bucket**

   ```text
   Bucket: tf-backend-onboarding-task
   Region: eu-central-1
   State key: infra/state
   ```

3. **AWS Secrets Manager secrets**

   RDS secret:

   ```json
   {
     "db_username": "...",
     "db_password": "..."
   }
   ```

   SMTP secret:

   ```json
   {
     "smtp_password": "..."
   }
   ```

   Secret ARNs are configured in `data.tf`.

4. **Container images**

   The following images are built by the images repository and use the common
   `image_tag` variable:

   ```text
   grafana
   prometheus
   alertmanager
   ollama-tinyllama
   ```

   Open WebUI and Node Exporter use separately versioned existing images.

5. **Bastion AMI**

   The AMI ID is configured in `packer_bastion_ami` (created in Task 2).

6. **EC2 key pair**

   ```text
   terraform-ssh-key
   ```

## Manual run

```bash
terraform init
terraform validate

terraform apply -var="image_tag=1.0.4"
```

To remove the infrastructure:

```bash
terraform destroy -var="image_tag=1.0.4"
```

## Jenkins pipeline

The infrastructure job is configured for `onb-3-infra-ecs` task (change branch in Jenkins setting in case of moving to `main` branch).

Available parameters:

```text
ACTION = PLAN, APPLY, DESTROY
IMAGE_TAG = tag created by the images pipeline
CONFIRM_DESTROY = required for DESTROY
```
