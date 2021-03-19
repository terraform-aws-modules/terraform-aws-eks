module "fargate" {
  source                            = "./modules/fargate"
  cluster_name                      = coalescelist(aws_eks_cluster.this[*].name, [""])[0]
  create_eks                        = var.create_eks
  create_fargate_pod_execution_role = var.create_fargate_pod_execution_role
  fargate_pod_execution_role_name   = var.fargate_pod_execution_role_name
  fargate_profiles                  = var.fargate_profiles
  permissions_boundary              = var.permissions_boundary
  iam_path                          = var.iam_path
  iam_policy_arn_prefix             = local.policy_arn_prefix
  subnets                           = var.subnets
  tags                              = var.tags

  # Hack to ensure ordering of resource creation.
  # This is a homemade `depends_on` https://discuss.hashicorp.com/t/tips-howto-implement-module-depends-on-emulation/2305/2
  # Do not create node_groups before other resources are ready and removes race conditions
  # Ensure these resources are created before "unlocking" the data source.
  # Will be removed in Terraform 0.13
  eks_depends_on = [
    aws_eks_cluster.this,
    kubernetes_config_map.aws_auth,
  ]
}
