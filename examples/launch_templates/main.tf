module "eks" {
  source                          = "../.."
  cluster_name                    = local.cluster_name
  cluster_version                 = var.cluster_version
  vpc_id                          = module.vpc.vpc_id
  subnets                         = module.vpc.private_subnets
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

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

  tags = {
    Example    = var.example_name
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}
