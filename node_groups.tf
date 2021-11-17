module "node_groups" {
  source = "./modules/node_groups"

  create_eks = var.create_eks

  cluster_name        = local.cluster_name
  cluster_endpoint    = local.cluster_endpoint
  cluster_auth_base64 = local.cluster_auth_base64

  default_iam_role_arn                 = coalescelist(aws_iam_role.workers[*].arn, [""])[0]
  ebs_optimized_not_supported          = local.ebs_optimized_not_supported
  workers_group_defaults               = local.workers_group_defaults
  worker_security_group_id             = local.worker_security_group_id
  worker_additional_security_group_ids = var.worker_additional_security_group_ids

  node_groups_defaults = var.node_groups_defaults
  node_groups          = var.node_groups

  tags = var.tags

  depends_on = [
    aws_eks_cluster.this,
    aws_iam_role_policy_attachment.workers_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.workers_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.workers_AmazonEC2ContainerRegistryReadOnly
  ]
}
