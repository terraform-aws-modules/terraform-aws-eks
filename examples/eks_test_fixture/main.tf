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

  worker_groups = "${list(
                  map("instance_type","t2.small",
                      "additional_userdata","echo foo bar"
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
  source        = "../.."
  cluster_name  = "${local.cluster_name}"
  subnets       = "${module.vpc.public_subnets}"
  tags          = "${local.tags}"
  vpc_id        = "${module.vpc.vpc_id}"
  worker_groups = "${local.worker_groups}"
}
