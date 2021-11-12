################################################################################
# Fargate
################################################################################

module "fargate_profile" {
  source = "./modules/fargate-profile"

  for_each = var.create ? var.fargate_profiles : {}

  # Fargate Profile
  cluster_name         = aws_eks_cluster.this[0].name
  fargate_profile_name = try(each.value.fargate_profile_name, each.key, true)
  subnet_ids           = try(each.value.subnet_ids, var.subnet_ids)
  selectors            = try(each.value.selectors, {})
  timeouts             = try(each.value.timeouts, {})

  # IAM role
  create_iam_role               = try(each.value.create_iam_role, true)
  iam_role_arn                  = try(each.value.iam_role_arn, null)
  iam_role_name                 = try(each.value.iam_role_name, null)
  iam_role_use_name_prefix      = try(each.value.iam_role_use_name_prefix, true)
  iam_role_path                 = try(each.value.iam_role_path, null)
  iam_role_permissions_boundary = try(each.value.iam_role_permissions_boundary, null)
  iam_role_tags                 = try(each.value.iam_role_tags, {})
  iam_role_additional_policies  = try(each.value.iam_role_additional_policies, [])

  tags = merge(var.tags, try(each.value.tags, {}))
}

################################################################################
# EKS Managed Node Group
################################################################################

module "eks_managed_node_group" {
  source = "./modules/eks-managed-node-group"

  for_each = var.create ? var.eks_managed_node_groups : {}

  cluster_name = aws_eks_cluster.this[0].name

  # EKS Managed Node Group
  name            = try(each.value.name, each.key)
  use_name_prefix = try(each.value.use_name_prefix, false)

  subnet_ids = try(each.value.subnet_ids, var.subnet_ids)

  min_size     = try(each.value.min_size, 1)
  max_size     = try(each.value.max_size, 3)
  desired_size = try(each.value.desired_size, 1)

  ami_id              = try(each.value.ami_id, null)
  ami_type            = try(each.value.ami_type, null)
  ami_release_version = try(each.value.ami_release_version, null)

  capacity_type        = try(each.value.capacity_type, null)
  disk_size            = try(each.value.disk_size, null)
  force_update_version = try(each.value.force_update_version, null)
  instance_types       = try(each.value.instance_types, null)
  labels               = try(each.value.labels, null)
  cluster_version      = try(each.value.cluster_version, var.cluster_version)

  remote_access = try(each.value.remote_access, {})
  taints        = try(each.value.taints, {})
  update_config = try(each.value.update_config, {})
  timeouts      = try(each.value.timeouts, {})

  # User data
  custom_user_data            = try(each.value.custom_user_data, null)
  custom_ami_is_eks_optimized = try(each.value.custom_ami_is_eks_optimized, true)
  cluster_endpoint            = try(aws_eks_cluster.this[0].endpoint, null)
  cluster_auth_base64         = try(aws_eks_cluster.this[0].certificate_authority[0].data, null)
  cluster_dns_ip              = try(aws_eks_cluster.this[0].kubernetes_network_config[0].service_ipv4_cidr, "")
  pre_bootstrap_user_data     = try(each.value.pre_bootstrap_user_data, "")
  post_bootstrap_user_data    = try(each.value.post_bootstrap_user_data, "")
  bootstrap_extra_args        = try(each.value.bootstrap_extra_args, "")
  kubelet_extra_args          = try(each.value.kubelet_extra_args, "")
  node_labels                 = try(each.value.node_labels, {})

  # Launch Template
  create_launch_template          = try(each.value.create_launch_template, false)
  launch_template_name            = try(each.value.launch_template_name, null)
  launch_template_use_name_prefix = try(each.value.launch_template_use_name_prefix, true)
  launch_template_version         = try(each.value.launch_template_version, null)
  description                     = try(each.value.description, null)

  ebs_optimized = try(each.value.ebs_optimized, null)
  key_name      = try(each.value.key_name, null)

  vpc_security_group_ids = try(each.value.vpc_security_group_ids, [])

  default_version                      = try(each.value.default_version, null)
  update_default_version               = try(each.value.update_default_version, null)
  disable_api_termination              = try(each.value.disable_api_termination, null)
  instance_initiated_shutdown_behavior = try(each.value.instance_initiated_shutdown_behavior, null)
  kernel_id                            = try(each.value.kernel_id, null)
  ram_disk_id                          = try(each.value.ram_disk_id, null)

  block_device_mappings              = try(each.value.block_device_mappings, [])
  capacity_reservation_specification = try(each.value.capacity_reservation_specification, null)
  cpu_options                        = try(each.value.cpu_options, null)
  credit_specification               = try(each.value.credit_specification, null)
  elastic_gpu_specifications         = try(each.value.elastic_gpu_specifications, null)
  elastic_inference_accelerator      = try(each.value.elastic_inference_accelerator, null)
  enclave_options                    = try(each.value.enclave_options, null)
  hibernation_options                = try(each.value.hibernation_options, null)
  instance_market_options            = try(each.value.instance_market_options, null)
  license_specifications             = try(each.value.license_specifications, null)
  metadata_options                   = try(each.value.metadata_options, null)
  enable_monitoring                  = try(each.value.enable_monitoring, null)
  network_interfaces                 = try(each.value.network_interfaces, [])
  placement                          = try(each.value.placement, null)

