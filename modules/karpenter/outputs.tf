################################################################################
# IAM Role for Service Account (IRSA)
################################################################################

output "irsa_name" {
  description = "The name of the IAM role for service accounts"
  value       = try(aws_iam_role.irsa[0].name, null)
}

output "irsa_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role for service accounts"
  value       = try(aws_iam_role.irsa[0].arn, null)
}

output "irsa_unique_id" {
  description = "Stable and unique string identifying the IAM role for service accounts"
  value       = try(aws_iam_role.irsa[0].unique_id, null)
}

################################################################################
# Node Termination Queue
################################################################################

output "queue_arn" {
  description = "The ARN of the SQS queue"
  value       = try(aws_sqs_queue.this[0].arn, null)
}

output "queue_name" {
  description = "The name of the created Amazon SQS queue"
  value       = try(aws_sqs_queue.this[0].name, null)
}

output "queue_url" {
  description = "The URL for the created Amazon SQS queue"
  value       = try(aws_sqs_queue.this[0].url, null)
}

################################################################################
# Node Termination Event Rules
################################################################################

output "event_rules" {
  description = "Map of the event rules created and their attributes"
  value       = aws_cloudwatch_event_rule.this
}

################################################################################
# Node IAM Role
################################################################################

output "role_name" {
  description = "The name of the IAM role"
  value       = try(aws_iam_role.this[0].name, null)
}

output "role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = try(aws_iam_role.this[0].arn, var.iam_role_arn)
}

output "role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = try(aws_iam_role.this[0].unique_id, null)
}

################################################################################
# Node IAM Instance Profile
################################################################################

output "instance_profile_arn" {
  description = "ARN assigned by AWS to the instance profile"
  value       = try(aws_iam_instance_profile.this[0].arn, null)
}

output "instance_profile_id" {
  description = "Instance profile's ID"
  value       = try(aws_iam_instance_profile.this[0].id, null)
}

output "instance_profile_name" {
  description = "Name of the instance profile"
  value       = try(aws_iam_instance_profile.this[0].name, null)
}

output "instance_profile_unique" {
  description = "Stable and unique string identifying the IAM instance profile"
  value       = try(aws_iam_instance_profile.this[0].unique_id, null)
}
