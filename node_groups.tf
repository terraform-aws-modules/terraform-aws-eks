################################################################################
# Fargate Profile
################################################################################

module "fargate_profile" {
  source = "./modules/fargate-profile"

  for_each = var.create ? var.fargate_profiles : {}

  # Fargate Profile
  cluster_name         = aws_eks_cluster.this[0].name
  fargate_profile_name = try(each.value.fargate_profile_name, each.key)
  subnet_ids           = try(each.value.subnet_ids, var.fargate_profile_defaults.subnet_ids, var.subnet_ids)
  selectors            = try(each.value.selectors, var.fargate_profile_defaults.selectors, [])
  timeouts             = try(each.value.timeouts, var.fargate_profile_defaults.timeouts, {})

  # IAM role
  create_iam_role               = try(each.value.create_iam_role, var.fargate_profile_defaults.create_iam_role, true)
  iam_role_arn                  = try(each.value.iam_role_arn, var.fargate_profile_defaults.iam_role_arn, null)
  iam_role_name                 = try(each.value.iam_role_name, var.fargate_profile_defaults.iam_role_name, null)
  iam_role_use_name_prefix      = try(each.value.iam_role_use_name_prefix, var.fargate_profile_defaults.iam_role_use_name_prefix, true)
  iam_role_path                 = try(each.value.iam_role_path, var.fargate_profile_defaults.iam_role_path, null)
  iam_role_permissions_boundary = try(each.value.iam_role_permissions_boundary, var.fargate_profile_defaults.iam_role_permissions_boundary, null)
  iam_role_tags                 = try(each.value.iam_role_tags, var.fargate_profile_defaults.iam_role_tags, {})
  iam_role_additional_policies  = try(each.value.iam_role_additional_policies, var.fargate_profile_defaults.iam_role_additional_policies, [])

  tags = merge(var.tags, try(each.value.tags, var.fargate_profile_defaults.tags, {}))
}

################################################################################
# EKS Managed Node Group
################################################################################

module "eks_managed_node_group" {
  source = "./modules/eks-managed-node-group"

  for_each = var.create ? var.eks_managed_node_groups : {}

  cluster_name              = aws_eks_cluster.this[0].name
  cluster_version           = try(each.value.cluster_version, var.eks_managed_node_group_defaults.cluster_version, var.cluster_version)
  cluster_security_group_id = local.cluster_security_group_id

  # EKS Managed Node Group
  name            = try(each.value.name, each.key)
  use_name_prefix = try(each.value.use_name_prefix, var.eks_managed_node_group_defaults.use_name_prefix, false)

  subnet_ids = try(each.value.subnet_ids, var.eks_managed_node_group_defaults.subnet_ids, var.subnet_ids)

  min_size     = try(each.value.min_size, var.eks_managed_node_group_defaults.min_size, 1)
  max_size     = try(each.value.max_size, var.eks_managed_node_group_defaults.max_size, 3)
  desired_size = try(each.value.desired_size, var.eks_managed_node_group_defaults.desired_size, 1)

  ami_id              = try(each.value.ami_id, var.eks_managed_node_group_defaults.ami_id, null)
  ami_type            = try(each.value.ami_type, var.eks_managed_node_group_defaults.ami_type, null)
  ami_release_version = try(each.value.ami_release_version, var.eks_managed_node_group_defaults.ami_release_version, null)

  capacity_type        = try(each.value.capacity_type, var.eks_managed_node_group_defaults.capacity_type, null)
  disk_size            = try(each.value.disk_size, var.eks_managed_node_group_defaults.disk_size, null)
  force_update_version = try(each.value.force_update_version, var.eks_managed_node_group_defaults.force_update_version, null)
  instance_types       = try(each.value.instance_types, var.eks_managed_node_group_defaults.instance_types, null)
  labels               = try(each.value.labels, var.eks_managed_node_group_defaults.labels, null)

  remote_access = try(each.value.remote_access, var.eks_managed_node_group_defaults.remote_access, {})
  taints        = try(each.value.taints, var.eks_managed_node_group_defaults.taints, {})
  update_config = try(each.value.update_config, var.eks_managed_node_group_defaults.update_config, {})
  timeouts      = try(each.value.timeouts, var.eks_managed_node_group_defaults.timeouts, {})

