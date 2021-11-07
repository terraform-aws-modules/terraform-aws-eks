locals {
  # Merge defaults and per-group values to make code cleaner
  node_groups_expanded = { for k, v in var.node_groups : k => merge(
    {
      desired_capacity                     = var.node_default_settings["asg_desired_capacity"]
      iam_role_arn                         = var.default_iam_role_arn
      instance_types                       = [var.node_default_settings["instance_type"]]
      key_name                             = var.node_default_settings["key_name"]
      launch_template_id                   = var.node_default_settings["launch_template_id"]
      launch_template_version              = var.node_default_settings["launch_template_version"]
      set_instance_types_on_lt             = false
      max_capacity                         = var.node_default_settings["asg_max_size"]
      min_capacity                         = var.node_default_settings["asg_min_size"]
      subnets                              = var.node_default_settings["subnets"]
      create_launch_template               = false
      bootstrap_env                        = {}
      kubelet_extra_args                   = var.node_default_settings["kubelet_extra_args"]
      disk_size                            = var.node_default_settings["root_volume_size"]
      disk_type                            = var.node_default_settings["root_volume_type"]
      disk_iops                            = var.node_default_settings["root_iops"]
      disk_throughput                      = var.node_default_settings["root_volume_throughput"]
      disk_encrypted                       = var.node_default_settings["root_encrypted"]
      disk_kms_key_id                      = var.node_default_settings["root_kms_key_id"]
      enable_monitoring                    = var.node_default_settings["enable_monitoring"]
      eni_delete                           = var.node_default_settings["eni_delete"]
      public_ip                            = var.node_default_settings["public_ip"]
      pre_userdata                         = var.node_default_settings["pre_userdata"]
      additional_security_group_ids        = var.node_default_settings["additional_security_group_ids"]
      taints                               = []
      timeouts                             = var.node_default_settings["timeouts"]
      update_default_version               = true
      ebs_optimized                        = null
      metadata_http_endpoint               = var.node_default_settings["metadata_http_endpoint"]
      metadata_http_tokens                 = var.node_default_settings["metadata_http_tokens"]
      metadata_http_put_response_hop_limit = var.node_default_settings["metadata_http_put_response_hop_limit"]
      ami_is_eks_optimized                 = true
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
