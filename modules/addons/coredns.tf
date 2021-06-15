resource "aws_eks_addon" "coredns" {
  count = var.create_coredns_addon ? 1 : 0

  cluster_name      = var.cluster_name
  addon_name        = "coredns"
  resolve_conflicts = "OVERWRITE"
  addon_version     = lookup(var.coredns_versions, var.cluster_version, "Not Found")

  depends_on = [
    var.eks_depends_on
  ]
}
