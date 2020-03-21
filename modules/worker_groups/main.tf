resource "aws_autoscaling_group" "workers" {
  for_each = local.worker_group_configurations

  name_prefix = join(
    "-",
    compact(
      [
        var.cluster_name,
        each.key,
      ]
    )
  )

  desired_capacity        = each.value["asg_desired_capacity"]
  max_size                = each.value["asg_max_size"]
  min_size                = each.value["asg_min_size"]
  force_delete            = each.value["asg_force_delete"]
  target_group_arns       = each.value["target_group_arns"]
  load_balancers          = each.value["load_balancers"]
  service_linked_role_arn = each.value["service_linked_role_arn"]
  vpc_zone_identifier     = each.value["subnets"]
  protect_from_scale_in   = each.value["protect_from_scale_in"]
  suspended_processes     = each.value["suspended_processes"]

  enabled_metrics = each.value["enabled_metrics"]

  placement_group = each.value["placement_group"]

  termination_policies      = each.value["termination_policies"]
  max_instance_lifetime     = each.value["max_instance_lifetime"]
  default_cooldown          = each.value["default_cooldown"]
  health_check_type         = each.value["health_check_type"]
  health_check_grace_period = each.value["health_check_grace_period"]
  capacity_rebalance        = each.value["capacity_rebalance"]

  dynamic "mixed_instances_policy" {
    iterator = item
    for_each = ((lookup(var.worker_groups[each.key], "override_instance_types", null) != null) || (each.value["on_demand_allocation_strategy"] != null)) ? [each.value] : []

    content {
      instances_distribution {
        on_demand_allocation_strategy            = lookup(item.value, "on_demand_allocation_strategy", "prioritized")
        on_demand_base_capacity                  = item.value["on_demand_base_capacity"]
        on_demand_percentage_above_base_capacity = item.value["on_demand_percentage_above_base_capacity"]

        spot_allocation_strategy = item.value["spot_allocation_strategy"]
        spot_instance_pools      = item.value["spot_instance_pools"]
        spot_max_price           = item.value["spot_max_price"]
      }

      launch_template {
        launch_template_specification {
          launch_template_id = aws_launch_template.workers[each.key].id
          version = lookup(var.worker_groups[each.key],
            "launch_template_version",
            var.workers_group_defaults["launch_template_version"] == "$Latest"
            ? aws_launch_template.workers[each.key].latest_version
            : aws_launch_template.workers[each.key].default_version
          )
        }

        dynamic "override" {
          for_each = item.value["override_instance_types"]

          content {
            instance_type = override.value
          }
        }
      }
    }
  }

  dynamic "launch_template" {
    iterator = item
    for_each = ((lookup(var.worker_groups[each.key], "override_instance_types", null) != null) || (each.value["on_demand_allocation_strategy"] != null)) ? [] : [each.value]

    content {
      id = aws_launch_template.workers[each.key].id
      version = lookup(var.worker_groups[each.key],
        "launch_template_version",
        var.workers_group_defaults["launch_template_version"] == "$Latest"
        ? aws_launch_template.workers[each.key].latest_version
        : aws_launch_template.workers[each.key].default_version
      )
    }
  }

  dynamic "initial_lifecycle_hook" {
    for_each = var.worker_create_initial_lifecycle_hooks ? each.value["asg_initial_lifecycle_hooks"] : []

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
    for_each = lookup(var.worker_groups[each.key], "warm_pool", null) != null ? [each.value["warm_pool"]] : []

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
          key                 = "Name"
          value               = "${var.cluster_name}-${each.key}-eks_asg"
          propagate_at_launch = true
        },
        {
          key                 = "kubernetes.io/cluster/${var.cluster_name}"
          value               = "owned"
          propagate_at_launch = true
        },
      ],
      [
        for tag_key, tag_value in var.tags :
        tomap({
          key                 = tag_key
          value               = tag_value
          propagate_at_launch = "true"
        })
        if tag_key != "Name" && !contains([for tag in each.value["tags"] : tag["key"]], tag_key)
      ],
      each.value["tags"]
    )
    content {
      key                 = tag.value.key
      value               = tag.value.value
      propagate_at_launch = tag.value.propagate_at_launch
    }
  }

  dynamic "instance_refresh" {
    for_each = each.value["instance_refresh_enabled"] ? [1] : []

    content {
      strategy = each.value["instance_refresh_strategy"]
      preferences {
        instance_warmup        = each.value["instance_refresh_instance_warmup"]
        min_healthy_percentage = each.value["instance_refresh_min_healthy_percentage"]
      }
      triggers = each.value["instance_refresh_triggers"]
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

resource "aws_launch_template" "workers" {
  for_each = local.worker_group_configurations

  name_prefix = "${var.cluster_name}-${each.key}"

  update_default_version = each.value["update_default_version"]

  network_interfaces {
    associate_public_ip_address = each.value["public_ip"]
    delete_on_termination       = each.value["eni_delete"]

    security_groups = flatten([
      var.worker_security_group_ids,
      each.value["additional_security_group_ids"]
    ])
  }

  iam_instance_profile {
    name = var.manage_worker_iam_resources ? aws_iam_instance_profile.workers[each.key].name : data.aws_iam_instance_profile.custom_worker_group_iam_instance_profile[each.key].name
  }

  enclave_options {
    enabled = each.value["enclave_support"]
  }

  image_id = lookup(
    var.worker_groups[each.key],
    "ami_id",
    each.value["platform"] == "windows" ? local.default_ami_id_windows : local.default_ami_id_linux,
  )

  instance_type = each.value["instance_type"]
  key_name      = each.value["key_name"]
  user_data     = base64encode(local.userdata_rendered[each.key])

  dynamic "elastic_inference_accelerator" {
    for_each = each.value["elastic_inference_accelerator"] != null ? [each.value["elastic_inference_accelerator"]] : []

    content {
      type = elastic_inference_accelerator.value
    }
  }

  ebs_optimized = lookup(
    var.worker_groups[each.key],
    "ebs_optimized",
    !contains(local.ebs_optimized_not_supported, each.value["instance_type"])
  )

  metadata_options {
    http_endpoint               = each.value["metadata_http_endpoint"]
    http_tokens                 = each.value["metadata_http_tokens"]
    http_put_response_hop_limit = each.value["metadata_http_put_response_hop_limit"]
  }

  dynamic "credit_specification" {
    for_each = lookup(var.worker_groups[each.key], "cpu_credits", each.value["cpu_credits"]) != null ? [each.value["cpu_credits"]] : []
    content {
      cpu_credits = credit_specification.value
    }
  }

  monitoring {
    enabled = each.value["enable_monitoring"]
  }

  dynamic "placement" {
    for_each = each.value["launch_template_placement_group"] != null ? [each.value["launch_template_placement_group"]] : []

    content {
      tenancy    = each.value["launch_template_placement_tenancy"]
      group_name = placement.value
    }
  }

  dynamic "instance_market_options" {
    for_each = lookup(var.worker_groups[each.key], "market_type", null) == null ? [] : tolist([lookup(var.worker_groups[each.key], "market_type", null)])

    content {
      market_type = instance_market_options.value
    }
  }

  block_device_mappings {
    device_name = lookup(
      var.worker_groups[each.key],
      "root_block_device_name",
      each.value["platform"] == "windows" ? local.default_root_block_device_name_windows : local.default_root_block_device_name,
    )

    ebs {
      volume_size = each.value["root_volume_size"]
      volume_type = each.value["root_volume_type"]
      iops        = each.value["root_iops"]
      throughput  = each.value["root_volume_throughput"]
      encrypted   = each.value["root_encrypted"]
      kms_key_id  = each.value["root_kms_key_id"]

      delete_on_termination = true
    }
  }

  dynamic "block_device_mappings" {
    for_each = each.value["additional_ebs_volumes"]

    content {
      device_name = block_device_mappings.value.block_device_name

      ebs {
        volume_size = lookup(block_device_mappings.value, "volume_size", var.workers_group_defaults["root_volume_size"])
        volume_type = lookup(block_device_mappings.value, "volume_type", var.workers_group_defaults["root_volume_type"])
        iops        = lookup(block_device_mappings.value, "iops", var.workers_group_defaults["root_iops"])
        throughput  = lookup(block_device_mappings.value, "throughput", var.workers_group_defaults["root_volume_throughput"])
        encrypted   = lookup(block_device_mappings.value, "encrypted", var.workers_group_defaults["root_encrypted"])
        kms_key_id  = lookup(block_device_mappings.value, "kms_key_id", var.workers_group_defaults["root_kms_key_id"])

        delete_on_termination = lookup(block_device_mappings.value, "delete_on_termination", true)
      }
    }
  }

  dynamic "block_device_mappings" {
    for_each = each.value["additional_instance_store_volumes"]

    content {
      device_name = block_device_mappings.value.block_device_name
      virtual_name = lookup(block_device_mappings.value,
        "virtual_name",
        var.workers_group_defaults["instance_store_virtual_name"]
      )
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      {
        Name = "${var.cluster_name}-${each.key}-eks_asg"
      },
      var.tags,
    )
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      {
        Name = "${var.cluster_name}-${each.key}-eks_asg"
      },
      {
        for tag_key, tag_value in var.tags :
        tag_key => tag_value
        if tag_key != "Name" && !contains([for tag in each.value["tags"] : tag["key"]], tag_key)
      }
    )
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    var.ng_depends_on,
  ]
}

resource "aws_iam_instance_profile" "workers" {
  for_each = var.manage_worker_iam_resources ? local.worker_group_configurations : {}

  name_prefix = var.cluster_name

  role = lookup(
    var.worker_groups[each.key],
    "iam_role_id",
    var.default_iam_role_id,
  )
  path = var.iam_path
  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}
