# Worker Groups using Launch Configurations

resource "aws_autoscaling_group" "workers" {
  count = var.create_eks ? local.worker_group_count : 0
  name_prefix = join(
    "-",
    compact(
      [
        aws_eks_cluster.this[0].name,
        lookup(var.worker_groups[count.index], "name", count.index),
        lookup(var.worker_groups[count.index], "asg_recreate_on_change", local.workers_group_defaults["asg_recreate_on_change"]) ? random_pet.workers[count.index].id : ""
      ]
    )
  )
  desired_capacity = lookup(
    var.worker_groups[count.index],
    "asg_desired_capacity",
    local.workers_group_defaults["asg_desired_capacity"],
  )
  max_size = lookup(
    var.worker_groups[count.index],
    "asg_max_size",
    local.workers_group_defaults["asg_max_size"],
  )
  min_size = lookup(
    var.worker_groups[count.index],
    "asg_min_size",
    local.workers_group_defaults["asg_min_size"],
  )
  force_delete = lookup(
    var.worker_groups[count.index],
    "asg_force_delete",
    local.workers_group_defaults["asg_force_delete"],
  )
  target_group_arns = lookup(
    var.worker_groups[count.index],
    "target_group_arns",
    local.workers_group_defaults["target_group_arns"]
  )
  service_linked_role_arn = lookup(
    var.worker_groups[count.index],
    "service_linked_role_arn",
    local.workers_group_defaults["service_linked_role_arn"],
  )
  launch_configuration = aws_launch_configuration.workers.*.id[count.index]
  vpc_zone_identifier = lookup(
    var.worker_groups[count.index],
    "subnets",
    local.workers_group_defaults["subnets"]
  )
  protect_from_scale_in = lookup(
    var.worker_groups[count.index],
    "protect_from_scale_in",
    local.workers_group_defaults["protect_from_scale_in"],
  )
  suspended_processes = lookup(
    var.worker_groups[count.index],
    "suspended_processes",
    local.workers_group_defaults["suspended_processes"]
  )
  enabled_metrics = lookup(
    var.worker_groups[count.index],
    "enabled_metrics",
    local.workers_group_defaults["enabled_metrics"]
  )
  placement_group = lookup(
    var.worker_groups[count.index],
    "placement_group",
    local.workers_group_defaults["placement_group"],
  )
  termination_policies = lookup(
    var.worker_groups[count.index],
    "termination_policies",
    local.workers_group_defaults["termination_policies"]
  )
  max_instance_lifetime = lookup(
    var.worker_groups[count.index],
    "max_instance_lifetime",
    local.workers_group_defaults["max_instance_lifetime"],
  )
  default_cooldown = lookup(
    var.worker_groups[count.index],
    "default_cooldown",
    local.workers_group_defaults["default_cooldown"]
  )
  health_check_grace_period = lookup(
    var.worker_groups[count.index],
    "health_check_grace_period",
    local.workers_group_defaults["health_check_grace_period"]
  )

  dynamic "initial_lifecycle_hook" {
    for_each = var.worker_create_initial_lifecycle_hooks ? lookup(var.worker_groups[count.index], "asg_initial_lifecycle_hooks", local.workers_group_defaults["asg_initial_lifecycle_hooks"]) : []
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

  tags = concat(
    [
      {
        "key"                 = "Name"
        "value"               = "${aws_eks_cluster.this[0].name}-${lookup(var.worker_groups[count.index], "name", count.index)}-eks_asg"
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
    local.asg_tags,
    lookup(
      var.worker_groups[count.index],
      "tags",
      local.workers_group_defaults["tags"]
    )
  )

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

resource "aws_launch_configuration" "workers" {
  count       = var.create_eks ? local.worker_group_count : 0
  name_prefix = "${aws_eks_cluster.this[0].name}-${lookup(var.worker_groups[count.index], "name", count.index)}"
  associate_public_ip_address = lookup(
    var.worker_groups[count.index],
    "public_ip",
    local.workers_group_defaults["public_ip"],
  )
  security_groups = flatten([
    local.worker_security_group_id,
    var.worker_additional_security_group_ids,
    lookup(
      var.worker_groups[count.index],
      "additional_security_group_ids",
      local.workers_group_defaults["additional_security_group_ids"]
    )
  ])
  iam_instance_profile = coalescelist(
    aws_iam_instance_profile.workers.*.id,
    data.aws_iam_instance_profile.custom_worker_group_iam_instance_profile.*.name,
  )[count.index]
  image_id = lookup(
    var.worker_groups[count.index],
    "ami_id",
    lookup(var.worker_groups[count.index], "platform", local.workers_group_defaults["platform"]) == "windows" ? local.default_ami_id_windows : local.default_ami_id_linux,
  )
  instance_type = lookup(
    var.worker_groups[count.index],
    "instance_type",
    local.workers_group_defaults["instance_type"],
  )
  key_name = lookup(
    var.worker_groups[count.index],
    "key_name",
    local.workers_group_defaults["key_name"],
  )
  user_data_base64 = base64encode(data.template_file.userdata.*.rendered[count.index])
  ebs_optimized = lookup(
    var.worker_groups[count.index],
    "ebs_optimized",
    ! contains(
      local.ebs_optimized_not_supported,
      lookup(
        var.worker_groups[count.index],
        "instance_type",
        local.workers_group_defaults["instance_type"]
      )
    )
  )
  enable_monitoring = lookup(
    var.worker_groups[count.index],
    "enable_monitoring",
    local.workers_group_defaults["enable_monitoring"],
  )
  spot_price = lookup(
    var.worker_groups[count.index],
    "spot_price",
    local.workers_group_defaults["spot_price"],
  )
  placement_tenancy = lookup(
    var.worker_groups[count.index],
    "placement_tenancy",
    local.workers_group_defaults["placement_tenancy"],
  )

  root_block_device {
    encrypted = lookup(
      var.worker_groups[count.index],
      "root_encrypted",
      local.workers_group_defaults["root_encrypted"],
    )
    volume_size = lookup(
      var.worker_groups[count.index],
      "root_volume_size",
      local.workers_group_defaults["root_volume_size"],
    )
    volume_type = lookup(
      var.worker_groups[count.index],
      "root_volume_type",
      local.workers_group_defaults["root_volume_type"],
    )
    iops = lookup(
      var.worker_groups[count.index],
      "root_iops",
      local.workers_group_defaults["root_iops"],
    )
    delete_on_termination = true
  }

  dynamic "ebs_block_device" {
    for_each = lookup(var.worker_groups[count.index], "additional_ebs_volumes", local.workers_group_defaults["additional_ebs_volumes"])

    content {
      device_name = ebs_block_device.value.block_device_name
      volume_size = lookup(
        ebs_block_device.value,
        "volume_size",
        local.workers_group_defaults["root_volume_size"],
      )
      volume_type = lookup(
        ebs_block_device.value,
        "volume_type",
        local.workers_group_defaults["root_volume_type"],
      )
      iops = lookup(
        ebs_block_device.value,
        "iops",
        local.workers_group_defaults["root_iops"],
      )
      encrypted = lookup(
        ebs_block_device.value,
        "encrypted",
        local.workers_group_defaults["root_encrypted"],
      )
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", true)
    }

  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "random_pet" "workers" {
  count = var.create_eks ? local.worker_group_count : 0

  separator = "-"
  length    = 2

  keepers = {
    lc_name = aws_launch_configuration.workers[count.index].name
  }
}

resource "aws_security_group" "workers" {
  count       = var.worker_create_security_group && var.create_eks ? 1 : 0
  name_prefix = aws_eks_cluster.this[0].name
  description = "Security group for all nodes in the cluster."
  vpc_id      = var.vpc_id
  tags = merge(
    var.tags,
    {
      "Name"                                                  = "${aws_eks_cluster.this[0].name}-eks_worker_sg"
      "kubernetes.io/cluster/${aws_eks_cluster.this[0].name}" = "owned"
    },
  )
}

resource "aws_security_group_rule" "workers_egress_internet" {
  count             = var.worker_create_security_group && var.create_eks ? 1 : 0
  description       = "Allow nodes all egress to the Internet."
  protocol          = "-1"
  security_group_id = local.worker_security_group_id
  cidr_blocks       = ["0.0.0.0/0"]
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

resource "aws_iam_role" "workers" {
  count                 = var.manage_worker_iam_resources && var.create_eks ? 1 : 0
  name_prefix           = var.workers_role_name != "" ? null : aws_eks_cluster.this[0].name
  name                  = var.workers_role_name != "" ? var.workers_role_name : null
  assume_role_policy    = data.aws_iam_policy_document.workers_assume_role_policy.json
  permissions_boundary  = var.permissions_boundary
  path                  = var.iam_path
  force_detach_policies = true
  tags                  = var.tags
}

resource "aws_iam_instance_profile" "workers" {
  count       = var.manage_worker_iam_resources && var.create_eks ? local.worker_group_count : 0
  name_prefix = aws_eks_cluster.this[0].name
  role = lookup(
    var.worker_groups[count.index],
    "iam_role_id",
    local.default_iam_role_id,
  )

  path = var.iam_path
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
