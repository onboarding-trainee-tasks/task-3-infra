# Onboarding Task 3 — ECS Infrastructure

This repository provisions the application and monitoring infrastructure on **AWS ECS Fargate** using Terraform. Custom Docker images are maintained in the companion [`task-3-images`](https://github.com/onboarding-trainee-tasks/task-3-images) repository.

## Implementation

- ECS Fargate services for **Open WebUI, Ollama, Grafana, Prometheus and Alertmanager**, with Node Exporter sidecars.
- Public ALB for Open WebUI and Grafana; internal ALB for Ollama, Prometheus and Alertmanager.
- AWS Cloud Map private DNS service discovery between ECS services.
- ECS Service Auto Scaling for Open WebUI and Ollama.
- PostgreSQL RDS with credentials retrieved from AWS Secrets Manager.
- Encrypted Amazon EFS storage with access points for Prometheus; AWS Backup plan targeting **EFS**.
- IAM task execution/task roles, CloudWatch Logs and Prometheus/Grafana monitoring configuration.
- Jenkins pipeline for Terraform **PLAN, APPLY and DESTROY**, using a saved plan and manual approval before changes.

## External dependencies

1. **AWS access** — configure AWS CLI credentials for local Terraform runs. Jenkins uses credentials with IDs `aws-access-key-id` and `aws-secret-access-key` and requires permissions for the resources managed by Terraform.
2. **S3 Terraform backend** — bucket `tf-backend-onboarding-task`, region `eu-central-1`, state key **`infra/state-t3`**. T3 intentionally has a separate state from T2.
3. **AWS Secrets Manager** — existing RDS credentials (`db_username`, `db_password`) and SMTP secret (`smtp_password`); the secret ARNs are configured in `data.tf`.
4. **Docker images in ECR** — the custom Grafana, Prometheus, Alertmanager and Ollama images are built by `task-3-images`. The selected tags are declared separately in [`image-tags.auto.tfvars`](image-tags.auto.tfvars). Open WebUI and Node Exporter reference existing, separately tagged images.
5. **Bastion AMI and EC2 Key Pair** — `packer_bastion_ami` (from T2) and the pre-existing `terraform-ssh-key` key pair in `eu-central-1`.

## Run Terraform locally

Use the `onb-3-infra-ecs` branch until it is merged into `main`.

```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform apply
```

Terraform automatically reads `image-tags.auto.tfvars`. There is no common `image_tag` variable; update the relevant image-specific tag when a new image is published.

## Jenkins pipeline

The infrastructure Jenkins job loads the `Jenkinsfile` from this repository. Configure it to use the target branch and run it on an agent with Git, Terraform and AWS CLI.

`ACTION` supports:

| Action | Behavior |
| --- | --- |
| `PLAN` | Initializes and validates Terraform, creates and prints a plan, then finishes **without applying**. |
| `APPLY` | Creates and prints a plan, pauses for manual approval, and applies the **same saved plan**. |
| `DESTROY` | Creates and prints a destroy plan, requires manual approval, and applies the **same saved plan**. |

Approval times out after 20 minutes. The pipeline does not automatically deploy on a Git push. Terraform plans are kept in the Jenkins workspace only during execution and the workspace is cleaned afterward.

## Access and verification

After deployment, retrieve service endpoints using:

```bash
terraform output open_webui_url
terraform output grafana_url
terraform output ssh_command
```
