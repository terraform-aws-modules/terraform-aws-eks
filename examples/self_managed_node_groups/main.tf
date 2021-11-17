provider "aws" {
  region = local.region
}

locals {
  name            = "ex-${replace(basename(path.cwd), "_", "-")}"
  cluster_version = "1.21"
  region          = "eu-west-1"

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

  cluster_name    = local.name
  cluster_version = local.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  self_managed_node_group_defaults = {
    disk_size = 50
  }

  self_managed_node_groups = {
    # Default node group - as provisioned by the module defaults
    default_node_group = {}

    # Complete
    complete = {
      name            = "complete-self-mng"
      use_name_prefix = false

      subnet_ids = module.vpc.public_subnets

      min_size     = 1
      max_size     = 7
      desired_size = 1

      ami_id               = "ami-0caf35bc73450c396"
      bootstrap_extra_args = "--kubelet-extra-args '--max-pods=110'"

      pre_bootstrap_user_data = <<-EOT
        #!/bin/bash set -ex
        export CONTAINER_RUNTIME="containerd"
        export USE_MAX_PODS=false
      EOT

      post_bootstrap_user_data = <<-EOT
        echo "you are free little kubelet!"
      EOT

      capacity_type        = "SPOT"
      disk_size            = 256
      force_update_version = true
      instance_types       = ["m6i.large", "m5.large", "m5n.large", "m5zn.large", "m3.large", "m4.large"]
      labels = {
        GithubRepo = "terraform-aws-eks"
        GithubOrg  = "terraform-aws-modules"
      }

      # TODO - why is this giving an error!!!
      # update_config = {
      #   max_unavailable = "1"
      # }

      create_launch_template          = true
      launch_template_name            = "self-managed-ex"
      launch_template_use_name_prefix = true
      description                     = "Self managed node group example launch template"
      update_default_version          = true

      ebs_optimized           = true
      vpc_security_group_ids  = [aws_security_group.additional.id]
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
            kms_key_id            = aws_kms_key.ebs.arn
            delete_on_termination = true
          }
        }
      }

      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 2
      }

      create_iam_role          = true
      iam_role_name            = "self-managed-node-group-complete-example"
      iam_role_use_name_prefix = false
      iam_role_path            = "/self/"
      iam_role_description     = "Self managed node group complete example role"
      iam_role_tags = {
        Purpose = "Protector of the kubelet"
      }
      iam_role_additional_policies = [
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      ]

      create_security_group          = true
      security_group_name            = "self-managed-node-group-complete-example"
      security_group_use_name_prefix = false
      security_group_description     = "Self managed node group complete example security group"
      security_group_rules = {
        phoneOut = {
          description = "Hello CloudFlare"
          protocol    = "udp"
          from_port   = 53
          to_port     = 53
          type        = "egress"
          cidr_blocks = ["1.1.1.1/32"]
        }
        phoneHome = {
          description                   = "Hello cluster"
          protocol                      = "udp"
          from_port                     = 53
          to_port                       = 53
          type                          = "egress"
          source_cluster_security_group = true # bit of reflection lookup
        }
      }
      security_group_tags = {
        Purpose = "Protector of the kubelet"
      }

      timeouts = {
        create = "80m"
        update = "80m"
        delete = "80m"
      }

      tags = {
        ExtraTag = "Self managed node group complete example"
      }
    }
  }

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = "10.0.0.0/16"

  azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb"              = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb"     = 1
  }

  tags = local.tags
}

resource "aws_security_group" "additional" {
  name_prefix = "${local.name}-additional"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.99.0.0/28"]
  }
}

data "aws_caller_identity" "current" {}

resource "aws_kms_key" "ebs" {
  description             = "Customer managed key to encrypt self managed node group volumes"
  deletion_window_in_days = 7
  policy                  = data.aws_iam_policy_document.ebs.json
}

# This policy is required for the KMS key used for EKS root volumes, so the cluster is allowed to enc/dec/attach encrypted EBS volumes
data "aws_iam_policy_document" "ebs" {
  # Copy of default KMS policy that lets you manage it
  statement {
    sid       = "Enable IAM User Permissions"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  # Required for EKS
  statement {
    sid = "Allow service-linked role use of the CMK"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling", # required for the ASG to manage encrypted volumes for nodes
        module.eks.cluster_iam_role_arn,                                                                                                            # required for the cluster / persistentvolume-controller to create encrypted PVCs
      ]
    }
  }

  statement {
    sid       = "Allow attachment of persistent resources"
    actions   = ["kms:CreateGrant"]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling", # required for the ASG to manage encrypted volumes for nodes
        module.eks.cluster_iam_role_arn,                                                                                                            # required for the cluster / persistentvolume-controller to create encrypted PVCs
      ]
    }

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}
