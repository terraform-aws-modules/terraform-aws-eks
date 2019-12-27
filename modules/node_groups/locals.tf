locals {
  # Trying to use `? var.node_groups : {}` does not work
  node_groups_keys  = toset(var.create_eks ? keys(var.node_groups) : [])
  node_groups_count = length(local.node_groups_keys)
  create_iam        = local.node_groups_count > 0
}
