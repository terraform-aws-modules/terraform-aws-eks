data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

################################################################################
# AMI SSM Parameter
################################################################################

locals {
  # Just to ensure templating doesn't fail when values are not provided
  ssm_cluster_version = var.cluster_version != null ? var.cluster_version : ""

  # TODO - Temporary stopgap for backwards compatibility until v21.0
  ami_type_to_user_data_type = {
    AL2_x86_64                 = "linux"
    AL2_x86_64_GPU             = "linux"
    AL2_ARM_64                 = "linux"
    BOTTLEROCKET_ARM_64        = "bottlerocket"
    BOTTLEROCKET_x86_64        = "bottlerocket"
    BOTTLEROCKET_ARM_64_NVIDIA = "bottlerocket"
    BOTTLEROCKET_x86_64_NVIDIA = "bottlerocket"
    WINDOWS_CORE_2019_x86_64   = "windows"
    WINDOWS_FULL_2019_x86_64   = "windows"
    WINDOWS_CORE_2022_x86_64   = "windows"
    WINDOWS_FULL_2022_x86_64   = "windows"
    AL2023_x86_64_STANDARD     = "al2023"
    AL2023_ARM_64_STANDARD     = "al2023"
  }

  user_data_type = local.ami_type_to_user_data_type[var.ami_type]

  # Map the AMI type to the respective SSM param path
  ami_type_to_ssm_param = {
    AL2_x86_64                 = "/aws/service/eks/optimized-ami/${local.ssm_cluster_version}/amazon-linux-2/recommended/image_id"
    AL2_x86_64_GPU             = "/aws/service/eks/optimized-ami/${local.ssm_cluster_version}/amazon-linux-2-gpu/recommended/image_id"
    AL2_ARM_64                 = "/aws/service/eks/optimized-ami/${local.ssm_cluster_version}/amazon-linux-2-arm64/recommended/image_id"
    BOTTLEROCKET_ARM_64        = "/aws/service/bottlerocket/aws-k8s-${local.ssm_cluster_version}/arm64/latest/image_id"
    BOTTLEROCKET_x86_64        = "/aws/service/bottlerocket/aws-k8s-${local.ssm_cluster_version}/x86_64/latest/image_id"
    BOTTLEROCKET_ARM_64_NVIDIA = "/aws/service/bottlerocket/aws-k8s-${local.ssm_cluster_version}-nvidia/arm64/latest/image_id"
    BOTTLEROCKET_x86_64_NVIDIA = "/aws/service/bottlerocket/aws-k8s-${local.ssm_cluster_version}-nvidia/x86_64/latest/image_id"
    WINDOWS_CORE_2019_x86_64   = "/aws/service/ami-windows-latest/Windows_Server-2019-English-Full-EKS_Optimized-${local.ssm_cluster_version}/image_id"
    WINDOWS_FULL_2019_x86_64   = "/aws/service/ami-windows-latest/Windows_Server-2019-English-Core-EKS_Optimized-${local.ssm_cluster_version}/image_id"
    WINDOWS_CORE_2022_x86_64   = "/aws/service/ami-windows-latest/Windows_Server-2022-English-Full-EKS_Optimized-${local.ssm_cluster_version}/image_id"
    WINDOWS_FULL_2022_x86_64   = "/aws/service/ami-windows-latest/Windows_Server-2022-English-Core-EKS_Optimized-${local.ssm_cluster_version}/image_id"
    AL2023_x86_64_STANDARD     = "/aws/service/eks/optimized-ami/${local.ssm_cluster_version}/amazon-linux-2023/x86_64/standard/recommended/image_id"
    AL2023_ARM_64_STANDARD     = "/aws/service/eks/optimized-ami/${local.ssm_cluster_version}/amazon-linux-2023/arm64/standard/recommended/image_id"
  }
}

data "aws_ssm_parameter" "ami" {
  count = var.create ? 1 : 0

  name = local.ami_type_to_ssm_param[var.ami_type]
}

################################################################################
# User Data
################################################################################

module "user_data" {
  source = "../_user_data"

  create                    = var.create
  platform                  = local.user_data_type
  ami_type                  = var.ami_type
  is_eks_managed_node_group = false

