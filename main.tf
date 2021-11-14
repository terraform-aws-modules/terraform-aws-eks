data "aws_partition" "current" {}

################################################################################
# Cluster
################################################################################

resource "aws_eks_cluster" "this" {
  count = var.create ? 1 : 0

  name                      = var.cluster_name
  role_arn                  = try(aws_iam_role.this[0].arn, var.iam_role_arn)
  version                   = var.cluster_version
  enabled_cluster_log_types = var.cluster_enabled_log_types

  vpc_config {
    security_group_ids      = var.create_cluster_security_group ? [aws_security_group.this[0].id] : [var.cluster_security_group_id]
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
    aws_iam_role_policy_attachment.this,
    aws_security_group_rule.cluster_egress_internet,
    # aws_security_group_rule.cluster_https_worker_ingress,
    aws_cloudwatch_log_group.this
  ]
}

resource "aws_cloudwatch_log_group" "this" {
  count = var.create && var.create_cloudwatch_log_group ? 1 : 0

  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  kms_key_id        = var.cloudwatch_log_group_kms_key_id

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

resource "aws_security_group_rule" "cluster_ingress_https_nodes" {
  for_each = local.create_cluster_sg ? merge(
    { for k, v in module.self_managed_node_group : k => v.security_group_id },
    { for k, v in module.eks_managed_node_group : k => v.security_group_id }
  ) : {}

  description              = "Allow pods to communicate with the EKS cluster API"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.this[0].id
  source_security_group_id = each.value
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
}

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
  iam_role_name     = coalesce(var.iam_role_name, "${var.cluster_name}-cluster")
  policy_arn_prefix = "arn:${data.aws_partition.current.partition}:iam::aws:policy"
}

data "aws_iam_policy_document" "assume_role_policy" {
  count = var.create && var.create_iam_role ? 1 : 0

  statement {
    sid     = "EKSClusterAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  count = var.create && var.create_iam_role ? 1 : 0

  name        = var.iam_role_use_name_prefix ? null : local.iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? try("${local.iam_role_name}-", local.iam_role_name) : null
  path        = var.iam_role_path

  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy[0].json
  permissions_boundary  = var.iam_role_permissions_boundary
  force_detach_policies = true

  inline_policy {
    name   = "additional-alb"
    policy = data.aws_iam_policy_document.additional[0].json
  }

  tags = merge(var.tags, var.iam_role_tags)
}

data "aws_iam_policy_document" "additional" {
  count = var.create && var.create_iam_role ? 1 : 0

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
    effect    = "Deny"
    actions   = ["logs:CreateLogGroup"]
    resources = ["*"]
  }
}

# Policies attached ref https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group
resource "aws_iam_role_policy_attachment" "this" {
  for_each = var.create && var.create_iam_role ? toset([
    "${local.policy_arn_prefix}/AmazonEKSClusterPolicy",
    "${local.policy_arn_prefix}/AmazonEKSVPCResourceController",
  ]) : toset([])

  policy_arn = each.value
  role       = aws_iam_role.this[0].name
}
