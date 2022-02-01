data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

################################################################################
# Kubernetes Namespace
################################################################################

locals {
  namespace_name = var.create ? coalesce(var.namespace_name, var.name) : ""
}

resource "kubernetes_namespace_v1" "this" {
  count = var.create && var.create_namespace ? 1 : 0

  metadata {
    name        = local.namespace_name
    annotations = merge(var.annotations, var.namespace_annotations)
    labels      = merge(var.labels, var.namespace_labels)
  }

  timeouts {
    delete = try(var.namespace_timeouts.delete, null)
  }
}

################################################################################
# Kubernetes Service Account
################################################################################

locals {
  service_account_name            = var.create ? coalesce(var.service_account_name, var.name) : ""
  service_account_role_annotation = var.create ? { "eks.amazonaws.com/role-arn" = aws_iam_role.this[0].arn } : {}
}

resource "kubernetes_service_account_v1" "this" {
  count = var.create && var.create_service_account ? 1 : 0

  automount_service_account_token = var.automount_service_account_token

  metadata {
    name      = local.service_account_name
    namespace = var.create && var.create_namespace ? kubernetes_namespace_v1.this[0].id : var.service_account_namespace
    annotations = merge(
      local.service_account_role_annotation,
      var.annotations,
      var.service_account_annotations
    )
    labels = merge(
      var.labels,
      var.service_account_labels
    )
  }

  dynamic "image_pull_secret" {
    for_each = toset(var.image_pull_secrets)
    content {
      name = image_pull_secret.value
    }
  }

  dynamic "secret" {
    for_each = toset(var.secrets)
    content {
      name = secret.value
    }
  }
}

################################################################################
# IAM Role
################################################################################

locals {
  oidc_issuer = var.create ? replace(data.aws_eks_cluster.this[0].identity[0].oidc[0].issuer, "https://", "") : ""

  iam_role_name = var.create ? coalesce(var.iam_role_name, var.name) : ""
}

data "aws_eks_cluster" "this" {
  count = var.create ? 1 : 0

  name = var.cluster_name
}

data "aws_iam_policy_document" "this" {
  count = var.create ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_issuer}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer}:sub"
      values   = ["system:serviceaccount:${local.namespace_name}:${local.service_account_name}"]
    }

    condition {
      test     = "StringLike"
      variable = "${local.oidc_issuer}:aud"
      values   = ["sts.${data.aws_partition.current.dns_suffix}"]
    }
  }
}

resource "aws_iam_role" "this" {
  count = var.create ? 1 : 0

  name                 = var.iam_role_use_name_prefix ? null : local.iam_role_name
  name_prefix          = var.iam_role_use_name_prefix ? "${local.iam_role_name}-" : null
  path                 = var.iam_role_path
  description          = var.iam_role_description
  max_session_duration = var.iam_role_max_session_duration

  assume_role_policy    = data.aws_iam_policy_document.this[0].json
  permissions_boundary  = var.iam_role_permissions_boundary
  force_detach_policies = true

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = { for k, v in var.iam_role_additional_policies : k => v if var.create }

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}