  cluster_name               = var.cluster_name
  cluster_endpoint           = var.cluster_endpoint
  cluster_auth_base64        = var.cluster_auth_base64
  cluster_ip_family          = var.cluster_ip_family
  cluster_service_cidr       = var.cluster_service_cidr
  additional_cluster_dns_ips = var.additional_cluster_dns_ips

  enable_bootstrap_user_data = true
  pre_bootstrap_user_data    = var.pre_bootstrap_user_data
  post_bootstrap_user_data   = var.post_bootstrap_user_data
  bootstrap_extra_args       = var.bootstrap_extra_args
  user_data_template_path    = var.user_data_template_path

  cloudinit_pre_nodeadm  = var.cloudinit_pre_nodeadm
  cloudinit_post_nodeadm = var.cloudinit_post_nodeadm
}

################################################################################
# EFA Support
################################################################################

data "aws_ec2_instance_type" "this" {
  count = local.enable_efa_support ? 1 : 0

  instance_type = var.instance_type
}

locals {
  enable_efa_support = var.create && var.enable_efa_support && local.instance_type_provided

  instance_type_provided = var.instance_type != ""
  num_network_cards      = try(data.aws_ec2_instance_type.this[0].maximum_network_cards, 0)

  efa_network_interfaces = [
    for i in range(local.num_network_cards) : {
      associate_public_ip_address = false
      delete_on_termination       = true
      device_index                = i == 0 ? 0 : 1
      network_card_index          = i
      interface_type              = "efa"
    }
  ]

  network_interfaces = local.enable_efa_support ? local.efa_network_interfaces : var.network_interfaces
}

################################################################################
# Launch template
################################################################################

locals {
  launch_template_name = coalesce(var.launch_template_name, "${var.name}-node-group")
  security_group_ids   = compact(concat([var.cluster_primary_security_group_id], var.vpc_security_group_ids))

  placement = local.enable_efa_support ? { group_name = aws_placement_group.this[0].name } : var.placement
}

