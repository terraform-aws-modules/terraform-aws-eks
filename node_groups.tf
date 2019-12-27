module "node_groups" {
  source                 = "./modules/node_groups"
  create_eks             = var.create_eks
  cluster_name           = var.cluster_name
  cluster_version        = coalescelist(aws_eks_cluster.this[*].version, [""])[0]
  workers_group_defaults = local.workers_group_defaults
  node_groups            = var.node_groups
  role_name              = var.node_groups_role_name
}
