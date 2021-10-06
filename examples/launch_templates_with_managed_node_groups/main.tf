module "eks" {
  source                          = "../.."
  cluster_name                    = local.cluster_name
  cluster_version                 = var.cluster_version
  vpc_id                          = module.vpc.vpc_id
  subnets                         = module.vpc.private_subnets
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  node_groups = {
    example1 = {
      name_prefix      = "example1"
      desired_capacity = 1
      max_capacity     = 15
      min_capacity     = 1

      launch_template_id      = aws_launch_template.default.id
      launch_template_version = aws_launch_template.default.default_version

      instance_types = var.instance_types

      additional_tags = {
        ExtraTag = "example1"
      }
    }
    example2 = {
      create_launch_template = true
      desired_capacity       = 1
      max_capacity           = 10
      min_capacity           = 1

      disk_size       = 50
      disk_type       = "gp3"
      disk_throughput = 150
      disk_iops       = 3000

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"
      k8s_labels = {
        GithubRepo = "terraform-aws-eks"
        GithubOrg  = "terraform-aws-modules"
      }
      additional_tags = {
        ExtraTag = "example2"
      }
      taints = [
        {
          key    = "dedicated"
          value  = "gpuGroup"
          effect = "NO_SCHEDULE"
        }
      ]
      update_config = {
        max_unavailable_percentage = 50 # or set `max_unavailable`
      }
    }
  }

  tags = {
    Example    = var.example_name
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}
