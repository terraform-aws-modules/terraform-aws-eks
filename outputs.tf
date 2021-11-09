output "cluster_id" {
  description = "The name/id of the EKS cluster. Will block on cluster creation until the cluster is really ready."
  value       = local.cluster_id
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster."
  value       = local.cluster_arn
}

output "cluster_certificate_authority_data" {
  description = "Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster."
  value       = local.cluster_auth_base64
}

output "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API."
  value       = local.cluster_endpoint
}

output "cluster_version" {
  description = "The Kubernetes server version for the EKS cluster."
  value       = element(concat(aws_eks_cluster.this[*].version, [""]), 0)
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster. On 1.14 or later, this is the 'Additional security groups' in the EKS console."
  value       = local.cluster_security_group_id
}

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster."
  value       = try(aws_iam_role.cluster[0].name, "")
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster."
  value       = try(aws_iam_role.cluster[0].arn, "")
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = try(aws_eks_cluster.this[0].identity[0].oidc[0].issuer, "")
}

output "cluster_primary_security_group_id" {
  description = "The cluster primary security group ID created by the EKS cluster on 1.14 or later. Referred to as 'Cluster security group' in the EKS console."
  value       = local.cluster_primary_security_group_id
}

output "cloudwatch_log_group_name" {
  description = "Name of cloudwatch log group created"
  value       = element(concat(aws_cloudwatch_log_group.this[*].name, [""]), 0)
}

output "cloudwatch_log_group_arn" {
  description = "Arn of cloudwatch log group created"
  value       = element(concat(aws_cloudwatch_log_group.this[*].arn, [""]), 0)
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`."
  value       = var.enable_irsa ? concat(aws_iam_openid_connect_provider.oidc_provider[*].arn, [""])[0] : null
}

# output "workers_asg_arns" {
#   description = "IDs of the autoscaling groups containing workers."
#   value       = aws_autoscaling_group.this.*.arn
# }

# output "workers_asg_names" {
#   description = "Names of the autoscaling groups containing workers."
#   value       = aws_autoscaling_group.this.*.id
# }

# output "workers_default_ami_id" {
#   description = "ID of the default worker group AMI"
#   value       = local.default_ami_id_linux
# }

# output "workers_default_ami_id_windows" {
#   description = "ID of the default Windows worker group AMI"
#   value       = local.default_ami_id_windows
# }

# output "workers_launch_template_ids" {
#   description = "IDs of the worker launch templates."
#   value       = aws_launch_template.this.*.id
# }

# output "workers_launch_template_arns" {
#   description = "ARNs of the worker launch templates."
#   value       = aws_launch_template.this.*.arn
# }

# output "workers_launch_template_latest_versions" {
#   description = "Latest versions of the worker launch templates."
#   value       = aws_launch_template.this.*.latest_version
# }

output "worker_security_group_id" {
  description = "Security group ID attached to the EKS workers."
  value       = local.worker_security_group_id
}

output "worker_iam_instance_profile_arns" {
  description = "default IAM instance profile ARN for EKS worker groups"
  value       = aws_iam_instance_profile.worker.*.arn
}

output "worker_iam_instance_profile_names" {
  description = "default IAM instance profile name for EKS worker groups"
  value       = aws_iam_instance_profile.worker.*.name
}

output "worker_iam_role_name" {
  description = "default IAM role name for EKS worker groups"
  value       = try(aws_iam_role.worker[0].name, "")
}

output "worker_iam_role_arn" {
  description = "default IAM role ARN for EKS worker groups"
  value       = try(aws_iam_role.worker[0].arn, "")
}

output "fargate_profile_ids" {
  description = "EKS Cluster name and EKS Fargate Profile names separated by a colon (:)."
  value       = module.fargate.fargate_profile_ids
}

output "fargate_profile_arns" {
  description = "Amazon Resource Name (ARN) of the EKS Fargate Profiles."
  value       = module.fargate.fargate_profile_arns
}

output "fargate_iam_role_name" {
  description = "IAM role name for EKS Fargate pods"
  value       = module.fargate.iam_role_name
}

output "fargate_iam_role_arn" {
  description = "IAM role ARN for EKS Fargate pods"
  value       = module.fargate.iam_role_arn
}

output "security_group_rule_cluster_https_worker_ingress" {
  description = "Security group rule responsible for allowing pods to communicate with the EKS cluster API."
  value       = aws_security_group_rule.cluster_https_worker_ingress
}
