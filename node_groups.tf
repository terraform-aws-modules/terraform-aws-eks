module "node_groups" {
  source                 = "./modules/node_groups"
  create_eks             = var.create_eks
  cluster_name           = var.cluster_name
  cluster_version        = coalescelist(aws_eks_cluster.this[*].version, [""])[0]
  default_iam_role_arn   = coalescelist(aws_iam_role.workers[*].arn, [""])[0]
  workers_group_defaults = local.workers_group_defaults
  tags                   = var.tags
  node_groups_defaults   = var.node_groups_defaults
  node_groups            = var.node_groups
}
