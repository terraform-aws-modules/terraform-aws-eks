locals {
  # Abstracted to a local so that it can be shared with node group as well
  # Only valus that are common between ASG and Node Group are pulled out to this local map
  group_default = {
    min_size         = try(var.group_default.min_size, 1)
    max_size         = try(var.group_default.max_size, 3)
    desired_capacity = try(var.group_default.desired_capacity, 1)
  }
}
resource "aws_autoscaling_group" "this" {
  for_each = var.create_eks ? var.worker_groups : {}

  name_prefix = "${join("-", [local.cluster_name, lookup(each.value, "name", each.key)])}-"

  launch_template {
    name    = each.value.launch_template_key # required
    version = try(each.value.launch_template_version, var.group_default.min_size, "$Latest")
  }

  availability_zones  = try(each.value.availability_zones, var.group_default.availability_zones, null)
  vpc_zone_identifier = try(each.value.vpc_zone_identifier, var.group_default.vpc_zone_identifier, null)

  min_size              = try(each.value.min_size, locals.wg_default.min_size)
  max_size              = try(each.value.max_size, locals.wg_default.max_size)
  desired_capacity      = try(each.value.desired_capacity, locals.wg_default.desired_capacity)
  capacity_rebalance    = try(each.value.capacity_rebalance, var.group_default.capacity_rebalance, null)
  default_cooldown      = try(each.value.default_cooldown, var.group_default.default_cooldown, null)
  protect_from_scale_in = try(each.value.protect_from_scale_in, var.group_default.protect_from_scale_in, null)

  load_balancers            = try(each.value.load_balancers, var.group_default.load_balancers, null)
  target_group_arns         = try(each.value.target_group_arns, var.group_default.target_group_arns, null)
  placement_group           = try(each.value.placement_group, var.group_default.placement_group, null)
  health_check_type         = try(each.value.health_check_type, var.group_default.health_check_type, null)
  health_check_grace_period = try(each.value.health_check_grace_period, var.group_default.health_check_grace_period, null)

  force_delete          = try(each.value.force_delete, var.group_default.force_delete, false)
  termination_policies  = try(each.value.termination_policies, var.group_default.termination_policies, null)
  suspended_processes   = try(each.value.suspended_processes, var.group_default.suspended_processes, "AZRebalance")
  max_instance_lifetime = try(each.value.max_instance_lifetime, var.group_default.max_instance_lifetime, null)

  enabled_metrics         = try(each.value.enabled_metrics, var.group_default.enabled_metrics, null)
  metrics_granularity     = try(each.value.metrics_granularity, var.group_default.metrics_granularity, null)
  service_linked_role_arn = try(each.value.service_linked_role_arn, var.group_default.service_linked_role_arn, null)

  dynamic "initial_lifecycle_hook" {
    for_each = try(each.value.initial_lifecycle_hook, var.group_default.initial_lifecycle_hook, {})
    iterator = hook

    content {
      name                    = hook.value.name
      default_result          = lookup(hook.value, "default_result", null)
      heartbeat_timeout       = lookup(hook.value, "heartbeat_timeout", null)
      lifecycle_transition    = hook.value.lifecycle_transition
      notification_metadata   = lookup(hook.value, "notification_metadata", null)
      notification_target_arn = lookup(hook.value, "notification_target_arn", null)
      role_arn                = lookup(hook.value, "role_arn", null)
    }
  }

  dynamic "instance_refresh" {
    for_each = try(each.value.instance_refresh, var.group_default.instance_refresh, {})
    iterator = refresh

    content {
      strategy = refresh.value.strategy
      triggers = lookup(refresh.value, "triggers", null)

      dynamic "preferences" {
        for_each = try(refresh.value.preferences, [])
        content {
          instance_warmup        = lookup(preferences.value, "instance_warmup", null)
          min_healthy_percentage = lookup(preferences.value, "min_healthy_percentage", null)
        }
      }
    }
  }

  dynamic "mixed_instances_policy" {
    for_each = try(each.value.mixed_instances_policy, var.group_default.mixed_instances_policy, {})
    iterator = mixed

    content {
      dynamic "instances_distribution" {
        for_each = try(mixed.value.instances_distribution, {})
        iterater = distro

        content {
          on_demand_allocation_strategy            = lookup(distro.value, "on_demand_allocation_strategy", null)
          on_demand_base_capacity                  = lookup(distro.value, "on_demand_base_capacity", null)
          on_demand_percentage_above_base_capacity = lookup(distro.value, "on_demand_percentage_above_base_capacity", null)
          spot_allocation_strategy                 = lookup(distro.value, "spot_allocation_strategy", null)
          spot_instance_pools                      = lookup(distro.value, "spot_instance_pools", null)
          spot_max_price                           = lookup(distro.value, "spot_max_price", null)
        }
      }

      launch_template {
        launch_template_specification {
          launch_template_name = local.launch_template
          version              = local.launch_template_version
        }

        dynamic "override" {
          for_each = try(mixed.value.override, {})
          content {
            instance_type     = lookup(override.value, "instance_type", null)
            weighted_capacity = lookup(override.value, "weighted_capacity", null)

            dynamic "launch_template_specification" {
              for_each = try(override.value.launch_template_specification, {})
              content {
                launch_template_id = lookup(launch_template_specification.value, "launch_template_id", null)
              }
            }
          }
        }
      }
    }
  }

  dynamic "warm_pool" {
    for_each = try(each.value.warm_pool, var.group_default.warm_pool, {})

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
          "value"               = "${join("-", [local.cluster_name, lookup(each.value, "name", each.key)])}-eks-asg"
          "propagate_at_launch" = true
        },
        {
          "key"                 = "kubernetes.io/cluster/${local.cluster_name}"
          "value"               = "owned"
          "propagate_at_launch" = true
        },
      ],
      [
        for tag_key, tag_value in var.tags :
        tomap({
          key                 = tag_key
          value               = tag_value
          propagate_at_launch = true
        })
        if tag_key != "Name" && !contains([for tag in lookup(each.value, "tags", []) : tag["key"]], tag_key)
      ],
      lookup(each.value, "tags", {})
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