  # IAM role
  create_iam_role               = try(each.value.create_iam_role, true)
  iam_role_arn                  = try(each.value.iam_role_arn, null)
  iam_role_name                 = try(each.value.iam_role_name, null)
  iam_role_use_name_prefix      = try(each.value.iam_role_use_name_prefix, true)
  iam_role_path                 = try(each.value.iam_role_path, null)
  iam_role_permissions_boundary = try(each.value.iam_role_permissions_boundary, null)
  iam_role_tags                 = try(each.value.iam_role_tags, {})
  iam_role_additional_policies  = try(each.value.iam_role_additional_policies, [])

  tags = merge(var.tags, try(each.value.tags, {}))
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
  use_name_prefix = try(each.value.use_name_prefix, false)

  launch_template_name    = try(each.value.launch_template_name, each.key)
  launch_template_version = try(each.value.launch_template_version, null)
  availability_zones      = try(each.value.availability_zones, null)
  subnet_ids              = try(each.value.subnet_ids, var.subnet_ids)

  min_size                  = try(each.value.min_size, 0)
  max_size                  = try(each.value.max_size, 0)
  desired_capacity          = try(each.value.desired_size, 0) # to be consisted with EKS MNG
  capacity_rebalance        = try(each.value.capacity_rebalance, null)
  min_elb_capacity          = try(each.value.min_elb_capacity, null)
  wait_for_elb_capacity     = try(each.value.wait_for_elb_capacity, null)
  wait_for_capacity_timeout = try(each.value.wait_for_capacity_timeout, null)
  default_cooldown          = try(each.value.default_cooldown, null)
  protect_from_scale_in     = try(each.value.protect_from_scale_in, null)

  target_group_arns         = try(each.value.target_group_arns, null)
  placement_group           = try(each.value.placement_group, null)
  health_check_type         = try(each.value.health_check_type, null)
  health_check_grace_period = try(each.value.health_check_grace_period, null)

  force_delete          = try(each.value.force_delete, null)
  termination_policies  = try(each.value.termination_policies, null)
  suspended_processes   = try(each.value.suspended_processes, null)
  max_instance_lifetime = try(each.value.max_instance_lifetime, null)

  enabled_metrics         = try(each.value.enabled_metrics, null)
  metrics_granularity     = try(each.value.metrics_granularity, null)
  service_linked_role_arn = try(each.value.service_linked_role_arn, null)

  initial_lifecycle_hooks    = try(each.value.initial_lifecycle_hooks, [])
  instance_refresh           = try(each.value.instance_refresh, null)
  use_mixed_instances_policy = try(each.value.use_mixed_instances_policy, false)
  warm_pool                  = try(each.value.warm_pool, null)

  create_schedule = try(each.value.create_schedule, false)
  schedules       = try(each.value.schedules, null)

  delete_timeout = try(each.value.delete_timeout, null)

  # Launch Template
  create_launch_template = try(each.value.create_launch_template, true)
  description            = try(each.value.description, null)

  ebs_optimized   = try(each.value.ebs_optimized, null)
  image_id        = try(each.value.image_id, null)
  cluster_version = try(each.value.cluster_version, var.cluster_version)
  instance_type   = try(each.value.instance_type, "m6i.large")
  key_name        = try(each.value.key_name, null)
  user_data       = try(each.value.user_data, null)

  vpc_security_group_ids = try(each.value.vpc_security_group_ids, [])

  default_version                      = try(each.value.default_version, null)
  update_default_version               = try(each.value.update_default_version, null)
  disable_api_termination              = try(each.value.disable_api_termination, null)
  instance_initiated_shutdown_behavior = try(each.value.instance_initiated_shutdown_behavior, null)
  kernel_id                            = try(each.value.kernel_id, null)
  ram_disk_id                          = try(each.value.ram_disk_id, null)

  block_device_mappings              = try(each.value.block_device_mappings, [])
  capacity_reservation_specification = try(each.value.capacity_reservation_specification, null)
  cpu_options                        = try(each.value.cpu_options, null)
  credit_specification               = try(each.value.credit_specification, null)
  elastic_gpu_specifications         = try(each.value.elastic_gpu_specifications, null)
  elastic_inference_accelerator      = try(each.value.elastic_inference_accelerator, null)
  enclave_options                    = try(each.value.enclave_options, null)
  hibernation_options                = try(each.value.hibernation_options, null)
  instance_market_options            = try(each.value.instance_market_options, null)
  license_specifications             = try(each.value.license_specifications, null)
  metadata_options                   = try(each.value.metadata_options, null)
  enable_monitoring                  = try(each.value.enable_monitoring, null)
  network_interfaces                 = try(each.value.network_interfaces, [])
  placement                          = try(each.value.placement, null)
  tag_specifications                 = try(each.value.tag_specifications, [])

  # IAM role
  create_iam_instance_profile   = try(each.value.create_iam_instance_profile, true)
  iam_instance_profile_arn      = try(each.value.iam_instance_profile_arn, null)
  iam_role_name                 = try(each.value.iam_role_name, null)
  iam_role_use_name_prefix      = try(each.value.iam_role_use_name_prefix, true)
  iam_role_path                 = try(each.value.iam_role_path, null)
  iam_role_permissions_boundary = try(each.value.iam_role_permissions_boundary, null)
  iam_role_tags                 = try(each.value.iam_role_tags, {})
  iam_role_attach_cni_policy    = try(each.value.iam_role_attach_cni_policy, true)
  iam_role_additional_policies  = try(each.value.iam_role_additional_policies, [])

  tags           = merge(var.tags, try(each.value.tags, {}))
  propagate_tags = try(each.value.propagate_tags, [])
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
