module "eks" {
  source                          = "../.."
  cluster_name                    = local.cluster_name
  cluster_version                 = var.cluster_version
  vpc_id                          = module.vpc.vpc_id
  subnets                         = module.vpc.private_subnets
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  node_groups = {
    example = {
      desired_capacity = 1
      max_capacity     = 15
      min_capacity     = 1

      launch_template_id      = aws_launch_template.default.id
      launch_template_version = aws_launch_template.default.default_version

      instance_types = var.instance_types

      additional_tags = {
        ExtraTag = "example"
      }
    }
  }

  tags = {
    Example    = var.example_name
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}
