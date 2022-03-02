################################################################################
# IAM Role
################################################################################

output "iam_role_name" {
  description = "The name of the IAM role"
  value       = try(aws_iam_role.this[0].name, "")
}

output "iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = try(aws_iam_role.this[0].arn, var.iam_role_arn)
}

output "iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = try(aws_iam_role.this[0].unique_id, "")
}

################################################################################
# Fargate Profile
################################################################################

output "fargate_profile_arn" {
  description = "Amazon Resource Name (ARN) of the EKS Fargate Profile"
  value       = try(aws_eks_fargate_profile.this[0].arn, "")
}

output "fargate_profile_id" {
  description = "EKS Cluster name and EKS Fargate Profile name separated by a colon (`:`)"
  value       = try(aws_eks_fargate_profile.this[0].id, "")
}

output "fargate_profile_status" {
  description = "Status of the EKS Fargate Profile"
  value       = try(aws_eks_fargate_profile.this[0].status, "")
}

output "fargate_profile_pod_execution_role_arn" {
  description = "Amazon Resource Name (ARN) of the EKS Fargate Profile Pod execution role ARN"
  value       = try(aws_eks_fargate_profile.this[0].pod_execution_role_arn, "")
}
