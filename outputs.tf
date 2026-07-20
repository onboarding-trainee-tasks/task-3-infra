output "ssh_command" {
  description = "The SSH command to connect to the bastion host"
  value       = "ssh -i C:\\Onboarding\\.ssh\\terraform-ssh-key.pem ubuntu@${module.bastion_instance.public_ip}"
}