  # User data
  custom_user_data            = try(each.value.custom_user_data, var.eks_managed_node_group_defaults.custom_user_data, null)
  custom_ami_is_eks_optimized = try(each.value.custom_ami_is_eks_optimized, var.eks_managed_node_group_defaults.custom_ami_is_eks_optimized, true)
  cluster_endpoint            = try(aws_eks_cluster.this[0].endpoint, var.eks_managed_node_group_defaults.cluster_endpoint, null)
  cluster_auth_base64         = try(aws_eks_cluster.this[0].certificate_authority[0].data, var.eks_managed_node_group_defaults.cluster_auth_base64, null)
  cluster_dns_ip              = try(aws_eks_cluster.this[0].kubernetes_network_config[0].service_ipv4_cidr, var.eks_managed_node_group_defaults.cluster_dns_ip, "")
  pre_bootstrap_user_data     = try(each.value.pre_bootstrap_user_data, var.eks_managed_node_group_defaults.pre_bootstrap_user_data, "")
  post_bootstrap_user_data    = try(each.value.post_bootstrap_user_data, var.eks_managed_node_group_defaults.post_bootstrap_user_data, "")
  bootstrap_extra_args        = try(each.value.bootstrap_extra_args, var.eks_managed_node_group_defaults.bootstrap_extra_args, "")

  # Launch Template
  create_launch_template          = try(each.value.create_launch_template, var.eks_managed_node_group_defaults.create_launch_template, false)
  launch_template_name            = try(each.value.launch_template_name, var.eks_managed_node_group_defaults.launch_template_name, null)
  launch_template_use_name_prefix = try(each.value.launch_template_use_name_prefix, var.eks_managed_node_group_defaults.launch_template_use_name_prefix, true)
  launch_template_version         = try(each.value.launch_template_version, var.eks_managed_node_group_defaults.launch_template_version, null)
  description                     = try(each.value.description, var.eks_managed_node_group_defaults.description, null)

  ebs_optimized                        = try(each.value.ebs_optimized, var.eks_managed_node_group_defaults.ebs_optimized, null)
  key_name                             = try(each.value.key_name, var.eks_managed_node_group_defaults.key_name, null)
  vpc_security_group_ids               = try(each.value.vpc_security_group_ids, var.eks_managed_node_group_defaults.vpc_security_group_ids, [])
  default_version                      = try(each.value.default_version, var.eks_managed_node_group_defaults.default_version, null)
  update_default_version               = try(each.value.update_default_version, var.eks_managed_node_group_defaults.update_default_version, null)
  disable_api_termination              = try(each.value.disable_api_termination, var.eks_managed_node_group_defaults.disable_api_termination, null)
  instance_initiated_shutdown_behavior = try(each.value.instance_initiated_shutdown_behavior, var.eks_managed_node_group_defaults.instance_initiated_shutdown_behavior, null)
  kernel_id                            = try(each.value.kernel_id, var.eks_managed_node_group_defaults.kernel_id, null)
  ram_disk_id                          = try(each.value.ram_disk_id, var.eks_managed_node_group_defaults.ram_disk_id, null)

  block_device_mappings              = try(each.value.block_device_mappings, var.eks_managed_node_group_defaults.block_device_mappings, [])
  capacity_reservation_specification = try(each.value.capacity_reservation_specification, var.eks_managed_node_group_defaults.capacity_reservation_specification, null)
  cpu_options                        = try(each.value.cpu_options, var.eks_managed_node_group_defaults.cpu_options, null)
  credit_specification               = try(each.value.credit_specification, var.eks_managed_node_group_defaults.credit_specification, null)
  elastic_gpu_specifications         = try(each.value.elastic_gpu_specifications, var.eks_managed_node_group_defaults.elastic_gpu_specifications, null)
  elastic_inference_accelerator      = try(each.value.elastic_inference_accelerator, var.eks_managed_node_group_defaults.elastic_inference_accelerator, null)
  enclave_options                    = try(each.value.enclave_options, var.eks_managed_node_group_defaults.enclave_options, null)
  hibernation_options                = try(each.value.hibernation_options, var.eks_managed_node_group_defaults.hibernation_options, null)
  instance_market_options            = try(each.value.instance_market_options, var.eks_managed_node_group_defaults.instance_market_options, null)
  license_specifications             = try(each.value.license_specifications, var.eks_managed_node_group_defaults.license_specifications, null)
  metadata_options                   = try(each.value.metadata_options, var.eks_managed_node_group_defaults.metadata_options, null)
  enable_monitoring                  = try(each.value.enable_monitoring, var.eks_managed_node_group_defaults.enable_monitoring, null)
  network_interfaces                 = try(each.value.network_interfaces, var.eks_managed_node_group_defaults.network_interfaces, [])
  placement                          = try(each.value.placement, var.eks_managed_node_group_defaults.placement, null)

