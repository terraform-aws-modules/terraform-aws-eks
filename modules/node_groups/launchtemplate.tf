data "template_file" "workers_userdata" {
  for_each = { for k, v in local.node_groups_expanded : k => v if v["create_launch_template"] }
  template = file("${path.module}/templates/userdata.sh.tpl")

  vars = {
    kubelet_extra_args = each.value["kubelet_extra_args"]
  }
}

# This is based on the LT that EKS would create if no custom one is specified (aws ec2 describe-launch-template-versions --launch-template-id xxx)
# there are several more options one could set but you probably dont need to modify them
# you can take the default and add your custom AMI and/or custom tags
#
# Trivia: AWS transparently creates a copy of your LaunchTemplate and actually uses that copy then for the node group. If you DONT use a custom AMI,
# then the default user-data for bootstrapping a cluster is merged in the copy.
resource "aws_launch_template" "workers" {
  for_each               = { for k, v in local.node_groups_expanded : k => v if v["create_launch_template"] }
  name_prefix            = lookup(each.value, "name", join("-", [var.cluster_name, each.key, random_pet.node_groups[each.key].id]))
  description            = lookup(each.value, "name", join("-", [var.cluster_name, each.key, random_pet.node_groups[each.key].id]))
  update_default_version = true

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = lookup(each.value, "disk_size", 20)
      volume_type           = "gp2"
      delete_on_termination = true
      # encrypted             = true

      # Enable this if you want to encrypt your node root volumes with a KMS/CMK. encryption of PVCs is handled via k8s StorageClass tho
      # you also need to attach data.aws_iam_policy_document.ebs_decryption.json from the disk_encryption_policy.tf to the KMS/CMK key then !!
      # kms_key_id            = var.kms_key_arn
    }
  }

  instance_type = each.value.instance_type

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
  }

  # if you want to use a custom AMI
  # image_id      = var.ami_id

  # If you use a custom AMI, you need to supply via user-data, the bootstrap script as EKS DOESNT merge its managed user-data then
  # you can add more than the minimum code you see in the template, e.g. install SSM agent, see https://github.com/aws/containers-roadmap/issues/593#issuecomment-577181345
  #
  # (optionally you can use https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/cloudinit_config to render the script, example: https://github.com/terraform-aws-modules/terraform-aws-eks/pull/997#issuecomment-705286151)

  user_data = base64encode(
    data.template_file.workers_userdata[each.key].rendered,
  )


  # Supplying custom tags to EKS instances is another use-case for LaunchTemplates
  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.tags,
      lookup(var.node_groups_defaults, "additional_tags", {}),
      lookup(var.node_groups[each.key], "additional_tags", {}),
      {
        Name = lookup(each.value, "name", join("-", [var.cluster_name, each.key, random_pet.node_groups[each.key].id]))
      }
    )
  }

  # Supplying custom tags to EKS instances root volumes is another use-case for LaunchTemplates. (doesnt add tags to dynamically provisioned volumes via PVC tho)
  tag_specifications {
    resource_type = "volume"

    tags = merge(
      var.tags,
      lookup(var.node_groups_defaults, "additional_tags", {}),
      lookup(var.node_groups[each.key], "additional_tags", {}),
      {
        Name = lookup(each.value, "name", join("-", [var.cluster_name, each.key, random_pet.node_groups[each.key].id]))
      }
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
