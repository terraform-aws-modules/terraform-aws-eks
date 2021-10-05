module "eks" {
  source                          = "../.."
  cluster_name                    = local.cluster_name
  cluster_version                 = var.cluster_version
  vpc_id                          = module.vpc.vpc_id
  subnets                         = module.vpc.private_subnets
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 50
  }

  node_groups = {
    example = {
      create_launch_template = true

      desired_capacity = 1
      max_capacity     = 10
      min_capacity     = 1

      disk_size       = 50
      disk_type       = "gp3"
      disk_throughput = 150
      disk_iops       = 3000

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"
      k8s_labels = {
        Example    = "managed_node_groups"
        GithubRepo = "terraform-aws-eks"
        GithubOrg  = "terraform-aws-modules"
      }
      additional_tags = {
        ExtraTag = "example"
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

  map_roles    = var.map_roles
  map_users    = var.map_users
  map_accounts = var.map_accounts

  tags = {
    Example    = var.example_name
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}
