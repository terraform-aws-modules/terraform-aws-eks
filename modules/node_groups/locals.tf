locals {
  # Merge defaults and per-group values to make code cleaner
  node_groups_expanded = { for k, v in var.node_groups : k => merge(
    var.node_groups_defaults,
    v,
  ) if var.create_eks }
}
