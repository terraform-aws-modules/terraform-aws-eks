resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

module "eks" {
  source                          = "../.."
  cluster_name                    = local.cluster_name
  cluster_version                 = var.cluster_version
  vpc_id                          = module.vpc.vpc_id
  subnets                         = module.vpc.private_subnets
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_encryption_config = [
    {
      provider_key_arn = aws_kms_key.eks.arn
      resources        = ["secrets"]
    }
  ]

  worker_groups = [
    {
      name                 = "worker-group-1"
      instance_type        = "t3.small"
      additional_userdata  = "echo foo bar"
      asg_desired_capacity = 2
    },
  ]

  map_roles    = var.map_roles
  map_users    = var.map_users
  map_accounts = var.map_accounts

  tags = {
    Example    = var.example_name
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}
