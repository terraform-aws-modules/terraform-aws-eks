output "aws_auth_roles" {
  description = "Roles for use in aws-auth ConfigMap"
  value = [
    for k, v in local.worker_group_configurations : {
      worker_role_arn = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${var.manage_worker_iam_resources ? aws_iam_instance_profile.workers[k].role : data.aws_iam_instance_profile.custom_worker_group_iam_instance_profile[k].role_name}"
      platform        = v["platform"]
    }
  ]
}

output "worker_groups" {
  description = "Outputs from EKS worker groups. Map of maps, keyed by `var.worker_groups` keys."
  value       = aws_autoscaling_group.workers
}

output "worker_iam_instance_profile_arns" {
  description = "default IAM instance profile ARN for EKS worker groups"
  value = {
    for k, v in local.worker_group_configurations :
    k => var.manage_worker_iam_resources ? aws_iam_instance_profile.workers[k].arn : data.aws_iam_instance_profile.custom_worker_group_iam_instance_profile[k].arn
  }
}

output "worker_iam_instance_profile_names" {
  description = "default IAM instance profile name for EKS worker groups"
  value = {
    for k, v in local.worker_group_configurations :
    k => var.manage_worker_iam_resources ? aws_iam_instance_profile.workers[k].name : data.aws_iam_instance_profile.custom_worker_group_iam_instance_profile[k].role_name
  }
}
