output "iam_role_arns" {
  description = "IAM role ARNs for EKS node groups. Map, keyed by var.node_groups keys"
  value       = { for k, v in var.node_groups : k => aws_eks_node_group.workers[k].node_role_arn }
}

output "aws_auth_snippet" {
  description = "Snippet for use in aws_auth ConfigMap"
  value       = distinct([for k, v in local.node_groups : data.template_file.node_group_arns[k].rendered])
}
