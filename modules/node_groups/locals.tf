locals {
  # Trying to use `? var.node_groups : {}` does not work
  node_groups_keys = toset(var.create_eks ? keys(var.node_groups) : [])

  # Merge defaults and per-group values to make code cleaner
  node_groups_expanded = { for k, v in var.node_groups : k => merge(
    var.node_groups_defaults,
    v,
  ) }
}
