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

# resource "random_pet" "suffix" {
#   length = 1
# }

# resource "random_string" "suffix" {
#   length = 8
#   special = false
# }

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
  tags               = "${local.tags}"
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "1.12.0"
  name    = "test-sg-https"
  vpc_id  = "${module.vpc.vpc_id}"
  tags    = "${local.tags}"
}

module "eks" {
  source = "../.."

  # cluster_name    = "test-eks-${random_string.suffix.result}"
  # cluster_name    = "test-eks-${random_pet.suffix.id}"
  cluster_name = "test-eks-cluster"

  security_groups = ["${module.security_group.this_security_group_id}"]
  subnets         = "${module.vpc.public_subnets}"
  tags            = "${local.tags}"
  vpc_id          = "${module.vpc.vpc_id}"
}
