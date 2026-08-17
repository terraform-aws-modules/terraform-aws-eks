module "eks_al2023" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "${local.name}-al2023"
  kubernetes_version = "1.33"

  # EKS Addons
  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  self_managed_node_groups = {
    example = {
      ami_type      = "AL2023_x86_64_STANDARD"
      instance_type = "m6i.large"

      min_size = 2
      max_size = 5
      # This value is ignored after the initial creation
      # https://github.com/bryantbiggs/eks-desired-size-hack
      desired_size = 2

      # This is not required - demonstrates how to pass additional configuration to nodeadm
      # Ref https://awslabs.github.io/amazon-eks-ami/nodeadm/doc/api/
      cloudinit_pre_nodeadm = [
        {
          content_type = "application/node.eks.aws"
          content      = <<-EOT
            ---
            apiVersion: node.eks.aws/v1alpha1
            kind: NodeConfig
            spec:
              kubelet:
                config:
                  shutdownGracePeriod: 30s
          EOT
        }
      ]

      # This is not required - demonstrates how to request capacity reservations for the ASG
      # https://docs.aws.amazon.com/autoscaling/ec2/userguide/use-ec2-capacity-reservations.html
      asg_capacity_reservation_specification = {
        capacity_reservation_preference = "capacity-reservations-first"
        capacity_reservation_target = {
          capacity_reservation_ids = ["cr-0a1b2c3d4e5f6g7h8"]
        }
      }

      # This is not required - demonstrates how to request the ASG to place machines within AZs
      # https://docs.aws.amazon.com/autoscaling/ec2/userguide/use-ec2-capacity-reservations.html
      availability_zone_distribution = {
        capacity_distribution_strategy = "balanced-only"
      }
    }
  }

  tags = local.tags
}
