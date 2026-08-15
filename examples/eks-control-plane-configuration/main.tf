provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {
  # Exclude local zones
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  name               = "ex-cp-config"
  kubernetes_version = "1.33"
  region             = "us-west-2"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Test       = local.name
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}

################################################################################
# EKS Module - Advanced Control Plane Configuration
################################################################################

module "eks_api_server" {
  source = "../.."

  name               = "${local.name}-api"
  kubernetes_version = local.kubernetes_version

  endpoint_public_access = true

  enable_cluster_creator_admin_permissions = true

  # API server configuration: Shorter event retention and custom node port range
  kube_api_server_config = {
    event_ttl = "30m"
    service_node_port_range = {
      min_port = 10260
      max_port = 32767
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  tags = local.tags
}

module "eks_hpa_sync" {
  source = "../.."

  name               = "${local.name}-hpa"
  kubernetes_version = local.kubernetes_version

  endpoint_public_access = true

  enable_cluster_creator_admin_permissions = true

  # Provisioned Control Plane required for HPA sync period
  control_plane_scaling_config = {
    tier = "tier-xl"
  }

  # Controller manager configuration: Faster HPA sync
  kube_controller_manager_config = {
    horizontal_pod_autoscaler_controller_config = {
      horizontal_pod_autoscaler_sync_period = "10s"
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  tags = local.tags
}

module "eks_combined" {
  source = "../.."

  name               = "${local.name}-all"
  kubernetes_version = local.kubernetes_version

  endpoint_public_access = true

  enable_cluster_creator_admin_permissions = true

  # Provisioned Control Plane
  control_plane_scaling_config = {
    tier = "tier-xl"
  }

  # All advanced control plane parameters combined
  kube_scheduler_config = {
    node_resources_fit = {
      scoring_strategy = {
        type = "MostAllocated"
        resources = [
          {
            name   = "cpu"
            weight = 50
          },
          {
            name   = "memory"
            weight = 50
          },
        ]
      }
    }
  }

  kube_controller_manager_config = {
    horizontal_pod_autoscaler_controller_config = {
      horizontal_pod_autoscaler_sync_period = "10s"
    }
  }

  kube_api_server_config = {
    event_ttl = "15m"
    service_node_port_range = {
      min_port = 20000
      max_port = 32767
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  tags = local.tags
}

module "disabled_eks" {
  source = "../.."

  create = false
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

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
