module "fargate" {
  source                            = "./modules/fargate"
  cluster_name                      = coalescelist(aws_eks_cluster.this[*].name, [""])[0]
  create_eks                        = var.create_eks
  create_fargate_pod_execution_role = var.create_fargate_pod_execution_role
  fargate_profiles                  = var.fargate_profiles
  subnets                           = var.subnets
  tags                              = var.tags
}
