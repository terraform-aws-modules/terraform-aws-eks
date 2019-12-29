output "iam_role_arns" {
  description = "IAM role ARNs for EKS node groups. Map, keyed by var.node_groups keys"
  value       = { for k, v in aws_eks_node_group.workers : k => v.node_role_arn }
}

output "aws_auth_snippet" {
  description = "Snippet for use in aws_auth ConfigMap"
  value       = distinct([for k, v in data.template_file.node_group_arns : v.rendered])
}
