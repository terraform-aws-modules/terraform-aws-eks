terraform {
  required_version = "= 0.11.7"
}

provider "aws" {
  version = ">= 1.24.0"
  region  = "${var.region}"
}

provider "random" {
  version = "= 1.3.1"
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "test-eks-${random_string.suffix.result}"

  # the commented out worker group list below shows an example of how to define
  # multiple worker groups of differing configurations
  # worker_groups = "${list(
  #                   map("asg_desired_capacity", "2",
  #                       "asg_max_size", "10",
  #                       "asg_min_size", "2",
  #                       "instance_type", "m4.xlarge",
  #                       "name", "worker_group_a",
  #                       "subnets", "${join(",", module.vpc.private_subnets)}",
  #                   ),
  #                   map("asg_desired_capacity", "1",
  #                       "asg_max_size", "5",
  #                       "asg_min_size", "1",
  #                       "instance_type", "m4.2xlarge",
  #                       "name", "worker_group_b",
  #                       "subnets", "${join(",", module.vpc.private_subnets)}",
  #                   ),
  # )}"

  worker_groups = "${list(
                  map("instance_type","t2.small",
                      "additional_userdata","echo foo bar",
                      "subnets", "${join(",", module.vpc.private_subnets)}",
                      ),
  )}"
  tags = "${map("Environment", "test",
                "GithubRepo", "terraform-aws-eks",
                "GithubOrg", "terraform-aws-modules",
                "Workspace", "${terraform.workspace}",
  )}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "1.14.0"
  name               = "test-vpc"
  cidr               = "10.0.0.0/16"
  azs                = ["${data.aws_availability_zones.available.names[0]}", "${data.aws_availability_zones.available.names[1]}", "${data.aws_availability_zones.available.names[2]}"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
  tags               = "${merge(local.tags, map("kubernetes.io/cluster/${local.cluster_name}", "shared"))}"
}

module "eks" {
  source             = "../.."
  cluster_name       = "${local.cluster_name}"
  subnets            = ["${module.vpc.public_subnets}", "${module.vpc.private_subnets}"]
  tags               = "${local.tags}"
  vpc_id             = "${module.vpc.vpc_id}"
  worker_groups      = "${local.worker_groups}"
  worker_group_count = "1"
  map_roles          = "${var.map_roles}"
  map_users          = "${var.map_users}"
  map_accounts       = "${var.map_accounts}"
}
