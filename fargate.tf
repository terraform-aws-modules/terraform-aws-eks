module "fargate" {
  source                            = "./modules/fargate"
  cluster_name                      = coalescelist(aws_eks_cluster.this[*].name, [""])[0]
  profiles                          = var.create_eks ? var.eks_fargate_profiles : {}
  subnets                           = var.subnets
  tags                              = var.tags
  cluster_primary_security_group_id = element(concat(aws_eks_cluster.this[*].vpc_config[0].cluster_security_group_id, list("")), 0)
  worker_security_group_id          = local.worker_security_group_id
}
