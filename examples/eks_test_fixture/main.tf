terraform {
  required_version = "= 0.11.7"
}

provider "aws" {
  version = ">= 1.22.0"
  region  = "${var.region}"
}

provider "random" {
  version = "= 1.3.1"
}

provider "http" {}

data "aws_ami" "eks_worker" {
  filter {
    name   = "name"
    values = ["eks-worker-*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon
}

data "aws_availability_zones" "available" {}

data "http" "workstation_external_ip" {
  url = "http://icanhazip.com"
}

locals {
  workstation_external_cidr = "${chomp(data.http.workstation_external_ip.body)}/32"
  cluster_name              = "test-eks-${random_string.suffix.result}"

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
  azs                = ["${data.aws_availability_zones.available.names[0]}", "${data.aws_availability_zones.available.names[1]}"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets     = ["10.0.3.0/24", "10.0.4.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
  tags               = "${merge(local.tags, map("kubernetes.io/cluster/${local.cluster_name}", "shared"))}"
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "1.12.0"
  name    = "test-sg-https"
  vpc_id  = "${module.vpc.vpc_id}"
  tags    = "${local.tags}"
}

module "eks" {
  source                = "../.."
  cluster_name          = "${local.cluster_name}"
  subnets               = "${module.vpc.public_subnets}"
  tags                  = "${local.tags}"
  vpc_id                = "${module.vpc.vpc_id}"
  workers_ami_id        = "${data.aws_ami.eks_worker.id}"
  cluster_ingress_cidrs = ["${local.workstation_external_cidr}"]
}
