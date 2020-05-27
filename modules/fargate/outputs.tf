output "iam_role_name" {
  description = "IAM role name for EKS Fargate pods"
  value       = element(concat(aws_iam_role.eks_fargate_pod.*.name, list("")), 0)
}

output "iam_role_arn" {
  description = "IAM role ARN for EKS Fargate pods"
  value       = element(concat(aws_iam_role.eks_fargate_pod.*.arn, list("")), 0)
}

output "aws_auth_roles" {
  description = "Roles for use in aws-auth ConfigMap"
  value = [
    for role in aws_iam_role.eks_fargate_pod : {
      worker_role_arn = role.arn
      platform        = "fargate"
    }
  ]
}
