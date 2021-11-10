data "cloudinit_config" "workers_userdata" {
  count = var.create && var.create_launch_template ? 1 : 0

  gzip          = false
  base64_encode = true
  boundary      = "//"

  part {
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/templates/userdata.sh.tpl",
      {
        cluster_name         = var.cluster_name
        cluster_endpoint     = var.cluster_endpoint
        cluster_auth_base64  = var.cluster_auth_base64
        ami_id               = var.ami_id
        ami_is_eks_optimized = each.value["ami_is_eks_optimized"]
        bootstrap_env        = each.value["bootstrap_env"]
        kubelet_extra_args   = each.value["kubelet_extra_args"]
        pre_userdata         = each.value["pre_userdata"]
        capacity_type        = lookup(each.value, "capacity_type", "ON_DEMAND")
        append_labels        = length(lookup(each.value, "k8s_labels", {})) > 0 ? ",${join(",", [for k, v in lookup(each.value, "k8s_labels", {}) : "${k}=${v}"])}" : ""
      }
    )
  }
}

# This is based on the LT that EKS would create if no custom one is specified (aws ec2 describe-launch-template-versions --launch-template-id xxx)
# there are several more options one could set but you probably dont need to modify them
# you can take the default and add your custom AMI and/or custom tags
#
# Trivia: AWS transparently creates a copy of your LaunchTemplate and actually uses that copy then for the node group. If you DONT use a custom AMI,
# then the default user-data for bootstrapping a cluster is merged in the copy.
resource "aws_launch_template" "workers" {
  count = var.create && var.create_launch_template ? 1 : 0

  name        = var.launch_template_use_name_prefix ? null : var.launch_template_name
  name_prefix = var.launch_template_use_name_prefix ? "${var.launch_template_name}-" : null
  description = coalesce(var.description, "EKS Managed Node Group custom LT for ${var.name}")


  ebs_optimized = var.ebs_optimized
  image_id      = var.image_id
  instance_type = var.instance_type
  key_name      = var.key_name
  user_data     = var.user_data

  vpc_security_group_ids = var.vpc_security_group_ids

  default_version                      = var.default_version
  update_default_version               = var.update_default_version
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
    for_each = var.capacity_reservation_specification != null ? [var.capacity_reservation_specification] : []
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
    for_each = var.cpu_options != null ? [var.cpu_options] : []
    content {
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

  dynamic "elastic_gpu_specifications" {
    for_each = var.elastic_gpu_specifications != null ? [var.elastic_gpu_specifications] : []
    content {
      type = elastic_gpu_specifications.value.type
    }
  }

  dynamic "elastic_inference_accelerator" {
    for_each = var.elastic_inference_accelerator != null ? [var.elastic_inference_accelerator] : []
    content {
      type = elastic_inference_accelerator.value.type
    }
  }

  dynamic "enclave_options" {
    for_each = var.enclave_options != null ? [var.enclave_options] : []
    content {
      enabled = enclave_options.value.enabled
    }
  }

  dynamic "hibernation_options" {
    for_each = var.hibernation_options != null ? [var.hibernation_options] : []
    content {
      configured = hibernation_options.value.configured
    }
  }

  dynamic "iam_instance_profile" {
    for_each = var.iam_instance_profile_name != null || var.iam_instance_profile_arn != null ? [1] : []
    content {
      name = var.iam_instance_profile_name
      arn  = var.iam_instance_profile_arn
    }
  }

  dynamic "instance_market_options" {
    for_each = var.instance_market_options != null ? [var.instance_market_options] : []
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
    for_each = var.license_specifications != null ? [var.license_specifications] : []
    content {
      license_configuration_arn = license_specifications.value.license_configuration_arn
    }
  }

  dynamic "metadata_options" {
    for_each = var.metadata_options != null ? [var.metadata_options] : []
    content {
      http_endpoint               = lookup(metadata_options.value, "http_endpoint", null)
      http_tokens                 = lookup(metadata_options.value, "http_tokens", null)
      http_put_response_hop_limit = lookup(metadata_options.value, "http_put_response_hop_limit", null)
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
      ipv4_addresses               = lookup(network_interfaces.value, "ipv4_addresses", null) != null ? network_interfaces.value.ipv4_addresses : []
      ipv4_address_count           = lookup(network_interfaces.value, "ipv4_address_count", null)
      ipv6_addresses               = lookup(network_interfaces.value, "ipv6_addresses", null) != null ? network_interfaces.value.ipv6_addresses : []
      ipv6_address_count           = lookup(network_interfaces.value, "ipv6_address_count", null)
      network_interface_id         = lookup(network_interfaces.value, "network_interface_id", null)
      private_ip_address           = lookup(network_interfaces.value, "private_ip_address", null)
      security_groups              = lookup(network_interfaces.value, "security_groups", null) != null ? network_interfaces.value.security_groups : []
      subnet_id                    = lookup(network_interfaces.value, "subnet_id", null)
    }
  }

  dynamic "placement" {
    for_each = var.placement != null ? [var.placement] : []
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
      tags          = merge(var.tags, { Name = var.name })
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

#   update_default_version = lookup(each.value, "update_default_version", true)

#   block_device_mappings {
#     device_name = "/dev/xvda"

#     ebs {
#       volume_size           = lookup(each.value, "disk_size", null)
#       volume_type           = lookup(each.value, "disk_type", null)
#       iops                  = lookup(each.value, "disk_iops", null)
#       throughput            = lookup(each.value, "disk_throughput", null)
#       encrypted             = lookup(each.value, "disk_encrypted", null)
#       kms_key_id            = lookup(each.value, "disk_kms_key_id", null)
#       delete_on_termination = true
#     }
#   }

#   ebs_optimized = lookup(each.value, "ebs_optimized", !contains(var.ebs_optimized_not_supported, element(each.value.instance_types, 0)))

#   instance_type = each.value["set_instance_types_on_lt"] ? element(each.value.instance_types, 0) : null

#   monitoring {
#     enabled = lookup(each.value, "enable_monitoring", null)
#   }

#   network_interfaces {
#     associate_public_ip_address = lookup(each.value, "public_ip", null)
#     delete_on_termination       = lookup(each.value, "eni_delete", null)
#     security_groups = compact(flatten([
#       var.worker_security_group_id,
#       var.worker_additional_security_group_ids,
#       lookup(
#         each.value,
#         "additional_security_group_ids",
#         null,
#       ),
#     ]))
#   }

#   # if you want to use a custom AMI
#   image_id = lookup(each.value, "ami_id", null)

#   # If you use a custom AMI, you need to supply via user-data, the bootstrap script as EKS DOESNT merge its managed user-data then
#   # you can add more than the minimum code you see in the template, e.g. install SSM agent, see https://github.com/aws/containers-roadmap/issues/593#issuecomment-577181345
#   #
#   # (optionally you can use https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/cloudinit_config to render the script, example: https://github.com/terraform-aws-modules/terraform-aws-eks/pull/997#issuecomment-705286151)

#   user_data = data.cloudinit_config.workers_userdata[each.key].rendered

#   key_name = lookup(each.value, "key_name", null)

#   metadata_options {
#     http_endpoint               = lookup(each.value, "metadata_http_endpoint", null)
#     http_tokens                 = lookup(each.value, "metadata_http_tokens", null)
#     http_put_response_hop_limit = lookup(each.value, "metadata_http_put_response_hop_limit", null)
#   }

#   # Supplying custom tags to EKS instances is another use-case for LaunchTemplates
#   tag_specifications {
#     resource_type = "instance"

#     tags = merge(
#       var.tags,
#       {
#         Name = local.node_groups_names[each.key]
#       },
#       lookup(var.node_groups_defaults, "additional_tags", {}),
#       lookup(var.node_groups[each.key], "additional_tags", {})
#     )
#   }

#   # Supplying custom tags to EKS instances root volumes is another use-case for LaunchTemplates. (doesnt add tags to dynamically provisioned volumes via PVC tho)
#   tag_specifications {
#     resource_type = "volume"

#     tags = merge(
#       var.tags,
#       {
#         Name = local.node_groups_names[each.key]
#       },
#       lookup(var.node_groups_defaults, "additional_tags", {}),
#       lookup(var.node_groups[each.key], "additional_tags", {})
#     )
#   }

#   # Supplying custom tags to EKS instances ENI's is another use-case for LaunchTemplates
#   tag_specifications {
#     resource_type = "network-interface"

#     tags = merge(
#       var.tags,
#       {
#         Name = local.node_groups_names[each.key]
#       },
#       lookup(var.node_groups_defaults, "additional_tags", {}),
#       lookup(var.node_groups[each.key], "additional_tags", {})
#     )
#   }

#   # Tag the LT itself
#   tags = merge(
#     var.tags,
#     lookup(var.node_groups_defaults, "additional_tags", {}),
#     lookup(var.node_groups[each.key], "additional_tags", {}),
#   )

#   lifecycle {
#     create_before_destroy = true
#   }
# }
