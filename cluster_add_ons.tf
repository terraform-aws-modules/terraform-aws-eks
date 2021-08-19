# Installs/configures add ons for the EKS cluster
resource "aws_eks_addon" "vpc_cni" {
  # while we're upgrading we don't want these to be created until we're on 1.20 cluster
  count = var.create_eks && tonumber(var.cluster_version) >= 1.20 ? 1 : 0
  cluster_name = aws_eks_cluster.this.*.name
  addon_name   = "vpc-cni"
  addon_version = null
  resolve_conflicts = "NONE"
}

resource "aws_eks_addon" "core_dns" {
  count = var.create_eks && tonumber(var.cluster_version) >= 1.20 ? 1 : 0
  cluster_name = aws_eks_cluster.this.*.name
  addon_name   = "coredns"
  addon_version = null
  resolve_conflicts = "NONE"
}

resource "aws_eks_addon" "kube_proxy" {
  count = var.create_eks && tonumber(var.cluster_version) >= 1.20 ? 1 : 0
  cluster_name = aws_eks_cluster.this.*.name
  addon_name   = "kube-proxy"
  addon_version = null
  resolve_conflicts = "NONE"
}