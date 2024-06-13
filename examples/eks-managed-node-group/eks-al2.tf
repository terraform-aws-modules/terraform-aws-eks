module "eks_bottlerocket" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${local.name}-bottlerocket"
  cluster_version = "1.30"

  # EKS Addons
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    example = {
      # Starting on 1.30, AL2023_x86_64_STANDARD is the default for EKS managed node group
      ami_type       = "AL2_x86_64"
      instance_types = ["m6i.large"]

      min_size     = 2
      max_size     = 5
      desired_size = 2
    }
  }

  tags = local.tags
}
