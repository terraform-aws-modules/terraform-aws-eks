################################################################################
# Node IAM Role
################################################################################

output "name" {
  description = "The name of the node IAM role"
  value       = try(aws_iam_role.this[0].name, null)
}

output "arn" {
  description = "The Amazon Resource Name (ARN) specifying the node IAM role"
  value       = try(aws_iam_role.this[0].arn, null)
}

output "unique_id" {
  description = "Stable and unique string identifying the node IAM role"
  value       = try(aws_iam_role.this[0].unique_id, null)
}

################################################################################
# Intermedaite IAM Role
################################################################################

output "intermediate_role_name" {
  description = "The name of the node IAM role"
  value       = try(aws_iam_role.intermediate[0].name, null)
}

output "intermediate_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the node IAM role"
  value       = try(aws_iam_role.intermediate[0].arn, null)
}

output "intermediate_role_unique_id" {
  description = "Stable and unique string identifying the node IAM role"
  value       = try(aws_iam_role.intermediate[0].unique_id, null)
}
