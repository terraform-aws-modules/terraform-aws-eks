# Worker Groups using Launch Configurations

resource "aws_autoscaling_group" "workers" {
  for_each = var.create_eks ? local.worker_groups_with_defaults : {}
  name_prefix = join(
    "-",
    compact(
      [
        coalescelist(aws_eks_cluster.this[*].name, [""])[0],
        each.value.name,
        each.value.asg_recreate_on_change ? random_pet.workers[each.key].id : ""
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
  launch_configuration      = aws_launch_configuration.workers[each.key].id
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

  dynamic "warm_pool" {
    for_each = lookup(each.value, "warm_pool", null) != null ? [lookup(each.value, "warm_pool")] : []

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
          "value"               = "${coalescelist(aws_eks_cluster.this[*].name, [""])[0]}-${each.value.name}-eks_asg"
          "propagate_at_launch" = true
        },
        {
          "key"                 = "kubernetes.io/cluster/${coalescelist(aws_eks_cluster.this[*].name, [""])[0]}"
          "value"               = "owned"
          "propagate_at_launch" = true
        },
        {
          "key"                 = "k8s.io/cluster/${coalescelist(aws_eks_cluster.this[*].name, [""])[0]}"
          "value"               = "owned"
          "propagate_at_launch" = true
        },
      ],
      [
        for tag_key, tag_value in var.tags :
        tomap({
          key                 = tag_key
          value               = tag_value
          propagate_at_launch = "true"
        })
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

resource "aws_launch_configuration" "workers" {
  for_each                    = var.create_eks ? local.worker_groups_with_defaults : {}
  name_prefix                 = "${coalescelist(aws_eks_cluster.this[*].name, [""])[0]}-${each.value.name}"
  associate_public_ip_address = each.value.public_ip
  security_groups = flatten([
    local.worker_security_group_id,
    var.worker_additional_security_group_ids,
    each.value.additional_security_group_ids
  ])
  iam_instance_profile = coalesce(
    aws_iam_instance_profile.workers[each.key].id,
    lookup(
      data.aws_iam_instance_profile.custom_worker_group_iam_instance_profile,
      each.key,
      { name = "" }
    ).name
  )
  image_id = lookup(
    each.value,
    "ami_id",
    each.value.platform == "windows" ? local.default_ami_id_windows : local.default_ami_id_linux,
  )
  instance_type    = each.value.instance_type
  key_name         = each.value.key_name
  user_data_base64 = base64encode(data.template_file.userdata[each.key].rendered)
  ebs_optimized = lookup(
    each.value,
    "ebs_optimized",
    !contains(
      local.ebs_optimized_not_supported,
      each.value.instance_type
    )
  )
  enable_monitoring = each.value.enable_monitoring
  spot_price        = each.value.spot_price
  placement_tenancy = each.value.placement_tenancy

  metadata_options {
    http_endpoint               = each.value.metadata_http_endpoint
    http_tokens                 = each.value.metadata_http_tokens
    http_put_response_hop_limit = each.value.metadata_http_put_response_hop_limit
  }

  root_block_device {
    encrypted             = each.value.root_encrypted
    volume_size           = each.value.root_volume_size
    volume_type           = each.value.root_volume_type
    iops                  = each.value.root_iops
    delete_on_termination = true
  }

  dynamic "ebs_block_device" {
    for_each = each.value.additional_ebs_volumes

    content {
      device_name           = ebs_block_device.value.block_device_name
      volume_size           = ebs_block_device.value.volume_size
      volume_type           = ebs_block_device.value.volume_type
      iops                  = ebs_block_device.value.iops
      encrypted             = ebs_block_device.value.encrypted
      delete_on_termination = ebs_block_device.value.delete_on_termination
    }
  }

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

resource "random_pet" "workers" {
  for_each = var.create_eks ? local.worker_groups_with_defaults : {}

  separator = "-"
  length    = 2

  keepers = {
    lc_name = aws_launch_configuration.workers[each.key].name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "workers" {
  count       = var.worker_create_security_group && var.create_eks ? 1 : 0
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
  count             = var.worker_create_security_group && var.create_eks ? 1 : 0
  description       = "Allow nodes all egress to the Internet."
  protocol          = "-1"
  security_group_id = local.worker_security_group_id
  cidr_blocks       = var.workers_egress_cidrs
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "workers_ingress_self" {
  count                    = var.worker_create_security_group && var.create_eks ? 1 : 0
  description              = "Allow node to communicate with each other."
  protocol                 = "-1"
  security_group_id        = local.worker_security_group_id
  source_security_group_id = local.worker_security_group_id
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster" {
  count                    = var.worker_create_security_group && var.create_eks ? 1 : 0
  description              = "Allow workers pods to receive communication from the cluster control plane."
  protocol                 = "tcp"
  security_group_id        = local.worker_security_group_id
  source_security_group_id = local.cluster_security_group_id
  from_port                = var.worker_sg_ingress_from_port
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_kubelet" {
  count                    = var.worker_create_security_group && var.create_eks ? var.worker_sg_ingress_from_port > 10250 ? 1 : 0 : 0
  description              = "Allow workers Kubelets to receive communication from the cluster control plane."
  protocol                 = "tcp"
  security_group_id        = local.worker_security_group_id
  source_security_group_id = local.cluster_security_group_id
  from_port                = 10250
  to_port                  = 10250
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_https" {
  count                    = var.worker_create_security_group && var.create_eks ? 1 : 0
  description              = "Allow pods running extension API servers on port 443 to receive communication from cluster control plane."
  protocol                 = "tcp"
  security_group_id        = local.worker_security_group_id
  source_security_group_id = local.cluster_security_group_id
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_primary" {
  count                    = var.worker_create_security_group && var.worker_create_cluster_primary_security_group_rules && var.cluster_version >= 1.14 && var.create_eks ? 1 : 0
  description              = "Allow pods running on workers to receive communication from cluster primary security group (e.g. Fargate pods)."
  protocol                 = "all"
  security_group_id        = local.worker_security_group_id
  source_security_group_id = local.cluster_primary_security_group_id
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster_primary_ingress_workers" {
  count                    = var.worker_create_security_group && var.worker_create_cluster_primary_security_group_rules && var.cluster_version >= 1.14 && var.create_eks ? 1 : 0
  description              = "Allow pods running on workers to send communication to cluster primary security group (e.g. Fargate pods)."
  protocol                 = "all"
  security_group_id        = local.cluster_primary_security_group_id
  source_security_group_id = local.worker_security_group_id
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_iam_role" "workers" {
  count                 = var.manage_worker_iam_resources && var.create_eks ? 1 : 0
  name_prefix           = var.workers_role_name != "" ? null : coalescelist(aws_eks_cluster.this[*].name, [""])[0]
  name                  = var.workers_role_name != "" ? var.workers_role_name : null
  assume_role_policy    = data.aws_iam_policy_document.workers_assume_role_policy.json
  permissions_boundary  = var.permissions_boundary
  path                  = var.iam_path
  force_detach_policies = true
  tags                  = var.tags
}

resource "aws_iam_instance_profile" "workers" {
  for_each    = var.manage_worker_iam_resources && var.create_eks ? local.worker_groups_with_defaults : {}
  name_prefix = aws_eks_cluster.this[0].name
  role        = each.value.iam_role_id
  path        = var.iam_path

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEKSWorkerNodePolicy" {
  count      = var.manage_worker_iam_resources && var.create_eks ? 1 : 0
  policy_arn = "${local.policy_arn_prefix}/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.workers[0].name
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEKS_CNI_Policy" {
  count      = var.manage_worker_iam_resources && var.attach_worker_cni_policy && var.create_eks ? 1 : 0
  policy_arn = "${local.policy_arn_prefix}/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.workers[0].name
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEC2ContainerRegistryReadOnly" {
  count      = var.manage_worker_iam_resources && var.create_eks ? 1 : 0
  policy_arn = "${local.policy_arn_prefix}/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.workers[0].name
}

resource "aws_iam_role_policy_attachment" "workers_additional_policies" {
  count      = var.manage_worker_iam_resources && var.create_eks ? length(var.workers_additional_policies) : 0
  role       = aws_iam_role.workers[0].name
  policy_arn = var.workers_additional_policies[count.index]
}