  # IAM role
  create_iam_role               = try(each.value.create_iam_role, var.eks_managed_node_group_defaults.create_iam_role, true)
  iam_role_arn                  = try(each.value.iam_role_arn, var.eks_managed_node_group_defaults.iam_role_arn, null)
  iam_role_name                 = try(each.value.iam_role_name, var.eks_managed_node_group_defaults.iam_role_name, null)
  iam_role_use_name_prefix      = try(each.value.iam_role_use_name_prefix, var.eks_managed_node_group_defaults.iam_role_use_name_prefix, true)
  iam_role_path                 = try(each.value.iam_role_path, var.eks_managed_node_group_defaults.iam_role_path, null)
  iam_role_permissions_boundary = try(each.value.iam_role_permissions_boundary, var.eks_managed_node_group_defaults.iam_role_permissions_boundary, null)
  iam_role_tags                 = try(each.value.iam_role_tags, var.eks_managed_node_group_defaults.iam_role_tags, {})
  iam_role_additional_policies  = try(each.value.iam_role_additional_policies, var.eks_managed_node_group_defaults.iam_role_additional_policies, [])

  # Security group
  create_security_group             = try(each.value.create_security_group, var.eks_managed_node_group_defaults.create_security_group, true)
  security_group_name               = try(each.value.security_group_name, var.eks_managed_node_group_defaults.security_group_name, null)
  security_group_use_name_prefix    = try(each.value.security_group_use_name_prefix, var.eks_managed_node_group_defaults.security_group_use_name_prefix, true)
  security_group_description        = try(each.value.security_group_description, var.eks_managed_node_group_defaults.security_group_description, "EKS managed node group security group")
  vpc_id                            = try(each.value.vpc_id, var.eks_managed_node_group_defaults.vpc_id, var.vpc_id)
  security_group_egress_cidr_blocks = try(each.value.security_group_egress_cidr_blocks, var.eks_managed_node_group_defaults.security_group_egress_cidr_blocks, ["0.0.0.0/0"])
  security_group_tags               = try(each.value.security_group_tags, var.eks_managed_node_group_defaults.security_group_tags, {})

  tags = merge(var.tags, try(each.value.tags, var.eks_managed_node_group_defaults.tags, {}))
}

################################################################################
# Self Managed Node Group
################################################################################

module "self_managed_node_group" {
  source = "./modules/self-managed-node-group"

  for_each = var.create ? var.self_managed_node_groups : {}

  cluster_name = aws_eks_cluster.this[0].name

  # Autoscaling Group
  name            = try(each.value.name, each.key)
  use_name_prefix = try(each.value.use_name_prefix, var.self_managed_node_group_defaults.use_name_prefix, false)

  launch_template_name    = try(each.value.launch_template_name, each.key)
  launch_template_version = try(each.value.launch_template_version, var.self_managed_node_group_defaults.launch_template_version, null)
  availability_zones      = try(each.value.availability_zones, var.self_managed_node_group_defaults.availability_zones, null)
  subnet_ids              = try(each.value.subnet_ids, var.self_managed_node_group_defaults.subnet_ids, var.subnet_ids)

  min_size                  = try(each.value.min_size, var.self_managed_node_group_defaults.min_size, 1)
  max_size                  = try(each.value.max_size, var.self_managed_node_group_defaults.max_size, 3)
  desired_size              = try(each.value.desired_size, var.self_managed_node_group_defaults.desired_size, 1)
  capacity_rebalance        = try(each.value.capacity_rebalance, var.self_managed_node_group_defaults.capacity_rebalance, null)
  min_elb_capacity          = try(each.value.min_elb_capacity, var.self_managed_node_group_defaults.min_elb_capacity, null)
  wait_for_elb_capacity     = try(each.value.wait_for_elb_capacity, var.self_managed_node_group_defaults.wait_for_elb_capacity, null)
  wait_for_capacity_timeout = try(each.value.wait_for_capacity_timeout, var.self_managed_node_group_defaults.wait_for_capacity_timeout, null)
  default_cooldown          = try(each.value.default_cooldown, var.self_managed_node_group_defaults.default_cooldown, null)
  protect_from_scale_in     = try(each.value.protect_from_scale_in, var.self_managed_node_group_defaults.protect_from_scale_in, null)

