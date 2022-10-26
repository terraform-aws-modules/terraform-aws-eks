provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
  }
}

locals {
  name            = "ex-${basename(path.cwd)}"
  cluster_version = "1.21" # Required by EKS on Outposts

  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}

################################################################################
# EKS Module
################################################################################

module "eks" {
  source = "../.."

  cluster_name                   = local.name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true

  outpost_config = {
    control_plane_instance_type = var.outpost_instance_type
    outpost_arns                = [tolist(data.aws_outposts_outposts.this.arns)[0]]
  }

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent              = true
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
    }
  }

  # Encryption key
  create_kms_key = true
  cluster_encryption_config = {
    resources = ["secrets"]
  }
  kms_key_deletion_window_in_days = 7
  enable_kms_key_rotation         = true

  create_cluster_security_group = false
  create_node_security_group    = false
  subnet_ids                    = [tolist(data.aws_subnets.this.ids)[0]]

  manage_aws_auth_configmap = true

  eks_managed_node_group_defaults = {
    instance_types = [var.outpost_instance_type]

    attach_cluster_primary_security_group = true
  }

  eks_managed_node_groups = {
    outpost = {
      name = local.name
    }
  }

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

data "aws_outposts_outposts" "this" {}

data "aws_subnets" "this" {
  filter {
    name   = "outpost-arn"
    values = [tolist(data.aws_outposts_outposts.this.arns)[0]]
  }
}

module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name_prefix      = "VPC-CNI-IRSA"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = local.tags
}
