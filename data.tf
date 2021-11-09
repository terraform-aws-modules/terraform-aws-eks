data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_ami" "eks_worker" {
  count = var.create ? 1 : 0

  filter {
    name   = "name"
    values = [coalesce(var.worker_ami_name_filter, "amazon-eks-node-${coalesce(var.cluster_version, "cluster_version")}-v*")]
  }

  most_recent = true

  owners = [var.worker_ami_owner_id]
}
