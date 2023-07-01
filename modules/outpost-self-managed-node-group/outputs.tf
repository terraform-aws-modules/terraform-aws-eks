output "placement_group_arn" {
  description = "Node asg group id"
  value       = aws_placement_group.this.arn
}

output "placement_group_name" {
  description = "Node placement group name"
  value       = aws_placement_group.this.name
}

output "self_managed_node_group_iam_role" {
  description = "Node asg group name"
  value       = module.self_managed_node_group.iam_role_arn
}

output "security_group_id" {
  description = "Node asg group name"
  value       = aws_security_group.this.id
}
