provider "aws" {
  region = local.region
}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

locals {
  name            = "ex-${replace(basename(path.cwd), "_", "-")}"
  cluster_version = "1.30"
  region          = "eu-west-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Test       = local.name
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

  # IPV6
  cluster_ip_family          = "ipv6"
  create_cni_ipv6_iam_policy = true

  enable_cluster_creator_admin_permissions = true

  # Enable EFA support by adding necessary security group rules
  # to the shared node security group
  enable_efa_support = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent    = true
      before_compute = true
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
  }

  cluster_upgrade_policy = {
    support_type = "STANDARD"
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    # Default node group - as provided by AWS EKS
    default_node_group = {
      # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
      # so we need to disable it to use the default template provided by the AWS EKS managed node group service
      use_custom_launch_template = false

      disk_size = 50

      # Remote access cannot be specified with a launch template
      remote_access = {
        ec2_ssh_key               = module.key_pair.key_pair_name
        source_security_group_ids = [aws_security_group.remote_access.id]
      }
    }

    placement_group = {
      create_placement_group = true
      # forces the subnet lookup to be restricted to this availability zone
      placement_group_az = element(local.azs, 3)
    }

    # AL2023 node group utilizing new user data format which utilizes nodeadm
    # to join nodes to the cluster (instead of /etc/eks/bootstrap.sh)
    al2023_nodeadm = {
      ami_type                       = "AL2023_x86_64_STANDARD"
      use_latest_ami_release_version = true

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
                  featureGates:
                    DisableKubeletCloudCredentialProviders: true
          EOT
        }
      ]
    }

    # Default node group - as provided by AWS EKS using Bottlerocket
    bottlerocket_default = {
      # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
      # so we need to disable it to use the default template provided by the AWS EKS managed node group service
      use_custom_launch_template = false

      ami_type = "BOTTLEROCKET_x86_64"
    }

    # Adds to the AWS provided user data
    bottlerocket_add = {
      ami_type = "BOTTLEROCKET_x86_64"

      use_latest_ami_release_version = true

      # This will get added to what AWS provides
      bootstrap_extra_args = <<-EOT
        # extra args added
        [settings.kernel]
        lockdown = "integrity"
      EOT
    }

    # Custom AMI, using module provided bootstrap data
    bottlerocket_custom = {
      # Current bottlerocket AMI
      ami_id   = data.aws_ami.eks_default_bottlerocket.image_id
      ami_type = "BOTTLEROCKET_x86_64"

      # Use module user data template to bootstrap
      enable_bootstrap_user_data = true
      # This will get added to the template
      bootstrap_extra_args = <<-EOT
        # The admin host container provides SSH access and runs with "superpowers".
        # It is disabled by default, but can be disabled explicitly.
        [settings.host-containers.admin]
        enabled = false

        # The control host container provides out-of-band access via SSM.
        # It is enabled by default, and can be disabled if you do not expect to use SSM.
        # This could leave you with no way to access the API and change settings on an existing node!
        [settings.host-containers.control]
        enabled = true

        # extra args added
        [settings.kernel]
        lockdown = "integrity"

        [settings.kubernetes.node-labels]
        label1 = "foo"
        label2 = "bar"

        [settings.kubernetes.node-taints]
        dedicated = "experimental:PreferNoSchedule"
        special = "true:NoSchedule"
      EOT
    }

    # Use a custom AMI
    custom_ami = {
      ami_type = "AL2_ARM_64"
      # Current default AMI used by managed node groups - pseudo "custom"
      ami_id = data.aws_ami.eks_default_arm.image_id

      # This will ensure the bootstrap user data is used to join the node
      # By default, EKS managed node groups will not append bootstrap script;
      # this adds it back in using the default template provided by the module
      # Note: this assumes the AMI provided is an EKS optimized AMI derivative
      enable_bootstrap_user_data = true

      instance_types = ["t4g.medium"]
    }

    # Complete
    complete = {
      name            = "complete-eks-mng"
      use_name_prefix = true

      subnet_ids = module.vpc.private_subnets

      min_size     = 1
      max_size     = 7
      desired_size = 1

      ami_id                     = data.aws_ami.eks_default.image_id
      enable_bootstrap_user_data = true

      pre_bootstrap_user_data = <<-EOT
        export FOO=bar
      EOT

      post_bootstrap_user_data = <<-EOT
        echo "you are free little kubelet!"
      EOT

      capacity_type        = "SPOT"
      force_update_version = true
      instance_types       = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
      labels = {
        GithubRepo = "terraform-aws-eks"
        GithubOrg  = "terraform-aws-modules"
      }

      taints = [
        {
          key    = "dedicated"
          value  = "gpuGroup"
          effect = "NO_SCHEDULE"
        }
      ]

      update_config = {
        max_unavailable_percentage = 33 # or set `max_unavailable`
      }

      description = "EKS managed node group example launch template"

      ebs_optimized           = true
      disable_api_termination = false
      enable_monitoring       = true

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 75
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 150
            encrypted             = true
            kms_key_id            = module.ebs_kms_key.key_arn
            delete_on_termination = true
          }
        }
      }

      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 2
        instance_metadata_tags      = "disabled"
      }

      create_iam_role          = true
      iam_role_name            = "eks-managed-node-group-complete-example"
      iam_role_use_name_prefix = false
      iam_role_description     = "EKS managed node group complete example role"
      iam_role_tags = {
        Purpose = "Protector of the kubelet"
      }
      iam_role_additional_policies = {
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
        additional                         = aws_iam_policy.node_additional.arn
      }
      iam_role_policy_statements = [
        {
          sid    = "ECRPullThroughCache"
          effect = "Allow"
          actions = [
            "ecr:CreateRepository",
            "ecr:BatchImportUpstreamImage",
          ]
          resources = ["*"]
        }
      ]

      launch_template_tags = {
        # enable discovery of autoscaling groups by cluster-autoscaler
        "k8s.io/cluster-autoscaler/enabled" : true,
        "k8s.io/cluster-autoscaler/${local.name}" : "owned",
      }

      tags = {
        ExtraTag = "EKS managed node group complete example"
      }
    }

    efa = {
      # Disabling automatic creation due to instance type/quota availability
      # Can be enabled when appropriate for testing/validation
      create = false

      ami_type       = "AL2_x86_64_GPU"
      instance_types = ["trn1n.32xlarge"]

      enable_efa_support      = true
      pre_bootstrap_user_data = <<-EOT
        # Mount NVME instance store volumes since they are typically
        # available on instances that support EFA
        setup-local-disks raid0
      EOT

      min_size     = 2
      max_size     = 2
      desired_size = 2
    }
  }

  access_entries = {
    # One access entry with a policy associated
    ex-single = {
      kubernetes_groups = []
      principal_arn     = aws_iam_role.this["single"].arn

      policy_associations = {
        single = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            namespaces = ["default"]
            type       = "namespace"
          }
        }
      }
    }

    # Example of adding multiple policies to a single access entry
    ex-multiple = {
      kubernetes_groups = []
      principal_arn     = aws_iam_role.this["multiple"].arn

      policy_associations = {
        ex-one = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
          access_scope = {
            namespaces = ["default"]
            type       = "namespace"
          }
        }
        ex-two = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  tags = local.tags
}