resource "aws_launch_template" "this" {
  count = var.create && var.create_launch_template ? 1 : 0

  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings

    content {
      device_name = try(block_device_mappings.value.device_name, null)

      dynamic "ebs" {
        for_each = try([block_device_mappings.value.ebs], [])

        content {
          delete_on_termination = try(ebs.value.delete_on_termination, null)
          encrypted             = try(ebs.value.encrypted, null)
          iops                  = try(ebs.value.iops, null)
          kms_key_id            = try(ebs.value.kms_key_id, null)
          snapshot_id           = try(ebs.value.snapshot_id, null)
          throughput            = try(ebs.value.throughput, null)
          volume_size           = try(ebs.value.volume_size, null)
          volume_type           = try(ebs.value.volume_type, null)
        }
      }

      no_device    = try(block_device_mappings.value.no_device, null)
      virtual_name = try(block_device_mappings.value.virtual_name, null)
    }
  }

  dynamic "capacity_reservation_specification" {
    for_each = length(var.capacity_reservation_specification) > 0 ? [var.capacity_reservation_specification] : []

    content {
      capacity_reservation_preference = try(capacity_reservation_specification.value.capacity_reservation_preference, null)

      dynamic "capacity_reservation_target" {
        for_each = try([capacity_reservation_specification.value.capacity_reservation_target], [])

        content {
          capacity_reservation_id                 = try(capacity_reservation_target.value.capacity_reservation_id, null)
          capacity_reservation_resource_group_arn = try(capacity_reservation_target.value.capacity_reservation_resource_group_arn, null)
        }
      }
    }
  }

  dynamic "cpu_options" {
    for_each = length(var.cpu_options) > 0 ? [var.cpu_options] : []

    content {
      core_count       = try(cpu_options.value.core_count, null)
      threads_per_core = try(cpu_options.value.threads_per_core, null)
    }
  }

  dynamic "credit_specification" {
    for_each = length(var.credit_specification) > 0 ? [var.credit_specification] : []

    content {
      cpu_credits = try(credit_specification.value.cpu_credits, null)
    }
  }

  default_version         = var.launch_template_default_version
  description             = var.launch_template_description
  disable_api_termination = var.disable_api_termination
  ebs_optimized           = var.ebs_optimized

  dynamic "elastic_gpu_specifications" {
    for_each = var.elastic_gpu_specifications

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

  image_id                             = coalesce(var.ami_id, nonsensitive(data.aws_ssm_parameter.ami[0].value))
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior

  dynamic "instance_market_options" {
    for_each = length(var.instance_market_options) > 0 ? [var.instance_market_options] : []

    content {
      market_type = try(instance_market_options.value.market_type, null)

      dynamic "spot_options" {
        for_each = try([instance_market_options.value.spot_options], [])

        content {
          block_duration_minutes         = try(spot_options.value.block_duration_minutes, null)
          instance_interruption_behavior = try(spot_options.value.instance_interruption_behavior, null)
          max_price                      = try(spot_options.value.max_price, null)
          spot_instance_type             = try(spot_options.value.spot_instance_type, null)
          valid_until                    = try(spot_options.value.valid_until, null)
        }
      }
    }
  }

  dynamic "instance_requirements" {
    for_each = length(var.instance_requirements) > 0 ? [var.instance_requirements] : []

    content {

      dynamic "accelerator_count" {
        for_each = try([instance_requirements.value.accelerator_count], [])

        content {
          max = try(accelerator_count.value.max, null)
          min = try(accelerator_count.value.min, null)
        }
      }

      accelerator_manufacturers = try(instance_requirements.value.accelerator_manufacturers, [])
      accelerator_names         = try(instance_requirements.value.accelerator_names, [])

      dynamic "accelerator_total_memory_mib" {
        for_each = try([instance_requirements.value.accelerator_total_memory_mib], [])

        content {
          max = try(accelerator_total_memory_mib.value.max, null)
          min = try(accelerator_total_memory_mib.value.min, null)
        }
      }

      accelerator_types      = try(instance_requirements.value.accelerator_types, [])
      allowed_instance_types = try(instance_requirements.value.allowed_instance_types, null)
      bare_metal             = try(instance_requirements.value.bare_metal, null)

      dynamic "baseline_ebs_bandwidth_mbps" {
        for_each = try([instance_requirements.value.baseline_ebs_bandwidth_mbps], [])

        content {
          max = try(baseline_ebs_bandwidth_mbps.value.max, null)
          min = try(baseline_ebs_bandwidth_mbps.value.min, null)
        }
      }

      burstable_performance   = try(instance_requirements.value.burstable_performance, null)
      cpu_manufacturers       = try(instance_requirements.value.cpu_manufacturers, [])
      excluded_instance_types = try(instance_requirements.value.excluded_instance_types, null)
      instance_generations    = try(instance_requirements.value.instance_generations, [])
      local_storage           = try(instance_requirements.value.local_storage, null)
      local_storage_types     = try(instance_requirements.value.local_storage_types, [])

      dynamic "memory_gib_per_vcpu" {
        for_each = try([instance_requirements.value.memory_gib_per_vcpu], [])

        content {
          max = try(memory_gib_per_vcpu.value.max, null)
          min = try(memory_gib_per_vcpu.value.min, null)
        }
      }

      dynamic "memory_mib" {
        for_each = [instance_requirements.value.memory_mib]

        content {
          max = try(memory_mib.value.max, null)
          min = memory_mib.value.min
        }
      }

      dynamic "network_bandwidth_gbps" {
        for_each = try([instance_requirements.value.network_bandwidth_gbps], [])

        content {
          max = try(network_bandwidth_gbps.value.max, null)
          min = try(network_bandwidth_gbps.value.min, null)
        }
      }

      dynamic "network_interface_count" {
        for_each = try([instance_requirements.value.network_interface_count], [])

        content {
          max = try(network_interface_count.value.max, null)
          min = try(network_interface_count.value.min, null)
        }
      }

      on_demand_max_price_percentage_over_lowest_price = try(instance_requirements.value.on_demand_max_price_percentage_over_lowest_price, null)
      require_hibernate_support                        = try(instance_requirements.value.require_hibernate_support, null)
      spot_max_price_percentage_over_lowest_price      = try(instance_requirements.value.spot_max_price_percentage_over_lowest_price, null)

      dynamic "total_local_storage_gb" {
        for_each = try([instance_requirements.value.total_local_storage_gb], [])

        content {
          max = try(total_local_storage_gb.value.max, null)
          min = try(total_local_storage_gb.value.min, null)
        }
      }

      dynamic "vcpu_count" {
        for_each = [instance_requirements.value.vcpu_count]

        content {
          max = try(vcpu_count.value.max, null)
          min = vcpu_count.value.min
        }
      }
    }
  }

  instance_type = var.instance_type
  kernel_id     = var.kernel_id
  key_name      = var.key_name

  dynamic "license_specification" {
    for_each = length(var.license_specifications) > 0 ? var.license_specifications : {}

    content {
      license_configuration_arn = license_specification.value.license_configuration_arn
    }
  }

  dynamic "maintenance_options" {
    for_each = length(var.maintenance_options) > 0 ? [var.maintenance_options] : []

    content {
      auto_recovery = try(maintenance_options.value.auto_recovery, null)
    }
  }

  dynamic "metadata_options" {
    for_each = length(var.metadata_options) > 0 ? [var.metadata_options] : []

    content {
      http_endpoint               = try(metadata_options.value.http_endpoint, null)
      http_protocol_ipv6          = try(metadata_options.value.http_protocol_ipv6, null)
      http_put_response_hop_limit = try(metadata_options.value.http_put_response_hop_limit, null)
      http_tokens                 = try(metadata_options.value.http_tokens, null)
      instance_metadata_tags      = try(metadata_options.value.instance_metadata_tags, null)
    }
  }

  dynamic "monitoring" {
    for_each = var.enable_monitoring ? [1] : []

    content {
      enabled = var.enable_monitoring
    }
  }

  name        = var.launch_template_use_name_prefix ? null : local.launch_template_name
  name_prefix = var.launch_template_use_name_prefix ? "${local.launch_template_name}-" : null

  dynamic "network_interfaces" {
    for_each = local.network_interfaces

    content {
      associate_carrier_ip_address = try(network_interfaces.value.associate_carrier_ip_address, null)
      associate_public_ip_address  = try(network_interfaces.value.associate_public_ip_address, null)
      delete_on_termination        = try(network_interfaces.value.delete_on_termination, null)
      description                  = try(network_interfaces.value.description, null)
      device_index                 = try(network_interfaces.value.device_index, null)
      interface_type               = try(network_interfaces.value.interface_type, null)
      ipv4_address_count           = try(network_interfaces.value.ipv4_address_count, null)
      ipv4_addresses               = try(network_interfaces.value.ipv4_addresses, [])
      ipv4_prefix_count            = try(network_interfaces.value.ipv4_prefix_count, null)
      ipv4_prefixes                = try(network_interfaces.value.ipv4_prefixes, null)
      ipv6_address_count           = try(network_interfaces.value.ipv6_address_count, null)
      ipv6_addresses               = try(network_interfaces.value.ipv6_addresses, [])
      ipv6_prefix_count            = try(network_interfaces.value.ipv6_prefix_count, null)
      ipv6_prefixes                = try(network_interfaces.value.ipv6_prefixes, [])
      network_card_index           = try(network_interfaces.value.network_card_index, null)
      network_interface_id         = try(network_interfaces.value.network_interface_id, null)
      private_ip_address           = try(network_interfaces.value.private_ip_address, null)
      # Ref: https://github.com/hashicorp/terraform-provider-aws/issues/4570
      security_groups = compact(concat(try(network_interfaces.value.security_groups, []), local.security_group_ids))
      subnet_id       = try(network_interfaces.value.subnet_id, null)
    }
  }

  dynamic "placement" {
    for_each = length(local.placement) > 0 ? [local.placement] : []

    content {
      affinity                = try(placement.value.affinity, null)
      availability_zone       = lookup(placement.value, "availability_zone", null)
      group_name              = lookup(placement.value, "group_name", null)
      host_id                 = lookup(placement.value, "host_id", null)
      host_resource_group_arn = lookup(placement.value, "host_resource_group_arn", null)
      partition_number        = try(placement.value.partition_number, null)
      spread_domain           = try(placement.value.spread_domain, null)
      tenancy                 = try(placement.value.tenancy, null)
    }
  }

  dynamic "private_dns_name_options" {
    for_each = length(var.private_dns_name_options) > 0 ? [var.private_dns_name_options] : []

    content {
      enable_resource_name_dns_aaaa_record = try(private_dns_name_options.value.enable_resource_name_dns_aaaa_record, null)
      enable_resource_name_dns_a_record    = try(private_dns_name_options.value.enable_resource_name_dns_a_record, null)
      hostname_type                        = try(private_dns_name_options.value.hostname_type, null)
    }
  }

  ram_disk_id = var.ram_disk_id

  dynamic "tag_specifications" {
    for_each = toset(var.tag_specifications)

    content {
      resource_type = tag_specifications.key
      tags          = merge(var.tags, { Name = var.name }, var.launch_template_tags)
    }
  }

  update_default_version = var.update_launch_template_default_version
  user_data              = module.user_data.user_data
  vpc_security_group_ids = length(local.network_interfaces) > 0 ? [] : local.security_group_ids

  tags = var.tags

  # Prevent premature access of policies by pods that
  # require permissions on create/destroy that depend on nodes
  depends_on = [
    aws_iam_role_policy_attachment.this,
    aws_iam_role_policy_attachment.additional,
  ]

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# Node Group
################################################################################

locals {
  launch_template_id = var.create && var.create_launch_template ? aws_launch_template.this[0].id : var.launch_template_id
  # Change order to allow users to set version priority before using defaults
  launch_template_version = coalesce(var.launch_template_version, try(aws_launch_template.this[0].default_version, "$Default"))
}

resource "aws_autoscaling_group" "this" {
  count = var.create && var.create_autoscaling_group ? 1 : 0

  availability_zones        = var.availability_zones
  capacity_rebalance        = var.capacity_rebalance
  context                   = var.context
  default_cooldown          = var.default_cooldown
  default_instance_warmup   = var.default_instance_warmup
  desired_capacity          = var.desired_size
  enabled_metrics           = var.enabled_metrics
  force_delete              = var.force_delete
  force_delete_warm_pool    = var.force_delete_warm_pool
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type

  dynamic "initial_lifecycle_hook" {
    for_each = var.initial_lifecycle_hooks

    content {
      default_result          = try(initial_lifecycle_hook.value.default_result, null)
      heartbeat_timeout       = try(initial_lifecycle_hook.value.heartbeat_timeout, null)
      lifecycle_transition    = initial_lifecycle_hook.value.lifecycle_transition
      name                    = initial_lifecycle_hook.value.name
      notification_metadata   = try(initial_lifecycle_hook.value.notification_metadata, null)
      notification_target_arn = try(initial_lifecycle_hook.value.notification_target_arn, null)
      role_arn                = try(initial_lifecycle_hook.value.role_arn, null)
    }
  }

  dynamic "instance_maintenance_policy" {
    for_each = length(var.instance_maintenance_policy) > 0 ? [var.instance_maintenance_policy] : []

    content {
      min_healthy_percentage = instance_maintenance_policy.value.min_healthy_percentage
      max_healthy_percentage = instance_maintenance_policy.value.max_healthy_percentage
    }
  }

  dynamic "instance_refresh" {
    for_each = length(var.instance_refresh) > 0 ? [var.instance_refresh] : []

    content {
      dynamic "preferences" {
        for_each = try([instance_refresh.value.preferences], [])

        content {
          checkpoint_delay             = try(preferences.value.checkpoint_delay, null)
          checkpoint_percentages       = try(preferences.value.checkpoint_percentages, null)
          instance_warmup              = try(preferences.value.instance_warmup, null)
          max_healthy_percentage       = try(preferences.value.max_healthy_percentage, null)
          min_healthy_percentage       = try(preferences.value.min_healthy_percentage, null)
          scale_in_protected_instances = try(preferences.value.scale_in_protected_instances, null)
          skip_matching                = try(preferences.value.skip_matching, null)
          standby_instances            = try(preferences.value.standby_instances, null)
        }
      }

      strategy = instance_refresh.value.strategy
      triggers = try(instance_refresh.value.triggers, null)
    }
  }

  dynamic "launch_template" {
    for_each = var.use_mixed_instances_policy ? [] : [1]

    content {
      id      = local.launch_template_id
      version = local.launch_template_version
    }
  }

  max_instance_lifetime = var.max_instance_lifetime
  max_size              = var.max_size
  metrics_granularity   = var.metrics_granularity
  min_elb_capacity      = var.min_elb_capacity
  min_size              = var.min_size

  ignore_failed_scaling_activities = var.ignore_failed_scaling_activities

  dynamic "mixed_instances_policy" {
    for_each = var.use_mixed_instances_policy ? [var.mixed_instances_policy] : []

    content {
      dynamic "instances_distribution" {
        for_each = try([mixed_instances_policy.value.instances_distribution], [])

        content {
          on_demand_allocation_strategy            = try(instances_distribution.value.on_demand_allocation_strategy, null)
          on_demand_base_capacity                  = try(instances_distribution.value.on_demand_base_capacity, null)
          on_demand_percentage_above_base_capacity = try(instances_distribution.value.on_demand_percentage_above_base_capacity, null)
          spot_allocation_strategy                 = try(instances_distribution.value.spot_allocation_strategy, null)
          spot_instance_pools                      = try(instances_distribution.value.spot_instance_pools, null)
          spot_max_price                           = try(instances_distribution.value.spot_max_price, null)
        }
      }

      launch_template {
        launch_template_specification {
          launch_template_id = local.launch_template_id
          version            = local.launch_template_version
        }

        dynamic "override" {
          for_each = try(mixed_instances_policy.value.override, [])

          content {
            dynamic "instance_requirements" {
              for_each = try([override.value.instance_requirements], [])

              content {

                dynamic "accelerator_count" {
                  for_each = try([instance_requirements.value.accelerator_count], [])

                  content {
                    max = try(accelerator_count.value.max, null)
                    min = try(accelerator_count.value.min, null)
                  }
                }

                accelerator_manufacturers = try(instance_requirements.value.accelerator_manufacturers, [])
                accelerator_names         = try(instance_requirements.value.accelerator_names, [])

                dynamic "accelerator_total_memory_mib" {
                  for_each = try([instance_requirements.value.accelerator_total_memory_mib], [])

                  content {
                    max = try(accelerator_total_memory_mib.value.max, null)
                    min = try(accelerator_total_memory_mib.value.min, null)
                  }
                }

                accelerator_types      = try(instance_requirements.value.accelerator_types, [])
                allowed_instance_types = try(instance_requirements.value.allowed_instance_types, null)
                bare_metal             = try(instance_requirements.value.bare_metal, null)

                dynamic "baseline_ebs_bandwidth_mbps" {
                  for_each = try([instance_requirements.value.baseline_ebs_bandwidth_mbps], [])

                  content {
                    max = try(baseline_ebs_bandwidth_mbps.value.max, null)
                    min = try(baseline_ebs_bandwidth_mbps.value.min, null)
                  }
                }

                burstable_performance   = try(instance_requirements.value.burstable_performance, null)
                cpu_manufacturers       = try(instance_requirements.value.cpu_manufacturers, [])
                excluded_instance_types = try(instance_requirements.value.excluded_instance_types, [])
                instance_generations    = try(instance_requirements.value.instance_generations, [])
                local_storage           = try(instance_requirements.value.local_storage, null)
                local_storage_types     = try(instance_requirements.value.local_storage_types, [])

                dynamic "memory_gib_per_vcpu" {
                  for_each = try([instance_requirements.value.memory_gib_per_vcpu], [])

                  content {
                    max = try(memory_gib_per_vcpu.value.max, null)
                    min = try(memory_gib_per_vcpu.value.min, null)
                  }
                }

                dynamic "memory_mib" {
                  for_each = [instance_requirements.value.memory_mib]

                  content {
                    max = try(memory_mib.value.max, null)
                    min = memory_mib.value.min
                  }
                }

                dynamic "network_interface_count" {
                  for_each = try([instance_requirements.value.network_interface_count], [])

                  content {
                    max = try(network_interface_count.value.max, null)
                    min = try(network_interface_count.value.min, null)
                  }
                }

                on_demand_max_price_percentage_over_lowest_price = try(instance_requirements.value.on_demand_max_price_percentage_over_lowest_price, null)
                require_hibernate_support                        = try(instance_requirements.value.require_hibernate_support, null)
                spot_max_price_percentage_over_lowest_price      = try(instance_requirements.value.spot_max_price_percentage_over_lowest_price, null)

                dynamic "total_local_storage_gb" {
                  for_each = try([instance_requirements.value.total_local_storage_gb], [])

                  content {
                    max = try(total_local_storage_gb.value.max, null)
                    min = try(total_local_storage_gb.value.min, null)
                  }
                }

                dynamic "vcpu_count" {
                  for_each = [instance_requirements.value.vcpu_count]

                  content {
                    max = try(vcpu_count.value.max, null)
                    min = vcpu_count.value.min
                  }
                }
              }
            }

            instance_type = try(override.value.instance_type, null)

            dynamic "launch_template_specification" {
              for_each = try([override.value.launch_template_specification], [])

              content {
                launch_template_id = try(launch_template_specification.value.launch_template_id, null)
                version            = try(launch_template_specification.value.version, null)
              }
            }

            weighted_capacity = try(override.value.weighted_capacity, null)
          }
        }
      }
    }
  }

  name                    = var.use_name_prefix ? null : var.name
  name_prefix             = var.use_name_prefix ? "${var.name}-" : null
  placement_group         = var.placement_group
  protect_from_scale_in   = var.protect_from_scale_in
  service_linked_role_arn = var.service_linked_role_arn
  suspended_processes     = var.suspended_processes

  dynamic "tag" {
    for_each = merge(
      {
        "Name"                                      = var.name
        "kubernetes.io/cluster/${var.cluster_name}" = "owned"
        "k8s.io/cluster/${var.cluster_name}"        = "owned"
      },
      var.tags
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

  target_group_arns         = var.target_group_arns
  termination_policies      = var.termination_policies
  vpc_zone_identifier       = local.enable_efa_support ? data.aws_subnets.placement_group[0].ids : var.subnet_ids
  wait_for_capacity_timeout = var.wait_for_capacity_timeout
  wait_for_elb_capacity     = var.wait_for_elb_capacity

  dynamic "warm_pool" {
    for_each = length(var.warm_pool) > 0 ? [var.warm_pool] : []

    content {
      dynamic "instance_reuse_policy" {
        for_each = try([warm_pool.value.instance_reuse_policy], [])

        content {
          reuse_on_scale_in = try(instance_reuse_policy.value.reuse_on_scale_in, null)
        }
      }

      max_group_prepared_capacity = try(warm_pool.value.max_group_prepared_capacity, null)
      min_size                    = try(warm_pool.value.min_size, null)
      pool_state                  = try(warm_pool.value.pool_state, null)
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
# IAM Role
################################################################################

locals {
  create_iam_instance_profile = var.create && var.create_iam_instance_profile

  iam_role_name          = coalesce(var.iam_role_name, "${var.name}-node-group")
  iam_role_policy_prefix = "arn:${data.aws_partition.current.partition}:iam::aws:policy"

  ipv4_cni_policy = { for k, v in {
    AmazonEKS_CNI_Policy = "${local.iam_role_policy_prefix}/AmazonEKS_CNI_Policy"
  } : k => v if var.iam_role_attach_cni_policy && var.cluster_ip_family == "ipv4" }
  ipv6_cni_policy = { for k, v in {
    AmazonEKS_CNI_IPv6_Policy = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:policy/AmazonEKS_CNI_IPv6_Policy"
  } : k => v if var.iam_role_attach_cni_policy && var.cluster_ip_family == "ipv6" }
}

data "aws_iam_policy_document" "assume_role_policy" {
  count = local.create_iam_instance_profile ? 1 : 0

  statement {
    sid     = "EKSNodeAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  count = local.create_iam_instance_profile ? 1 : 0

  name        = var.iam_role_use_name_prefix ? null : local.iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.iam_role_name}-" : null
  path        = var.iam_role_path
  description = var.iam_role_description

  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy[0].json
  permissions_boundary  = var.iam_role_permissions_boundary
  force_detach_policies = true

  tags = merge(var.tags, var.iam_role_tags)
}

# Policies attached ref https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group
resource "aws_iam_role_policy_attachment" "this" {
  for_each = { for k, v in merge(
    {
      AmazonEKSWorkerNodePolicy          = "${local.iam_role_policy_prefix}/AmazonEKSWorkerNodePolicy"
      AmazonEC2ContainerRegistryReadOnly = "${local.iam_role_policy_prefix}/AmazonEC2ContainerRegistryReadOnly"
    },
    local.ipv4_cni_policy,
    local.ipv6_cni_policy
  ) : k => v if local.create_iam_instance_profile }

  policy_arn = each.value
  role       = aws_iam_role.this[0].name
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = { for k, v in var.iam_role_additional_policies : k => v if local.create_iam_instance_profile }

  policy_arn = each.value
  role       = aws_iam_role.this[0].name
}

resource "aws_iam_instance_profile" "this" {
  count = local.create_iam_instance_profile ? 1 : 0

  role = aws_iam_role.this[0].name

  name        = var.iam_role_use_name_prefix ? null : local.iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.iam_role_name}-" : null
  path        = var.iam_role_path

  tags = merge(var.tags, var.iam_role_tags)

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# IAM Role Policy
################################################################################

locals {
  create_iam_role_policy = local.create_iam_instance_profile && var.create_iam_role_policy && length(var.iam_role_policy_statements) > 0
}

data "aws_iam_policy_document" "role" {
  count = local.create_iam_role_policy ? 1 : 0

  dynamic "statement" {
    for_each = var.iam_role_policy_statements

    content {
      sid           = try(statement.value.sid, null)
      actions       = try(statement.value.actions, null)
      not_actions   = try(statement.value.not_actions, null)
      effect        = try(statement.value.effect, null)
      resources     = try(statement.value.resources, null)
      not_resources = try(statement.value.not_resources, null)

      dynamic "principals" {
        for_each = try(statement.value.principals, [])

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = try(statement.value.not_principals, [])

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = try(statement.value.conditions, [])

        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }
}

resource "aws_iam_role_policy" "this" {
  count = local.create_iam_role_policy ? 1 : 0

  name        = var.iam_role_use_name_prefix ? null : local.iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.iam_role_name}-" : null
  policy      = data.aws_iam_policy_document.role[0].json
  role        = aws_iam_role.this[0].id
}

################################################################################
# Placement Group
################################################################################

locals {
  create_placement_group = var.create && (local.enable_efa_support || var.create_placement_group)
}

resource "aws_placement_group" "this" {
  count = local.create_placement_group ? 1 : 0

  name     = "${var.cluster_name}-${var.name}"
  strategy = "cluster"

  tags = var.tags
}

################################################################################
# Instance AZ Lookup

# Instances usually used in placement groups w/ EFA are only available in
# select availability zones. These data sources will cross reference the availability
# zones supported by the instance type with the subnets provided to ensure only
# AZs/subnets that are supported are used.
################################################################################

# Find the availability zones supported by the instance type
# TODO - remove at next breaking change
# Force users to be explicit about which AZ to use when using placement groups,
# with or without EFA support
data "aws_ec2_instance_type_offerings" "this" {
  count = local.enable_efa_support ? 1 : 0

  filter {
    name   = "instance-type"
    values = [var.instance_type]
  }

  location_type = "availability-zone-id"
}

# Reverse the lookup to find one of the subnets provided based on the availability
# availability zone ID of the queried instance type (supported)
data "aws_subnets" "placement_group" {
  count = local.create_placement_group ? 1 : 0

  filter {
    name   = "subnet-id"
    values = var.subnet_ids
  }

  # The data source can lookup the first available AZ or you can specify an AZ (next filter)
  dynamic "filter" {
    for_each = local.create_placement_group && var.placement_group_az == null ? [1] : []

    content {
      name   = "availability-zone-id"
      values = data.aws_ec2_instance_type_offerings.this[0].locations
    }
  }

  dynamic "filter" {
    for_each = var.placement_group_az != null ? [var.placement_group_az] : []

    content {
      name   = "availability-zone"
      values = [filter.value]
    }
  }
}

################################################################################
# Access Entry
################################################################################

resource "aws_eks_access_entry" "this" {
  count = var.create && var.create_access_entry ? 1 : 0

  cluster_name  = var.cluster_name
  principal_arn = var.create_iam_instance_profile ? aws_iam_role.this[0].arn : var.iam_role_arn
  type          = local.user_data_type == "windows" ? "EC2_WINDOWS" : "EC2_LINUX"

  tags = var.tags
}

################################################################################
# Autoscaling group schedule
################################################################################

resource "aws_autoscaling_schedule" "this" {
  for_each = { for k, v in var.schedules : k => v if var.create && var.create_schedule }

  scheduled_action_name  = each.key
  autoscaling_group_name = aws_autoscaling_group.this[0].name

  min_size         = try(each.value.min_size, null)
  max_size         = try(each.value.max_size, null)
  desired_capacity = try(each.value.desired_size, null)
  start_time       = try(each.value.start_time, null)
  end_time         = try(each.value.end_time, null)
  time_zone        = try(each.value.time_zone, null)

  # [Minute] [Hour] [Day_of_Month] [Month_of_Year] [Day_of_Week]
  # Cron examples: https://crontab.guru/examples.html
  recurrence = try(each.value.recurrence, null)
}
