output "ssm_start_session" {
  description = "SSM start session command to connect to remote host created"
  value       = "aws ssm start-session --region ${var.region} --target ${module.ssm_bastion_ec2.id}"
}
