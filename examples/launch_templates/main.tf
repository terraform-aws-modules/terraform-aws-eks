terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  version = ">= 2.11"
  region  = var.region
}

provider "random" {
  version = "~> 2.1"
}

provider "local" {
  version = "~> 1.2"
}

provider "null" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}

data "aws_availability_zones" "available" {
}

locals {
  cluster_name = "test-eks-lt-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.6.0"

  name                 = "test-vpc-lt"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
}

module "eks" {
  source       = "../.."
#  source          = "terraform-aws-modules/eks/aws"
#  version         = "5.1.0"

  cluster_name = local.cluster_name
  subnets      = module.vpc.public_subnets
  vpc_id       = module.vpc.vpc_id

  worker_groups_launch_template = [
    {
      name                 = "worker-group-1"
      instance_type        = "t2.small"
      asg_desired_capacity = 0
      asg_min_size         = 0
      public_ip            = true
    },
    {
      name                 = "worker-spot-1"
      instance_type        = "c5d.large"
      asg_desired_capacity = 1
      public_ip            = true
      market_type          = "spot"
      key_name             = "sre-keypair-eu-tn-prod-oregon"
      pre_userdata         = file("${path.module}/pre_userdata.sh")
    },
    {
      name                          = "worker-mixed-1"
      on_demand_allocation_strategy = "prioritized"
      override_instance_types       = ["t3.small", "t3.micro"]
      instance_type                 = "t3.medium"
      asg_desired_capacity          = 0
      asg_min_size         = 0
      public_ip                     = true
    }
  ]
}
