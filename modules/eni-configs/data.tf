###############################################################################
# Data
###############################################################################
data "aws_subnets" "subnets_in_tier" {
  filter {
    name   = "vpc-id"
    values = [data.aws_eks_cluster.cluster.vpc_config[0].vpc_id]
  }
  tags = {
    Tier = "Pod Level"
  }
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_subnet" "subnet_eniconfig" {
  for_each = toset(data.aws_subnets.subnets_in_tier.ids)
  id       = each.value
}
