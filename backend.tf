terraform {
  backend "s3" {
    bucket = "tf-backend-onboarding-task"
    key    = "infra/state"
    region = "eu-central-1"
  }
}
