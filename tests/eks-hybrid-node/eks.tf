locals {
  cluster_version = "1.30"
}

################################################################################
# EKS Cluster
################################################################################

module "eks" {
  # source  = "terraform-aws-modules/eks/aws"
  # version = "~> 20.0"
  source = "../.."

  cluster_name    = local.name
  cluster_version = local.cluster_version
  # Required for Hybrid Nodes beta
  cluster_endpoint_public_access = true

  enable_cluster_creator_admin_permissions = true

  # Required for Hybrid Nodes beta
  authentication_mode = "API_AND_CONFIG_MAP"

  cluster_security_group_additional_rules = {
    hybrid-all = {
      cidr_blocks = [local.remote_network_cidr]
      description = "Allow all HTTPS traffic from remote node/pod network"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      type        = "ingress"
    }
  }

  node_security_group_additional_rules = {
    hybrid-all = {
      cidr_blocks = [local.remote_network_cidr]
      description = "Allow all traffic from remote node/pod network"
      from_port   = "-1"
      to_port     = "-1"
      protocol    = "all"
      type        = "ingress"
    }
  }

  # EKS Addons
  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni = {
      configuration_values = jsonencode({
        # Required for Hybrid Nodes beta
        affinity = {
          nodeAffinity = {
            requiredDuringSchedulingIgnoredDuringExecution = {
              nodeSelectorTerms = [
                {
                  matchExpressions = [
                    {
                      key      = "kubernetes.io/os"
                      operator = "In"
                      values   = ["linux"]
                    },
                    {
                      key      = "kubernetes.io/arch"
                      operator = "In"
                      values   = ["amd64", "arm64"]
                    },
                    {
                      key      = "eks.amazonaws.com/compute-type"
                      operator = "NotIn"
                      values   = ["fargate", "hybrid"]
                    }
                  ]
                },
              ]
            }
          }
        }
      })
    }
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

  eks_managed_node_groups = {
    default = {
      instance_types = ["m6i.large"]

      min_size     = 2
      max_size     = 5
      desired_size = 2
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
