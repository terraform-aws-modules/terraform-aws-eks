################################################################################
# Cluster
################################################################################
resource "aws_eks_cluster" "this" {
  count = var.create ? 1 : 0

  name                      = var.cluster_name
  enabled_cluster_log_types = var.cluster_enabled_log_types
  role_arn                  = try(aws_iam_role.cluster[0].arn, var.cluster_iam_role_arn)
  version                   = var.cluster_version

  vpc_config {
    security_group_ids      = compact([local.cluster_security_group_id])
    subnet_ids              = var.subnets
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
    create = var.cluster_create_timeout
    delete = var.cluster_delete_timeout
    update = var.cluster_update_timeout
  }

  depends_on = [
    aws_security_group_rule.cluster_egress_internet,
    aws_security_group_rule.cluster_https_worker_ingress,
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSServicePolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceControllerPolicy,
    aws_cloudwatch_log_group.this
  ]
}

resource "aws_cloudwatch_log_group" "this" {
  count = length(var.cluster_enabled_log_types) > 0 && var.create ? 1 : 0

  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.cluster_log_retention_in_days
  kms_key_id        = var.cluster_log_kms_key_id

  tags = var.tags
}

################################################################################
# Security Group
################################################################################

resource "aws_security_group" "cluster" {
  count = var.cluster_create_security_group && var.create ? 1 : 0

  name_prefix = var.cluster_name
  description = "EKS cluster security group."
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      "Name" = "${var.cluster_name}-eks_cluster_sg"
    },
  )
}

resource "aws_security_group_rule" "cluster_egress_internet" {
  count = var.cluster_create_security_group && var.create ? 1 : 0

  description       = "Allow cluster egress access to the Internet."
  protocol          = "-1"
  security_group_id = local.cluster_security_group_id
  cidr_blocks       = var.cluster_egress_cidrs
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "cluster_https_worker_ingress" {
  count = var.cluster_create_security_group && var.create && var.worker_create_security_group ? 1 : 0

  description              = "Allow pods to communicate with the EKS cluster API."
  protocol                 = "tcp"
  security_group_id        = local.cluster_security_group_id
  source_security_group_id = local.worker_security_group_id
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster_private_access_cidrs_source" {
  for_each = var.create && var.cluster_create_endpoint_private_access_sg_rule && var.cluster_endpoint_private_access && var.cluster_endpoint_private_access_cidrs != null ? toset(var.cluster_endpoint_private_access_cidrs) : []

  description = "Allow private K8S API ingress from custom CIDR source."
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = [each.value]

  security_group_id = aws_eks_cluster.this[0].vpc_config[0].cluster_security_group_id
}

resource "aws_security_group_rule" "cluster_private_access_sg_source" {
  count = var.create && var.cluster_create_endpoint_private_access_sg_rule && var.cluster_endpoint_private_access && var.cluster_endpoint_private_access_sg != null ? length(var.cluster_endpoint_private_access_sg) : 0

  description              = "Allow private K8S API ingress from custom Security Groups source."
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = var.cluster_endpoint_private_access_sg[count.index]

  security_group_id = aws_eks_cluster.this[0].vpc_config[0].cluster_security_group_id
}

################################################################################
# Kubeconfig
################################################################################

resource "local_file" "kubeconfig" {
  count = var.write_kubeconfig && var.create ? 1 : 0

  content              = local.kubeconfig
  filename             = substr(var.kubeconfig_output_path, -1, 1) == "/" ? "${var.kubeconfig_output_path}kubeconfig_${var.cluster_name}" : var.kubeconfig_output_path
  file_permission      = var.kubeconfig_file_permission
  directory_permission = "0755"
}

################################################################################
# IRSA
################################################################################

# Enable IAM Roles for EKS Service-Accounts (IRSA).
# The Root CA Thumbprint for an OpenID Connect Identity Provider is currently
# Being passed as a default value which is the same for all regions and
# Is valid until (Jun 28 17:39:16 2034 GMT).
# https://crt.sh/?q=9E99A48A9960B14926BB7F3B02E22DA2B0AB7280
# https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc_verify-thumbprint.html
# https://github.com/terraform-providers/terraform-provider-aws/issues/10104

# TODO - update to use TLS data source and drop hacks
resource "aws_iam_openid_connect_provider" "oidc_provider" {
  count = var.enable_irsa && var.create ? 1 : 0

  client_id_list  = local.client_id_list
  thumbprint_list = [var.eks_oidc_root_ca_thumbprint]
  url             = local.cluster_oidc_issuer_url

  tags = merge(
    {
      Name = "${var.cluster_name}-eks-irsa"
    },
    var.tags
  )
}

################################################################################
# Cluster IAM Role, Permissions, & Policies
################################################################################

locals {
  cluster_iam_role_name = try(var.cluster_iam_role_name, var.cluster_name)
}

resource "aws_iam_role" "cluster" {
  count = var.create_cluster_iam_role && var.create ? 1 : 0

  name                  = var.cluster_iam_role_use_name_prefix ? null : local.cluster_iam_role_name
  name_prefix           = var.cluster_iam_role_use_name_prefix ? "${local.cluster_iam_role_name}-" : null
  assume_role_policy    = data.aws_iam_policy_document.cluster_assume_role_policy.json
  permissions_boundary  = var.cluster_iam_role_permissions_boundary
  path                  = var.cluster_iam_role_path
  force_detach_policies = true

  tags = merge(var.tags, var.cluster_role_iam_tags)
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  count = var.create_cluster_iam_role && var.create ? 1 : 0

  role       = aws_iam_role.cluster.name
  policy_arn = "${local.policy_arn_prefix}/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSServicePolicy" {
  count = var.create_cluster_iam_role && var.create ? 1 : 0

  role       = aws_iam_role.cluster.name
  policy_arn = "${local.policy_arn_prefix}/AmazonEKSServicePolicy"
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSVPCResourceControllerPolicy" {
  count = var.create_cluster_iam_role && var.create ? 1 : 0

  role       = aws_iam_role.cluster.name
  policy_arn = "${local.policy_arn_prefix}/AmazonEKSVPCResourceController"
}

data "aws_iam_policy_document" "cluster_additional" {
  count = var.create_cluster_iam_role && var.create ? 1 : 0

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
  count = var.create_cluster_iam_role && var.create ? 1 : 0

  name        = var.cluster_iam_role_use_name_prefix ? null : local.cluster_iam_role_name
  name_prefix = var.cluster_iam_role_use_name_prefix ? "${local.cluster_iam_role_name}-" : null
  description = "Additional permissions for EKS cluster"
  policy      = data.aws_iam_policy_document.cluster_additional[0].json

  tags = merge(var.tags, var.cluster_role_iam_tags)
}

resource "aws_iam_role_policy_attachment" "cluster_additional" {
  count = var.create_cluster_iam_role && var.create ? 1 : 0

  role       = aws_iam_role.cluster.name
  policy_arn = aws_iam_policy.cluster_additional[0].arn
}
