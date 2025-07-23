locals {
  kubernetes_network_config = try(aws_eks_cluster.this[0].kubernetes_network_config[0], {})
}

# This sleep resource is used to provide a timed gap between the cluster creation and the downstream dependencies
# that consume the outputs from here. Any of the values that are used as triggers can be used in dependencies
# to ensure that the downstream resources are created after both the cluster is ready and the sleep time has passed.
# This was primarily added to give addons that need to be configured BEFORE data plane compute resources
# enough time to create and configure themselves before the data plane compute resources are created.
resource "time_sleep" "this" {
  count = var.create ? 1 : 0

  create_duration = var.dataplane_wait_duration

  triggers = {
    name               = aws_eks_cluster.this[0].id
    endpoint           = aws_eks_cluster.this[0].endpoint
    kubernetes_version = aws_eks_cluster.this[0].version
    service_cidr       = var.ip_family == "ipv6" ? try(local.kubernetes_network_config.service_ipv6_cidr, "") : try(local.kubernetes_network_config.service_ipv4_cidr, "")

    certificate_authority_data = aws_eks_cluster.this[0].certificate_authority[0].data
  }
}

################################################################################
# EKS IPV6 CNI Policy
# https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html#cni-iam-role-create-ipv6-policy
################################################################################

data "aws_iam_policy_document" "cni_ipv6_policy" {
  count = var.create && var.create_cni_ipv6_iam_policy ? 1 : 0

  statement {
    sid = "AssignDescribe"
    actions = [
      "ec2:AssignIpv6Addresses",
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeInstanceTypes"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "CreateTags"
    actions   = ["ec2:CreateTags"]
    resources = ["arn:${local.partition}:ec2:*:*:network-interface/*"]
  }
}

# Note - we are keeping this to a minimum in hopes that its soon replaced with an AWS managed policy like `AmazonEKS_CNI_Policy`
resource "aws_iam_policy" "cni_ipv6_policy" {
  count = var.create && var.create_cni_ipv6_iam_policy ? 1 : 0

  # Will cause conflicts if trying to create on multiple clusters but necessary to reference by exact name in sub-modules
  name        = "AmazonEKS_CNI_IPv6_Policy"
  description = "IAM policy for EKS CNI to assign IPV6 addresses"
  policy      = data.aws_iam_policy_document.cni_ipv6_policy[0].json

  tags = var.tags
}

################################################################################
# Node Security Group
# Defaults follow https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html
# Plus NTP/HTTPS (otherwise nodes fail to launch)
################################################################################

locals {
  node_sg_name   = coalesce(var.node_security_group_name, "${var.name}-node")
  create_node_sg = var.create && var.create_node_security_group

  node_security_group_id = local.create_node_sg ? aws_security_group.node[0].id : var.node_security_group_id

  node_security_group_rules = {
    ingress_cluster_443 = {
      description                   = "Cluster API to node groups"
      protocol                      = "tcp"
      from_port                     = 443
      to_port                       = 443
      type                          = "ingress"
      source_cluster_security_group = true
    }
    ingress_cluster_kubelet = {
      description                   = "Cluster API to node kubelets"
      protocol                      = "tcp"
      from_port                     = 10250
      to_port                       = 10250
      type                          = "ingress"
      source_cluster_security_group = true
    }
    ingress_self_coredns_tcp = {
      description = "Node to node CoreDNS"
      protocol    = "tcp"
      from_port   = 53
      to_port     = 53
      type        = "ingress"
      self        = true
    }
    ingress_self_coredns_udp = {
      description = "Node to node CoreDNS UDP"
      protocol    = "udp"
      from_port   = 53
      to_port     = 53
      type        = "ingress"
      self        = true
    }
  }

  node_security_group_recommended_rules = { for k, v in {
    ingress_nodes_ephemeral = {
      description = "Node to node ingress on ephemeral ports"
      protocol    = "tcp"
      from_port   = 1025
      to_port     = 65535
      type        = "ingress"
      self        = true
    }
    # metrics-server
    ingress_cluster_4443_webhook = {
      description                   = "Cluster API to node 4443/tcp webhook"
      protocol                      = "tcp"
      from_port                     = 4443
      to_port                       = 4443
      type                          = "ingress"
      source_cluster_security_group = true
    }
    # prometheus-adapter
    ingress_cluster_6443_webhook = {
      description                   = "Cluster API to node 6443/tcp webhook"
      protocol                      = "tcp"
      from_port                     = 6443
      to_port                       = 6443
      type                          = "ingress"
      source_cluster_security_group = true
    }
    # Karpenter
    ingress_cluster_8443_webhook = {
      description                   = "Cluster API to node 8443/tcp webhook"
      protocol                      = "tcp"
      from_port                     = 8443
      to_port                       = 8443
      type                          = "ingress"
      source_cluster_security_group = true
    }
    # ALB controller, NGINX
    ingress_cluster_9443_webhook = {
      description                   = "Cluster API to node 9443/tcp webhook"
      protocol                      = "tcp"
      from_port                     = 9443
      to_port                       = 9443
      type                          = "ingress"
      source_cluster_security_group = true
    }
    egress_all = {
      description      = "Allow all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = var.ip_family == "ipv6" ? ["::/0"] : null
    }
  } : k => v if var.node_security_group_enable_recommended_rules }
}

resource "aws_security_group" "node" {
  count = local.create_node_sg ? 1 : 0

  region = var.region

  name        = var.node_security_group_use_name_prefix ? null : local.node_sg_name
  name_prefix = var.node_security_group_use_name_prefix ? "${local.node_sg_name}${var.prefix_separator}" : null
  description = var.node_security_group_description
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      "Name"                              = local.node_sg_name
      "kubernetes.io/cluster/${var.name}" = "owned"
    },
    var.node_security_group_tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "node" {
  for_each = { for k, v in merge(
    local.node_security_group_rules,
    local.node_security_group_recommended_rules,
    var.node_security_group_additional_rules,
  ) : k => v if local.create_node_sg }

  region = var.region

  security_group_id        = aws_security_group.node[0].id
  protocol                 = each.value.protocol
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  type                     = each.value.type
  description              = try(each.value.description, null)
  cidr_blocks              = try(each.value.cidr_blocks, null)
  ipv6_cidr_blocks         = try(each.value.ipv6_cidr_blocks, null)
  prefix_list_ids          = try(each.value.prefix_list_ids, null)
  self                     = try(each.value.self, null)
  source_security_group_id = try(each.value.source_cluster_security_group, false) ? local.security_group_id : try(each.value.source_security_group_id, null)
}

################################################################################
# Fargate Profile
################################################################################

module "fargate_profile" {
  source = "./modules/fargate-profile"

  for_each = var.create && !local.create_outposts_local_cluster && var.fargate_profiles != null ? var.fargate_profiles : {}

  create = each.value.create

  region = var.region

  # Pass through values to reduce GET requests from data sources
  partition  = local.partition
  account_id = local.account_id

  # Fargate Profile
  cluster_name      = time_sleep.this[0].triggers["name"]
  cluster_ip_family = var.ip_family
  name              = coalesce(each.value.name, each.key)
  subnet_ids        = coalesce(each.value.subnet_ids, var.subnet_ids)
  selectors         = each.value.selectors
  timeouts          = each.value.timeouts

  # IAM role
  create_iam_role               = each.value.create_iam_role
  iam_role_arn                  = each.value.iam_role_arn
  iam_role_name                 = each.value.iam_role_name
  iam_role_use_name_prefix      = each.value.iam_role_use_name_prefix
  iam_role_path                 = each.value.iam_role_path
  iam_role_description          = each.value.iam_role_description
  iam_role_permissions_boundary = each.value.iam_role_permissions_boundary
  iam_role_tags                 = each.value.iam_role_tags
  iam_role_attach_cni_policy    = each.value.iam_role_attach_cni_policy
  iam_role_additional_policies  = lookup(each.value, "iam_role_additional_policies", null)
  create_iam_role_policy        = each.value.create_iam_role_policy
  iam_role_policy_statements    = each.value.iam_role_policy_statements

  tags = merge(
    var.tags,
    each.value.tags,
  )
}

################################################################################
# EKS Managed Node Group
################################################################################

module "eks_managed_node_group" {
  source = "./modules/eks-managed-node-group"

  for_each = var.create && !local.create_outposts_local_cluster && var.eks_managed_node_groups != null ? var.eks_managed_node_groups : {}

  create = each.value.create

  region = var.region

  # Pass through values to reduce GET requests from data sources
  partition  = local.partition
  account_id = local.account_id

  cluster_name       = time_sleep.this[0].triggers["name"]
  kubernetes_version = try(each.value.kubernetes_version, time_sleep.this[0].triggers["kubernetes_version"])

  # EKS Managed Node Group
  name            = coalesce(each.value.name, each.key)
  use_name_prefix = each.value.use_name_prefix

  subnet_ids = coalesce(each.value.subnet_ids, var.subnet_ids)

  min_size     = each.value.min_size
  max_size     = each.value.max_size
  desired_size = each.value.desired_size

  ami_id                         = each.value.ami_id
  ami_type                       = each.value.ami_type
  ami_release_version            = each.value.ami_release_version
  use_latest_ami_release_version = each.value.use_latest_ami_release_version

  capacity_type        = each.value.capacity_type
  disk_size            = each.value.disk_size
  force_update_version = each.value.force_update_version
  instance_types       = each.value.instance_types
  labels               = each.value.labels
  node_repair_config   = each.value.node_repair_config
  remote_access        = each.value.remote_access
  taints               = each.value.taints
  update_config        = each.value.update_config
  timeouts             = each.value.timeouts

  # User data
  cluster_endpoint           = try(time_sleep.this[0].triggers["endpoint"], "")
  cluster_auth_base64        = try(time_sleep.this[0].triggers["certificate_authority_data"], "")
  cluster_ip_family          = var.ip_family
  cluster_service_cidr       = try(time_sleep.this[0].triggers["service_cidr"], "")
  enable_bootstrap_user_data = each.value.enable_bootstrap_user_data
  pre_bootstrap_user_data    = each.value.pre_bootstrap_user_data
  post_bootstrap_user_data   = each.value.post_bootstrap_user_data
  bootstrap_extra_args       = each.value.bootstrap_extra_args
  user_data_template_path    = each.value.user_data_template_path
  cloudinit_pre_nodeadm      = each.value.cloudinit_pre_nodeadm
  cloudinit_post_nodeadm     = each.value.cloudinit_post_nodeadm

  # Launch Template
  create_launch_template                 = each.value.create_launch_template
  use_custom_launch_template             = each.value.use_custom_launch_template
  launch_template_id                     = each.value.launch_template_id
  launch_template_name                   = coalesce(each.value.launch_template_name, each.key)
  launch_template_use_name_prefix        = each.value.launch_template_use_name_prefix
  launch_template_version                = each.value.launch_template_version
  launch_template_default_version        = each.value.launch_template_default_version
  update_launch_template_default_version = each.value.update_launch_template_default_version
  launch_template_description            = coalesce(each.value.launch_template_description, "Custom launch template for ${coalesce(each.value.name, each.key)} EKS managed node group")
  launch_template_tags                   = each.value.launch_template_tags
  tag_specifications                     = each.value.tag_specifications

  ebs_optimized           = each.value.ebs_optimized
  key_name                = each.value.key_name
  disable_api_termination = each.value.disable_api_termination
  kernel_id               = each.value.kernel_id
  ram_disk_id             = each.value.ram_disk_id

  block_device_mappings              = each.value.block_device_mappings
  capacity_reservation_specification = each.value.capacity_reservation_specification
  cpu_options                        = each.value.cpu_options
  credit_specification               = each.value.credit_specification
  enclave_options                    = each.value.enclave_options
  instance_market_options            = each.value.instance_market_options
  license_specifications             = each.value.license_specifications
  metadata_options                   = each.value.metadata_options
  enable_monitoring                  = each.value.enable_monitoring
  enable_efa_support                 = each.value.enable_efa_support
  enable_efa_only                    = each.value.enable_efa_only
  efa_indices                        = each.value.efa_indices
  create_placement_group             = each.value.create_placement_group
  placement                          = each.value.placement
  network_interfaces                 = each.value.network_interfaces
  maintenance_options                = each.value.maintenance_options
  private_dns_name_options           = each.value.private_dns_name_options

  # IAM role
  create_iam_role               = each.value.create_iam_role
  iam_role_arn                  = each.value.iam_role_arn
  iam_role_name                 = each.value.iam_role_name
  iam_role_use_name_prefix      = each.value.iam_role_use_name_prefix
  iam_role_path                 = each.value.iam_role_path
  iam_role_description          = each.value.iam_role_description
  iam_role_permissions_boundary = each.value.iam_role_permissions_boundary
  iam_role_tags                 = each.value.iam_role_tags
  iam_role_attach_cni_policy    = each.value.iam_role_attach_cni_policy
  iam_role_additional_policies  = lookup(each.value, "iam_role_additional_policies", null)
  create_iam_role_policy        = each.value.create_iam_role_policy
  iam_role_policy_statements    = each.value.iam_role_policy_statements

  # Security group
  vpc_security_group_ids            = compact(concat([local.node_security_group_id], each.value.vpc_security_group_ids))
  cluster_primary_security_group_id = each.value.attach_cluster_primary_security_group ? aws_eks_cluster.this[0].vpc_config[0].cluster_security_group_id : null
  create_security_group             = each.value.create_security_group
  security_group_name               = each.value.security_group_name
  security_group_use_name_prefix    = each.value.security_group_use_name_prefix
  security_group_description        = each.value.security_group_description
  security_group_ingress_rules      = each.value.security_group_ingress_rules
  security_group_egress_rules       = each.value.security_group_egress_rules
  security_group_tags               = each.value.security_group_tags

  tags = merge(
    var.tags,
    each.value.tags,
  )
}

################################################################################
# Self Managed Node Group
################################################################################

module "self_managed_node_group" {
  source = "./modules/self-managed-node-group"

  for_each = var.create && var.self_managed_node_groups != null ? var.self_managed_node_groups : {}

  create = each.value.create

  region = var.region

  # Pass through values to reduce GET requests from data sources
  partition  = local.partition
  account_id = local.account_id

  cluster_name = time_sleep.this[0].triggers["name"]

  # Autoscaling Group
  create_autoscaling_group = each.value.create_autoscaling_group

  name            = coalesce(each.value.name, each.key)
  use_name_prefix = each.value.use_name_prefix

  availability_zones = each.value.availability_zones
  subnet_ids         = coalesce(each.value.subnet_ids, var.subnet_ids)

  min_size                = each.value.min_size
  max_size                = each.value.max_size
  desired_size            = each.value.desired_size
  desired_size_type       = each.value.desired_size_type
  capacity_rebalance      = each.value.capacity_rebalance
  default_instance_warmup = each.value.default_instance_warmup
  protect_from_scale_in   = each.value.protect_from_scale_in
  context                 = each.value.context

  create_placement_group    = each.value.create_placement_group
  placement_group           = each.value.placement_group
  health_check_type         = each.value.health_check_type
  health_check_grace_period = each.value.health_check_grace_period

  ignore_failed_scaling_activities = each.value.ignore_failed_scaling_activities

  force_delete          = each.value.force_delete
  termination_policies  = each.value.termination_policies
  suspended_processes   = each.value.suspended_processes
  max_instance_lifetime = each.value.max_instance_lifetime

  enabled_metrics     = each.value.enabled_metrics
  metrics_granularity = each.value.metrics_granularity

  initial_lifecycle_hooks     = each.value.initial_lifecycle_hooks
  instance_maintenance_policy = each.value.instance_maintenance_policy
  instance_refresh            = each.value.instance_refresh
  use_mixed_instances_policy  = each.value.use_mixed_instances_policy
  mixed_instances_policy      = each.value.mixed_instances_policy

  timeouts               = each.value.timeouts
  autoscaling_group_tags = each.value.autoscaling_group_tags

  # User data
  ami_type                   = try(each.value.ami_type, null)
  cluster_endpoint           = try(time_sleep.this[0].triggers["endpoint"], "")
  cluster_auth_base64        = try(time_sleep.this[0].triggers["certificate_authority_data"], "")
  cluster_service_cidr       = try(time_sleep.this[0].triggers["service_cidr"], "")
  additional_cluster_dns_ips = try(each.value.additional_cluster_dns_ips, null)
  cluster_ip_family          = var.ip_family
  pre_bootstrap_user_data    = try(each.value.pre_bootstrap_user_data, null)
  post_bootstrap_user_data   = try(each.value.post_bootstrap_user_data, null)
  bootstrap_extra_args       = try(each.value.bootstrap_extra_args, null)
  user_data_template_path    = try(each.value.user_data_template_path, null)
  cloudinit_pre_nodeadm      = try(each.value.cloudinit_pre_nodeadm, null)
  cloudinit_post_nodeadm     = try(each.value.cloudinit_post_nodeadm, null)

  # Launch Template
  create_launch_template                 = try(each.value.create_launch_template, null)
  launch_template_id                     = try(each.value.launch_template_id, null)
  launch_template_name                   = coalesce(each.value.launch_template_name, each.key)
  launch_template_use_name_prefix        = try(each.value.launch_template_use_name_prefix, null)
  launch_template_version                = try(each.value.launch_template_version, null)
  launch_template_default_version        = try(each.value.launch_template_default_version, null)
  update_launch_template_default_version = try(each.value.update_launch_template_default_version, null)
  launch_template_description            = coalesce(each.value.launch_template_description, "Custom launch template for ${coalesce(each.value.name, each.key)} self managed node group")
  launch_template_tags                   = try(each.value.launch_template_tags, null)
  tag_specifications                     = try(each.value.tag_specifications, null)

  ebs_optimized      = try(each.value.ebs_optimized, null)
  ami_id             = try(each.value.ami_id, null)
  kubernetes_version = try(each.value.kubernetes_version, time_sleep.this[0].triggers["kubernetes_version"])
  instance_type      = try(each.value.instance_type, null)
  key_name           = try(each.value.key_name, null)

  disable_api_termination              = try(each.value.disable_api_termination, null)
  instance_initiated_shutdown_behavior = try(each.value.instance_initiated_shutdown_behavior, null)
  kernel_id                            = try(each.value.kernel_id, null)
  ram_disk_id                          = try(each.value.ram_disk_id, null)

  block_device_mappings              = try(each.value.block_device_mappings, null)
  capacity_reservation_specification = try(each.value.capacity_reservation_specification, null)
  cpu_options                        = try(each.value.cpu_options, null)
  credit_specification               = try(each.value.credit_specification, null)
  enclave_options                    = try(each.value.enclave_options, null)
  instance_requirements              = try(each.value.instance_requirements, null)
  instance_market_options            = try(each.value.instance_market_options, null)
  license_specifications             = try(each.value.license_specifications, null)
  metadata_options                   = try(each.value.metadata_options, null)
  enable_monitoring                  = try(each.value.enable_monitoring, null)
  enable_efa_support                 = try(each.value.enable_efa_support, null)
  enable_efa_only                    = try(each.value.enable_efa_only, null)
  efa_indices                        = try(each.value.efa_indices, null)
  network_interfaces                 = try(each.value.network_interfaces, null)
  placement                          = try(each.value.placement, null)
  maintenance_options                = try(each.value.maintenance_options, null)
  private_dns_name_options           = try(each.value.private_dns_name_options, null)

  # IAM role
  create_iam_instance_profile   = try(each.value.create_iam_instance_profile, null)
  iam_instance_profile_arn      = try(each.value.iam_instance_profile_arn, null)
  iam_role_name                 = try(each.value.iam_role_name, null)
  iam_role_use_name_prefix      = try(each.value.iam_role_use_name_prefix, true)
  iam_role_path                 = try(each.value.iam_role_path, null)
  iam_role_description          = try(each.value.iam_role_description, null)
  iam_role_permissions_boundary = try(each.value.iam_role_permissions_boundary, null)
  iam_role_tags                 = try(each.value.iam_role_tags, null)
  iam_role_attach_cni_policy    = try(each.value.iam_role_attach_cni_policy, null)
  iam_role_additional_policies  = lookup(each.value, "iam_role_additional_policies", null)
  create_iam_role_policy        = try(each.value.create_iam_role_policy, null)
  iam_role_policy_statements    = try(each.value.iam_role_policy_statements, null)

  # Access entry
  create_access_entry = try(each.value.create_access_entry, null)
  iam_role_arn        = try(each.value.iam_role_arn, null)

  # Security group
  vpc_security_group_ids            = compact(concat([local.node_security_group_id], try(each.value.vpc_security_group_ids, [])))
  cluster_primary_security_group_id = try(each.value.attach_cluster_primary_security_group, false) ? aws_eks_cluster.this[0].vpc_config[0].cluster_security_group_id : null
  create_security_group             = try(each.value.create_security_group, null)
  security_group_name               = try(each.value.security_group_name, null)
  security_group_use_name_prefix    = try(each.value.security_group_use_name_prefix, null)
  security_group_description        = try(each.value.security_group_description, null)
  security_group_ingress_rules      = try(each.value.security_group_ingress_rules, null)
  security_group_egress_rules       = try(each.value.security_group_egress_rules, null)
  security_group_tags               = try(each.value.security_group_tags, null)

  tags = merge(
    var.tags,
    each.value.tags,
  )
}
