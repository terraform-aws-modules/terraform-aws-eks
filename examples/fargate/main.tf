provider "aws" {
  region = local.region
}

locals {
  name            = "ex-${replace(basename(path.cwd), "_", "-")}"
  cluster_version = "1.21"
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

  # You require a node group to schedule coredns which is critical for running correctly internal DNS.
  # If you want to use only fargate you must follow docs `(Optional) Update CoreDNS`
  # available under https://docs.aws.amazon.com/eks/latest/userguide/fargate-getting-started.html
  eks_managed_node_groups = {
    example = {
      desired_size = 1

      instance_types = ["t3.large"]
      labels = {
        Example    = "managed_node_groups"
        GithubRepo = "terraform-aws-eks"
        GithubOrg  = "terraform-aws-modules"
      }
      tags = {
        ExtraTag = "example"
      }
      # TODO - this is throwing an error
      # update_config = {
      #   max_unavailable_percentage = 50 # or set `max_unavailable`
      # }
    }
  }

  fargate_profiles = {
    default = {
      fargate_profile_name = "default"
      selectors = [
        {
          namespace = "kube-system"
          labels = {
            k8s-app = "kube-dns"
          }
        },
        {
          namespace = "default"
          labels = {
            WorkerType = "fargate"
          }
        }
      ]

      tags = {
        Owner = "default"
      }

      timeouts = {
        create = "20m"
        delete = "20m"
      }
    }

    secondary = {
      fargate_profile_name = "secondary"
      selectors = [
        {
          namespace = "default"
          labels = {
            Environment = "test"
            GithubRepo  = "terraform-aws-eks"
            GithubOrg   = "terraform-aws-modules"
          }
        }
      ]

      # Using specific subnets instead of the subnets supplied for the cluster itself
      subnet_ids = [module.vpc.private_subnets[1]]

      tags = {
        Owner = "secondary"
      }
    }
  }

  tags = local.tags
}

##############################################
# Calling submodule with existing EKS cluster
##############################################

# module "fargate_profile_existing_cluster" {
#   source = "../../modules/fargate-profile"

#   cluster_name = module.eks.cluster_id
#   subnet_ids   = [module.vpc.private_subnets[0], module.vpc.private_subnets[2]]


#   fargate_profile_name = "profile1"
#   selectors = [
#     {
#       namespace = "kube-system"
#       labels = {
#         k8s-app = "kube-dns"
#       }
#     },
#     {
#       namespace = "profile"
#       labels = {
#         WorkerType = "fargate"
#       }
#     }
#   ]

#   tags = merge(local.tags, {
#     Owner     = "profile1"
#     submodule = "true"
#   })
# }

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = "10.0.0.0/16"

  azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  enable_flow_log                      = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb"              = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb"     = 1
  }

  tags = local.tags
}
