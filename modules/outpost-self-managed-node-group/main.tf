###############################################################################
# Node Group Resources
###############################################################################
resource "aws_placement_group" "this" {
  name            = "${var.name}-${random_integer.this.result}"
  strategy        = var.placement_group_strategy
  spread_level    = var.placement_group_strategy == "spread" ? var.placement_group_spread_level : null
  partition_count = var.placement_group_strategy == "partition" ? var.placement_group_partition_count : null
  tags            = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_lifecycle_hook" "this" {
  count                  = var.enable_lifecycle_hook ? 1 : 0
  name                   = "${var.name}-nth-hook"
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
  autoscaling_group_name = module.self_managed_node_group.autoscaling_group_name
  heartbeat_timeout      = 300
  default_result         = "CONTINUE"
  depends_on = [
    module.self_managed_node_group
  ]
}

###############################################################################
# Outpost Node Group
###############################################################################
module "self_managed_node_group" {
  source  = "terraform-aws-modules/eks/aws//modules/self-managed-node-group"
  name    = var.name

  # Cluster
  cluster_name                = local.cluster_name
  cluster_version             = local.cluster_version
  cluster_endpoint            = local.cluster_endpoint
  cluster_auth_base64         = local.cluster_auth
  use_name_prefix             = true
  create_iam_instance_profile = false
  iam_instance_profile_arn    = var.aws_iam_instance_profile_arn

  # Template
  create_launch_template          = true
  launch_template_version         = "$Default"
  launch_template_use_name_prefix = false
  launch_template_name            = "${var.name}-${random_integer.this.result}"
  ami_id                          = var.ami_id != "" ? var.ami_id : var.platform == "bottlerocket" ? data.aws_ami.eks_default_bottlerocket.id : null
  instance_type                   = var.family
  platform                        = var.platform
  bootstrap_extra_args = var.platform == "bottlerocket" ? templatefile(
    "${path.module}/templates/bottlerocket_user_data.tftpl",
    {
      config = {
        "taints" = var.taints
        "labels" = merge(
          {
            "node.kubernetes.io/lifecycle" : "on-demand"
        }, var.extra_labels)
        "enable_ecr_credential_provider" = true
      }
    }
  ) : "--kubelet-extra-args '--node-labels=node.kubernetes.io/lifecycle=on-demand${var.extra_labels != null ? "," : ""}${join(",", [for k, v in var.extra_labels : "${k}=${v}"])}' '--register-with-taints=${join(",", [for v in var.taints : "${v.key}=${v.value}:${v.effect}"])}'"

  ## Storage
  block_device_mappings = merge({
    xvda = {
      device_name = "/dev/xvda"
      ebs = {
        volume_size           = var.root_volume_size
        volume_type           = "gp2"
        encrypted             = true
        delete_on_termination = true
      }
    }
    xvdb = {
      device_name = "/dev/xvdb"
      ebs = {
        volume_size           = var.extra_volume_size
        volume_type           = "gp2"
        encrypted             = true
        delete_on_termination = true
      }
    }
  }, var.extra_block_device_mappings)

  ebs_optimized   = true
  enabled_metrics = local.enabled_metrics

  # Network
  subnet_ids             = [var.node_subnet_id]
  vpc_security_group_ids = local.security_group_ids

  placement_group = aws_placement_group.this.id
  desired_size    = var.max_group_size
  max_size        = var.max_group_size
  min_size        = var.min_group_size

  # Tags
  tags = merge(var.tags, {
    instance_family                  = var.family,
    autoscaling_group_name           = var.name,
    placement_group_strategy         = aws_placement_group.this.strategy,
    spread_level                     = aws_placement_group.this.spread_level,
    placement_group_id               = aws_placement_group.this.id,
    outpost_name                     = var.outpost_name,
    },
    var.add_node_termination_handler_tags ? { "aws-node-termination-handler/managed" = true } : {},
  var.additional_tags == null ? {} : var.additional_tags)
  tag_specifications = ["instance", "network-interface", "volume"]
}

# This helps make the launch template and sg deploys more reliable
resource "random_integer" "this" {
  keepers = {
    placement_group_strategy        = var.placement_group_strategy
    placement_group_partition_count = var.placement_group_partition_count
  }
  min = 1000
  max = 9999
}
