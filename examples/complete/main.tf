provider "aws" {
  region = local.region
}

locals {
  name            = "ex-${replace(basename(path.cwd), "_", "-")}"
  cluster_version = "1.20"
  region          = "eu-west-1"

  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}

################################################################################
# EKS Module
################################################################################

module "eks" {
  source = "../.."

  cluster_name    = local.name
  cluster_version = local.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  # TODO
  # vpc_security_group_ids = [aws_security_group.additional.id]

  self_managed_node_groups = {
    one = {
      name                    = "spot-1"
      override_instance_types = ["m5.large", "m5a.large", "m5d.large", "m5ad.large"]
      spot_instance_pools     = 4
      asg_max_size            = 5
      asg_desired_capacity    = 5
      kubelet_extra_args      = "--node-labels=node.kubernetes.io/lifecycle=spot"
      public_ip               = true

      vpc_security_group_ids = [aws_security_group.additional.id] # TODO
    }
  }

  # # Managed Node Groups
  # node_groups_defaults = {
  #   ami_type  = "AL2_x86_64"
  #   disk_size = 50
  # }

  eks_managed_node_groups = {
    example = {
      desired_capacity = 1
      max_capacity     = 10
      min_capacity     = 1

      vpc_security_group_ids = [aws_security_group.additional.id] # TODO

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"
      k8s_labels = {
        Environment = "test"
        GithubRepo  = "terraform-aws-eks"
        GithubOrg   = "terraform-aws-modules"
      }
      additional_tags = {
        ExtraTag = "example"
      }
      taints = {
        dedicated = {
          key    = "dedicated"
          value  = "gpuGroup"
          effect = "NO_SCHEDULE"
        }
      }
      update_config = {
        max_unavailable_percentage = 50 # or set `max_unavailable`
      }
    }
  }

  # # Fargate
  # fargate_profiles = {
  #   default = {
  #     name = "default"
  #     selectors = [
  #       {
  #         namespace = "kube-system"
  #         labels = {
  #           k8s-app = "kube-dns"
  #         }
  #       },
  #       {
  #         namespace = "default"
  #       }
  #     ]

  #     tags = {
  #       Owner = "test"
  #     }

  #     timeouts = {
  #       create = "20m"
  #       delete = "20m"
  #     }
  #   }
  # }

  tags = local.tags
}

################################################################################
# Disabled creation
################################################################################

module "disabled_eks" {
  source = "../.."

  create = false
}

module "disabled_fargate" {
  source = "../../modules/fargate-profile"

  create = false
}

################################################################################
# Additional security groups for workers
################################################################################

resource "aws_security_group" "additional" {
  name_prefix = "all_worker_management"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}

################################################################################
# Supporting resources
################################################################################

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name                 = local.name
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb"              = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb"     = "1"
  }

  tags = local.tags
}
