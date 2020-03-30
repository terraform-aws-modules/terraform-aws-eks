# Worker Groups using Launch Templates

resource "aws_autoscaling_group" "workers_launch_template" {
  count = var.create_eks ? local.worker_group_launch_template_count : 0
  name_prefix = join(
    "-",
    compact(
      [
        aws_eks_cluster.this[0].name,
        lookup(var.worker_groups_launch_template[count.index], "name", count.index),
        lookup(var.worker_groups_launch_template[count.index], "asg_recreate_on_change", local.workers_group_defaults["asg_recreate_on_change"]) ? random_pet.workers_launch_template[count.index].id : ""
      ]
    )
  )
  desired_capacity = lookup(
    var.worker_groups_launch_template[count.index],
    "asg_desired_capacity",
    local.workers_group_defaults["asg_desired_capacity"],
  )
  max_size = lookup(
    var.worker_groups_launch_template[count.index],
    "asg_max_size",
    local.workers_group_defaults["asg_max_size"],
  )
  min_size = lookup(
    var.worker_groups_launch_template[count.index],
    "asg_min_size",
    local.workers_group_defaults["asg_min_size"],
  )
  force_delete = lookup(
    var.worker_groups_launch_template[count.index],
    "asg_force_delete",
    local.workers_group_defaults["asg_force_delete"],
  )
  target_group_arns = lookup(
    var.worker_groups_launch_template[count.index],
    "target_group_arns",
    local.workers_group_defaults["target_group_arns"]
  )
  service_linked_role_arn = lookup(
    var.worker_groups_launch_template[count.index],
    "service_linked_role_arn",
    local.workers_group_defaults["service_linked_role_arn"],
  )
  vpc_zone_identifier = lookup(
    var.worker_groups_launch_template[count.index],
    "subnets",
    local.workers_group_defaults["subnets"]
  )
  protect_from_scale_in = lookup(
    var.worker_groups_launch_template[count.index],
    "protect_from_scale_in",
    local.workers_group_defaults["protect_from_scale_in"],
  )
  suspended_processes = lookup(
    var.worker_groups_launch_template[count.index],
    "suspended_processes",
    local.workers_group_defaults["suspended_processes"]
  )
  enabled_metrics = lookup(
    var.worker_groups_launch_template[count.index],
    "enabled_metrics",
    local.workers_group_defaults["enabled_metrics"]
  )
  placement_group = lookup(
    var.worker_groups_launch_template[count.index],
    "placement_group",
    local.workers_group_defaults["placement_group"],
  )
  termination_policies = lookup(
    var.worker_groups_launch_template[count.index],
    "termination_policies",
    local.workers_group_defaults["termination_policies"]
  )
  max_instance_lifetime = lookup(
    var.worker_groups_launch_template[count.index],
    "max_instance_lifetime",
    local.workers_group_defaults["max_instance_lifetime"],
  )
  default_cooldown = lookup(
    var.worker_groups_launch_template[count.index],
    "default_cooldown",
    local.workers_group_defaults["default_cooldown"]
  )
  health_check_grace_period = lookup(
    var.worker_groups_launch_template[count.index],
    "health_check_grace_period",
    local.workers_group_defaults["health_check_grace_period"]
  )

  dynamic mixed_instances_policy {
    iterator = item
    for_each = (lookup(var.worker_groups_launch_template[count.index], "override_instance_types", null) != null) || (lookup(var.worker_groups_launch_template[count.index], "on_demand_allocation_strategy", null) != null) ? list(var.worker_groups_launch_template[count.index]) : []

    content {
      instances_distribution {
        on_demand_allocation_strategy = lookup(
          item.value,
          "on_demand_allocation_strategy",
          "prioritized",
        )
        on_demand_base_capacity = lookup(
          item.value,
          "on_demand_base_capacity",
          local.workers_group_defaults["on_demand_base_capacity"],
        )
        on_demand_percentage_above_base_capacity = lookup(
          item.value,
          "on_demand_percentage_above_base_capacity",
          local.workers_group_defaults["on_demand_percentage_above_base_capacity"],
        )
        spot_allocation_strategy = lookup(
          item.value,
          "spot_allocation_strategy",
          local.workers_group_defaults["spot_allocation_strategy"],
        )
        spot_instance_pools = lookup(
          item.value,
          "spot_instance_pools",
          local.workers_group_defaults["spot_instance_pools"],
        )
        spot_max_price = lookup(
          item.value,
          "spot_max_price",
          local.workers_group_defaults["spot_max_price"],
        )
      }

      launch_template {
        launch_template_specification {
          launch_template_id = aws_launch_template.workers_launch_template.*.id[count.index]
          version = lookup(
            var.worker_groups_launch_template[count.index],
            "launch_template_version",
            local.workers_group_defaults["launch_template_version"],
          )
        }

        dynamic "override" {
          for_each = lookup(
            var.worker_groups_launch_template[count.index],
            "override_instance_types",
            local.workers_group_defaults["override_instance_types"]
          )

          content {
            instance_type = override.value
          }
        }

      }
    }
  }
  dynamic launch_template {
    iterator = item
    for_each = (lookup(var.worker_groups_launch_template[count.index], "override_instance_types", null) != null) || (lookup(var.worker_groups_launch_template[count.index], "on_demand_allocation_strategy", null) != null) ? [] : list(var.worker_groups_launch_template[count.index])

    content {
      id = aws_launch_template.workers_launch_template.*.id[count.index]
      version = lookup(
        var.worker_groups_launch_template[count.index],
        "launch_template_version",
        local.workers_group_defaults["launch_template_version"],
      )
    }
  }

  dynamic "initial_lifecycle_hook" {
    for_each = var.worker_create_initial_lifecycle_hooks ? lookup(var.worker_groups_launch_template[count.index], "asg_initial_lifecycle_hooks", local.workers_group_defaults["asg_initial_lifecycle_hooks"]) : []
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

  tags = concat(
    [
      {
        "key" = "Name"
        "value" = "${aws_eks_cluster.this[0].name}-${lookup(
          var.worker_groups_launch_template[count.index],
          "name",
          count.index,
        )}-eks_asg"
        "propagate_at_launch" = true
      },
      {
        "key"                 = "kubernetes.io/cluster/${aws_eks_cluster.this[0].name}"
        "value"               = "owned"
        "propagate_at_launch" = true
      },
    ],
    local.asg_tags,
    lookup(
      var.worker_groups_launch_template[count.index],
      "tags",
      local.workers_group_defaults["tags"]
    )
  )

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

