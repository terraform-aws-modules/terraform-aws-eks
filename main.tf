locals {
  cluster_security_group_id = var.create_cluster_security_group ? join("", aws_security_group.this.*.id) : var.cluster_security_group_id

  # Worker groups
  policy_arn_prefix = "arn:${data.aws_partition.current.partition}:iam::aws:policy"
}

data "aws_partition" "current" {}

################################################################################
# Cluster
################################################################################

resource "aws_eks_cluster" "this" {
  count = var.create ? 1 : 0

  name                      = var.cluster_name
  role_arn                  = try(aws_iam_role.cluster[0].arn, var.cluster_iam_role_arn)
  version                   = var.cluster_version
  enabled_cluster_log_types = var.cluster_enabled_log_types

  vpc_config {
    security_group_ids      = compact([local.cluster_security_group_id])
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.cluster_service_ipv4_cidr
  }

  dynamic "encryption_config" {
    for_each = toset(var.cluster_encryption_config)

    content {
      provider {
        key_arn = encryption_config.value["provider_key_arn"]
      }
      resources = encryption_config.value["resources"]
    }
  }

  tags = merge(
    var.tags,
    var.cluster_tags,
  )

  timeouts {
    create = lookup(var.cluster_timeouts, "create", null)
    delete = lookup(var.cluster_timeouts, "update", null)
    update = lookup(var.cluster_timeouts, "delete", null)
  }

  depends_on = [
    aws_security_group_rule.cluster_egress_internet,
    # aws_security_group_rule.cluster_https_worker_ingress,
    aws_cloudwatch_log_group.this
  ]
}

resource "aws_cloudwatch_log_group" "this" {
  count = var.create && length(var.cluster_enabled_log_types) > 0 ? 1 : 0

  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.cluster_log_retention_in_days
  kms_key_id        = var.cluster_log_kms_key_id

  tags = var.tags
}

################################################################################
# Security Group
# Defaults follow https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html
################################################################################

locals {
  cluster_sg_name                           = coalesce(var.cluster_security_group_name, "${var.cluster_name}-cluster")
  create_cluster_sg                         = var.create && var.create_cluster_security_group
  enable_cluster_private_endpoint_sg_access = local.create_cluster_sg && var.cluster_create_endpoint_private_access_sg_rule && var.cluster_endpoint_private_access
}

resource "aws_security_group" "this" {
  count = local.create_cluster_sg ? 1 : 0

  name        = var.cluster_security_group_use_name_prefix ? null : local.cluster_sg_name
  name_prefix = var.cluster_security_group_use_name_prefix ? "${local.cluster_sg_name}-" : null
  description = "EKS cluster security group"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      "Name" = local.cluster_sg_name
    },
    var.cluster_security_group_tags
  )
}