  target_group_arns         = try(each.value.target_group_arns, var.self_managed_node_group_defaults.target_group_arns, null)
  placement_group           = try(each.value.placement_group, var.self_managed_node_group_defaults.placement_group, null)
  health_check_type         = try(each.value.health_check_type, var.self_managed_node_group_defaults.health_check_type, null)
  health_check_grace_period = try(each.value.health_check_grace_period, var.self_managed_node_group_defaults.health_check_grace_period, null)

  force_delete          = try(each.value.force_delete, var.self_managed_node_group_defaults.force_delete, null)
  termination_policies  = try(each.value.termination_policies, var.self_managed_node_group_defaults.termination_policies, null)
  suspended_processes   = try(each.value.suspended_processes, var.self_managed_node_group_defaults.suspended_processes, null)
  max_instance_lifetime = try(each.value.max_instance_lifetime, var.self_managed_node_group_defaults.max_instance_lifetime, null)

  enabled_metrics         = try(each.value.enabled_metrics, var.self_managed_node_group_defaults.enabled_metrics, null)
  metrics_granularity     = try(each.value.metrics_granularity, var.self_managed_node_group_defaults.metrics_granularity, null)
  service_linked_role_arn = try(each.value.service_linked_role_arn, var.self_managed_node_group_defaults.service_linked_role_arn, null)

  initial_lifecycle_hooks    = try(each.value.initial_lifecycle_hooks, var.self_managed_node_group_defaults.initial_lifecycle_hooks, [])
  instance_refresh           = try(each.value.instance_refresh, var.self_managed_node_group_defaults.instance_refresh, null)
  use_mixed_instances_policy = try(each.value.use_mixed_instances_policy, var.self_managed_node_group_defaults.use_mixed_instances_policy, false)
  warm_pool                  = try(each.value.warm_pool, var.self_managed_node_group_defaults.warm_pool, null)

  create_schedule = try(each.value.create_schedule, var.self_managed_node_group_defaults.create_schedule, false)
  schedules       = try(each.value.schedules, var.self_managed_node_group_defaults.schedules, null)

  delete_timeout = try(each.value.delete_timeout, var.self_managed_node_group_defaults.delete_timeout, null)

  # Launch Template
  create_launch_template = try(each.value.create_launch_template, var.self_managed_node_group_defaults.create_launch_template, true)
  description            = try(each.value.description, var.self_managed_node_group_defaults.description, null)

  ebs_optimized   = try(each.value.ebs_optimized, var.self_managed_node_group_defaults.ebs_optimized, null)
  image_id        = try(each.value.image_id, var.self_managed_node_group_defaults.image_id, null)
  cluster_version = try(each.value.cluster_version, var.self_managed_node_group_defaults.cluster_version, var.cluster_version)
  instance_type   = try(each.value.instance_type, var.self_managed_node_group_defaults.instance_type, "m6i.large")
  key_name        = try(each.value.key_name, var.self_managed_node_group_defaults.key_name, null)
  user_data       = try(each.value.user_data, var.self_managed_node_group_defaults.user_data, null)

  vpc_security_group_ids               = try(each.value.vpc_security_group_ids, var.self_managed_node_group_defaults.vpc_security_group_ids, [])
  cluster_security_group_id            = local.cluster_security_group_id
  default_version                      = try(each.value.default_version, var.self_managed_node_group_defaults.default_version, null)
  update_default_version               = try(each.value.update_default_version, var.self_managed_node_group_defaults.update_default_version, null)
  disable_api_termination              = try(each.value.disable_api_termination, var.self_managed_node_group_defaults.disable_api_termination, null)
  instance_initiated_shutdown_behavior = try(each.value.instance_initiated_shutdown_behavior, var.self_managed_node_group_defaults.instance_initiated_shutdown_behavior, null)
  kernel_id                            = try(each.value.kernel_id, var.self_managed_node_group_defaults.kernel_id, null)
  ram_disk_id                          = try(each.value.ram_disk_id, var.self_managed_node_group_defaults.ram_disk_id, null)