resource "aws_launch_template" "workers_launch_template" {
  count = var.create_eks ? (local.worker_group_launch_template_count) : 0
  name_prefix = "${aws_eks_cluster.this[0].name}-${lookup(
    var.worker_groups_launch_template[count.index],
    "name",
    count.index,
  )}"

  network_interfaces {
    associate_public_ip_address = lookup(
      var.worker_groups_launch_template[count.index],
      "public_ip",
      local.workers_group_defaults["public_ip"],
    )
    delete_on_termination = lookup(
      var.worker_groups_launch_template[count.index],
      "eni_delete",
      local.workers_group_defaults["eni_delete"],
    )
    security_groups = flatten([
      local.worker_security_group_id,
      var.worker_additional_security_group_ids,
      lookup(
        var.worker_groups_launch_template[count.index],
        "additional_security_group_ids",
        local.workers_group_defaults["additional_security_group_ids"],
      ),
    ])
  }

  iam_instance_profile {
    name = coalescelist(
      aws_iam_instance_profile.workers_launch_template.*.name,
      data.aws_iam_instance_profile.custom_worker_group_launch_template_iam_instance_profile.*.name,
    )[count.index]
  }

  image_id = lookup(
    var.worker_groups_launch_template[count.index],
    "ami_id",
    lookup(var.worker_groups_launch_template[count.index], "platform", local.workers_group_defaults["platform"]) == "windows" ? local.default_ami_id_windows : local.default_ami_id_linux,
  )
  instance_type = lookup(
    var.worker_groups_launch_template[count.index],
    "instance_type",
    local.workers_group_defaults["instance_type"],
  )
  key_name = lookup(
    var.worker_groups_launch_template[count.index],
    "key_name",
    local.workers_group_defaults["key_name"],
  )
  user_data = base64encode(
    data.template_file.launch_template_userdata.*.rendered[count.index],
  )

  ebs_optimized = lookup(
    var.worker_groups_launch_template[count.index],
    "ebs_optimized",
    ! contains(
      local.ebs_optimized_not_supported,
      lookup(
        var.worker_groups_launch_template[count.index],
        "instance_type",
        local.workers_group_defaults["instance_type"],
      )
    )
  )

  credit_specification {
    cpu_credits = lookup(
      var.worker_groups_launch_template[count.index],
      "cpu_credits",
      local.workers_group_defaults["cpu_credits"]
    )
  }

  monitoring {
    enabled = lookup(
      var.worker_groups_launch_template[count.index],
      "enable_monitoring",
      local.workers_group_defaults["enable_monitoring"],
    )
  }

  placement {
    tenancy = lookup(
      var.worker_groups_launch_template[count.index],
      "launch_template_placement_tenancy",
      local.workers_group_defaults["launch_template_placement_tenancy"],
    )
    group_name = lookup(
      var.worker_groups_launch_template[count.index],
      "launch_template_placement_group",
      local.workers_group_defaults["launch_template_placement_group"],
    )
  }

  dynamic instance_market_options {
    for_each = lookup(var.worker_groups_launch_template[count.index], "market_type", null) == null ? [] : list(lookup(var.worker_groups_launch_template[count.index], "market_type", null))
    content {
      market_type = instance_market_options.value
    }
  }

  block_device_mappings {
    device_name = lookup(
      var.worker_groups_launch_template[count.index],
      "root_block_device_name",
      local.workers_group_defaults["root_block_device_name"],
    )

    ebs {
      volume_size = lookup(
        var.worker_groups_launch_template[count.index],
        "root_volume_size",
        local.workers_group_defaults["root_volume_size"],
      )
      volume_type = lookup(
        var.worker_groups_launch_template[count.index],
        "root_volume_type",
        local.workers_group_defaults["root_volume_type"],
      )
      iops = lookup(
        var.worker_groups_launch_template[count.index],
        "root_iops",
        local.workers_group_defaults["root_iops"],
      )
      encrypted = lookup(
        var.worker_groups_launch_template[count.index],
        "root_encrypted",
        local.workers_group_defaults["root_encrypted"],
      )
      kms_key_id = lookup(
        var.worker_groups_launch_template[count.index],
        "root_kms_key_id",
        local.workers_group_defaults["root_kms_key_id"],
      )
      delete_on_termination = true
    }
  }

  dynamic "block_device_mappings" {
    for_each = lookup(var.worker_groups_launch_template[count.index], "additional_ebs_volumes", local.workers_group_defaults["additional_ebs_volumes"])
    content {
      device_name = block_device_mappings.value.block_device_name

      ebs {
        volume_size = lookup(
          block_device_mappings.value,
          "volume_size",
          local.workers_group_defaults["root_volume_size"],
        )
        volume_type = lookup(
          block_device_mappings.value,
          "volume_type",
          local.workers_group_defaults["root_volume_type"],
        )
        iops = lookup(
          block_device_mappings.value,
          "iops",
          local.workers_group_defaults["root_iops"],
        )
        encrypted = lookup(
          block_device_mappings.value,
          "encrypted",
          local.workers_group_defaults["root_encrypted"],
        )
        kms_key_id = lookup(
          block_device_mappings.value,
          "kms_key_id",
          local.workers_group_defaults["root_kms_key_id"],
        )
        delete_on_termination = lookup(block_device_mappings.value, "delete_on_termination", true)
      }
    }

  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      {
        "Name" = "${aws_eks_cluster.this[0].name}-${lookup(
          var.worker_groups_launch_template[count.index],
          "name",
          count.index,
        )}-eks_asg"
      },
      var.tags,
    )
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      {
        "Name" = "${aws_eks_cluster.this[0].name}-${lookup(
          var.worker_groups_launch_template[count.index],
          "name",
          count.index,
        )}-eks_asg"
      },
      var.tags,
    )
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "random_pet" "workers_launch_template" {
  count = var.create_eks ? local.worker_group_launch_template_count : 0

  separator = "-"
  length    = 2

  keepers = {
    lt_name = join(
      "-",
      compact(
        [
          aws_launch_template.workers_launch_template[count.index].name,
          aws_launch_template.workers_launch_template[count.index].latest_version
        ]
      )
    )
  }
}

resource "aws_iam_instance_profile" "workers_launch_template" {
  count       = var.manage_worker_iam_resources && var.create_eks ? local.worker_group_launch_template_count : 0
  name_prefix = aws_eks_cluster.this[0].name
  role = lookup(
    var.worker_groups_launch_template[count.index],
    "iam_role_id",
    local.default_iam_role_id,
  )
  path = var.iam_path
}
