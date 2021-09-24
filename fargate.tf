module "fargate" {
  source = "./modules/fargate"

  create_eks                        = var.create_eks
  create_fargate_pod_execution_role = var.create_fargate_pod_execution_role

  cluster_name                    = local.cluster_name
  fargate_pod_execution_role_name = var.fargate_pod_execution_role_name
  permissions_boundary            = var.permissions_boundary
  iam_path                        = var.iam_path
  subnets                         = coalescelist(var.fargate_subnets, var.subnets, [""])

  fargate_profiles = var.fargate_profiles

  tags = var.tags
}