  block_device_mappings              = try(each.value.block_device_mappings, var.self_managed_node_group_defaults.block_device_mappings, [])
  capacity_reservation_specification = try(each.value.capacity_reservation_specification, var.self_managed_node_group_defaults.capacity_reservation_specification, null)
  cpu_options                        = try(each.value.cpu_options, var.self_managed_node_group_defaults.cpu_options, null)
  credit_specification               = try(each.value.credit_specification, var.self_managed_node_group_defaults.credit_specification, null)
  elastic_gpu_specifications         = try(each.value.elastic_gpu_specifications, var.self_managed_node_group_defaults.elastic_gpu_specifications, null)
  elastic_inference_accelerator      = try(each.value.elastic_inference_accelerator, var.self_managed_node_group_defaults.elastic_inference_accelerator, null)
  enclave_options                    = try(each.value.enclave_options, var.self_managed_node_group_defaults.enclave_options, null)
  hibernation_options                = try(each.value.hibernation_options, var.self_managed_node_group_defaults.hibernation_options, null)
  instance_market_options            = try(each.value.instance_market_options, var.self_managed_node_group_defaults.instance_market_options, null)
  license_specifications             = try(each.value.license_specifications, var.self_managed_node_group_defaults.license_specifications, null)
  metadata_options                   = try(each.value.metadata_options, var.self_managed_node_group_defaults.metadata_options, null)
  enable_monitoring                  = try(each.value.enable_monitoring, var.self_managed_node_group_defaults.enable_monitoring, null)
  network_interfaces                 = try(each.value.network_interfaces, var.self_managed_node_group_defaults.network_interfaces, [])
  placement                          = try(each.value.placement, var.self_managed_node_group_defaults.placement, null)

  # IAM role
  create_iam_instance_profile   = try(each.value.create_iam_instance_profile, var.self_managed_node_group_defaults.create_iam_instance_profile, true)
  iam_instance_profile_arn      = try(each.value.iam_instance_profile_arn, var.self_managed_node_group_defaults.iam_instance_profile_arn, null)
  iam_role_name                 = try(each.value.iam_role_name, var.self_managed_node_group_defaults.iam_role_name, null)
  iam_role_use_name_prefix      = try(each.value.iam_role_use_name_prefix, var.self_managed_node_group_defaults.iam_role_use_name_prefix, true)
  iam_role_path                 = try(each.value.iam_role_path, var.self_managed_node_group_defaults.iam_role_path, null)
  iam_role_permissions_boundary = try(each.value.iam_role_permissions_boundary, var.self_managed_node_group_defaults.iam_role_permissions_boundary, null)
  iam_role_tags                 = try(each.value.iam_role_tags, var.self_managed_node_group_defaults.iam_role_tags, {})
  iam_role_attach_cni_policy    = try(each.value.iam_role_attach_cni_policy, var.self_managed_node_group_defaults.iam_role_attach_cni_policy, true)
  iam_role_additional_policies  = try(each.value.iam_role_additional_policies, var.self_managed_node_group_defaults.iam_role_additional_policies, [])

  # Security group
  create_security_group             = try(each.value.create_security_group, var.eks_managed_node_group_defaults.create_security_group, true)
  security_group_name               = try(each.value.security_group_name, var.eks_managed_node_group_defaults.security_group_name, null)
  security_group_use_name_prefix    = try(each.value.security_group_use_name_prefix, var.eks_managed_node_group_defaults.security_group_use_name_prefix, true)
  security_group_description        = try(each.value.security_group_description, var.eks_managed_node_group_defaults.security_group_description, "Self managed node group security group")
  vpc_id                            = try(each.value.vpc_id, var.eks_managed_node_group_defaults.vpc_id, var.vpc_id)
  security_group_egress_cidr_blocks = try(each.value.security_group_egress_cidr_blocks, var.eks_managed_node_group_defaults.security_group_egress_cidr_blocks, ["0.0.0.0/0"])
  security_group_tags               = try(each.value.security_group_tags, var.eks_managed_node_group_defaults.security_group_tags, {})

  tags           = merge(var.tags, try(each.value.tags, var.self_managed_node_group_defaults.tags, {}))
  propagate_tags = try(each.value.propagate_tags, var.self_managed_node_group_defaults.propagate_tags, [])
}

# ################################################################################
# # Security Group
# ################################################################################

# resource "aws_security_group_rule" "cluster_primary_ingress_worker" {
#   count = local.create_worker_sg && var.worker_create_cluster_primary_security_group_rules ? 1 : 0

#   description              = "Allow pods running on worker to send communication to cluster primary security group (e.g. Fargate pods)."
#   protocol                 = "all"
#   security_group_id        = aws_eks_cluster.this[0].vpc_config[0].cluster_security_group_id
#   source_security_group_id = local.worker_security_group_id
#   from_port                = 0
#   to_port                  = 65535
#   type                     = "ingress"
# }
