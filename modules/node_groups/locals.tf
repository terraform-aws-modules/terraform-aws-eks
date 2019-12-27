locals {
  node_groups       = var.create_eks ? var.node_groups : {}
  node_groups_count = length(local.node_groups)
  create_iam        = local.node_groups_count > 0
}
