# Worker Groups using Launch Configurations

resource "aws_autoscaling_group" "workers" {
  count = var.create_eks ? local.worker_group_legacy_count : 0
  name_prefix = join(
    "-",
    compact(
      [
        coalescelist(aws_eks_cluster.this[*].name, [""])[0],
        lookup(var.worker_groups_legacy[count.index], "name", count.index),
      ]
    )
  )
  desired_capacity = lookup(
    var.worker_groups_legacy[count.index],
    "asg_desired_capacity",
    local.workers_group_defaults["asg_desired_capacity"],
  )
  max_size = lookup(
    var.worker_groups_legacy[count.index],
    "asg_max_size",
    local.workers_group_defaults["asg_max_size"],
  )
  min_size = lookup(
    var.worker_groups_legacy[count.index],
    "asg_min_size",
    local.workers_group_defaults["asg_min_size"],
  )
  force_delete = lookup(
    var.worker_groups_legacy[count.index],
    "asg_force_delete",
    local.workers_group_defaults["asg_force_delete"],
  )
  target_group_arns = lookup(
    var.worker_groups_legacy[count.index],
    "target_group_arns",
    local.workers_group_defaults["target_group_arns"]
  )
  load_balancers = lookup(
    var.worker_groups_legacy[count.index],
    "load_balancers",
    local.workers_group_defaults["load_balancers"]
  )
  service_linked_role_arn = lookup(
    var.worker_groups_legacy[count.index],
    "service_linked_role_arn",
    local.workers_group_defaults["service_linked_role_arn"],
  )
  launch_configuration = aws_launch_configuration.workers.*.id[count.index]
  vpc_zone_identifier = lookup(
    var.worker_groups_legacy[count.index],
    "subnets",
    local.workers_group_defaults["subnets"]
  )
  protect_from_scale_in = lookup(
    var.worker_groups_legacy[count.index],
    "protect_from_scale_in",
    local.workers_group_defaults["protect_from_scale_in"],
  )
  suspended_processes = lookup(
    var.worker_groups_legacy[count.index],
    "suspended_processes",
    local.workers_group_defaults["suspended_processes"]
  )
  enabled_metrics = lookup(
    var.worker_groups_legacy[count.index],
    "enabled_metrics",
    local.workers_group_defaults["enabled_metrics"]
  )
  placement_group = lookup(
    var.worker_groups_legacy[count.index],
    "placement_group",
    local.workers_group_defaults["placement_group"],
  )
  termination_policies = lookup(
    var.worker_groups_legacy[count.index],
    "termination_policies",
    local.workers_group_defaults["termination_policies"]
  )
  max_instance_lifetime = lookup(
    var.worker_groups_legacy[count.index],
    "max_instance_lifetime",
    local.workers_group_defaults["max_instance_lifetime"],
  )
  default_cooldown = lookup(
    var.worker_groups_legacy[count.index],
    "default_cooldown",
    local.workers_group_defaults["default_cooldown"]
  )
  health_check_type = lookup(
    var.worker_groups_legacy[count.index],
    "health_check_type",
    local.workers_group_defaults["health_check_type"]
  )
  health_check_grace_period = lookup(
    var.worker_groups_legacy[count.index],
    "health_check_grace_period",
    local.workers_group_defaults["health_check_grace_period"]
  )
  capacity_rebalance = lookup(
    var.worker_groups_legacy[count.index],
    "capacity_rebalance",
    local.workers_group_defaults["capacity_rebalance"]
  )

  dynamic "initial_lifecycle_hook" {
    for_each = var.worker_create_initial_lifecycle_hooks ? lookup(var.worker_groups_legacy[count.index], "asg_initial_lifecycle_hooks", local.workers_group_defaults["asg_initial_lifecycle_hooks"]) : []
    content {
      name                    = initial_lifecycle_hook.value["name"]
      lifecycle_transition    = initial_lifecycle_hook.value["lifecycle_transition"]
      notification_metadata   = lookup(initial_lifecycle_hook.value, "notification_metadata", null)
      heartbeat_timeout       = lookup(initial_lifecycle_hook.value, "heartbeat_timeout", null)
      notification_target_arn = lookup(initial_lifecycle_hook.value, "notification_target_arn", null)
      role_arn                = lookup(initial_lifecycle_hook.value, "role_arn", null)
      default_result          = lookup(initial_lifecycle_hook.value, "default_result", null)
    }
  }

  dynamic "warm_pool" {
    for_each = lookup(var.worker_groups_legacy[count.index], "warm_pool", null) != null ? [lookup(var.worker_groups_legacy[count.index], "warm_pool")] : []

    content {
      pool_state                  = lookup(warm_pool.value, "pool_state", null)
      min_size                    = lookup(warm_pool.value, "min_size", null)
      max_group_prepared_capacity = lookup(warm_pool.value, "max_group_prepared_capacity", null)
    }
  }

  dynamic "tag" {
    for_each = concat(
      [
        {
          "key"                 = "Name"
          "value"               = "${coalescelist(aws_eks_cluster.this[*].name, [""])[0]}-${lookup(var.worker_groups_legacy[count.index], "name", count.index)}-eks_asg"
          "propagate_at_launch" = true
        },
        {
          "key"                 = "kubernetes.io/cluster/${coalescelist(aws_eks_cluster.this[*].name, [""])[0]}"
          "value"               = "owned"
          "propagate_at_launch" = true
        },
        {
          "key"                 = "k8s.io/cluster/${coalescelist(aws_eks_cluster.this[*].name, [""])[0]}"
          "value"               = "owned"
          "propagate_at_launch" = true
        },
      ],
      [
        for tag_key, tag_value in var.tags :
        {
          "key"                 = tag_key,
          "value"               = tag_value,
          "propagate_at_launch" = "true"
        }
        if tag_key != "Name" && !contains([for tag in lookup(var.worker_groups_legacy[count.index], "tags", local.workers_group_defaults["tags"]) : tag["key"]], tag_key)
      ],
      lookup(
        var.worker_groups_legacy[count.index],
        "tags",
        local.workers_group_defaults["tags"]
      )
    )
    content {
      key                 = tag.value.key
      value               = tag.value.value
      propagate_at_launch = tag.value.propagate_at_launch
    }
  }

  # logic duplicated in workers_launch_template.tf
  dynamic "instance_refresh" {
    for_each = lookup(var.worker_groups_legacy[count.index],
      "instance_refresh_enabled",
    local.workers_group_defaults["instance_refresh_enabled"]) ? [1] : []
    content {
      strategy = lookup(
        var.worker_groups_legacy[count.index], "instance_refresh_strategy",
        local.workers_group_defaults["instance_refresh_strategy"]
      )
      preferences {
        instance_warmup = lookup(
          var.worker_groups_legacy[count.index], "instance_refresh_instance_warmup",
          local.workers_group_defaults["instance_refresh_instance_warmup"]
        )
        min_healthy_percentage = lookup(
          var.worker_groups_legacy[count.index], "instance_refresh_min_healthy_percentage",
          local.workers_group_defaults["instance_refresh_min_healthy_percentage"]
        )
      }
      triggers = lookup(
        var.worker_groups_legacy[count.index], "instance_refresh_triggers",
        local.workers_group_defaults["instance_refresh_triggers"]
      )
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

resource "aws_launch_configuration" "workers" {
  count       = var.create_eks ? local.worker_group_legacy_count : 0
  name_prefix = "${coalescelist(aws_eks_cluster.this[*].name, [""])[0]}-${lookup(var.worker_groups_legacy[count.index], "name", count.index)}"
  associate_public_ip_address = lookup(
    var.worker_groups_legacy[count.index],
    "public_ip",
    local.workers_group_defaults["public_ip"],
  )
  security_groups = flatten([
    local.worker_security_group_id,
    var.worker_additional_security_group_ids,
    lookup(
      var.worker_groups_legacy[count.index],
      "additional_security_group_ids",
      local.workers_group_defaults["additional_security_group_ids"]
    )
  ])
  iam_instance_profile = coalescelist(
    aws_iam_instance_profile.workers.*.id,
    data.aws_iam_instance_profile.custom_worker_group_iam_instance_profile.*.name,
  )[count.index]
  image_id = lookup(
    var.worker_groups_legacy[count.index],
    "ami_id",
    lookup(var.worker_groups_legacy[count.index], "platform", local.workers_group_defaults["platform"]) == "windows" ? local.default_ami_id_windows : local.default_ami_id_linux,
  )
  instance_type = lookup(
    var.worker_groups_legacy[count.index],
    "instance_type",
    local.workers_group_defaults["instance_type"],
  )
  key_name = lookup(
    var.worker_groups_legacy[count.index],
    "key_name",
    local.workers_group_defaults["key_name"],
  )
  user_data_base64 = base64encode(local.userdata_rendered[count.index])
  ebs_optimized = lookup(
    var.worker_groups_legacy[count.index],
    "ebs_optimized",
    !contains(
      local.ebs_optimized_not_supported,
      lookup(
        var.worker_groups_legacy[count.index],
        "instance_type",
        local.workers_group_defaults["instance_type"]
      )
    )
  )
  enable_monitoring = lookup(
    var.worker_groups_legacy[count.index],
    "enable_monitoring",
    local.workers_group_defaults["enable_monitoring"],
  )
  spot_price = lookup(
    var.worker_groups_legacy[count.index],
    "spot_price",
    local.workers_group_defaults["spot_price"],
  )
  placement_tenancy = lookup(
    var.worker_groups_legacy[count.index],
    "placement_tenancy",
    local.workers_group_defaults["placement_tenancy"],
  )

  metadata_options {
    http_endpoint = lookup(
      var.worker_groups_legacy[count.index],
      "metadata_http_endpoint",
      local.workers_group_defaults["metadata_http_endpoint"],
    )
    http_tokens = lookup(
      var.worker_groups_legacy[count.index],
      "metadata_http_tokens",
      local.workers_group_defaults["metadata_http_tokens"],
    )
    http_put_response_hop_limit = lookup(
      var.worker_groups_legacy[count.index],
      "metadata_http_put_response_hop_limit",
      local.workers_group_defaults["metadata_http_put_response_hop_limit"],
    )
  }

  root_block_device {
    encrypted = lookup(
      var.worker_groups_legacy[count.index],
      "root_encrypted",
      local.workers_group_defaults["root_encrypted"],
    )
    volume_size = lookup(
      var.worker_groups_legacy[count.index],
      "root_volume_size",
      local.workers_group_defaults["root_volume_size"],
    )
    volume_type = lookup(
      var.worker_groups_legacy[count.index],
      "root_volume_type",
      local.workers_group_defaults["root_volume_type"],
    )
    iops = lookup(
      var.worker_groups_legacy[count.index],
      "root_iops",
      local.workers_group_defaults["root_iops"],
    )
    delete_on_termination = true
  }

  dynamic "ebs_block_device" {
    for_each = lookup(var.worker_groups_legacy[count.index], "additional_ebs_volumes", local.workers_group_defaults["additional_ebs_volumes"])

    content {
      device_name = ebs_block_device.value.block_device_name
      volume_size = lookup(
        ebs_block_device.value,
        "volume_size",
        local.workers_group_defaults["root_volume_size"],
      )
      volume_type = lookup(
        ebs_block_device.value,
        "volume_type",
        local.workers_group_defaults["root_volume_type"],
      )
      iops = lookup(
        ebs_block_device.value,
        "iops",
        local.workers_group_defaults["root_iops"],
      )
      encrypted = lookup(
        ebs_block_device.value,
        "encrypted",
        local.workers_group_defaults["root_encrypted"],
      )
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", true)
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  # Prevent premature access of security group roles and policies by pods that
  # require permissions on create/destroy that depend on workers.
  depends_on = [
    aws_security_group_rule.workers_egress_internet,
    aws_security_group_rule.workers_ingress_self,
    aws_security_group_rule.workers_ingress_cluster,
    aws_security_group_rule.workers_ingress_cluster_kubelet,
    aws_security_group_rule.workers_ingress_cluster_https,
    aws_security_group_rule.workers_ingress_cluster_primary,
    aws_security_group_rule.cluster_primary_ingress_workers,
    aws_iam_role_policy_attachment.workers_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.workers_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.workers_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.workers_additional_policies
  ]
}

resource "aws_iam_instance_profile" "workers" {
  count       = var.manage_worker_iam_resources && var.create_eks ? local.worker_group_legacy_count : 0
  name_prefix = coalescelist(aws_eks_cluster.this[*].name, [""])[0]
  role = lookup(
    var.worker_groups_legacy[count.index],
    "iam_role_id",
    local.default_iam_role_id,
  )

  path = var.iam_path
  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}
