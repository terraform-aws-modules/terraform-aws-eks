data "aws_region" "current" {
  count = var.create ? 1 : 0

  region = var.region
}
data "aws_partition" "current" {
  count = var.create && var.partition == "" ? 1 : 0
}
data "aws_caller_identity" "current" {
  count = var.create && var.account_id == "" ? 1 : 0
}

locals {
  account_id = try(data.aws_caller_identity.current[0].account_id, var.account_id)
  partition  = try(data.aws_partition.current[0].partition, var.partition)
  region     = try(data.aws_region.current[0].region, "")
}

locals {
  create_iam_role = var.create && var.create_iam_role

  iam_role_name          = coalesce(var.iam_role_name, var.name, "fargate-profile")
  iam_role_policy_prefix = "arn:${local.partition}:iam::aws:policy"

  ipv4_cni_policy = { for k, v in {
    AmazonEKS_CNI_Policy = "${local.iam_role_policy_prefix}/AmazonEKS_CNI_Policy"
  } : k => v if var.iam_role_attach_cni_policy && var.cluster_ip_family == "ipv4" }
  ipv6_cni_policy = { for k, v in {
    AmazonEKS_CNI_IPv6_Policy = "arn:${local.partition}:iam::${local.account_id}:policy/AmazonEKS_CNI_IPv6_Policy"
  } : k => v if var.iam_role_attach_cni_policy && var.cluster_ip_family == "ipv6" }
}

################################################################################
# IAM Role
################################################################################

data "aws_iam_policy_document" "assume_role_policy" {
  count = local.create_iam_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks-fargate-pods.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"

      values = [
        "arn:${local.partition}:eks:${local.region}:${local.account_id}:fargateprofile/${var.cluster_name}/*",
      ]
    }
  }
}

resource "aws_iam_role" "this" {
  count = local.create_iam_role ? 1 : 0

  name        = var.iam_role_use_name_prefix ? null : local.iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.iam_role_name}-" : null
  path        = var.iam_role_path
  description = var.iam_role_description

  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy[0].json
  permissions_boundary  = var.iam_role_permissions_boundary
  force_detach_policies = true

  tags = merge(var.tags, var.iam_role_tags)
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = { for k, v in merge(
    {
      AmazonEKSFargatePodExecutionRolePolicy = "${local.iam_role_policy_prefix}/AmazonEKSFargatePodExecutionRolePolicy"
    },
    local.ipv4_cni_policy,
    local.ipv6_cni_policy
  ) : k => v if local.create_iam_role }

  policy_arn = each.value
  role       = aws_iam_role.this[0].name
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = { for k, v in var.iam_role_additional_policies : k => v if local.create_iam_role }

  policy_arn = each.value
  role       = aws_iam_role.this[0].name
}

################################################################################
# IAM Role Policy
################################################################################

locals {
  create_iam_role_policy = local.create_iam_role && var.create_iam_role_policy && var.iam_role_policy_statements != null
}

data "aws_iam_policy_document" "role" {
  count = local.create_iam_role_policy ? 1 : 0

  dynamic "statement" {
    for_each = var.iam_role_policy_statements != null ? var.iam_role_policy_statements : []

    content {
      sid           = statement.value.sid
      actions       = statement.value.actions
      not_actions   = statement.value.not_actions
      effect        = statement.value.effect
      resources     = statement.value.resources
      not_resources = statement.value.not_resources

      dynamic "principals" {
        for_each = statement.value.principals != null ? statement.value.principals : []

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = statement.value.not_principals != null ? statement.value.not_principals : []

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = statement.value.condition != null ? statement.value.condition : []

        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }
}

resource "aws_iam_role_policy" "this" {
  count = local.create_iam_role_policy ? 1 : 0

  name        = var.iam_role_use_name_prefix ? null : local.iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.iam_role_name}-" : null
  policy      = data.aws_iam_policy_document.role[0].json
  role        = aws_iam_role.this[0].id
}

################################################################################
# Fargate Profile
################################################################################

resource "aws_eks_fargate_profile" "this" {
  count = var.create ? 1 : 0

  region = var.region

  cluster_name           = var.cluster_name
  fargate_profile_name   = var.name
  pod_execution_role_arn = var.create_iam_role ? aws_iam_role.this[0].arn : var.iam_role_arn
  subnet_ids             = var.subnet_ids

  dynamic "selector" {
    for_each = var.selectors != null ? var.selectors : []

    content {
      namespace = selector.value.namespace
      labels    = selector.value.labels
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      create = var.timeouts.create
      delete = var.timeouts.delete
    }
  }

  tags = var.tags
}
