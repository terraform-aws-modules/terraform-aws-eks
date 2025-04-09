# Installs/configures add ons for the EKS cluster
resource "aws_eks_addon" "vpc_cni" {
  # while we're upgrading we don't want these to be created until we're on 1.20 cluster
  count             = var.create_eks && var.enable_vpc_cni_addon ? 1 : 0
  cluster_name      = aws_eks_cluster.this[0].name
  addon_name        = "vpc-cni"
  addon_version     = var.vpc_cni_version
  resolve_conflicts = var.vpc_cni_resolve_conflicts
}

resource "aws_eks_addon" "coredns" {
  count             = var.create_eks && var.enable_coredns_addon ? 1 : 0
  cluster_name      = aws_eks_cluster.this[0].name
  addon_name        = "coredns"
  addon_version     = var.coredns_version
  resolve_conflicts = var.coredns_resolve_conflicts
  configuration_values = jsonencode({
    autoScaling = {
      enabled = var.coredns_scaling_enabled
      minReplicas = var.coredns_minreplicas
      maxReplicas = var.coredns_maxreplicas
    }
  })
}

resource "aws_eks_addon" "kube_proxy" {
  count             = var.create_eks && var.enable_kube_proxy_addon ? 1 : 0
  cluster_name      = aws_eks_cluster.this[0].name
  addon_name        = "kube-proxy"
  addon_version     = var.kube_proxy_version
  resolve_conflicts = var.kube_proxy_resolve_conflicts
}

resource "aws_eks_addon" "aws_ebs_csi_driver" {
  count                    = var.create_eks && var.enable_aws_ebs_csi_driver_addon ? 1 : 0
  cluster_name             = aws_eks_cluster.this[0].name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = var.aws_ebs_csi_driver_version
  resolve_conflicts        = var.aws_ebs_csi_driver_resolve_conflicts
  service_account_role_arn = var.ebs_csi_driver_role_arn
}

# EKS EFS CSI ADD-ON Module
resource "aws_eks_addon" "aws_efs_csi_driver" {
  count                    = var.create_eks && var.enable_aws_efs_csi_driver_addon ? 1 : 0
  cluster_name             = aws_eks_cluster.this[0].name
  addon_name               = "aws-efs-csi-driver"
  addon_version            = var.aws_efs_csi_driver_version
  resolve_conflicts        = var.aws_efs_csi_driver_resolve_conflicts
  service_account_role_arn = var.efs_csi_driver_role_arn
}