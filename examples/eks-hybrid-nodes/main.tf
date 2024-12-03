provider "aws" {
  region = local.region
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "us-west-2"

  cluster_version = "1.31"

  tags = {
    Test       = local.name
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}

################################################################################
# EKS Cluster
################################################################################

module "eks" {
  source = "../.."

  cluster_name    = local.name
  cluster_version = local.cluster_version

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
  }

  create_node_security_group = false
  cluster_security_group_additional_rules = {
    hybrid-all = {
      cidr_blocks = [local.remote_network_cidr]
      description = "Allow all traffic from remote node/pod network"
      from_port   = 0
      to_port     = 0
      protocol    = "all"
      type        = "ingress"
    }
  }

  cluster_compute_config = {
    enabled    = true
    node_pools = ["system"]
  }

  access_entries = {
    hybrid-node-role = {
      principal_arn = module.eks_hybrid_node_role.arn
      type          = "HYBRID_LINUX"
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_remote_network_config = {
    remote_node_networks = {
      cidrs = [local.remote_node_cidr]
    }
    remote_pod_networks = {
      cidrs = [local.remote_pod_cidr]
    }
  }

  tags = local.tags
}

################################################################################
# VPC
################################################################################

locals {
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
}

data "aws_availability_zones" "available" {
  # Exclude local zones
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 52)]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}

################################################################################
# VPC Peering Connection
################################################################################

resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = aws_vpc_peering_connection.remote_node.id
  auto_accept               = true

  tags = local.tags
}

resource "aws_route" "peer" {
  route_table_id            = one(module.vpc.private_route_table_ids)
  destination_cidr_block    = local.remote_network_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.remote_node.id
}
