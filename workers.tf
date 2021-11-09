################################################################################
# Fargate
################################################################################

module "fargate" {
  source = "./modules/fargate"

  create                            = var.create_fargate
  create_fargate_pod_execution_role = var.create_fargate_pod_execution_role
  fargate_pod_execution_role_arn    = var.fargate_pod_execution_role_arn

  cluster_name = aws_eks_cluster.this[0].name
  subnet_ids   = coalescelist(var.fargate_subnet_ids, var.subnet_ids, [""])

  iam_path             = var.fargate_iam_role_path
  permissions_boundary = var.fargate_iam_role_permissions_boundary

  fargate_profiles = var.fargate_profiles

  tags = merge(var.tags, var.fargate_tags)
}

################################################################################
# Fargate
################################################################################

locals {
  # Abstracted to a local so that it can be shared with node group as well
  # Only valus that are common between ASG and Node Group are pulled out to this local map
  group_default_settings = {
    min_size         = try(var.group_default_settings.min_size, 1)
    max_size         = try(var.group_default_settings.max_size, 3)
    desired_capacity = try(var.group_default_settings.desired_capacity, 1)
  }
}

resource "aws_launch_template" "this" {
  for_each = var.create ? var.launch_templates : {}

  name_prefix = "${aws_eks_cluster.this[0].name}-${try(each.value.name, each.key)}"
  description = try(each.value.description, var.group_default_settings.description, null)

  ebs_optimized = try(each.value.ebs_optimized, var.group_default_settings.ebs_optimized, null)
  image_id      = try(each.value.image_id, var.group_default_settings.image_id, data.aws_ami.eks_worker[0].image_id)
  instance_type = try(each.value.instance_type, var.group_default_settings.instance_type, "m6i.large")
  key_name      = try(each.value.key_name, var.group_default_settings.key_name, null)
  user_data     = try(each.value.user_data, var.group_default_settings.user_data, null)

  vpc_security_group_ids = compact(concat(
    [try(aws_security_group.worker[0].id, "")],
    try(each.value.vpc_security_group_ids, var.group_default_settings.vpc_security_group_ids, [])
  ))

  default_version                      = try(each.value.default_version, var.group_default_settings.default_version, null)
  update_default_version               = try(each.value.update_default_version, var.group_default_settings.update_default_version, null)
  disable_api_termination              = try(each.value.disable_api_termination, var.group_default_settings.disable_api_termination, null)
  instance_initiated_shutdown_behavior = try(each.value.instance_initiated_shutdown_behavior, var.group_default_settings.instance_initiated_shutdown_behavior, null)
  kernel_id                            = try(each.value.kernel_id, var.group_default_settings.kernel_id, null)
  ram_disk_id                          = try(each.value.ram_disk_id, var.group_default_settings.ram_disk_id, null)

  dynamic "block_device_mappings" {
    for_each = try(each.value.block_device_mappings, var.group_default_settings.block_device_mappings, [])
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
    for_each = try(each.value.capacity_reservation_specification, var.group_default_settings.capacity_reservation_specification, [])
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
    for_each = try(each.value.cpu_options, var.group_default_settings.cpu_options, [])
    content {
      core_count       = cpu_options.value.core_count
      threads_per_core = cpu_options.value.threads_per_core
    }
  }

  dynamic "credit_specification" {
    for_each = try(each.value.credit_specification, var.group_default_settings.credit_specification, [])
    content {
      cpu_credits = credit_specification.value.cpu_credits
    }
  }

  dynamic "elastic_gpu_specifications" {
    for_each = try(each.value.elastic_gpu_specifications, var.group_default_settings.elastic_gpu_specifications, [])
    content {
      type = elastic_gpu_specifications.value.type
    }
  }

  dynamic "elastic_inference_accelerator" {
    for_each = try(each.value.elastic_inference_accelerator, var.group_default_settings.elastic_inference_accelerator, [])
    content {
      type = elastic_inference_accelerator.value.type
    }
  }

  dynamic "enclave_options" {
    for_each = try(each.value.enclave_options, var.group_default_settings.enclave_options, [])
    content {
      enabled = enclave_options.value.enabled
    }
  }

  dynamic "hibernation_options" {
    for_each = try(each.value.hibernation_options, var.group_default_settings.hibernation_options, [])
    content {
      configured = hibernation_options.value.configured
    }
  }

  dynamic "iam_instance_profile" {
    for_each = [{
      "arn" = try(each.value.iam_instance_profile_arn, aws_iam_instance_profile.worker[0].arn, {})
    }]
    content {
      arn = lookup(iam_instance_profile.value, "arn", null)
    }
  }

  dynamic "instance_market_options" {
    for_each = try(each.value.instance_market_options, var.group_default_settings.instance_market_options, [])
    content {
      market_type = instance_market_options.value.market_type

      dynamic "spot_options" {
        for_each = try([instance_market_options.value.spot_options], [])
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
    for_each = try(each.value.license_specifications, var.group_default_settings.license_specifications, [])
    content {
      license_configuration_arn = license_specifications.value.license_configuration_arn
    }
  }

  dynamic "metadata_options" {
    for_each = try([each.value.metadata_options], [var.group_default_settings.metadata_options], [])
    content {
      http_endpoint               = lookup(metadata_options.value, "http_endpoint", null)
      http_tokens                 = lookup(metadata_options.value, "http_tokens", null)
      http_put_response_hop_limit = lookup(metadata_options.value, "http_put_response_hop_limit", null)
    }
  }

  dynamic "monitoring" {
    for_each = try(each.value.enable_monitoring, var.group_default_settings.enable_monitoring, [])
    content {
      enabled = each.value
    }
  }

  dynamic "network_interfaces" {
    for_each = try(each.value.network_interfaces, var.group_default_settings.network_interfaces, [])
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
    for_each = try(each.value.placement, var.group_default_settings.placement, [])
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

  # tag_specifications {
  #   resource_type = "volume"
  #   tags = merge(
  #     var.tags,
  #     lookup(each.value, "tags", {}),
  #     { "Name" = try(each.value.name, "${aws_eks_cluster.this[0].name}-${each.key}") }
  #   )
  # }

  # tag_specifications {
  #   resource_type = "instance"
  #   tags = merge(
  #     var.tags,
  #     lookup(each.value, "tags", {}),
  #     { "Name" = try(each.value.name, "${aws_eks_cluster.this[0].name}-${each.key}") }
  #   )
  # }

  # tag_specifications {
  #   resource_type = "network-interface"
  #   tags = merge(
  #     var.tags,
  #     lookup(each.value, "tags", {}),
  #     { "Name" = try(each.value.name, "${aws_eks_cluster.this[0].name}-${each.key}") }
  #   )
  # }

  # Prevent premature access of security group roles and policies by pods that
  # require permissions on create/destroy that depend on worker.
  depends_on = [
    aws_security_group_rule.worker_egress_internet,
    aws_security_group_rule.worker_ingress_self,
    aws_security_group_rule.worker_ingress_cluster,
    aws_security_group_rule.worker_ingress_cluster_kubelet,
    aws_security_group_rule.worker_ingress_cluster_https,
    aws_security_group_rule.worker_ingress_cluster_primary,
    aws_security_group_rule.cluster_primary_ingress_worker,
  ]

  lifecycle {
    create_before_destroy = true
  }

  # tags = merge(var.tags, lookup(each.value, "tags", {}))
}

################################################################################
# Node Groups
################################################################################


# resource "aws_eks_node_group" "worker" {
#   for_each = var.create : var.node_groups : {}

#   node_group_name_prefix = lookup(each.value, "name", null) == null ? local.node_groups_names[each.key] : null
#   node_group_name        = lookup(each.value, "name_prefix", null)

#   cluster_name  = var.cluster_name
#   node_role_arn = try(each.value.iam_role_arn, var.default_iam_role_arn)
#   subnet_ids    = coalescelist(each.value["subnet_ids"], var.subnet_ids, [""])

#   scaling_config {
#     desired_size = each.value["desired_capacity"]
#     max_size     = each.value["max_capacity"]
#     min_size     = each.value["min_capacity"]
#   }

#   ami_type             = lookup(each.value, "ami_type", null)
#   disk_size            = lookup(each.value, "disk_size", null)
#   instance_types       = lookup(each.value, "instance_types", null)
#   release_version      = lookup(each.value, "ami_release_version", null)
#   capacity_type        = lookup(each.value, "capacity_type", null)
#   force_update_version = lookup(each.value, "force_update_version", null)

#   dynamic "remote_access" {
#     for_each = each.value["key_name"] != "" && each.value["launch_template_id"] == null && !each.value["create_launch_template"] ? [{
#       ec2_ssh_key               = each.value["key_name"]
#       source_security_group_ids = lookup(each.value, "source_security_group_ids", [])
#     }] : []

#     content {
#       ec2_ssh_key               = remote_access.value["ec2_ssh_key"]
#       source_security_group_ids = remote_access.value["source_security_group_ids"]
#     }
#   }

#   dynamic "launch_template" {
#     for_each = [try(each.value.launch_template, {})]

#     content {
#       id      = lookup(launch_template.value, "id", null)
#       name    = lookup(launch_template.value, "name", null)
#       version = launch_template.value.version
#     }
#   }

#   dynamic "taint" {
#     for_each = each.value["taints"]

#     content {
#       key    = taint.value["key"]
#       value  = taint.value["value"]
#       effect = taint.value["effect"]
#     }
#   }

#   dynamic "update_config" {
#     for_each = try(each.value.update_config.max_unavailable_percentage > 0, each.value.update_config.max_unavailable > 0, false) ? [true] : []

#     content {
#       max_unavailable_percentage = try(each.value.update_config.max_unavailable_percentage, null)
#       max_unavailable            = try(each.value.update_config.max_unavailable, null)
#     }
#   }

#   timeouts {
#     create = lookup(each.value["timeouts"], "create", null)
#     update = lookup(each.value["timeouts"], "update", null)
#     delete = lookup(each.value["timeouts"], "delete", null)
#   }

#   version = lookup(each.value, "version", null)

#   labels = merge(
#     lookup(var.node_groups_defaults, "k8s_labels", {}),
#     lookup(each.value, "k8s_labels", {})
#   )

#   tags = merge(
#     var.tags,
#     lookup(var.node_groups_defaults, "additional_tags", {}),
#     lookup(each.value, "additional_tags", {}),
#   )

#   lifecycle {
#     create_before_destroy = true
#     ignore_changes        = [scaling_config[0].desired_size]
#   }
# }

################################################################################
# Autoscaling Group
################################################################################

resource "aws_autoscaling_group" "this" {
  for_each = var.create ? var.worker_groups : object({})

  name_prefix = "${join("-", [aws_eks_cluster.this[0].name, try(each.value.name, each.key)])}-"

  launch_template {
    name = try(
      aws_launch_template.this[each.value.launch_template_key].name,
      each.value.launch_template_name,
      # defaults should be last
      aws_launch_template.this[var.group_default_settings.launch_template_key].name,
      var.group_default_settings.launch_template_name,
    )
    version = try(each.value.launch_template_version, var.group_default_settings.launch_template_version, "$Latest")
  }

  availability_zones  = try(each.value.availability_zones, var.group_default_settings.availability_zones, null)
  vpc_zone_identifier = try(each.value.vpc_zone_identifier, var.group_default_settings.vpc_zone_identifier, var.subnet_ids)

  min_size              = try(each.value.min_size, local.group_default_settings.min_size)
  max_size              = try(each.value.max_size, local.group_default_settings.max_size)
  desired_capacity      = try(each.value.desired_capacity, local.group_default_settings.desired_capacity)
  capacity_rebalance    = try(each.value.capacity_rebalance, var.group_default_settings.capacity_rebalance, null)
  default_cooldown      = try(each.value.default_cooldown, var.group_default_settings.default_cooldown, null)
  protect_from_scale_in = try(each.value.protect_from_scale_in, var.group_default_settings.protect_from_scale_in, null)

  load_balancers            = try(each.value.load_balancers, var.group_default_settings.load_balancers, null)
  target_group_arns         = try(each.value.target_group_arns, var.group_default_settings.target_group_arns, null)
  placement_group           = try(each.value.placement_group, var.group_default_settings.placement_group, null)
  health_check_type         = try(each.value.health_check_type, var.group_default_settings.health_check_type, null)
  health_check_grace_period = try(each.value.health_check_grace_period, var.group_default_settings.health_check_grace_period, null)

  force_delete          = try(each.value.force_delete, var.group_default_settings.force_delete, false)
  termination_policies  = try(each.value.termination_policies, var.group_default_settings.termination_policies, null)
  suspended_processes   = try(each.value.suspended_processes, var.group_default_settings.suspended_processes, ["AZRebalance"])
  max_instance_lifetime = try(each.value.max_instance_lifetime, var.group_default_settings.max_instance_lifetime, null)

  enabled_metrics         = try(each.value.enabled_metrics, var.group_default_settings.enabled_metrics, null)
  metrics_granularity     = try(each.value.metrics_granularity, var.group_default_settings.metrics_granularity, null)
  service_linked_role_arn = try(each.value.service_linked_role_arn, var.group_default_settings.service_linked_role_arn, null)

  dynamic "initial_lifecycle_hook" {
    for_each = try(each.value.initial_lifecycle_hook, var.group_default_settings.initial_lifecycle_hook, {})
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
    for_each = try(each.value.instance_refresh, var.group_default_settings.instance_refresh, {})
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
    for_each = try(each.value.mixed_instances_policy, var.group_default_settings.mixed_instances_policy, {})
    iterator = mixed

    content {
      dynamic "instances_distribution" {
        for_each = try(mixed.value.instances_distribution, {})
        iterator = distro

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
    for_each = try(each.value.warm_pool, var.group_default_settings.warm_pool, {})

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
          "value"               = "${join("-", [aws_eks_cluster.this[0].name, lookup(each.value, "name", each.key)])}-eks-asg"
          "propagate_at_launch" = true
        },
        {
          "key"                 = "kubernetes.io/cluster/${aws_eks_cluster.this[0].name}"
          "value"               = "owned"
          "propagate_at_launch" = true
        },
        {
          "key"                 = "k8s.io/cluster/${aws_eks_cluster.this[0].name}"
          "value"               = "owned"
          "propagate_at_launch" = true
        },
      ],
      [
        for k, v in merge(var.tags, lookup(each.value, "tags", {})) :
        tomap({
          key                 = k
          value               = v
          propagate_at_launch = true
        })
      ],
      lookup(each.value, "propogated_tags", [])
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

  depends_on = [
    aws_launch_template.this
  ]
}

################################################################################
# IAM Role & Instance Profile
################################################################################

locals {
  worker_iam_role_name = coalesce(var.worker_iam_role_name, var.cluster_name)
}

resource "aws_iam_role" "worker" {
  count = var.create && var.create_worker_iam_role ? 1 : 0

  name        = var.worker_iam_role_use_name_prefix ? null : local.worker_iam_role_name
  name_prefix = var.worker_iam_role_use_name_prefix ? try("${local.worker_iam_role_name}-", local.worker_iam_role_name) : null
  path        = var.worker_iam_role_path

  assume_role_policy   = data.aws_iam_policy_document.worker_assume_role_policy[0].json
  permissions_boundary = var.worker_iam_role_permissions_boundary
  managed_policy_arns = compact(distinct(concat([
    "${local.policy_arn_prefix}/AmazonEKSWorkerNodePolicy",
    "${local.policy_arn_prefix}/AmazonEC2ContainerRegistryReadOnly",
    var.attach_worker_cni_policy ? "${local.policy_arn_prefix}/AmazonEKS_CNI_Policy" : "",
  ], var.worker_additional_policies)))
  force_detach_policies = true

  tags = merge(var.tags, var.worker_iam_role_tags)
}

data "aws_iam_policy_document" "worker_assume_role_policy" {
  count = var.create && var.create_worker_iam_role ? 1 : 0

  statement {
    sid     = "EKSWorkerAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = [local.ec2_principal]
    }
  }
}

resource "aws_iam_instance_profile" "worker" {
  count = var.create && var.create_worker_iam_role ? 1 : 0

  name        = var.worker_iam_role_use_name_prefix ? null : local.worker_iam_role_name
  name_prefix = var.worker_iam_role_use_name_prefix ? try("${local.worker_iam_role_name}-", local.worker_iam_role_name) : null
  path        = var.worker_iam_role_path
  role        = aws_iam_role.worker[0].id

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, var.worker_iam_role_tags)
}

################################################################################
# Security Group
################################################################################

locals {
  create_worker_sg = var.create && var.worker_create_security_group
}

resource "aws_security_group" "worker" {
  count = local.create_worker_sg ? 1 : 0

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

resource "aws_security_group_rule" "worker_egress_internet" {
  count = local.create_worker_sg ? 1 : 0

  description       = "Allow nodes all egress to the Internet."
  protocol          = "-1"
  security_group_id = local.worker_security_group_id
  cidr_blocks       = var.worker_egress_cidrs
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "worker_ingress_self" {
  count = local.create_worker_sg ? 1 : 0

  description              = "Allow node to communicate with each other."
  protocol                 = "-1"
  security_group_id        = local.worker_security_group_id
  source_security_group_id = local.worker_security_group_id
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "worker_ingress_cluster" {
  count = local.create_worker_sg ? 1 : 0

  description              = "Allow worker pods to receive communication from the cluster control plane."
  protocol                 = "tcp"
  security_group_id        = local.worker_security_group_id
  source_security_group_id = local.cluster_security_group_id
  from_port                = var.worker_sg_ingress_from_port
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "worker_ingress_cluster_kubelet" {
  count = local.create_worker_sg ? var.worker_sg_ingress_from_port > 10250 ? 1 : 0 : 0

  description              = "Allow worker Kubelets to receive communication from the cluster control plane."
  protocol                 = "tcp"
  security_group_id        = local.worker_security_group_id
  source_security_group_id = local.cluster_security_group_id
  from_port                = 10250
  to_port                  = 10250
  type                     = "ingress"
}

resource "aws_security_group_rule" "worker_ingress_cluster_https" {
  count = local.create_worker_sg ? 1 : 0

  description              = "Allow pods running extension API servers on port 443 to receive communication from cluster control plane."
  protocol                 = "tcp"
  security_group_id        = local.worker_security_group_id
  source_security_group_id = local.cluster_security_group_id
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "worker_ingress_cluster_primary" {
  count = local.create_worker_sg && var.worker_create_cluster_primary_security_group_rules ? 1 : 0

  description              = "Allow pods running on worker to receive communication from cluster primary security group (e.g. Fargate pods)."
  protocol                 = "all"
  security_group_id        = local.worker_security_group_id
  source_security_group_id = try(aws_eks_cluster.this[0].vpc_config[0].cluster_security_group_id, "")
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster_primary_ingress_worker" {
  count = local.create_worker_sg && var.worker_create_cluster_primary_security_group_rules ? 1 : 0

  description              = "Allow pods running on worker to send communication to cluster primary security group (e.g. Fargate pods)."
  protocol                 = "all"
  security_group_id        = aws_eks_cluster.this[0].vpc_config[0].cluster_security_group_id
  source_security_group_id = local.worker_security_group_id
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}
