provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
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

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

################################################################################
# Supporting Resources
################################################################################

module "disabled_irsa" {
  source = "../../modules/irsa"

  create = false
}

module "irsa_simple" {
  source = "../../modules/irsa"

  name         = "${local.name}-simple"
  cluster_name = module.eks.cluster_id

  tags = local.tags
}

module "irsa" {
  source = "../../modules/irsa"

  cluster_name = module.eks.cluster_id
  annotations = {
    global = "annotation"
  }
  labels = {
    global = "label"
  }

  # IAM Role
  iam_role_name        = local.name
  iam_role_description = "Example IRSA role"

  iam_role_additional_policies  = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
  iam_role_max_session_duration = 7200

  # Namespace
  namespace_name = "${local.name}-ns"
  namespace_annotations = {
    namespace = true
  }
  namespace_labels = {
    namespace = true
  }
  namespace_timeouts = {
    delete = "10m"
  }

  # Service Account
  service_account_name            = "${local.name}-sa"
  automount_service_account_token = false
  service_account_annotations = {
    service_account = true
  }
  service_account_labels = {
    service_account = true
  }
  image_pull_secrets = [
    "one",
    "two",
  ]
  secrets = [
    "three",
    "four",
  ]

  tags = local.tags
}

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

module "eks" {
  source = "../.."

  cluster_name                    = local.name
  cluster_version                 = local.cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  eks_managed_node_groups = {
    default_node_group = {
      create_launch_template = false
      launch_template_name   = ""
    }
  }

  tags = local.tags
}
