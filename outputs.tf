output "cluster_id" {
  description = "The name/id of the EKS cluster. Will block on cluster creation until the cluster is really ready."
  value       = try(aws_eks_cluster.this[0].id, "")
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster."
  value       = try(aws_eks_cluster.this[0].arn, "")
}

output "cluster_certificate_authority_data" {
  description = "Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster."
  value       = try(aws_eks_cluster.this[0].certificate_authority[0].data, "")
}

output "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API."
  value       = try(aws_eks_cluster.this[0].endpoint, "")
}

output "cluster_version" {
  description = "The Kubernetes server version for the EKS cluster."
  value       = try(aws_eks_cluster.this[0].version, "")
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
  value       = try(aws_eks_cluster.this[0].vpc_config[0].cluster_security_group_id, "")
}

output "cloudwatch_log_group_name" {
  description = "Name of cloudwatch log group created"
  value       = try(aws_cloudwatch_log_group.this[0].name, "")
}

output "cloudwatch_log_group_arn" {
  description = "Arn of cloudwatch log group created"
  value       = try(aws_cloudwatch_log_group.this[0].arn, "")
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`."
  value       = try(aws_iam_openid_connect_provider.oidc_provider[0].arn, "")
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

# output "security_group_rule_cluster_https_worker_ingress" {
#   description = "Security group rule responsible for allowing pods to communicate with the EKS cluster API."
#   value       = aws_security_group_rule.cluster_https_worker_ingress
# }

output "self_managed_node_groups" {
  description = "Map of attribute maps for all self managed node groups created"
  value = module.self_managed_node_groups
}

output "eks_managed_node_groups" {
  description = "Map of attribute maps for all EKS managed node groups created"
  value = module.eks_managed_node_groups
}