resource "aws_security_group_rule" "cluster_egress_internet" {
  count = local.create_cluster_sg ? 1 : 0

  description       = "Allow cluster egress access to the Internet"
  protocol          = "-1"
  security_group_id = aws_security_group.this[0].id
  cidr_blocks       = var.cluster_egress_cidrs
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

# resource "aws_security_group_rule" "cluster_https_worker_ingress" {
#   count = local.create_cluster_sg && var.create_worker_security_group ? 1 : 0

#   description              = "Allow pods to communicate with the EKS cluster API"
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.this[0].id
#   source_security_group_id = local.worker_security_group_id # TODO - what a circle, oy
#   from_port                = 443
#   to_port                  = 443
#   type                     = "ingress"
# }

resource "aws_security_group_rule" "cluster_private_access_cidrs_source" {
  count = local.enable_cluster_private_endpoint_sg_access && length(var.cluster_endpoint_private_access_cidrs) > 0 ? 1 : 0

  description = "Allow private K8S API ingress from custom CIDR source"
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = var.cluster_endpoint_private_access_cidrs

  security_group_id = aws_eks_cluster.this[0].vpc_config[0].cluster_security_group_id
}

resource "aws_security_group_rule" "cluster_private_access_sg_source" {
  for_each = local.enable_cluster_private_endpoint_sg_access ? toset(var.cluster_endpoint_private_access_sg) : toset([])

  description              = "Allow private K8S API ingress from custom Security Groups source"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = each.value

  security_group_id = aws_eks_cluster.this[0].vpc_config[0].cluster_security_group_id
}

# TODO
# resource "aws_security_group_rule" "cluster_primary_ingress_worker" {
#   count = local.create_security_group && var.worker_create_cluster_primary_security_group_rules ? 1 : 0

#   description              = "Allow pods running on worker to send communication to cluster primary security group (e.g. Fargate pods)."
#   protocol                 = "all"
#   security_group_id        = aws_eks_cluster.this[0].vpc_config[0].cluster_security_group_id
#   source_security_group_id = local.worker_security_group_id
#   from_port                = 0
#   to_port                  = 65535
#   type                     = "ingress"
# }

################################################################################
# IRSA
################################################################################

data "tls_certificate" "this" {
  count = var.create && var.enable_irsa ? 1 : 0

  url = aws_eks_cluster.this[0].identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  count = var.create && var.enable_irsa ? 1 : 0

  client_id_list  = distinct(compact(concat(["sts.${data.aws_partition.current.dns_suffix}"], var.openid_connect_audiences)))
  thumbprint_list = [data.tls_certificate.this[0].certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this[0].identity[0].oidc[0].issuer

  tags = merge(
    {
      Name = "${var.cluster_name}-eks-irsa"
    },
    var.tags
  )
}

################################################################################
# IAM Role
################################################################################

locals {
  cluster_iam_role_name = coalesce(var.cluster_iam_role_name, "${var.cluster_name}-cluster")
}

resource "aws_iam_role" "cluster" {
  count = var.create && var.create_cluster_iam_role ? 1 : 0

  name        = var.cluster_iam_role_use_name_prefix ? null : local.cluster_iam_role_name
  name_prefix = var.cluster_iam_role_use_name_prefix ? try("${local.cluster_iam_role_name}-", local.cluster_iam_role_name) : null
  path        = var.cluster_iam_role_path

  assume_role_policy   = data.aws_iam_policy_document.cluster_assume_role_policy[0].json
  permissions_boundary = var.cluster_iam_role_permissions_boundary
  managed_policy_arns = [
    "${local.policy_arn_prefix}/AmazonEKSClusterPolicy",
    "${local.policy_arn_prefix}/AmazonEKSServicePolicy",
    "${local.policy_arn_prefix}/AmazonEKSVPCResourceController",
    aws_iam_policy.cluster_additional[0].arn,
  ]
  force_detach_policies = true

  tags = merge(var.tags, var.cluster_iam_role_tags)
}

data "aws_iam_policy_document" "cluster_assume_role_policy" {
  count = var.create && var.create_cluster_iam_role ? 1 : 0

  statement {
    sid     = "EKSClusterAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cluster_additional" {
  count = var.create && var.create_cluster_iam_role ? 1 : 0

  # Permissions required to create AWSServiceRoleForElasticLoadBalancing service-linked role by EKS during ELB provisioning
  statement {
    sid    = "ELBServiceLinkedRole"
    effect = "Allow"
    actions = [
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeAddresses"
    ]
    resources = ["*"]
  }

  # Deny permissions to logs:CreateLogGroup it is not needed since we create the log group ourselve in this module,
  # and it is causing trouble during cleanup/deletion
  statement {
    effect = "Deny"
    actions = [
      "logs:CreateLogGroup"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cluster_additional" {
  count = var.create && var.create_cluster_iam_role ? 1 : 0

  name        = var.cluster_iam_role_use_name_prefix ? null : local.cluster_iam_role_name
  name_prefix = var.cluster_iam_role_use_name_prefix ? try("${local.cluster_iam_role_name}-", local.cluster_iam_role_name) : null
  description = "Additional permissions for EKS cluster"
  policy      = data.aws_iam_policy_document.cluster_additional[0].json

  tags = merge(var.tags, var.cluster_iam_role_tags)
}
