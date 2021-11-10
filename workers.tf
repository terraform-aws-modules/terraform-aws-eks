################################################################################
# Fargate
################################################################################

module "fargate" {
  source = "./modules/fargate"

  create                            = var.create_fargate
  create_fargate_pod_execution_role = var.create_fargate_pod_execution_role
  fargate_pod_execution_role_arn    = var.fargate_pod_execution_role_arn

  cluster_name = aws_eks_cluster.this[0].name
  subnet_ids   = coalescelist(var.fargate_subnet_ids, var.subnet_ids, [""])

  iam_path             = var.fargate_iam_role_path
  permissions_boundary = var.fargate_iam_role_permissions_boundary

  fargate_profiles = var.fargate_profiles

  tags = merge(var.tags, var.fargate_tags)
}

################################################################################
# EKS Managed Node Group
################################################################################

# module "eks_managed_node_groups" {
#   source = "./modules/eks-managed-node-group"

#   create_eks = var.create_eks

#   cluster_name        = local.cluster_name
#   cluster_endpoint    = local.cluster_endpoint
#   cluster_auth_base64 = local.cluster_auth_base64

#   default_iam_role_arn                 = coalescelist(aws_iam_role.workers[*].arn, [""])[0]
#   ebs_optimized_not_supported          = local.ebs_optimized_not_supported
#   workers_group_defaults               = local.workers_group_defaults
#   worker_security_group_id             = local.worker_security_group_id
#   worker_additional_security_group_ids = var.worker_additional_security_group_ids

#   node_groups_defaults = var.node_groups_defaults
#   node_groups          = var.node_groups

#   tags = var.tags

#   depends_on = [
#     aws_eks_cluster.this,
#   ]
# }

################################################################################
# Self Managed Node Group
################################################################################

module "self_managed_node_group" {
  source = "./modules/self-managed-node-group"

  for_each = var.create ? var.self_managed_node_groups : {}

  cluster_name = var.cluster_name

  # Autoscaling Group
  name            = try(each.value.name, var.cluster_name)
  use_name_prefix = try(each.value.use_name_prefix, false)

  launch_template_name    = try(each.value.launch_template_name, var.cluster_name)
  launch_template_version = try(each.value.launch_template_version, null)
  availability_zones      = try(each.value.availability_zones, null)
  subnet_ids              = try(each.value.subnet_ids, var.subnet_ids)

  min_size                  = try(each.value.min_size, 0)
  max_size                  = try(each.value.max_size, 0)
  desired_capacity          = try(each.value.desired_capacity, 0)
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

  ebs_optimized = try(each.value.ebs_optimized, null)
  image_id      = try(each.value.image_id, data.aws_ami.eks_worker[0].image_id)
  instance_type = try(each.value.instance_type, "m6i.large")
  key_name      = try(each.value.key_name, null)
  user_data     = try(each.value.user_data, null)

  vpc_security_group_ids = try(each.value.vpc_security_group_ids, null)

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
  iam_instance_profile_name          = try(each.value.iam_instance_profile_name, null)
  iam_instance_profile_arn           = try(each.value.iam_instance_profile_arn, null)
  instance_market_options            = try(each.value.instance_market_options, null)
  license_specifications             = try(each.value.license_specifications, null)
  metadata_options                   = try(each.value.metadata_options, null)
  enable_monitoring                  = try(each.value.enable_monitoring, null)
  network_interfaces                 = try(each.value.network_interfaces, [])
  placement                          = try(each.value.placement, null)
  tag_specifications                 = try(each.value.tag_specifications, [])

  tags           = try(each.value.tags, {})
  propagate_tags = try(each.value.propagate_tags, [])
}

################################################################################
# IAM Role & Instance Profile
################################################################################

locals {
  worker_iam_role_name = coalesce(var.worker_iam_role_name, "${var.cluster_name}-worker")
}

resource "aws_iam_role" "worker" {
  count = var.create && var.create_worker_iam_role ? 1 : 0

  name        = var.worker_iam_role_use_name_prefix ? null : local.worker_iam_role_name
  name_prefix = var.worker_iam_role_use_name_prefix ? try("${local.worker_iam_role_name}-", local.worker_iam_role_name) : null
  path        = var.worker_iam_role_path

  assume_role_policy   = data.aws_iam_policy_document.worker_assume_role_policy[0].json
  permissions_boundary = var.worker_iam_role_permissions_boundary
  managed_policy_arns = compact(distinct(concat([
    "${local.policy_arn_prefix}/AmazonEKSWorkerNodePolicy",
    "${local.policy_arn_prefix}/AmazonEC2ContainerRegistryReadOnly",
    var.attach_worker_cni_policy ? "${local.policy_arn_prefix}/AmazonEKS_CNI_Policy" : "",
  ], var.worker_additional_policies)))
  force_detach_policies = true

  tags = merge(var.tags, var.worker_iam_role_tags)
}

