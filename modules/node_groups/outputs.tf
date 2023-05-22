output "node_groups" {
  description = "Outputs from EKS node groups. Map of maps, keyed by `var.node_groups` keys. See `aws_eks_node_group` Terraform documentation for values"
  value       = aws_eks_node_group.workers
}

output "launch_templates" {
  value = aws_launch_template.workers
}

output "aws_auth_roles" {
  description = "Roles for use in aws-auth ConfigMap"
  sensitive = true
  value = [
    for k, v in local.node_groups_expanded : {
      worker_role_arn = lookup(v, "iam_role_arn", var.default_iam_role_arn)
      platform        = "linux"
    }
  ]
}
