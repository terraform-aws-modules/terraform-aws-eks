output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks.cluster_security_group_id
}

output "sqs_queue_asg_notification_arn" {
  description = "SQS queue ASG notification ARN"
  value       = module.aws_node_termination_handler_sqs.sqs_queue_arn
}

output "sqs_queue_asg_notification_url" {
  description = "SQS queue ASG notification URL"
  value       = module.aws_node_termination_handler_sqs.sqs_queue_id
}
