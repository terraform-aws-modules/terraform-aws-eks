data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_default_tags" "current" {}

data "aws_ami" "eks_default" {
  count = var.create ? 1 : 0

  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.cluster_version}-v*"]
  }

  most_recent = true
  owners      = ["amazon"]
}

################################################################################
# User Data
################################################################################

module "user_data" {
  source = "../_user_data"

  create                    = var.create
  platform                  = var.platform
  is_eks_managed_node_group = false

  cluster_name        = var.cluster_name
  cluster_endpoint    = var.cluster_endpoint
  cluster_auth_base64 = var.cluster_auth_base64

  enable_bootstrap_user_data = true
  pre_bootstrap_user_data    = var.pre_bootstrap_user_data
  post_bootstrap_user_data   = var.post_bootstrap_user_data
  bootstrap_extra_args       = var.bootstrap_extra_args
  user_data_template_path    = var.user_data_template_path
}

################################################################################
# Launch template
################################################################################

locals {
  launch_template_name_int = coalesce(var.launch_template_name, "${var.name}-node-group")

  security_group_ids = compact(concat([try(aws_security_group.this[0].id, ""), var.cluster_primary_security_group_id], var.vpc_security_group_ids))
}

resource "aws_launch_template" "this" {
  count = var.create && var.create_launch_template ? 1 : 0

  name        = var.launch_template_use_name_prefix ? null : local.launch_template_name_int
  name_prefix = var.launch_template_use_name_prefix ? "${local.launch_template_name_int}-" : null
  description = var.launch_template_description

  ebs_optimized = var.ebs_optimized
  image_id      = coalesce(var.ami_id, data.aws_ami.eks_default[0].image_id)
  instance_type = var.instance_type
  key_name      = var.key_name
  user_data     = module.user_data.user_data

  vpc_security_group_ids = length(var.network_interfaces) > 0 ? [] : local.security_group_ids

  default_version                      = var.launch_template_default_version
  update_default_version               = var.update_launch_template_default_version
  disable_api_termination              = var.disable_api_termination
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  kernel_id                            = var.kernel_id
  ram_disk_id                          = var.ram_disk_id

  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings
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
    for_each = length(var.capacity_reservation_specification) > 0 ? [var.capacity_reservation_specification] : []
    content {
      capacity_reservation_preference = lookup(capacity_reservation_specification.value, "capacity_reservation_preference", null)

      dynamic "capacity_reservation_target" {
        for_each = try([capacity_reservation_specification.value.capacity_reservation_target], [])
        content {
          capacity_reservation_id = lookup(capacity_reservation_target.value, "capacity_reservation_id", null)
        }
      }
    }
  }

  dynamic "cpu_options" {
    for_each = length(var.cpu_options) > 0 ? [var.cpu_options] : []
    content {
      core_count       = cpu_options.value.core_count
      threads_per_core = cpu_options.value.threads_per_core
    }
  }

  dynamic "credit_specification" {
    for_each = length(var.credit_specification) > 0 ? [var.credit_specification] : []
    content {
      cpu_credits = credit_specification.value.cpu_credits
    }
  }

  dynamic "elastic_gpu_specifications" {
    for_each = length(var.elastic_gpu_specifications) > 0 ? [var.elastic_gpu_specifications] : []
    content {
      type = elastic_gpu_specifications.value.type
    }
  }

  dynamic "elastic_inference_accelerator" {
    for_each = length(var.elastic_inference_accelerator) > 0 ? [var.elastic_inference_accelerator] : []
    content {
      type = elastic_inference_accelerator.value.type
    }
  }

  dynamic "enclave_options" {
    for_each = length(var.enclave_options) > 0 ? [var.enclave_options] : []
    content {
      enabled = enclave_options.value.enabled
    }
  }

  dynamic "hibernation_options" {
    for_each = length(var.hibernation_options) > 0 ? [var.hibernation_options] : []
    content {
      configured = hibernation_options.value.configured
    }
  }

  iam_instance_profile {
    arn = var.create_iam_instance_profile ? aws_iam_instance_profile.this[0].arn : var.iam_instance_profile_arn
  }

  dynamic "instance_market_options" {
    for_each = length(var.instance_market_options) > 0 ? [var.instance_market_options] : []
    content {
      market_type = instance_market_options.value.market_type

      dynamic "spot_options" {
        for_each = length(lookup(instance_market_options.value, "spot_options", {})) > 0 ? [instance_market_options.value.spot_options] : []
        content {
          block_duration_minutes         = lookup(spot_options.value, "block_duration_minutes", null)
          instance_interruption_behavior = lookup(spot_options.value, "instance_interruption_behavior", null)
          max_price                      = lookup(spot_options.value, "max_price", null)
          spot_instance_type             = lookup(spot_options.value, "spot_instance_type", null)
          valid_until                    = lookup(spot_options.value, "valid_until", null)
        }
      }
    }
  }

  dynamic "license_specification" {
    for_each = length(var.license_specifications) > 0 ? [var.license_specifications] : []
    content {
      license_configuration_arn = license_specifications.value.license_configuration_arn
    }
  }

  dynamic "metadata_options" {
    for_each = length(var.metadata_options) > 0 ? [var.metadata_options] : []
    content {
      http_endpoint               = lookup(metadata_options.value, "http_endpoint", null)
      http_tokens                 = lookup(metadata_options.value, "http_tokens", null)
      http_put_response_hop_limit = lookup(metadata_options.value, "http_put_response_hop_limit", null)
      http_protocol_ipv6          = lookup(metadata_options.value, "http_protocol_ipv6", null)
      instance_metadata_tags      = lookup(metadata_options.value, "instance_metadata_tags", null)
    }
  }

  dynamic "monitoring" {
    for_each = var.enable_monitoring != null ? [1] : []
    content {
      enabled = var.enable_monitoring
    }
  }

  dynamic "network_interfaces" {
    for_each = var.network_interfaces
    content {
      associate_carrier_ip_address = lookup(network_interfaces.value, "associate_carrier_ip_address", null)
      associate_public_ip_address  = lookup(network_interfaces.value, "associate_public_ip_address", null)
      delete_on_termination        = lookup(network_interfaces.value, "delete_on_termination", null)
      description                  = lookup(network_interfaces.value, "description", null)
      device_index                 = lookup(network_interfaces.value, "device_index", null)
      interface_type               = lookup(network_interfaces.value, "interface_type", null)
      ipv4_addresses               = try(network_interfaces.value.ipv4_addresses, [])
      ipv4_address_count           = lookup(network_interfaces.value, "ipv4_address_count", null)
      ipv6_addresses               = try(network_interfaces.value.ipv6_addresses, [])
      ipv6_address_count           = lookup(network_interfaces.value, "ipv6_address_count", null)
      network_interface_id         = lookup(network_interfaces.value, "network_interface_id", null)
      private_ip_address           = lookup(network_interfaces.value, "private_ip_address", null)
      security_groups              = compact(concat(try(network_interfaces.value.security_groups, []), local.security_group_ids))
      subnet_id                    = lookup(network_interfaces.value, "subnet_id", null)
    }
  }

  dynamic "placement" {
    for_each = length(var.placement) > 0 ? [var.placement] : []
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

  dynamic "tag_specifications" {
    for_each = toset(["instance", "volume", "network-interface"])
    content {
      resource_type = tag_specifications.key
      tags          = merge(var.tags, { Name = var.name }, var.launch_template_tags)
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  # Prevent premature access of security group roles and policies by pods that
  # require permissions on create/destroy that depend on nodes
  depends_on = [
    aws_security_group_rule.this,
    aws_iam_role_policy_attachment.this,
  ]

  tags = var.tags
}

################################################################################
# Node Group
################################################################################

locals {
  launch_template_name = try(aws_launch_template.this[0].name, var.launch_template_name)
  # Change order to allow users to set version priority before using defaults
  launch_template_version = coalesce(var.launch_template_version, try(aws_launch_template.this[0].default_version, "$Default"))
}

resource "aws_autoscaling_group" "this" {
  count = var.create && var.create_autoscaling_group ? 1 : 0

  name        = var.use_name_prefix ? null : var.name
  name_prefix = var.use_name_prefix ? "${var.name}-" : null

  dynamic "launch_template" {
    for_each = var.use_mixed_instances_policy ? [] : [1]

    content {
      name    = local.launch_template_name
      version = local.launch_template_version
    }
  }

  availability_zones  = var.availability_zones
  vpc_zone_identifier = var.subnet_ids

  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_size
  capacity_rebalance        = var.capacity_rebalance
  min_elb_capacity          = var.min_elb_capacity
  wait_for_elb_capacity     = var.wait_for_elb_capacity
  wait_for_capacity_timeout = var.wait_for_capacity_timeout
  default_cooldown          = var.default_cooldown
  protect_from_scale_in     = var.protect_from_scale_in

  target_group_arns         = var.target_group_arns
  placement_group           = var.placement_group
  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period

  force_delete          = var.force_delete
  termination_policies  = var.termination_policies
  suspended_processes   = var.suspended_processes
  max_instance_lifetime = var.max_instance_lifetime

  enabled_metrics         = var.enabled_metrics
  metrics_granularity     = var.metrics_granularity
  service_linked_role_arn = var.service_linked_role_arn

  dynamic "initial_lifecycle_hook" {
    for_each = var.initial_lifecycle_hooks
    content {
      name                    = initial_lifecycle_hook.value.name
      default_result          = lookup(initial_lifecycle_hook.value, "default_result", null)
      heartbeat_timeout       = lookup(initial_lifecycle_hook.value, "heartbeat_timeout", null)
      lifecycle_transition    = initial_lifecycle_hook.value.lifecycle_transition
      notification_metadata   = lookup(initial_lifecycle_hook.value, "notification_metadata", null)
      notification_target_arn = lookup(initial_lifecycle_hook.value, "notification_target_arn", null)
      role_arn                = lookup(initial_lifecycle_hook.value, "role_arn", null)
    }
  }

  dynamic "instance_refresh" {
    for_each = length(var.instance_refresh) > 0 ? [var.instance_refresh] : []
    content {
      strategy = instance_refresh.value.strategy
      triggers = lookup(instance_refresh.value, "triggers", null)

      dynamic "preferences" {
        for_each = length(lookup(instance_refresh.value, "preferences", {})) > 0 ? [instance_refresh.value.preferences] : []
        content {
          instance_warmup        = lookup(preferences.value, "instance_warmup", null)
          min_healthy_percentage = lookup(preferences.value, "min_healthy_percentage", null)
          checkpoint_delay       = lookup(preferences.value, "checkpoint_delay", null)
          checkpoint_percentages = lookup(preferences.value, "checkpoint_percentages", null)
        }
      }
    }
  }

  dynamic "mixed_instances_policy" {
    for_each = var.use_mixed_instances_policy ? [var.mixed_instances_policy] : []
    content {
      dynamic "instances_distribution" {
        for_each = try([mixed_instances_policy.value.instances_distribution], [])
        content {
          on_demand_allocation_strategy            = lookup(instances_distribution.value, "on_demand_allocation_strategy", null)
          on_demand_base_capacity                  = lookup(instances_distribution.value, "on_demand_base_capacity", null)
          on_demand_percentage_above_base_capacity = lookup(instances_distribution.value, "on_demand_percentage_above_base_capacity", null)
          spot_allocation_strategy                 = lookup(instances_distribution.value, "spot_allocation_strategy", null)
          spot_instance_pools                      = lookup(instances_distribution.value, "spot_instance_pools", null)
          spot_max_price                           = lookup(instances_distribution.value, "spot_max_price", null)
        }
      }

      launch_template {
        launch_template_specification {
          launch_template_name = local.launch_template_name
          version              = local.launch_template_version
        }

        dynamic "override" {
          for_each = try(mixed_instances_policy.value.override, [])
          content {
            instance_type     = lookup(override.value, "instance_type", null)
            weighted_capacity = lookup(override.value, "weighted_capacity", null)

            dynamic "launch_template_specification" {
              for_each = length(lookup(override.value, "launch_template_specification", {})) > 0 ? override.value.launch_template_specification : []
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
    for_each = length(var.warm_pool) > 0 ? [var.warm_pool] : []
    content {
      pool_state                  = lookup(warm_pool.value, "pool_state", null)
      min_size                    = lookup(warm_pool.value, "min_size", null)
      max_group_prepared_capacity = lookup(warm_pool.value, "max_group_prepared_capacity", null)
    }
  }

  dynamic "tag" {
    for_each = merge(
      {
        "Name"                                      = var.name
        "kubernetes.io/cluster/${var.cluster_name}" = "owned"
        "k8s.io/cluster/${var.cluster_name}"        = "owned"
      },
      var.use_default_tags ? merge(data.aws_default_tags.current.tags, var.tags) : var.tags
    )

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  dynamic "tag" {
    for_each = var.autoscaling_group_tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = false
    }
  }

  timeouts {
    delete = var.delete_timeout
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      desired_capacity
    ]
  }
}

################################################################################
# Autoscaling group schedule
################################################################################

resource "aws_autoscaling_schedule" "this" {
  for_each = var.create && var.create_schedule ? var.schedules : {}

  scheduled_action_name  = each.key
  autoscaling_group_name = aws_autoscaling_group.this[0].name

  min_size         = lookup(each.value, "min_size", null)
  max_size         = lookup(each.value, "max_size", null)
  desired_capacity = lookup(each.value, "desired_size", null)
  start_time       = lookup(each.value, "start_time", null)
  end_time         = lookup(each.value, "end_time", null)
  time_zone        = lookup(each.value, "time_zone", null)

  # [Minute] [Hour] [Day_of_Month] [Month_of_Year] [Day_of_Week]
  # Cron examples: https://crontab.guru/examples.html
  recurrence = lookup(each.value, "recurrence", null)
}

################################################################################
# Security Group
################################################################################

locals {
  security_group_name   = coalesce(var.security_group_name, "${var.name}-node-group")
  create_security_group = var.create && var.create_security_group
}

resource "aws_security_group" "this" {
  count = local.create_security_group ? 1 : 0

  name        = var.security_group_use_name_prefix ? null : local.security_group_name
  name_prefix = var.security_group_use_name_prefix ? "${local.security_group_name}-" : null
  description = var.security_group_description
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      "Name" = local.security_group_name
    },
    var.security_group_tags
  )

  # https://github.com/hashicorp/terraform-provider-aws/issues/2445
  # https://github.com/hashicorp/terraform-provider-aws/issues/9692
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "this" {
  for_each = { for k, v in var.security_group_rules : k => v if local.create_security_group }

  # Required
  security_group_id = aws_security_group.this[0].id
  protocol          = each.value.protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  type              = each.value.type

  # Optional
  description      = try(each.value.description, null)
  cidr_blocks      = try(each.value.cidr_blocks, null)
  ipv6_cidr_blocks = try(each.value.ipv6_cidr_blocks, null)
  prefix_list_ids  = try(each.value.prefix_list_ids, [])
  self             = try(each.value.self, null)
  source_security_group_id = try(
    each.value.source_security_group_id,
    try(each.value.source_cluster_security_group, false) ? var.cluster_security_group_id : null
  )
}

################################################################################
# IAM Role
################################################################################

locals {
  iam_role_name = coalesce(var.iam_role_name, "${var.name}-node-group")

  iam_role_policy_prefix = "arn:${data.aws_partition.current.partition}:iam::aws:policy"

  cni_policy = var.cluster_ip_family == "ipv6" ? "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:policy/AmazonEKS_CNI_IPv6_Policy" : "${local.iam_role_policy_prefix}/AmazonEKS_CNI_Policy"
}

data "aws_iam_policy_document" "assume_role_policy" {
  count = var.create && var.create_iam_instance_profile ? 1 : 0

  statement {
    sid     = "EKSNodeAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.${data.aws_partition.current.dns_suffix}"]
    }
  }
}

resource "aws_iam_role" "this" {
  count = var.create && var.create_iam_instance_profile ? 1 : 0

  name        = var.iam_role_use_name_prefix ? null : local.iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.iam_role_name}-" : null
  path        = var.iam_role_path
  description = var.iam_role_description

  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy[0].json
  permissions_boundary  = var.iam_role_permissions_boundary
  force_detach_policies = true

  tags = merge(var.tags, var.iam_role_tags)
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = var.create && var.create_iam_instance_profile ? toset(compact(distinct(concat([
    "${local.iam_role_policy_prefix}/AmazonEKSWorkerNodePolicy",
    "${local.iam_role_policy_prefix}/AmazonEC2ContainerRegistryReadOnly",
    var.iam_role_attach_cni_policy ? local.cni_policy : "",
  ], var.iam_role_additional_policies)))) : toset([])

  policy_arn = each.value
  role       = aws_iam_role.this[0].name
}

# Only self-managed node group requires instance profile
resource "aws_iam_instance_profile" "this" {
  count = var.create && var.create_iam_instance_profile ? 1 : 0

  role = aws_iam_role.this[0].name

  name        = var.iam_role_use_name_prefix ? null : local.iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.iam_role_name}-" : null
  path        = var.iam_role_path

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, var.iam_role_tags)
}
