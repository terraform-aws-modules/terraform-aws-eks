module "worker_groups" {
  source = "./modules/worker_groups"

  create_workers = var.create_eks

  cluster_version     = var.cluster_version
  cluster_name        = var.cluster_name
  cluster_endpoint    = coalescelist(aws_eks_cluster.this[*].endpoint, [""])[0]
  cluster_auth_base64 = flatten(concat(aws_eks_cluster.this[*].certificate_authority[*].data, [""]))[0]

  default_iam_role_id = coalescelist(aws_iam_role.workers[*].id, [""])[0]

  vpc_id = var.vpc_id

  iam_path                              = var.iam_path
  manage_worker_iam_resources           = var.manage_worker_iam_resources
  worker_create_initial_lifecycle_hooks = var.worker_create_initial_lifecycle_hooks

  workers_group_defaults = local.workers_group_defaults
  worker_groups          = var.worker_groups

  worker_ami_name_filter         = var.worker_ami_name_filter
  worker_ami_name_filter_windows = var.worker_ami_name_filter_windows
  worker_ami_owner_id            = var.worker_ami_owner_id
  worker_ami_owner_id_windows    = var.worker_ami_owner_id_windows

  worker_security_group_ids = flatten([
    local.worker_security_group_id,
    var.worker_additional_security_group_ids
  ])

  tags = var.tags

  # Hack to ensure ordering of resource creation.
  # This is a homemade `depends_on` https://discuss.hashicorp.com/t/tips-howto-implement-module-depends-on-emulation/2305/2
  # Do not create node_groups before other resources are ready and removes race conditions
  # Ensure these resources are created before "unlocking" the data source.
  # Will be removed in Terraform 0.13
  ng_depends_on = [
    aws_eks_cluster.this,
    kubernetes_config_map.aws_auth,
    aws_iam_role_policy_attachment.workers_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.workers_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.workers_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.workers_additional_policies,
  ]
}
