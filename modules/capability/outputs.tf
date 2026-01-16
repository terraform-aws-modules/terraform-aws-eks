################################################################################
# Capability
################################################################################

output "arn" {
  description = "The ARN of the EKS Capability"
  value       = try(aws_eks_capability.this[0].arn, null)
}

output "version" {
  description = "The version of the EKS Capability"
  value       = try(aws_eks_capability.this[0].version, null)
}

output "argocd_server_url" {
  description = "URL of the Argo CD server"
  value       = try(aws_eks_capability.this[0].configuration[0].argo_cd[0].server_url, null)
}

################################################################################
# IAM Role
################################################################################

output "iam_role_name" {
  description = "The name of the IAM role"
  value       = try(aws_iam_role.this[0].name, null)
}

output "iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = try(aws_iam_role.this[0].arn, null)
}

output "iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = try(aws_iam_role.this[0].unique_id, null)
}