data "aws_iam_policy_document" "worker_assume_role_policy" {
  count = var.create && var.create_worker_iam_role ? 1 : 0

  statement {
    sid     = "EKSWorkerAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.${data.aws_partition.current.dns_suffix}"]
    }
  }
}

resource "aws_iam_instance_profile" "worker" {
  count = var.create && var.create_worker_iam_role ? 1 : 0

  name        = var.worker_iam_role_use_name_prefix ? null : local.worker_iam_role_name
  name_prefix = var.worker_iam_role_use_name_prefix ? try("${local.worker_iam_role_name}-", local.worker_iam_role_name) : null
  path        = var.worker_iam_role_path
  role        = aws_iam_role.worker[0].id

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, var.worker_iam_role_tags)
}

################################################################################
# Security Group
################################################################################

locals {
  worker_sg_name   = coalesce(var.worker_security_group_name, "${var.cluster_name}-worker")
  create_worker_sg = var.create && var.create_worker_security_group
}

resource "aws_security_group" "worker" {
  count = local.create_worker_sg ? 1 : 0

  name        = var.worker_security_group_use_name_prefix ? null : local.worker_sg_name
  name_prefix = var.worker_security_group_use_name_prefix ? try("${local.worker_sg_name}-", local.worker_sg_name) : null
  description = "EKS worker security group"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      "Name"                                      = local.worker_sg_name
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    },
    var.worker_security_group_tags
  )
}

resource "aws_security_group_rule" "worker_egress_internet" {
  count = local.create_worker_sg ? 1 : 0

  description       = "Allow nodes all egress to the Internet."
  protocol          = "-1"
  security_group_id = local.worker_security_group_id
  cidr_blocks       = var.worker_egress_cidrs
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "worker_ingress_self" {
  count = local.create_worker_sg ? 1 : 0

  description              = "Allow node to communicate with each other."
  protocol                 = "-1"
  security_group_id        = local.worker_security_group_id
  source_security_group_id = local.worker_security_group_id
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "worker_ingress_cluster" {
  count = local.create_worker_sg ? 1 : 0

  description              = "Allow worker pods to receive communication from the cluster control plane."
  protocol                 = "tcp"
  security_group_id        = local.worker_security_group_id
  source_security_group_id = local.cluster_security_group_id
  from_port                = var.worker_sg_ingress_from_port
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "worker_ingress_cluster_kubelet" {
  count = local.create_worker_sg ? var.worker_sg_ingress_from_port > 10250 ? 1 : 0 : 0

  description              = "Allow worker Kubelets to receive communication from the cluster control plane."
  protocol                 = "tcp"
  security_group_id        = local.worker_security_group_id
  source_security_group_id = local.cluster_security_group_id
  from_port                = 10250
  to_port                  = 10250
  type                     = "ingress"
}

resource "aws_security_group_rule" "worker_ingress_cluster_https" {
  count = local.create_worker_sg ? 1 : 0

  description              = "Allow pods running extension API servers on port 443 to receive communication from cluster control plane."
  protocol                 = "tcp"
  security_group_id        = local.worker_security_group_id
  source_security_group_id = local.cluster_security_group_id
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "worker_ingress_cluster_primary" {
  count = local.create_worker_sg && var.worker_create_cluster_primary_security_group_rules ? 1 : 0

  description              = "Allow pods running on worker to receive communication from cluster primary security group (e.g. Fargate pods)."
  protocol                 = "all"
  security_group_id        = local.worker_security_group_id
  source_security_group_id = aws_eks_cluster.this[0].vpc_config[0].cluster_security_group_id
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster_primary_ingress_worker" {
  count = local.create_worker_sg && var.worker_create_cluster_primary_security_group_rules ? 1 : 0

  description              = "Allow pods running on worker to send communication to cluster primary security group (e.g. Fargate pods)."
  protocol                 = "all"
  security_group_id        = aws_eks_cluster.this[0].vpc_config[0].cluster_security_group_id
  source_security_group_id = local.worker_security_group_id
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}
