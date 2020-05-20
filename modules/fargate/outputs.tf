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
    for index in range(0, local.create ? 1 : 0) : {
      worker_role_arn = element(concat(aws_iam_role.eks_fargate_pod.*.arn, list("")), 0)
      platform        = "fargate"
    }
  ]
}
