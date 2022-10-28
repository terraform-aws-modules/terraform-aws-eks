provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = ["eks", "get-token", "--cluster-id", module.eks.cluster_id, "--region", var.region]
  }
}

locals {
  name            = "ex-${basename(path.cwd)}"
  cluster_version = "1.21" # Required by EKS on Outposts

  outpost_arn   = element(tolist(data.aws_outposts_outposts.this.arns), 0)
  instance_type = element(tolist(data.aws_outposts_outpost_instance_types.this.instance_types), 0)

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

  cluster_endpoint_public_access  = false # Not available on Outpost
  cluster_endpoint_private_access = true

  vpc_id     = data.aws_vpc.this.id
  subnet_ids = data.aws_subnets.this.ids

  outpost_config = {
    control_plane_instance_type = local.instance_type
    outpost_arns                = [local.outpost_arn]
  }

  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
    ingress_vpc_https = {
      description = "Remote host to control plane"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = [data.aws_vpc.this.cidr_block]
    }
    inress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "ingress"
      source_node_security_group = true
    }
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_vpc_all = {
      description = "VPC"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      cidr_blocks = [data.aws_vpc.this.cidr_block]
    }
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  self_managed_node_group_defaults = {
    attach_cluster_primary_security_group = true

    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
  }

  self_managed_node_groups = {
    outpost = {
      name = local.name

      min_size      = 2
      max_size      = 5
      desired_size  = 3
      instance_type = local.instance_type
    }
  }

  # We need to add the node group IAM role to the aws-auth configmap
  create_aws_auth_configmap = true

  tags = local.tags
}

resource "kubernetes_storage_class_v1" "this" {
  metadata {
    name = "ebs-sc"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    type      = "gp2"
    encrypted = "true"
  }
}

################################################################################
# Supporting Resources
################################################################################

data "aws_outposts_outposts" "this" {}

data "aws_outposts_outpost_instance_types" "this" {
  arn = local.outpost_arn
}

# This just grabs the first Outpost and returns its subnets
data "aws_subnets" "lookup" {
  filter {
    name   = "outpost-arn"
    values = [local.outpost_arn]
  }
}

# This grabs a single subnet to reverse lookup those that belong to same VPC
# This is whats used for the cluster
data "aws_subnet" "this" {
  id = element(tolist(data.aws_subnets.lookup.ids), 0)
}

# These are subnets for the Outpost and restricted to the same VPC
# This is whats used for the cluster
data "aws_subnets" "this" {
  filter {
    name   = "outpost-arn"
    values = [local.outpost_arn]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_subnet.this.vpc_id]
  }
}

data "aws_vpc" "this" {
  id = data.aws_subnet.this.vpc_id
}
