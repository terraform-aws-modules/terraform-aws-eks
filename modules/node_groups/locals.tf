locals {
  # Merge defaults and per-group values to make code cleaner
  node_groups_expanded = { for k, v in var.node_groups : k => merge(
    {
      desired_capacity              = var.workers_group_defaults["asg_desired_capacity"]
      iam_role_arn                  = var.default_iam_role_arn
      instance_types                = [var.workers_group_defaults["instance_type"]]
      key_name                      = var.workers_group_defaults["key_name"]
      launch_template_id            = var.workers_group_defaults["launch_template_id"]
      launch_template_version       = var.workers_group_defaults["launch_template_version"]
      set_instance_types_on_lt      = false
      max_capacity                  = var.workers_group_defaults["asg_max_size"]
      min_capacity                  = var.workers_group_defaults["asg_min_size"]
      subnets                       = var.workers_group_defaults["subnets"]
      create_launch_template        = false
      kubelet_extra_args            = var.workers_group_defaults["kubelet_extra_args"]
      disk_size                     = var.workers_group_defaults["root_volume_size"]
      disk_type                     = var.workers_group_defaults["root_volume_type"]
      enable_monitoring             = var.workers_group_defaults["enable_monitoring"]
      eni_delete                    = var.workers_group_defaults["eni_delete"]
      public_ip                     = var.workers_group_defaults["public_ip"]
      pre_userdata                  = var.workers_group_defaults["pre_userdata"]
      additional_security_group_ids = var.workers_group_defaults["additional_security_group_ids"]
      taints                        = []
    },
    var.node_groups_defaults,
    v,
  ) if var.create_eks }

  # This node_groups_names construct is a consequence of not explicitly
  # declaring the node_group object.
  #
  # lookup will *always* return the default condition if an attribute exists,
  # but Terraform will set an attribute to null when it is supposed to be
  # omitted -- the attribute will exist, but shouldn't be used.
  #
  # With the decision to implicitly define the node_group object, we have to
  # first check if an attribute exists, and then check if the attribute is null
  # if it does exist. We cannot take a shortcut by chaining the lookups in the
  # default condition, since the default condition will not be reached if the
  # attribute exists and is null.
  #
  # It would be ideal to rework this module to explicitly declare
  # the node_group object, as that would simplify the logic.
  #
  # For more information, refer to this issue:
  # https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1462
  node_groups_names = { for k, v in local.node_groups_expanded : k => lookup(v, "name", null) != null ? v["name"] : lookup(v, "name_prefix", null) != null ? v["name_prefix"] : join("-", [var.cluster_name, k]) }
}
