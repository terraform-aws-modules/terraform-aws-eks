###############################################################################
#  Locals
###############################################################################
locals {
  cluster_name                     = var.cluster_name ## Allow overriding the cluster name
  cluster_version                  = length(data.aws_eks_cluster.cluster) > 0 ? data.aws_eks_cluster.cluster[local.cluster_name].version : var.cluster_version
  cluster_endpoint                 = length(data.aws_eks_cluster.cluster) > 0 ? data.aws_eks_cluster.cluster[local.cluster_name].endpoint : var.cluster_endpoint
  cluster_auth                     = length(data.aws_eks_cluster.cluster) > 0 ? data.aws_eks_cluster.cluster[local.cluster_name].certificate_authority[0].data : var.cluster_auth
  security_group_ids               = flatten([var.node_security_group_id, var.security_group_ids, var.shared_security_group_id, aws_security_group.this.id])
  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceCapacity",
    "GroupPendingCapacity",
    "GroupMinSize",
    "GroupMaxSize",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupStandbyCapacity",
    "GroupTerminatingCapacity",
    "GroupTerminatingInstances",
    "GroupTotalCapacity",
    "GroupTotalInstances"
  ]
}
