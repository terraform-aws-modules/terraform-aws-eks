################################################################################
# Launch template
################################################################################

output "launch_template_id" {
  description = "The ID of the launch template"
  value       = try(aws_launch_template.this[0].id, null)
}

output "launch_template_arn" {
  description = "The ARN of the launch template"
  value       = try(aws_launch_template.this[0].arn, null)
}

output "launch_template_latest_version" {
  description = "The latest version of the launch template"
  value       = try(aws_launch_template.this[0].latest_version, null)
}

output "launch_template_name" {
  description = "The name of the launch template"
  value       = try(aws_launch_template.this[0].name, null)
}

################################################################################
# Node Group
################################################################################

output "node_group_arn" {
  description = "Amazon Resource Name (ARN) of the EKS Node Group"
  value       = try(aws_eks_node_group.this[0].arn, null)
}

output "node_group_id" {
  description = "EKS Cluster name and EKS Node Group name separated by a colon (`:`)"
  value       = try(aws_eks_node_group.this[0].id, null)
}

output "node_group_resources" {
  description = "List of objects containing information about underlying resources"
  value       = try(aws_eks_node_group.this[0].resources, null)
}

output "node_group_autoscaling_group_names" {
  description = "List of the autoscaling group names"
  value       = try(flatten(aws_eks_node_group.this[0].resources[*].autoscaling_groups[*].name), [])
}

output "node_group_status" {
  description = "Status of the EKS Node Group"
  value       = try(aws_eks_node_group.this[0].status, null)
}

output "node_group_labels" {
  description = "Map of labels applied to the node group"
  value       = try(aws_eks_node_group.this[0].labels, {})
}

output "node_group_taints" {
  description = "List of objects containing information about taints applied to the node group"
  value       = try(aws_eks_node_group.this[0].taint, [])
}

################################################################################
# Autoscaling Group Schedule
################################################################################

output "autoscaling_group_schedule_arns" {
  description = "ARNs of autoscaling group schedules"
  value       = { for k, v in aws_autoscaling_schedule.this : k => v.arn }
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
  value       = try(aws_iam_role.this[0].arn, var.iam_role_arn)
}

output "iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = try(aws_iam_role.this[0].unique_id, null)
}

################################################################################
# Additional
################################################################################

output "platform" {
  description = "Identifies if the OS platform is `bottlerocket`, `linux`, or `windows` based"
  value       = var.platform
}
