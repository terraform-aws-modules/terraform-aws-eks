terraform {
  required_version = "= 0.11.8"
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
  # worker_groups = [
  #   {
  #     asg_desired_capacity = 2
  #     asg_max_size = 10
  #     asg_min_size = 2
  #     instance_type = "m4.xlarge"
  #     name = "worker_group_a"
  #     additional_userdata = "echo foo bar"
  #     subnets = "${join(",", module.vpc.private_subnets)}"
  #   },
  #   {
  #     asg_desired_capacity = 1
  #     asg_max_size = 5
  #     asg_min_size = 1
  #     instance_type = "m4.2xlarge"
  #     name = "worker_group_b"
  #     additional_userdata = "echo foo bar"
  #     subnets = "${join(",", module.vpc.private_subnets)}"
  #   },
  # ]

  worker_groups = [
    {
      instance_type       = "t2.small"
      additional_userdata = "echo foo bar"
      subnets             = "${join(",", module.vpc.private_subnets)}"
    },
    {
      instance_type                 = "t2.small"
      additional_userdata           = "echo foo bar"
      subnets                       = "${join(",", module.vpc.private_subnets)}"
      additional_security_group_ids = "${aws_security_group.worker_group_mgmt_one.id},${aws_security_group.worker_group_mgmt_two.id}"
    },
  ]
  tags = {
    Environment = "test"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
    Workspace   = "${terraform.workspace}"
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  description = "SG to be applied to all *nix machines"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

resource "aws_security_group" "worker_group_mgmt_two" {
  name_prefix = "worker_group_mgmt_two"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "192.168.0.0/16",
    ]
  }
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = "${module.vpc.vpc_id}"

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
  source                               = "../.."
  cluster_name                         = "${local.cluster_name}"
  subnets                              = ["${module.vpc.private_subnets}"]
  tags                                 = "${local.tags}"
  vpc_id                               = "${module.vpc.vpc_id}"
  worker_groups                        = "${local.worker_groups}"
  worker_group_count                   = "2"
  worker_additional_security_group_ids = ["${aws_security_group.all_worker_mgmt.id}"]
  map_roles                            = "${var.map_roles}"
  map_users                            = "${var.map_users}"
  map_accounts                         = "${var.map_accounts}"
}
