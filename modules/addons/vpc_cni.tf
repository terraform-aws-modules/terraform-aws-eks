resource "aws_eks_addon" "vpc_cni" {
  count = var.create_vpc_cni_addon && var.enable_irsa ? 1 : 0

  cluster_name             = var.cluster_name
  addon_name               = "vpc-cni"
  resolve_conflicts        = "OVERWRITE"
  addon_version            = lookup(var.vpc_cni_versions, var.cluster_version, "Not Found")
  service_account_role_arn = module.iam_assumable_role_with_oidc.iam_role_arn
  tags                     = var.tags

  depends_on = [
    var.eks_depends_on
  ]
}
