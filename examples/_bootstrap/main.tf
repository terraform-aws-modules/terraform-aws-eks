provider "aws" {
  region = local.region
}

locals {
  region   = "eu-west-1"
  name     = "bootstrap-example"
  vpc_cidr = "10.0.0.0/16"

  cluster_name    = "test-eks-${random_string.suffix.result}"
  cluster_version = "1.21"
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

  enable_nat_gateway = false # true
  single_nat_gateway = false # true

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

############################################################
# Barebone EKS Cluster where submodules can add extra stuff
############################################################

module "barebone_eks" {
  source = "../.."

  cluster_name    = "barebone-${local.cluster_name}"
  cluster_version = local.cluster_version

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnets

  tags = {
    Environment = "test"
    Barebone    = "yes_please"
  }
}

#############
# Kubernetes
#############

data "aws_eks_cluster" "cluster" {
  name = module.barebone_eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.barebone_eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
