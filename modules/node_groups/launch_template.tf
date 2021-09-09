data "cloudinit_config" "workers_userdata" {
  for_each = { for k, v in local.node_groups_expanded : k => v if v["create_launch_template"] }

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
        ami_id               = lookup(each.value, "ami_id", "")
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
  for_each = { for k, v in local.node_groups_expanded : k => v if v["create_launch_template"] }

  name_prefix            = local.node_groups_names[each.key]
  description            = format("EKS Managed Node Group custom LT for %s", local.node_groups_names[each.key])
  update_default_version = lookup(each.value, "update_default_version", true)

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = lookup(each.value, "disk_size", null)
      volume_type           = lookup(each.value, "disk_type", null)
      iops                  = lookup(each.value, "disk_iops", null)
      throughput            = lookup(each.value, "disk_throughput", null)
      encrypted             = lookup(each.value, "disk_encrypted", null)
      kms_key_id            = lookup(each.value, "disk_kms_key_id", null)
      delete_on_termination = true
    }
  }

  ebs_optimized = lookup(each.value, "ebs_optimized", !contains(var.ebs_optimized_not_supported, element(each.value.instance_types, 0)))

  instance_type = each.value["set_instance_types_on_lt"] ? element(each.value.instance_types, 0) : null

  monitoring {
    enabled = lookup(each.value, "enable_monitoring", null)
  }

  network_interfaces {
    associate_public_ip_address = lookup(each.value, "public_ip", null)
    delete_on_termination       = lookup(each.value, "eni_delete", null)
    security_groups = compact(flatten([
      var.worker_security_group_id,
      var.worker_additional_security_group_ids,
      lookup(
        each.value,
        "additional_security_group_ids",
        null,
      ),
    ]))
  }

  # if you want to use a custom AMI
  image_id = lookup(each.value, "ami_id", null)

  # If you use a custom AMI, you need to supply via user-data, the bootstrap script as EKS DOESNT merge its managed user-data then
  # you can add more than the minimum code you see in the template, e.g. install SSM agent, see https://github.com/aws/containers-roadmap/issues/593#issuecomment-577181345
  #
  # (optionally you can use https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/cloudinit_config to render the script, example: https://github.com/terraform-aws-modules/terraform-aws-eks/pull/997#issuecomment-705286151)

  user_data = data.cloudinit_config.workers_userdata[each.key].rendered

  key_name = lookup(each.value, "key_name", null)

  metadata_options {
    http_endpoint               = lookup(each.value, "metadata_http_endpoint", null)
    http_tokens                 = lookup(each.value, "metadata_http_tokens", null)
    http_put_response_hop_limit = lookup(each.value, "metadata_http_put_response_hop_limit", null)
  }

  # Supplying custom tags to EKS instances is another use-case for LaunchTemplates
  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.tags,
      {
        Name = local.node_groups_names[each.key]
      },
      lookup(var.node_groups_defaults, "additional_tags", {}),
      lookup(var.node_groups[each.key], "additional_tags", {})
    )
  }

  # Supplying custom tags to EKS instances root volumes is another use-case for LaunchTemplates. (doesnt add tags to dynamically provisioned volumes via PVC tho)
  tag_specifications {
    resource_type = "volume"

    tags = merge(
      var.tags,
      {
        Name = local.node_groups_names[each.key]
      },
      lookup(var.node_groups_defaults, "additional_tags", {}),
      lookup(var.node_groups[each.key], "additional_tags", {})
    )
  }

  # Supplying custom tags to EKS instances ENI's is another use-case for LaunchTemplates
  tag_specifications {
    resource_type = "network-interface"

    tags = merge(
      var.tags,
      {
        Name = local.node_groups_names[each.key]
      },
      lookup(var.node_groups_defaults, "additional_tags", {}),
      lookup(var.node_groups[each.key], "additional_tags", {})
    )
  }

  # Tag the LT itself
  tags = merge(
    var.tags,
    lookup(var.node_groups_defaults, "additional_tags", {}),
    lookup(var.node_groups[each.key], "additional_tags", {}),
  )

  lifecycle {
    create_before_destroy = true
  }
}
