# Hack to ensure ordering of resource creation. Do not create node_groups
# before other resources are ready. Removes race conditions
data "null_data_source" "node_groups" {
  count = var.create_eks ? 1 : 0

  inputs = {
    cluster_name = aws_eks_cluster.this[0].name

    # Ensure these resources are created before "unlocking" the data source.
    # `depends_on` causes a refresh on every run so is useless here.
    # [Re]creating or removing these resources will trigger recreation of Node Group resources
    aws_auth        = coalescelist(kubernetes_config_map.aws_auth[*].id, [""])[0]
    role_NodePolicy = coalescelist(aws_iam_role_policy_attachment.workers_AmazonEKSWorkerNodePolicy[*].id, [""])[0]
    role_CNI_Policy = coalescelist(aws_iam_role_policy_attachment.workers_AmazonEKS_CNI_Policy[*].id, [""])[0]
    role_Container  = coalescelist(aws_iam_role_policy_attachment.workers_AmazonEC2ContainerRegistryReadOnly[*].id, [""])[0]
  }
}

module "node_groups" {
  source                 = "./modules/node_groups"
  create_eks             = var.create_eks
  cluster_name           = coalescelist(data.null_data_source.node_groups[*].outputs["cluster_name"], [""])[0]
  default_iam_role_arn   = coalescelist(aws_iam_role.workers[*].arn, [""])[0]
  workers_group_defaults = local.workers_group_defaults
  tags                   = var.tags
  node_groups_defaults   = var.node_groups_defaults
  node_groups            = var.node_groups
}
