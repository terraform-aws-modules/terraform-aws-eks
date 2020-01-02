output "iam_role_arns" {
  description = "IAM role ARNs for EKS node groups. Map, keyed by var.node_groups keys"
  value       = { for k, v in aws_eks_node_group.workers : k => v.node_role_arn }
}

output "aws_auth_roles" {
  description = "Roles for use in aws_auth ConfigMap"
  value = [
    for k, v in local.node_groups_expanded : {
      worker_role_arn = lookup(v, "iam_role_arn", var.default_iam_role_arn)
      platform        = "linux"
    }
  ]
}
