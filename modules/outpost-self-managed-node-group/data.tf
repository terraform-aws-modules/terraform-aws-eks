###############################################################################
# Data
###############################################################################
data "aws_eks_clusters" "clusters" {}

data "aws_eks_cluster" "cluster" {
  for_each = toset([for name in data.aws_eks_clusters.clusters.names : name if name == local.cluster_name])
  name     = each.value
}

data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

data "aws_ami" "eks_default_bottlerocket" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["bottlerocket-aws-k8s-${local.cluster_version}-x86_64-*"]
  }
}

data "aws_subnet" "outpost_node_subnet" {
  id = var.node_subnet_id
}

resource "aws_security_group" "subnet" {
  vpc_id = var.vpc_id
  ingress {
    cidr_blocks = [data.aws_subnet.outpost_node_subnet.cidr_block]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }
}
