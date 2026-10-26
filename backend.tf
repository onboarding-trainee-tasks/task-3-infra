terraform {
  backend "s3" {
    bucket = "tf-backend-onboarding-task"
    key    = "infra/state-t3"
    region = "eu-central-1"
  }
}