resource "aws_launch_template" "this" {
  for_each = var.create_eks ? var.launch_templates : {}
  iterater = template

  name_prefix = "${local.cluster_name}-${lookup(template.value, "name", each.key)}"
  description = lookup(template.value, "description", null)

  ebs_optimized = lookup(template.value, "ebs_optimized", null)
  image_id      = lookup(template.value, "image_id", null)
  instance_type = lookup(template.value, "instance_type", "m6i.large")
  key_name      = lookup(template.value, "key_name", null)
  user_data     = lookup(template.value, "user_data", null)

  vpc_security_group_ids = lookup(template.value, "vpc_security_group_ids", null)

  default_version                      = lookup(template.value, "default_version", null)
  update_default_version               = lookup(template.value, "update_default_version", null)
  disable_api_termination              = lookup(template.value, "disable_api_termination", null)
  instance_initiated_shutdown_behavior = lookup(template.value, "instance_initiated_shutdown_behavior", null)
  kernel_id                            = lookup(template.value, "kernel_id", null)
  ram_disk_id                          = lookup(template.value, "ram_disk_id", null)

  dynamic "block_device_mappings" {
    for_each = lookup(each.value, "block_device_mappings", null) != null ? each.value.block_device_mappings : []
    content {
      device_name  = block_device_mappings.value.device_name
      no_device    = lookup(block_device_mappings.value, "no_device", null)
      virtual_name = lookup(block_device_mappings.value, "virtual_name", null)

      dynamic "ebs" {
        for_each = flatten([lookup(block_device_mappings.value, "ebs", [])])
        content {
          delete_on_termination = lookup(ebs.value, "delete_on_termination", null)
          encrypted             = lookup(ebs.value, "encrypted", null)
          kms_key_id            = lookup(ebs.value, "kms_key_id", null)
          iops                  = lookup(ebs.value, "iops", null)
          throughput            = lookup(ebs.value, "throughput", null)
          snapshot_id           = lookup(ebs.value, "snapshot_id", null)
          volume_size           = lookup(ebs.value, "volume_size", null)
          volume_type           = lookup(ebs.value, "volume_type", null)
        }
      }
    }
  }

  dynamic "capacity_reservation_specification" {
    for_each = lookup(each.value, "capacity_reservation_specification", null) != null ? [each.value.capacity_reservation_specification] : []
    content {
      capacity_reservation_preference = lookup(capacity_reservation_specification.value, "capacity_reservation_preference", null)

      dynamic "capacity_reservation_target" {
        for_each = lookup(capacity_reservation_specification.value, "capacity_reservation_target", [])
        content {
          capacity_reservation_id = lookup(capacity_reservation_target.value, "capacity_reservation_id", null)
        }
      }
    }
  }

  dynamic "cpu_options" {
    for_each = lookup(each.value, "cpu_options", null) != null ? [each.value.cpu_options] : []
    content {
      core_count       = cpu_options.value.core_count
      threads_per_core = cpu_options.value.threads_per_core
    }
  }

  dynamic "credit_specification" {
    for_each = lookup(each.value, "credit_specification", null) != null ? [each.value.credit_specification] : []
    content {
      cpu_credits = credit_specification.value.cpu_credits
    }
  }

  dynamic "elastic_gpu_specifications" {
    for_each = lookup(each.value, "elastic_gpu_specifications", null) != null ? [each.value.elastic_gpu_specifications] : []
    content {
      type = elastic_gpu_specifications.value.type
    }
  }

  dynamic "elastic_inference_accelerator" {
    for_each = lookup(each.value, "elastic_inference_accelerator", null) != null ? [each.value.elastic_inference_accelerator] : []
    content {
      type = elastic_inference_accelerator.value.type
    }
  }

  dynamic "enclave_options" {
    for_each = lookup(each.value, "enclave_options", null) != null ? [each.value.enclave_options] : []
    content {
      enabled = enclave_options.value.enabled
    }
  }

  dynamic "hibernation_options" {
    for_each = lookup(each.value, "hibernation_options", null) != null ? [each.value.hibernation_options] : []
    content {
      configured = hibernation_options.value.configured
    }
  }

  # iam_instance_profile {
  #   name = coalescelist(
  #     aws_iam_instance_profile.workers.*.name,
  #     data.aws_iam_instance_profile.custom_worker_group_iam_instance_profile.*.name,
  #   )[count.index]
  # }

  dynamic "iam_instance_profile" {
    for_each = lookup(each.value, "iam_instance_profile", null) != null ? [1] : []
    content {
      name = iam_instance_profile.value.name
      arn  = iam_instance_profile.value.arn
    }
  }

  dynamic "instance_market_options" {
    for_each = lookup(each.value, "instance_market_options", null) != null ? [each.value.instance_market_options] : []
    content {
      market_type = instance_market_options.value.market_type

      dynamic "spot_options" {
        for_each = lookup(instance_market_options.value, "spot_options", null) != null ? [instance_market_options.value.spot_options] : []
        content {
          block_duration_minutes         = spot_options.value.block_duration_minutes
          instance_interruption_behavior = lookup(spot_options.value, "instance_interruption_behavior", null)
          max_price                      = lookup(spot_options.value, "max_price", null)
          spot_instance_type             = lookup(spot_options.value, "spot_instance_type", null)
          valid_until                    = lookup(spot_options.value, "valid_until", null)
        }
      }
    }
  }

  dynamic "license_specification" {
    for_each = lookup(each.value, "license_specifications", null) != null ? [each.value.license_specifications] : []
    content {
      license_configuration_arn = license_specifications.value.license_configuration_arn
    }
  }

  dynamic "metadata_options" {
    for_each = lookup(each.value, "metadata_options", null) != null ? [each.value.metadata_options] : []
    content {
      http_endpoint               = lookup(metadata_options.value, "http_endpoint", null)
      http_tokens                 = lookup(metadata_options.value, "http_tokens", null)
      http_put_response_hop_limit = lookup(metadata_options.value, "http_put_response_hop_limit", null)
    }
  }

  dynamic "monitoring" {
    for_each = lookup(each.value, "enable_monitoring", null) != null ? [1] : []
    content {
      enabled = each.value.enable_monitoring
    }
  }

  dynamic "network_interfaces" {
    for_each = lookup(each.value, "network_interfaces", null) != null ? each.value.network_interfaces : []
    iterator = interface
    content {
      associate_carrier_ip_address = lookup(interface.value, "associate_carrier_ip_address", null)
      associate_public_ip_address  = lookup(interface.value, "associate_public_ip_address", null)
      delete_on_termination        = lookup(interface.value, "delete_on_termination", null)
      description                  = lookup(interface.value, "description", null)
      device_index                 = lookup(interface.value, "device_index", null)
      ipv4_addresses               = lookup(interface.value, "ipv4_addresses", null) != null ? interface.value.ipv4_addresses : []
      ipv4_address_count           = lookup(interface.value, "ipv4_address_count", null)
      ipv6_addresses               = lookup(interface.value, "ipv6_addresses", null) != null ? interface.value.ipv6_addresses : []
      ipv6_address_count           = lookup(interface.value, "ipv6_address_count", null)
      network_interface_id         = lookup(interface.value, "network_interface_id", null)
      private_ip_address           = lookup(interface.value, "private_ip_address", null)
      security_groups              = lookup(interface.value, "security_groups", null) != null ? interface.value.security_groups : []
      subnet_id                    = lookup(interface.value, "subnet_id", null)
    }
  }

  dynamic "placement" {
    for_each = lookup(each.value, "placement", null) != null ? [each.value.placement] : []
    content {
      affinity          = lookup(placement.value, "affinity", null)
      availability_zone = lookup(placement.value, "availability_zone", null)
      group_name        = lookup(placement.value, "group_name", null)
      host_id           = lookup(placement.value, "host_id", null)
      spread_domain     = lookup(placement.value, "spread_domain", null)
      tenancy           = lookup(placement.value, "tenancy", null)
      partition_number  = lookup(placement.value, "partition_number", null)
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      { "Name" = "${local.cluster_name}-${lookup(each.value, "name", each.key)}-eks_asg" },
      var.tags,
      { for tag in lookup(each.value, "tags", {}) : tag["key"] => tag["value"] if tag["key"] != "Name" && tag["propagate_at_launch"] }
    )
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      { "Name" = "${local.cluster_name}-${lookup(each.value, "name", each.key)}-eks_asg" },
      { for tag_key, tag_value in var.tags :
        tag_key => tag_value
        if tag_key != "Name" && !contains([for tag in lookup(each.value, "tags", {}) : tag["key"]], tag_key)
      }
    )
  }

  tag_specifications {
    resource_type = "network-interface"

    tags = merge(
      { "Name" = "${local.cluster_name}-${lookup(each.value, "name", each.key)}-eks_asg" },
      var.tags,
      { for tag in lookup(each.value, "tags", {}) : tag["key"] => tag["value"] if tag["key"] != "Name" && tag["propagate_at_launch"] }
    )
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

  dynamic "tag_specifications" {
    for_each = lookup(each.value, "tag_specifications", null) != null ? each.value.tag_specifications : []
    content {
      resource_type = tag_specifications.value.resource_type
      tags          = tag_specifications.value.tags
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

resource "aws_iam_instance_profile" "workers" {
  count = var.manage_worker_iam_resources && var.create_eks ? var.iam_instance_profiles : {}

  name_prefix = local.cluster_name
  role        = lookup(var.worker_groups[count.index], "iam_role_id", local.default_iam_role_id)
  path        = var.iam_path

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

resource "aws_security_group" "workers" {
  count = var.worker_create_security_group && var.create_eks ? 1 : 0

  name_prefix = var.cluster_name
  description = "Security group for all nodes in the cluster."
  vpc_id      = var.vpc_id
  tags = merge(
    var.tags,
    {
      "Name"                                      = "${var.cluster_name}-eks_worker_sg"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    },
  )
}

resource "aws_security_group_rule" "workers_egress_internet" {
  count = var.worker_create_security_group && var.create_eks ? 1 : 0

  description       = "Allow nodes all egress to the Internet."
  protocol          = "-1"
  security_group_id = local.worker_security_group_id
  cidr_blocks       = var.workers_egress_cidrs
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "workers_ingress_self" {
  count = var.worker_create_security_group && var.create_eks ? 1 : 0

  description              = "Allow node to communicate with each other."
  protocol                 = "-1"
  security_group_id        = local.worker_security_group_id
  source_security_group_id = local.worker_security_group_id
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster" {
  count = var.worker_create_security_group && var.create_eks ? 1 : 0

  description              = "Allow workers pods to receive communication from the cluster control plane."
  protocol                 = "tcp"
  security_group_id        = local.worker_security_group_id
  source_security_group_id = local.cluster_security_group_id
  from_port                = var.worker_sg_ingress_from_port
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_kubelet" {
  count = var.worker_create_security_group && var.create_eks ? var.worker_sg_ingress_from_port > 10250 ? 1 : 0 : 0

  description              = "Allow workers Kubelets to receive communication from the cluster control plane."
  protocol                 = "tcp"
  security_group_id        = local.worker_security_group_id
  source_security_group_id = local.cluster_security_group_id
  from_port                = 10250
  to_port                  = 10250
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_https" {
  count = var.worker_create_security_group && var.create_eks ? 1 : 0

  description              = "Allow pods running extension API servers on port 443 to receive communication from cluster control plane."
  protocol                 = "tcp"
  security_group_id        = local.worker_security_group_id
  source_security_group_id = local.cluster_security_group_id
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_primary" {
  count = var.worker_create_security_group && var.worker_create_cluster_primary_security_group_rules && var.create_eks ? 1 : 0

  description              = "Allow pods running on workers to receive communication from cluster primary security group (e.g. Fargate pods)."
  protocol                 = "all"
  security_group_id        = local.worker_security_group_id
  source_security_group_id = local.cluster_primary_security_group_id
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster_primary_ingress_workers" {
  count = var.worker_create_security_group && var.worker_create_cluster_primary_security_group_rules && var.create_eks ? 1 : 0

  description              = "Allow pods running on workers to send communication to cluster primary security group (e.g. Fargate pods)."
  protocol                 = "all"
  security_group_id        = local.cluster_primary_security_group_id
  source_security_group_id = local.worker_security_group_id
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_iam_role" "workers" {
  count = var.manage_worker_iam_resources && var.create_eks ? 1 : 0

  name_prefix           = var.workers_role_name != "" ? null : local.cluster_name
  name                  = var.workers_role_name != "" ? var.workers_role_name : null
  assume_role_policy    = data.aws_iam_policy_document.workers_assume_role_policy.json
  permissions_boundary  = var.permissions_boundary
  path                  = var.iam_path
  force_detach_policies = true

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEKSWorkerNodePolicy" {
  count = var.manage_worker_iam_resources && var.create_eks ? 1 : 0

  policy_arn = "${local.policy_arn_prefix}/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.workers[0].name
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEKS_CNI_Policy" {
  count = var.manage_worker_iam_resources && var.attach_worker_cni_policy && var.create_eks ? 1 : 0

  policy_arn = "${local.policy_arn_prefix}/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.workers[0].name
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEC2ContainerRegistryReadOnly" {
  count = var.manage_worker_iam_resources && var.create_eks ? 1 : 0

  policy_arn = "${local.policy_arn_prefix}/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.workers[0].name
}

resource "aws_iam_role_policy_attachment" "workers_additional_policies" {
  count = var.manage_worker_iam_resources && var.create_eks ? length(var.workers_additional_policies) : 0

  role       = aws_iam_role.workers[0].name
  policy_arn = var.workers_additional_policies[count.index]
}
