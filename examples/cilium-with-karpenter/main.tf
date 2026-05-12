data "aws_availability_zones" "available" {}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "us-east-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}

module "eks" {
  # source  = "terraform-aws-modules/eks/aws"
  # version = "21.20.0"
  source = "../.."

  name               = local.name
  kubernetes_version = "1.35"

  enable_cluster_creator_admin_permissions = true
  endpoint_public_access                   = true

  control_plane_scaling_config = {
    tier = "standard"
  }

  enable_irsa = true

  # NO addons here — coredns needs nodes, add later
  addons = {
    eks-pod-identity-agent = {
      before_compute = true
      most_recent    = true
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  # NO eks_managed_node_groups here — moved below

  node_security_group_tags = merge(local.tags, {
    "karpenter.sh/discovery" = local.name
  })

  tags = local.tags
}


# ─── STEP 4: Managed Node Group (Karpenter controller nodes) ─────────────────
# Nodes join AFTER Cilium is installed. The cilium taint prevents any
# non-cilium pods from running until the DaemonSet pod is Ready on that node.
module "eks_managed_node_group" {
  # source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  # version = "21.10.1"
  source = "../../modules/eks-managed-node-group"

  name                 = "${local.name}-karpenter"
  cluster_name         = module.eks.cluster_name
  cluster_service_cidr = module.eks.cluster_service_cidr

  subnet_ids = module.vpc.private_subnets

  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id
  vpc_security_group_ids            = [module.eks.node_security_group_id]

  ami_type       = "BOTTLEROCKET_x86_64"
  instance_types = ["m5.large"]

  min_size     = 2
  max_size     = 6
  desired_size = 2

  labels = {
    "karpenter.sh/controller" = "true"
  }

  taints = {
    cilium_not_ready = {
      key    = "node.cilium.io/agent-not-ready"
      value  = "true"
      effect = "NO_EXECUTE"
    }
  }

  iam_role_use_name_prefix = false
  iam_role_name            = "${local.name}-karpenter-ng"

  iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    CiliumPolicy                 = aws_iam_policy.aws_cilium_policy.arn
  }

  tags = merge(local.tags, {
  })

  # Nodes join only after Cilium CNI is registered in the cluster
  depends_on = [helm_release.cilium]
}

# ─── STEP 5: EKS Addons that require nodes ───────────────────────────────────
resource "aws_eks_addon" "coredns" {
  cluster_name = module.eks.cluster_name
  addon_name   = "coredns"
  depends_on   = [module.eks_managed_node_group]
}
