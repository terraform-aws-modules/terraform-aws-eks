output "fargate_profile_ids" {
  description = "EKS Cluster name and EKS Fargate Profile names separated by a colon (:)."
  value       = [for f in aws_eks_fargate_profile.this : f.id]
}

output "fargate_profile_arns" {
  description = "Amazon Resource Name (ARN) of the EKS Fargate Profiles."
  value       = [for f in aws_eks_fargate_profile.this : f.arn]
}

output "iam_role_name" {
  description = "Name of IAM role created for EKS Fargate pods"
  value       = try(aws_iam_role.eks_fargate_pod[0].name, "")
}

output "iam_role_arn" {
  description = "ARN of IAM role of the EKS Fargate pods"
  value       = try(aws_iam_role.eks_fargate_pod[0].arn, var.fargate_pod_execution_role_arn, "")
}