module "disabled_eks" {
  source = "../.."

  create = false
}

################################################################################
# Sub-Module Usage on Existing/Separate Cluster
################################################################################

module "eks_managed_node_group" {
  source = "../../modules/eks-managed-node-group"

  name                 = "separate-eks-mng"
  cluster_name         = module.eks.cluster_name
  cluster_ip_family    = module.eks.cluster_ip_family
  cluster_service_cidr = module.eks.cluster_service_cidr

  subnet_ids                        = module.vpc.private_subnets
  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id
  vpc_security_group_ids            = [module.eks.node_security_group_id]

  ami_type = "BOTTLEROCKET_x86_64"

  # this will get added to what AWS provides
  bootstrap_extra_args = <<-EOT
    # extra args added
    [settings.kernel]
    lockdown = "integrity"

    [settings.kubernetes.node-labels]
    "label1" = "foo"
    "label2" = "bar"
  EOT

  tags = merge(local.tags, { Separate = "eks-managed-node-group" })
}

module "disabled_eks_managed_node_group" {
  source = "../../modules/eks-managed-node-group"

  create = false
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 52)]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  enable_ipv6            = true
  create_egress_only_igw = true

  public_subnet_ipv6_prefixes                    = [0, 1, 2]
  public_subnet_assign_ipv6_address_on_creation  = true
  private_subnet_ipv6_prefixes                   = [3, 4, 5]
  private_subnet_assign_ipv6_address_on_creation = true
  intra_subnet_ipv6_prefixes                     = [6, 7, 8]
  intra_subnet_assign_ipv6_address_on_creation   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}

module "ebs_kms_key" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 2.1"

  description = "Customer managed key to encrypt EKS managed node group volumes"

  # Policy
  key_administrators = [
    data.aws_caller_identity.current.arn
  ]

  key_service_roles_for_autoscaling = [
    # required for the ASG to manage encrypted volumes for nodes
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
    # required for the cluster / persistentvolume-controller to create encrypted PVCs
    module.eks.cluster_iam_role_arn,
  ]

  # Aliases
  aliases = ["eks/${local.name}/ebs"]

  tags = local.tags
}

module "key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "~> 2.0"

  key_name_prefix    = local.name
  create_private_key = true

  tags = local.tags
}

resource "aws_security_group" "remote_access" {
  name_prefix = "${local.name}-remote-access"
  description = "Allow remote SSH access"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.tags, { Name = "${local.name}-remote" })
}

resource "aws_iam_policy" "node_additional" {
  name        = "${local.name}-additional"
  description = "Example usage of node additional policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })

  tags = local.tags
}

data "aws_ami" "eks_default" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-${local.cluster_version}-v*"]
  }
}

data "aws_ami" "eks_default_arm" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-arm64-node-${local.cluster_version}-v*"]
  }
}

data "aws_ami" "eks_default_bottlerocket" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["bottlerocket-aws-k8s-${local.cluster_version}-x86_64-*"]
  }
}

resource "aws_iam_role" "this" {
  for_each = toset(["single", "multiple"])

  name = "ex-${each.key}"

  # Just using for this example
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "Example"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = local.tags
}
