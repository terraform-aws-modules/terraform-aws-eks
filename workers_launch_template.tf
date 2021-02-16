# Worker Groups using Launch Templates

resource "aws_autoscaling_group" "workers_launch_template" {
  for_each = var.create_eks ? local.worker_groups_launch_template_with_defaults : {}

  name_prefix = join(
    "-",
    compact(
      [
        coalescelist(aws_eks_cluster.this[*].name, [""])[0],
        lookup(each.value, "name", each.key),
        each.value.asg_recreate_on_change ? random_pet.workers_launch_template[each.key].id : ""
      ]
    )
  )
  desired_capacity          = each.value.asg_desired_capacity
  max_size                  = each.value.asg_max_size
  min_size                  = each.value.asg_min_size
  force_delete              = each.value.asg_force_delete
  target_group_arns         = each.value.target_group_arns
  load_balancers            = each.value.load_balancers
  service_linked_role_arn   = each.value.service_linked_role_arn
  vpc_zone_identifier       = each.value.subnets
  protect_from_scale_in     = each.value.protect_from_scale_in
  suspended_processes       = each.value.suspended_processes
  enabled_metrics           = each.value.enabled_metrics
  placement_group           = each.value.placement_group
  termination_policies      = each.value.termination_policies
  max_instance_lifetime     = each.value.max_instance_lifetime
  default_cooldown          = each.value.default_cooldown
  health_check_type         = each.value.health_check_type
  health_check_grace_period = each.value.health_check_grace_period

  dynamic "mixed_instances_policy" {
    iterator = item

    for_each = (lookup(var.worker_groups_launch_template[each.key], "override_instance_types", null) != null) || (each.value.on_demand_allocation_strategy != null) ? list(each.value) : []

    content {
      instances_distribution {
        on_demand_allocation_strategy            = each.value.on_demand_allocation_strategy
        on_demand_base_capacity                  = each.value.on_demand_base_capacity
        on_demand_percentage_above_base_capacity = each.value.on_demand_percentage_above_base_capacity
        spot_allocation_strategy                 = each.value.spot_allocation_strategy
        spot_instance_pools                      = each.value.spot_instance_pools
        spot_max_price                           = each.value.spot_max_price
      }

      launch_template {
        launch_template_specification {
          launch_template_id = aws_launch_template.workers_launch_template[each.key].id
          version = each.value.launch_template_version
        }

        dynamic "override" {
          for_each = each.value.override_instance_types

          content {
            instance_type = override.value
          }
        }

      }
    }
  }

  dynamic "launch_template" {
    iterator = item
    for_each = (lookup(var.worker_groups_launch_template[each.key], "override_instance_types", null) != null) || (each.value.on_demand_allocation_strategy != null) ? [] : list(each.value)

    content {
      id = aws_launch_template.workers_launch_template[each.key].id
      version = each.value.launch_template_version
    }
  }

  dynamic "initial_lifecycle_hook" {
    for_each = var.worker_create_initial_lifecycle_hooks ? each.value.asg_initial_lifecycle_hooks : []
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

  dynamic "tag" {
    for_each = concat(
      [
        {
          "key" = "Name"
          "value" = "${coalescelist(aws_eks_cluster.this[*].name, [""])[0]}-${lookup(
            each.value,
            "name",
            each.key,
          )}-eks_asg"
          "propagate_at_launch" = true
        },
        {
          "key"                 = "kubernetes.io/cluster/${coalescelist(aws_eks_cluster.this[*].name, [""])[0]}"
          "value"               = "owned"
          "propagate_at_launch" = true
        },
      ],
      [
        for tag_key, tag_value in var.tags :
        map(
          "key", tag_key,
          "value", tag_value,
          "propagate_at_launch", "true"
        )
        if tag_key != "Name" && !contains([for tag in each.value.tags : tag["key"]], tag_key)
      ],
      each.value.tags
    )
    content {
      key                 = tag.value.key
      value               = tag.value.value
      propagate_at_launch = tag.value.propagate_at_launch
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

resource "aws_launch_template" "workers_launch_template" {
  for_each = var.create_eks ? local.worker_groups_launch_template_with_defaults : {}
  
  name_prefix = "${coalescelist(aws_eks_cluster.this[*].name, [""])[0]}-${lookup(
    each.value,
    "name",
    each.key,
  )}"

  network_interfaces {
    associate_public_ip_address = each.value.public_ip
    delete_on_termination = each.value.eni_delete
    security_groups = flatten([
      local.worker_security_group_id,
      var.worker_additional_security_group_ids,
      each.value.additional_security_group_ids,
    ])
  }

  iam_instance_profile {
    name = coalesce(
      aws_iam_instance_profile.workers_launch_template[each.key].name,
      data.aws_iam_instance_profile.custom_worker_group_launch_template_iam_instance_profile[each.key].name,
    )
  }

  image_id = lookup(
    each.value,
    "ami_id",
    each.value.platform == "windows" ? local.default_ami_id_windows : local.default_ami_id_linux,
  )
  instance_type = each.value.instance_type
  key_name = each.value.key_name
  user_data = base64encode(
    data.template_file.launch_template_userdata[each.key].rendered,
  )

  ebs_optimized = lookup(
    each.value,
    "ebs_optimized",
    !contains(
      local.ebs_optimized_not_supported,
      each.value.instance_type,
    )
  )

  metadata_options {
    http_endpoint = each.value.metadata_http_endpoint
    http_tokens = each.value.metadata_http_tokens
    http_put_response_hop_limit = each.value.metadata_http_put_response_hop_limit
  }

  dynamic "credit_specification" {
    for_each = each.value.cpu_credits != null ? [each.value.cpu_credits] : []
    content {
      cpu_credits = credit_specification.value
    }
  }

  monitoring {
    enabled = each.value.enable_monitoring
  }

  dynamic "placement" {
    for_each = each.value.launch_template_placement_group != null ? [each.value.launch_template_placement_group] : []

    content {
      tenancy    = each.value.launch_template_placement_tenancy
      group_name = placement.value
    }
  }

  dynamic "instance_market_options" {
    for_each = lookup(each.value, "market_type", null) == null ? [] : list(lookup(each.value, "market_type", null))
    content {
      market_type = instance_market_options.value
    }
  }

  block_device_mappings {
    device_name = each.value.root_block_device_name

    ebs {
      volume_size           = each.value.root_volume_size
      volume_type           = each.value.root_volume_type
      iops                  = each.value.root_iops
      throughput            = each.value.root_volume_throughput
      encrypted             = each.value.root_encrypted
      kms_key_id            = each.value.root_kms_key_id
      delete_on_termination = each.value.root_delete_on_termination
    }
  }

  dynamic "block_device_mappings" {
    for_each = each.value.additional_ebs_volumes
    content {
      device_name = block_device_mappings.value.block_device_name

      ebs {
        volume_size           = block_device_mappings.value.volume_size
        volume_type           = block_device_mappings.value.volume_type
        iops                  = block_device_mappings.value.iops
        throughput            = block_device_mappings.value.volume_throughput
        encrypted             = block_device_mappings.value.encrypted
        kms_key_id            = block_device_mappings.value.kms_key_id
        delete_on_termination = block_device_mappings.value.delete_on_termination
      }
    }

  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      {
        "Name" = "${coalescelist(aws_eks_cluster.this[*].name, [""])[0]}-${lookup(
          each.value,
          "name",
          each.key,
        )}-eks_asg"
      },
      var.tags,
    )
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      {
        "Name" = "${coalescelist(aws_eks_cluster.this[*].name, [""])[0]}-${lookup(
          each.value,
          "name",
          each.key,
        )}-eks_asg"
      },
      { for tag_key, tag_value in var.tags :
        tag_key => tag_value
        if tag_key != "Name" && !contains([for tag in each.value.tags : tag["key"]], tag_key)
      }
    )
  }

  tags = var.tags

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

resource "random_pet" "workers_launch_template" {
  for_each = var.create_eks ? local.worker_groups_launch_template_with_defaults : {}

  separator = "-"
  length    = 2

  keepers = {
    lt_name = join(
      "-",
      compact(
        [
          aws_launch_template.workers_launch_template[each.key].name,
          aws_launch_template.workers_launch_template[each.key].latest_version
        ]
      )
    )
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_instance_profile" "workers_launch_template" {
  for_each = var.manage_worker_iam_resources && var.create_eks ? local.worker_groups_launch_template_with_defaults : {}

  name_prefix = coalescelist(aws_eks_cluster.this[*].name, [""])[0]
  role = lookup(
    each.value,
    "iam_role_id",
    local.default_iam_role_id,
  )
  path = var.iam_path

  lifecycle {
    create_before_destroy = true
  }
}
