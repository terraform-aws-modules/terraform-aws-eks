data "aws_partition" "current" {
  count = var.create && var.partition == "" ? 1 : 0
}
data "aws_caller_identity" "current" {
  count = var.create && var.account_id == "" ? 1 : 0
}

locals {
  partition  = try(data.aws_partition.current[0].partition, var.partition)
  account_id = try(data.aws_caller_identity.current[0].account_id, var.account_id)
}

################################################################################
# AMI SSM Parameter
################################################################################

locals {
  # Just to ensure templating doesn't fail when values are not provided
  ssm_kubernetes_version = var.kubernetes_version != null ? var.kubernetes_version : ""

  # Map the AMI type to the respective SSM param path
  ami_type_to_ssm_param = {
    AL2_x86_64                 = "/aws/service/eks/optimized-ami/${local.ssm_kubernetes_version}/amazon-linux-2/recommended/image_id"
    AL2_x86_64_GPU             = "/aws/service/eks/optimized-ami/${local.ssm_kubernetes_version}/amazon-linux-2-gpu/recommended/image_id"
    AL2_ARM_64                 = "/aws/service/eks/optimized-ami/${local.ssm_kubernetes_version}/amazon-linux-2-arm64/recommended/image_id"
    BOTTLEROCKET_ARM_64        = "/aws/service/bottlerocket/aws-k8s-${local.ssm_kubernetes_version}/arm64/latest/image_id"
    BOTTLEROCKET_x86_64        = "/aws/service/bottlerocket/aws-k8s-${local.ssm_kubernetes_version}/x86_64/latest/image_id"
    BOTTLEROCKET_ARM_64_FIPS   = "/aws/service/bottlerocket/aws-k8s-${local.ssm_kubernetes_version}-fips/arm64/latest/image_id"
    BOTTLEROCKET_x86_64_FIPS   = "/aws/service/bottlerocket/aws-k8s-${local.ssm_kubernetes_version}-fips/x86_64/latest/image_id"
    BOTTLEROCKET_ARM_64_NVIDIA = "/aws/service/bottlerocket/aws-k8s-${local.ssm_kubernetes_version}-nvidia/arm64/latest/image_id"
    BOTTLEROCKET_x86_64_NVIDIA = "/aws/service/bottlerocket/aws-k8s-${local.ssm_kubernetes_version}-nvidia/x86_64/latest/image_id"
    WINDOWS_CORE_2019_x86_64   = "/aws/service/ami-windows-latest/Windows_Server-2019-English-Full-EKS_Optimized-${local.ssm_kubernetes_version}/image_id"
    WINDOWS_FULL_2019_x86_64   = "/aws/service/ami-windows-latest/Windows_Server-2019-English-Core-EKS_Optimized-${local.ssm_kubernetes_version}/image_id"
    WINDOWS_CORE_2022_x86_64   = "/aws/service/ami-windows-latest/Windows_Server-2022-English-Full-EKS_Optimized-${local.ssm_kubernetes_version}/image_id"
    WINDOWS_FULL_2022_x86_64   = "/aws/service/ami-windows-latest/Windows_Server-2022-English-Core-EKS_Optimized-${local.ssm_kubernetes_version}/image_id"
    AL2023_x86_64_STANDARD     = "/aws/service/eks/optimized-ami/${local.ssm_kubernetes_version}/amazon-linux-2023/x86_64/standard/recommended/image_id"
    AL2023_ARM_64_STANDARD     = "/aws/service/eks/optimized-ami/${local.ssm_kubernetes_version}/amazon-linux-2023/arm64/standard/recommended/image_id"
    AL2023_x86_64_NEURON       = "/aws/service/eks/optimized-ami/${local.ssm_kubernetes_version}/amazon-linux-2023/x86_64/neuron/recommended/image_id"
    AL2023_x86_64_NVIDIA       = "/aws/service/eks/optimized-ami/${local.ssm_kubernetes_version}/amazon-linux-2023/x86_64/nvidia/recommended/image_id"
    AL2023_ARM_64_NVIDIA       = "/aws/service/eks/optimized-ami/${local.ssm_kubernetes_version}/amazon-linux-2023/arm64/nvidia/recommended/image_id"
  }
}

