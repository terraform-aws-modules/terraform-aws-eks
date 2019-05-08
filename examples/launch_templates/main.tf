terraform {
  required_version = ">= 0.11.8"
}

provider "aws" {
  version = ">= 2.6.0"
  region  = "${var.region}"
}

provider "random" {
  version = "= 1.3.1"
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "test-eks-lt-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source         = "terraform-aws-modules/vpc/aws"
  version        = "1.60.0"
  name           = "test-vpc-lt"
  cidr           = "10.0.0.0/16"
  azs            = ["${data.aws_availability_zones.available.names}"]
  public_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
}

module "eks" {
  source                             = "../.."
  cluster_name                       = "${local.cluster_name}"
  subnets                            = ["${module.vpc.public_subnets}"]
  vpc_id                             = "${module.vpc.vpc_id}"
  worker_group_count                 = 0
  worker_group_launch_template_count = 2

  worker_groups_launch_template = [
    {
      name                 = "worker-group-1"
      instance_type        = "t2.small"
      asg_desired_capacity = 2
      public_ip            = true
    },
    {
      name                 = "worker-group-2"
      instance_type        = "t2.medium"
      asg_desired_capacity = 1
      public_ip            = true
    },
  ]
}
