module "fargate" {
  source                            = "./modules/fargate"
  create                            = var.create_eks && var.create_eks_fargate
  cluster_name                      = aws_eks_cluster.this[0].name
  profiles                          = var.eks_fargate_profiles
  subnets                           = var.subnets
  tags                              = var.tags
  cluster_primary_security_group_id = element(concat(aws_eks_cluster.this[*].vpc_config[0].cluster_security_group_id, list("")), 0)
  worker_security_group_id          = local.worker_security_group_id
}
