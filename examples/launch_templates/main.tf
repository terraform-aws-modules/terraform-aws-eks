provider "aws" {
  region = "eu-west-1"
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
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
  version = "~> 2.47"

  name                 = "test-vpc-lt"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames = true
}

module "eks" {
  source          = "../.."
  cluster_name    = local.cluster_name
  cluster_version = "1.20"
  subnets         = module.vpc.public_subnets
  vpc_id          = module.vpc.vpc_id

  worker_groups_launch_template = [
    {
      name                 = "worker-group-1"
      instance_type        = "t3.small"
      asg_desired_capacity = 2
      public_ip            = true
      tags = [{
        key                 = "ExtraTag"
        value               = "TagValue"
        propagate_at_launch = true
      }]
    },
    {
      name                 = "worker-group-2"
      instance_type        = "t3.medium"
      asg_desired_capacity = 1
      public_ip            = true
      ebs_optimized        = true
    },
    {
      name                          = "worker-group-3"
      instance_type                 = "t2.large"
      asg_desired_capacity          = 1
      public_ip                     = true
      elastic_inference_accelerator = "eia2.medium"
    },
    {
      name                   = "worker-group-4"
      instance_type          = "t3.small"
      asg_desired_capacity   = 1
      public_ip              = true
      root_volume_size       = 150
      root_volume_type       = "gp3"
      root_volume_throughput = 300
      additional_ebs_volumes = [
        {
          block_device_name = "/dev/xvdb"
          volume_size       = 100
          volume_type       = "gp3"
          throughput        = 150
        },
      ]
    },
  ]
}
