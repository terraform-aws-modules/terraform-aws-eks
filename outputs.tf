output "cluster_id" {
  description = "The name/id of the EKS cluster."
  value       = element(concat(aws_eks_cluster.this.*.id, tolist([""])), 0)
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster."
  value       = element(concat(aws_eks_cluster.this.*.arn, tolist([""])), 0)
}

output "cluster_certificate_authority_data" {
  description = "Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster."
  value       = element(concat(aws_eks_cluster.this[*].certificate_authority[0].data, tolist([""])), 0)
}

output "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API."
  value       = element(concat(aws_eks_cluster.this.*.endpoint, tolist([""])), 0)
}

output "cluster_version" {
  description = "The Kubernetes server version for the EKS cluster."
  value       = element(concat(aws_eks_cluster.this[*].version, tolist([""])), 0)
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster."
  value       = local.cluster_security_group_id
}

output "config_map_aws_auth" {
  description = "A kubernetes configuration to authenticate to this EKS cluster."
  value       = kubernetes_config_map.aws_auth.*
}

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster."
  value       = local.cluster_iam_role_name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster."
  value       = local.cluster_iam_role_arn
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = flatten(concat(aws_eks_cluster.this[*].identity[*].oidc.0.issuer, [""]))[0]
}

output "cloudwatch_log_group_name" {
  description = "Name of cloudwatch log group created"
  value       = aws_cloudwatch_log_group.this[*].name
}

output "kubeconfig" {
  description = "kubectl config file contents for this EKS cluster."
  value       = concat(data.template_file.kubeconfig[*].rendered, [""])[0]
}

output "kubeconfig_filename" {
  description = "The filename of the generated kubectl config."
  value       = concat(local_file.kubeconfig.*.filename, [""])[0]
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`."
  value       = var.enable_irsa ? concat(aws_iam_openid_connect_provider.oidc_provider[*].arn, [""])[0] : null
}
output "worker_iam_role_name" {
  description = "default IAM role name for EKS worker groups"
  value = coalescelist(
    aws_iam_role.workers.*.name,
    [""]
  )[0]
}

output "worker_iam_role_arn" {
  description = "default IAM role ARN for EKS worker groups"
  value = coalescelist(
    aws_iam_role.workers.*.arn,
    [""]
  )[0]
}

output "node_groups" {
  description = "Outputs from EKS node groups. Map of maps, keyed by var.node_groups keys"
  value       = module.node_groups.node_groups
}

output "node_group_LTs" {
  value = module.node_groups.launch_templates
}

output "worker_security_group_id" {
  description = "security groups id for the worker nodes"
  value       = local.worker_security_group_id
}

output "worker_iam_arn" {
  description = "IAM Role ARN for worker groups"
  value       = join("", aws_iam_role.workers.*.arn)
}

output "worker_iam_name" {
  description = "IAM Role name for worker groups"
  value       = join("", aws_iam_role.workers.*.name)
}