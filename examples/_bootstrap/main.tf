provider "aws" {
  region = local.region
}

locals {
  region   = "eu-west-1"
  name     = "bootstrap-example"
  vpc_cidr = "10.0.0.0/16"

  cluster_name = "test-eks-${random_string.suffix.result}"
}

data "aws_availability_zones" "available" {}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = "10.0.0.0/16"

  azs             = data.aws_availability_zones.available.names
  public_subnets  = [for k, v in data.aws_availability_zones.available.names : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in data.aws_availability_zones.available.names : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  # NAT Gateway is disabled in the examples primarily to save costs and be able to recreate VPC faster.
  enable_nat_gateway = false
  single_nat_gateway = false

  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}
