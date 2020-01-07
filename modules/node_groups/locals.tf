locals {
  # Merge defaults and per-group values to make code cleaner
  node_groups_expanded = { for k, v in var.node_groups : k => merge(
    {
      desired_capacity = var.workers_group_defaults["asg_desired_capacity"]
      iam_role_arn     = var.default_iam_role_arn
      instance_type    = var.workers_group_defaults["instance_type"]
      key_name         = var.workers_group_defaults["key_name"]
      max_capacity     = var.workers_group_defaults["asg_max_size"]
      min_capacity     = var.workers_group_defaults["asg_min_size"]
      subnets          = var.workers_group_defaults["subnets"]
    },
    var.node_groups_defaults,
    v,
  ) if var.create_eks }
}
