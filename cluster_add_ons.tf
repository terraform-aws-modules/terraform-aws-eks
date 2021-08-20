# Installs/configures add ons for the EKS cluster
resource "aws_eks_addon" "vpc_cni" {
  # while we're upgrading we don't want these to be created until we're on 1.20 cluster
  count = var.create_eks && var.enable_vpc_cni_addon ? 1 : 0
  cluster_name = aws_eks_cluster.this.*.name
  addon_name   = "vpc-cni"
  addon_version = var.vpc_cni_version
  resolve_conflicts = var.vpc_cni_resolve_conflicts
}

resource "aws_eks_addon" "coredns" {
  count = var.create_eks && var.enable_coredns_addon ? 1 : 0
  cluster_name = aws_eks_cluster.this.*.name
  addon_name   = "coredns"
  addon_version = var.cordns_version
  resolve_conflicts = var.coredns_resolve_conflicts
}

resource "aws_eks_addon" "kube_proxy" {
  count = var.create_eks && var.enable_kube_proxy_addon ? 1 : 0
  cluster_name = aws_eks_cluster.this.*.name
  addon_name   = "kube-proxy"
  addon_version = var.kube_proxy_version
  resolve_conflicts = var.kube_proxy_resolve_conflicts
}