data "aws_ssm_parameter" "ami" {
  count = var.create ? 1 : 0

  region = var.region

  name = local.ami_type_to_ssm_param[var.ami_type]
}

################################################################################
# User Data
################################################################################

module "user_data" {
  source = "../_user_data"

  create                    = var.create
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
  count = var.create && var.enable_efa_support ? 1 : 0

  region = var.region

  instance_type = var.instance_type
}

locals {
  enable_efa_support = var.create && var.enable_efa_support && local.instance_type_provided

  instance_type_provided = var.instance_type != ""
  num_network_cards      = try(data.aws_ec2_instance_type.this[0].maximum_network_cards, 0)

  # Primary network interface must be EFA, remaining can be EFA or EFA-only
  efa_network_interfaces = [
    for i in range(local.num_network_cards) : {
      associate_public_ip_address = false
      delete_on_termination       = true
      device_index                = i == 0 ? 0 : 1
      network_card_index          = i
      interface_type              = var.enable_efa_only ? contains(concat([0], var.efa_indices), i) ? "efa" : "efa-only" : "efa"
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
}

resource "aws_launch_template" "this" {
  count = var.create && var.create_launch_template ? 1 : 0

  region = var.region

  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings != null ? var.block_device_mappings : {}

    content {
      device_name = block_device_mappings.value.device_name

      dynamic "ebs" {
        for_each = block_device_mappings.value.ebs != null ? [block_device_mappings.value.ebs] : []

        content {
          delete_on_termination      = ebs.value.delete_on_termination
          encrypted                  = ebs.value.encrypted
          iops                       = ebs.value.iops
          kms_key_id                 = ebs.value.kms_key_id
          snapshot_id                = ebs.value.snapshot_id
          throughput                 = ebs.value.throughput
          volume_initialization_rate = ebs.value.volume_initialization_rate
          volume_size                = ebs.value.volume_size
          volume_type                = ebs.value.volume_type
        }
      }

      no_device    = block_device_mappings.value.no_device
      virtual_name = block_device_mappings.value.virtual_name
    }
  }

  dynamic "capacity_reservation_specification" {
    for_each = var.capacity_reservation_specification != null ? [var.capacity_reservation_specification] : []

    content {
      capacity_reservation_preference = capacity_reservation_specification.value.capacity_reservation_preference

      dynamic "capacity_reservation_target" {
        for_each = capacity_reservation_specification.value.capacity_reservation_target != null ? [capacity_reservation_specification.value.capacity_reservation_target] : []
        content {
          capacity_reservation_id                 = capacity_reservation_target.value.capacity_reservation_id
          capacity_reservation_resource_group_arn = capacity_reservation_target.value.capacity_reservation_resource_group_arn
        }
      }
    }
  }

  dynamic "cpu_options" {
    for_each = var.cpu_options != null ? [var.cpu_options] : []

    content {
      amd_sev_snp      = cpu_options.value.amd_sev_snp
      core_count       = cpu_options.value.core_count
      threads_per_core = cpu_options.value.threads_per_core
    }
  }

  dynamic "credit_specification" {
    for_each = var.credit_specification != null ? [var.credit_specification] : []

    content {
      cpu_credits = credit_specification.value.cpu_credits
    }
  }

  default_version         = var.launch_template_default_version
  description             = var.launch_template_description
  disable_api_termination = var.disable_api_termination
  ebs_optimized           = var.ebs_optimized

  dynamic "enclave_options" {
    for_each = var.enclave_options != null ? [var.enclave_options] : []

    content {
      enabled = enclave_options.value.enabled
    }
  }

  iam_instance_profile {
    arn = var.create_iam_instance_profile ? aws_iam_instance_profile.this[0].arn : var.iam_instance_profile_arn
  }

  image_id                             = coalesce(var.ami_id, nonsensitive(data.aws_ssm_parameter.ami[0].value))
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior

  dynamic "instance_market_options" {
    for_each = var.instance_market_options != null ? [var.instance_market_options] : []

    content {
      market_type = instance_market_options.value.market_type

      dynamic "spot_options" {
        for_each = instance_market_options.value.spot_options != null ? [instance_market_options.value.spot_options] : []

        content {
          block_duration_minutes         = spot_options.value.block_duration_minutes
          instance_interruption_behavior = spot_options.value.instance_interruption_behavior
          max_price                      = spot_options.value.max_price
          spot_instance_type             = spot_options.value.spot_instance_type
          valid_until                    = spot_options.value.valid_until
        }
      }
    }
  }

  dynamic "instance_requirements" {
    for_each = var.instance_requirements != null ? [var.instance_requirements] : []

    content {
      dynamic "accelerator_count" {
        for_each = instance_requirements.value.accelerator_count != null ? [instance_requirements.value.accelerator_count] : []

        content {
          max = accelerator_count.value.max
          min = accelerator_count.value.min
        }
      }

      accelerator_manufacturers = instance_requirements.value.accelerator_manufacturers
      accelerator_names         = instance_requirements.value.accelerator_names

      dynamic "accelerator_total_memory_mib" {
        for_each = instance_requirements.value.accelerator_total_memory_mib != null ? [instance_requirements.value.accelerator_total_memory_mib] : []

        content {
          max = accelerator_total_memory_mib.value.max
          min = accelerator_total_memory_mib.value.min
        }
      }

      accelerator_types      = instance_requirements.value.accelerator_types
      allowed_instance_types = instance_requirements.value.allowed_instance_types
      bare_metal             = instance_requirements.value.bare_metal

      dynamic "baseline_ebs_bandwidth_mbps" {
        for_each = instance_requirements.value.baseline_ebs_bandwidth_mbps != null ? [instance_requirements.value.baseline_ebs_bandwidth_mbps] : []

        content {
          max = baseline_ebs_bandwidth_mbps.value.max
          min = baseline_ebs_bandwidth_mbps.value.min
        }
      }

      burstable_performance                                   = instance_requirements.value.burstable_performance
      cpu_manufacturers                                       = instance_requirements.value.cpu_manufacturers
      excluded_instance_types                                 = instance_requirements.value.excluded_instance_types
      instance_generations                                    = instance_requirements.value.instance_generations
      local_storage                                           = instance_requirements.value.local_storage
      local_storage_types                                     = instance_requirements.value.local_storage_types
      max_spot_price_as_percentage_of_optimal_on_demand_price = instance_requirements.value.max_spot_price_as_percentage_of_optimal_on_demand_price

      dynamic "memory_gib_per_vcpu" {
        for_each = instance_requirements.value.memory_gib_per_vcpu != null ? [instance_requirements.value.memory_gib_per_vcpu] : []

        content {
          max = memory_gib_per_vcpu.value.max
          min = memory_gib_per_vcpu.value.min
        }
      }

      dynamic "memory_mib" {
        for_each = instance_requirements.value.memory_mib != null ? [instance_requirements.value.memory_mib] : []

        content {
          max = memory_mib.value.max
          min = memory_mib.value.min
        }
      }

      dynamic "network_interface_count" {
        for_each = instance_requirements.value.network_interface_count != null ? [instance_requirements.value.network_interface_count] : []

        content {
          max = network_interface_count.value.max
          min = network_interface_count.value.min
        }
      }

      on_demand_max_price_percentage_over_lowest_price = instance_requirements.value.on_demand_max_price_percentage_over_lowest_price
      require_hibernate_support                        = instance_requirements.value.require_hibernate_support
      spot_max_price_percentage_over_lowest_price      = instance_requirements.value.spot_max_price_percentage_over_lowest_price

      dynamic "total_local_storage_gb" {
        for_each = instance_requirements.value.total_local_storage_gb != null ? [instance_requirements.value.total_local_storage_gb] : []

        content {
          max = total_local_storage_gb.value.max
          min = total_local_storage_gb.value.min
        }
      }

      dynamic "vcpu_count" {
        for_each = instance_requirements.value.vcpu_count != null ? [instance_requirements.value.vcpu_count] : []

        content {
          max = vcpu_count.value.max
          min = vcpu_count.value.min
        }
      }
    }
  }

  instance_type = var.instance_type
  kernel_id     = var.kernel_id
  key_name      = var.key_name

  dynamic "license_specification" {
    for_each = var.license_specifications != null ? var.license_specifications : []

    content {
      license_configuration_arn = license_specification.value.license_configuration_arn
    }
  }

  dynamic "maintenance_options" {
    for_each = var.maintenance_options != null ? [var.maintenance_options] : []

    content {
      auto_recovery = maintenance_options.value.auto_recovery
    }
  }

  dynamic "metadata_options" {
    for_each = var.metadata_options != null ? [var.metadata_options] : []

    content {
      http_endpoint               = metadata_options.value.http_endpoint
      http_protocol_ipv6          = metadata_options.value.http_protocol_ipv6
      http_put_response_hop_limit = metadata_options.value.http_put_response_hop_limit
      http_tokens                 = metadata_options.value.http_tokens
      instance_metadata_tags      = metadata_options.value.instance_metadata_tags
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
    for_each = length(var.network_interfaces) > 0 ? var.network_interfaces : []

    content {
      associate_carrier_ip_address = network_interfaces.value.associate_carrier_ip_address
      associate_public_ip_address  = network_interfaces.value.associate_public_ip_address

      dynamic "connection_tracking_specification" {
        for_each = network_interfaces.value.connection_tracking_specification != null ? [network_interfaces.value.connection_tracking_specification] : []

        content {
          tcp_established_timeout = connection_tracking_specification.value.tcp_established_timeout
          udp_stream_timeout      = connection_tracking_specification.value.udp_stream_timeout
          udp_timeout             = connection_tracking_specification.value.udp_timeout
        }
      }

      delete_on_termination = network_interfaces.value.delete_on_termination
      description           = network_interfaces.value.description
      device_index          = network_interfaces.value.device_index

      dynamic "ena_srd_specification" {
        for_each = network_interfaces.value.ena_srd_specification != null ? [network_interfaces.value.ena_srd_specification] : []

        content {
          ena_srd_enabled = ena_srd_specification.value.ena_srd_enabled

          dynamic "ena_srd_udp_specification" {
            for_each = ena_srd_specification.value.ena_srd_udp_specification != null ? [ena_srd_specification.value.ena_srd_udp_specification] : []

            content {
              ena_srd_udp_enabled = ena_srd_udp_specification.value.ena_srd_udp_enabled
            }
          }
        }
      }

      interface_type       = network_interfaces.value.interface_type
      ipv4_address_count   = network_interfaces.value.ipv4_address_count
      ipv4_addresses       = network_interfaces.value.ipv4_addresses
      ipv4_prefix_count    = network_interfaces.value.ipv4_prefix_count
      ipv4_prefixes        = network_interfaces.value.ipv4_prefixes
      ipv6_address_count   = network_interfaces.value.ipv6_address_count
      ipv6_addresses       = network_interfaces.value.ipv6_addresses
      ipv6_prefix_count    = network_interfaces.value.ipv6_prefix_count
      ipv6_prefixes        = network_interfaces.value.ipv6_prefixes
      network_card_index   = network_interfaces.value.network_card_index
      network_interface_id = network_interfaces.value.network_interface_id
      primary_ipv6         = network_interfaces.value.primary_ipv6
      private_ip_address   = network_interfaces.value.private_ip_address
      # Ref: https://github.com/hashicorp/terraform-provider-aws/issues/4570
      security_groups = compact(concat(network_interfaces.value.security_groups, var.vpc_security_group_ids))
      # Set on EKS managed node group, will fail if set here
      # https://docs.aws.amazon.com/eks/latest/userguide/launch-templates.html#launch-template-basics
      # subnet_id       = try(network_interfaces.value.subnet_id, null)
    }
  }

  dynamic "placement" {
    for_each = var.placement != null || local.create_placement_group ? [var.placement] : []

    content {
      affinity                = try(placement.value.affinity, null)
      availability_zone       = try(placement.value.availability_zone, null)
      group_name              = try(aws_placement_group.this[0].name, placement.value.group_name)
      host_id                 = try(placement.value.host_id, null)
      host_resource_group_arn = try(placement.value.host_resource_group_arn, null)
      partition_number        = try(placement.value.partition_number, null)
      spread_domain           = try(placement.value.spread_domain, null)
      tenancy                 = try(placement.value.tenancy, null)
    }
  }

  dynamic "private_dns_name_options" {
    for_each = var.private_dns_name_options != null ? [var.private_dns_name_options] : []

    content {
      enable_resource_name_dns_aaaa_record = private_dns_name_options.value.enable_resource_name_dns_aaaa_record
      enable_resource_name_dns_a_record    = private_dns_name_options.value.enable_resource_name_dns_a_record
      hostname_type                        = private_dns_name_options.value.hostname_type
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

  region = var.region

  availability_zones        = var.availability_zones
  capacity_rebalance        = var.capacity_rebalance
  context                   = var.context
  default_instance_warmup   = var.default_instance_warmup
  desired_capacity          = var.desired_size
  desired_capacity_type     = var.desired_size_type
  enabled_metrics           = var.enabled_metrics
  force_delete              = var.force_delete
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type

  dynamic "initial_lifecycle_hook" {
    for_each = var.initial_lifecycle_hooks != null ? var.initial_lifecycle_hooks : []

    content {
      default_result          = initial_lifecycle_hook.value.default_result
      heartbeat_timeout       = initial_lifecycle_hook.value.heartbeat_timeout
      lifecycle_transition    = initial_lifecycle_hook.value.lifecycle_transition
      name                    = initial_lifecycle_hook.value.name
      notification_metadata   = initial_lifecycle_hook.value.notification_metadata
      notification_target_arn = initial_lifecycle_hook.value.notification_target_arn
      role_arn                = initial_lifecycle_hook.value.role_arn
    }
  }

  dynamic "instance_maintenance_policy" {
    for_each = var.instance_maintenance_policy != null ? [var.instance_maintenance_policy] : []

    content {
      min_healthy_percentage = instance_maintenance_policy.value.min_healthy_percentage
      max_healthy_percentage = instance_maintenance_policy.value.max_healthy_percentage
    }
  }

  dynamic "instance_refresh" {
    for_each = var.instance_refresh != null ? [var.instance_refresh] : []

    content {
      dynamic "preferences" {
        for_each = instance_refresh.value.preferences != null ? [instance_refresh.value.preferences] : []

        content {
          dynamic "alarm_specification" {
            for_each = preferences.value.alarm_specification != null ? [preferences.value.alarm_specification] : []

            content {
              alarms = alarm_specification.value.alarms
            }
          }

          auto_rollback                = preferences.value.auto_rollback
          checkpoint_delay             = preferences.value.checkpoint_delay
          checkpoint_percentages       = preferences.value.checkpoint_percentages
          instance_warmup              = preferences.value.instance_warmup
          max_healthy_percentage       = preferences.value.max_healthy_percentage
          min_healthy_percentage       = preferences.value.min_healthy_percentage
          scale_in_protected_instances = preferences.value.scale_in_protected_instances
          skip_matching                = preferences.value.skip_matching
          standby_instances            = preferences.value.standby_instances
        }
      }

      strategy = instance_refresh.value.strategy
      triggers = instance_refresh.value.triggers
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
  min_size              = var.min_size

  ignore_failed_scaling_activities = var.ignore_failed_scaling_activities

  dynamic "mixed_instances_policy" {
    for_each = var.use_mixed_instances_policy ? [var.mixed_instances_policy] : []

    content {
      dynamic "instances_distribution" {
        for_each = mixed_instances_policy.value.instances_distribution != null ? [mixed_instances_policy.value.instances_distribution] : []

        content {
          on_demand_allocation_strategy            = instances_distribution.value.on_demand_allocation_strategy
          on_demand_base_capacity                  = instances_distribution.value.on_demand_base_capacity
          on_demand_percentage_above_base_capacity = instances_distribution.value.on_demand_percentage_above_base_capacity
          spot_allocation_strategy                 = instances_distribution.value.spot_allocation_strategy
          spot_instance_pools                      = instances_distribution.value.spot_instance_pools
          spot_max_price                           = instances_distribution.value.spot_max_price
        }
      }

      dynamic "launch_template" {
        for_each = [mixed_instances_policy.value.launch_template]

        content {
          launch_template_specification {
            launch_template_id = local.launch_template_id
            version            = local.launch_template_version
          }

          dynamic "override" {
            for_each = launch_template.value.override != null ? launch_template.value.override : []

            content {
              dynamic "instance_requirements" {
                for_each = override.value.instance_requirements != null ? [override.value.instance_requirements] : []

                content {
                  dynamic "accelerator_count" {
                    for_each = instance_requirements.value.accelerator_count != null ? [instance_requirements.value.accelerator_count] : []

                    content {
                      max = accelerator_count.value.max
                      min = accelerator_count.value.min
                    }
                  }

                  accelerator_manufacturers = instance_requirements.value.accelerator_manufacturers
                  accelerator_names         = instance_requirements.value.accelerator_names

                  dynamic "accelerator_total_memory_mib" {
                    for_each = instance_requirements.value.accelerator_total_memory_mib != null ? [instance_requirements.value.accelerator_total_memory_mib] : []

                    content {
                      max = accelerator_total_memory_mib.value.max
                      min = accelerator_total_memory_mib.value.min
                    }
                  }

                  accelerator_types      = instance_requirements.value.accelerator_types
                  allowed_instance_types = instance_requirements.value.allowed_instance_types
                  bare_metal             = instance_requirements.value.bare_metal

                  dynamic "baseline_ebs_bandwidth_mbps" {
                    for_each = instance_requirements.value.baseline_ebs_bandwidth_mbps != null ? [instance_requirements.value.baseline_ebs_bandwidth_mbps] : []

                    content {
                      max = baseline_ebs_bandwidth_mbps.value.max
                      min = baseline_ebs_bandwidth_mbps.value.min
                    }
                  }

                  burstable_performance                                   = instance_requirements.value.burstable_performance
                  cpu_manufacturers                                       = instance_requirements.value.cpu_manufacturers
                  excluded_instance_types                                 = instance_requirements.value.excluded_instance_types
                  instance_generations                                    = instance_requirements.value.instance_generations
                  local_storage                                           = instance_requirements.value.local_storage
                  local_storage_types                                     = instance_requirements.value.local_storage_types
                  max_spot_price_as_percentage_of_optimal_on_demand_price = instance_requirements.value.max_spot_price_as_percentage_of_optimal_on_demand_price

                  dynamic "memory_gib_per_vcpu" {
                    for_each = instance_requirements.value.memory_gib_per_vcpu != null ? [instance_requirements.value.memory_gib_per_vcpu] : []

                    content {
                      max = memory_gib_per_vcpu.value.max
                      min = memory_gib_per_vcpu.value.min
                    }
                  }

                  dynamic "memory_mib" {
                    for_each = instance_requirements.value.memory_mib != null ? [instance_requirements.value.memory_mib] : []

                    content {
                      max = memory_mib.value.max
                      min = memory_mib.value.min
                    }
                  }

                  dynamic "network_bandwidth_gbps" {
                    for_each = instance_requirements.value.network_bandwidth_gbps != null ? [instance_requirements.value.network_bandwidth_gbps] : []

                    content {
                      max = network_bandwidth_gbps.value.max
                      min = network_bandwidth_gbps.value.min
                    }
                  }

                  dynamic "network_interface_count" {
                    for_each = instance_requirements.value.network_interface_count != null ? [instance_requirements.value.network_interface_count] : []

                    content {
                      max = network_interface_count.value.max
                      min = network_interface_count.value.min
                    }
                  }

                  on_demand_max_price_percentage_over_lowest_price = instance_requirements.value.on_demand_max_price_percentage_over_lowest_price
                  require_hibernate_support                        = instance_requirements.value.require_hibernate_support
                  spot_max_price_percentage_over_lowest_price      = instance_requirements.value.spot_max_price_percentage_over_lowest_price

                  dynamic "total_local_storage_gb" {
                    for_each = instance_requirements.value.total_local_storage_gb != null ? [instance_requirements.value.total_local_storage_gb] : []

                    content {
                      max = total_local_storage_gb.value.max
                      min = total_local_storage_gb.value.min
                    }
                  }

                  dynamic "vcpu_count" {
                    for_each = instance_requirements.value.vcpu_count != null ? [instance_requirements.value.vcpu_count] : []

                    content {
                      max = vcpu_count.value.max
                      min = vcpu_count.value.min
                    }
                  }
                }
              }

              instance_type = override.value.instance_type

              dynamic "launch_template_specification" {
                for_each = override.value.launch_template_specification != null ? [override.value.launch_template_specification] : []

                content {
                  launch_template_id   = launch_template_specification.value.launch_template_id
                  launch_template_name = launch_template_specification.value.launch_template_name
                  version              = launch_template_specification.value.version
                }
              }

              weighted_capacity = override.value.weighted_capacity
            }
          }
        }
      }
    }
  }

  name                  = var.use_name_prefix ? null : var.name
  name_prefix           = var.use_name_prefix ? "${var.name}-" : null
  placement_group       = var.placement_group
  protect_from_scale_in = var.protect_from_scale_in
  suspended_processes   = var.suspended_processes

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

  termination_policies = var.termination_policies
  vpc_zone_identifier  = var.subnet_ids

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      delete = var.timeouts.delete
    }
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
  iam_role_policy_prefix = "arn:${local.partition}:iam::aws:policy"

  ipv4_cni_policy = { for k, v in {
    AmazonEKS_CNI_Policy = "${local.iam_role_policy_prefix}/AmazonEKS_CNI_Policy"
  } : k => v if var.iam_role_attach_cni_policy && var.cluster_ip_family == "ipv4" }
  ipv6_cni_policy = { for k, v in {
    AmazonEKS_CNI_IPv6_Policy = "arn:${local.partition}:iam::${local.account_id}:policy/AmazonEKS_CNI_IPv6_Policy"
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
  create_iam_role_policy = local.create_iam_instance_profile && var.create_iam_role_policy && var.iam_role_policy_statements != null
}

data "aws_iam_policy_document" "role" {
  count = local.create_iam_role_policy ? 1 : 0

  dynamic "statement" {
    for_each = var.iam_role_policy_statements != null ? var.iam_role_policy_statements : []

    content {
      sid           = statement.value.sid
      actions       = statement.value.actions
      not_actions   = statement.value.not_actions
      effect        = statement.value.effect
      resources     = statement.value.resources
      not_resources = statement.value.not_resources

      dynamic "principals" {
        for_each = statement.value.principals != null ? statement.value.principals : []

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = statement.value.not_principals != null ? statement.value.not_principals : []

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = statement.value.condition != null ? statement.value.condition : []

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

  region = var.region

  name     = "${var.cluster_name}-${var.name}"
  strategy = "cluster"

  tags = var.tags
}

################################################################################
# Access Entry
################################################################################

resource "aws_eks_access_entry" "this" {
  count = var.create && var.create_access_entry ? 1 : 0

  region = var.region

  cluster_name  = var.cluster_name
  principal_arn = var.create_iam_instance_profile ? aws_iam_role.this[0].arn : var.iam_role_arn
  type          = startswith(var.ami_type, "WINDOWS_") ? "EC2_WINDOWS" : "EC2_LINUX"

  tags = var.tags
}

################################################################################
# Security Group
################################################################################

locals {
  create_security_group = var.create && var.create_security_group && length(merge(local.security_group_ingress_rules, local.security_group_egress_rules)) > 0
  security_group_name   = coalesce(var.security_group_name, "${var.cluster_name}-${var.name}")

  security_group_ingress_rules = merge({ for k, v in
    {
      all_self_efa = {
        description = "Node to node EFA"
        protocol    = "-1"
        from_port   = 0
        self        = true
      }
    } : k => v if var.enable_efa_support
    },
    var.security_group_ingress_rules
  )
  security_group_egress_rules = merge({ for k, v in
    {
      all_self_efa = {
        description = "Node to node EFA"
        protocol    = "-1"
        to_port     = 0
        self        = true
      }
    } : k => v if var.enable_efa_support
    },
    var.security_group_egress_rules
  )
}

data "aws_subnet" "this" {
  count = local.create_security_group ? 1 : 0

  region = var.region

  id = element(var.subnet_ids, 0)
}

resource "aws_security_group" "this" {
  count = local.create_security_group ? 1 : 0

  region = var.region

  name        = var.security_group_use_name_prefix ? null : local.security_group_name
  name_prefix = var.security_group_use_name_prefix ? "${local.security_group_name}-" : null
  description = var.security_group_description
  vpc_id      = data.aws_subnet.this[0].vpc_id

  tags = merge(
    var.tags,
    { "Name" = local.security_group_name },
    var.security_group_tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = { for k, v in local.security_group_ingress_rules : k => v if length(local.security_group_ingress_rules) > 0 && local.create_security_group }

  region = var.region

  cidr_ipv4                    = each.value.cidr_ipv4
  cidr_ipv6                    = each.value.cidr_ipv6
  description                  = each.value.description
  from_port                    = each.value.from_port
  ip_protocol                  = each.value.ip_protocol
  prefix_list_id               = each.value.prefix_list_id
  referenced_security_group_id = each.value.self ? aws_security_group.this[0].id : each.value.referenced_security_group_id
  security_group_id            = aws_security_group.this[0].id
  tags = merge(
    var.tags,
    var.security_group_tags,
    { "Name" = coalesce(each.value.name, "${local.security_group_name}-${each.key}") },
    each.value.tags
  )
  to_port = try(coalesce(each.value.to_port, each.value.from_port), null)
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = { for k, v in local.security_group_egress_rules : k => v if length(local.security_group_egress_rules) > 0 && local.create_security_group }

  region = var.region

  cidr_ipv4                    = each.value.cidr_ipv4
  cidr_ipv6                    = each.value.cidr_ipv6
  description                  = each.value.description
  from_port                    = try(coalesce(each.value.from_port, each.value.to_port), null)
  ip_protocol                  = each.value.ip_protocol
  prefix_list_id               = each.value.prefix_list_id
  referenced_security_group_id = each.value.self ? aws_security_group.this[0].id : each.value.referenced_security_group_id
  security_group_id            = aws_security_group.this[0].id
  tags = merge(
    var.tags,
    var.security_group_tags,
    { "Name" = coalesce(each.value.name, "${local.security_group_name}-${each.key}") },
    each.value.tags
  )
  to_port = each.value.to_port
}
