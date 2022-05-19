locals {
  # Merge defaults and per-group values to make code cleaner
  node_groups_expanded = { for k, v in var.node_groups : k => merge(
    {
      iam_role_arn = var.default_iam_role_arn
    },
    var.node_groups_defaults,
    v,
  ) if var.create_eks }

  node_groups_names = { for k, v in local.node_groups_expanded : k => lookup(
    v,
    "name",
    lookup(
      v,
      "name_prefix",
      join("-", [var.cluster_name, k])
    )
  ) }
}
