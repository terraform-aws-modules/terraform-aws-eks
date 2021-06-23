resource "aws_eks_addon" "kube_proxy" {
  count = var.create_kube_proxy_addon ? 1 : 0

  cluster_name      = var.cluster_name
  addon_name        = "kube-proxy"
  resolve_conflicts = "OVERWRITE"
  addon_version     = lookup(var.kube_proxy_versions, var.cluster_version, "Not Found")

  depends_on = [
    var.eks_depends_on
  ]
}
