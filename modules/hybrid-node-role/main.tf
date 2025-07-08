data "aws_partition" "current" {
  count = var.create ? 1 : 0
}

locals {
  partition = try(data.aws_partition.current[0].partition, "")
}

################################################################################
# Node IAM Role
################################################################################

data "aws_iam_policy_document" "assume_role" {
  count = var.create ? 1 : 0

  # SSM
  dynamic "statement" {
    for_each = var.enable_ira ? [] : [1]

    content {
      actions = [
        "sts:AssumeRole",
        "sts:TagSession",
      ]

      principals {
        type        = "Service"
        identifiers = ["ssm.amazonaws.com"]
      }
    }
  }

  # IAM Roles Anywhere
  dynamic "statement" {
    for_each = var.enable_ira ? [1] : []

    content {
      actions = [
        "sts:TagSession",
        "sts:SetSourceIdentity",
      ]

      principals {
        type        = "AWS"
        identifiers = [aws_iam_role.intermediate[0].arn]
      }
    }
  }

  dynamic "statement" {
    for_each = var.enable_ira ? [1] : []

    content {
      actions = [
        "sts:AssumeRole",
        "sts:TagSession",
      ]

      principals {
        type        = "AWS"
        identifiers = [aws_iam_role.intermediate[0].arn]
      }

      condition {
        test     = "StringEquals"
        variable = "sts:RoleSessionName"
        values   = ["$${aws:PrincipalTag/x509Subject/CN}"]
      }
    }
  }
}

resource "aws_iam_role" "this" {
  count = var.create ? 1 : 0

  name        = var.use_name_prefix ? null : var.name
  name_prefix = var.use_name_prefix ? "${var.name}-" : null
  path        = var.path
  description = var.description

  assume_role_policy    = data.aws_iam_policy_document.assume_role[0].json
  max_session_duration  = var.max_session_duration
  permissions_boundary  = var.permissions_boundary_arn
  force_detach_policies = true

  tags = var.tags
}

################################################################################
# Node IAM Role Policy
################################################################################

data "aws_iam_policy_document" "this" {
  count = var.create ? 1 : 0

  statement {
    actions = [
      "ssm:DeregisterManagedInstance",
      "ssm:DescribeInstanceInformation",
    ]

    resources = ["*"]
  }

  statement {
    actions   = ["eks:DescribeCluster"]
    resources = var.cluster_arns
  }

  dynamic "statement" {
    for_each = var.enable_pod_identity ? [1] : []

    content {
      actions   = ["eks-auth:AssumeRoleForPodIdentity"]
      resources = ["*"]
    }
  }

  dynamic "statement" {
    for_each = var.policy_statements != null ? var.policy_statements : []

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

resource "aws_iam_policy" "this" {
  count = var.create ? 1 : 0

  name        = var.policy_use_name_prefix ? null : var.policy_name
  name_prefix = var.policy_use_name_prefix ? "${var.policy_name}-" : null
  path        = var.policy_path
  description = var.policy_description
  policy      = data.aws_iam_policy_document.this[0].json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = { for k, v in merge(
    {
      node                               = try(aws_iam_policy.this[0].arn, null)
      AmazonSSMManagedInstanceCore       = "arn:${local.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
      AmazonEC2ContainerRegistryPullOnly = "arn:${local.partition}:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
    },
    var.policies
  ) : k => v if var.create }

  policy_arn = each.value
  role       = aws_iam_role.this[0].name
}

################################################################################
# Roles Anywhere Profile
################################################################################

locals {
  enable_ira = var.create && var.enable_ira
}

resource "aws_rolesanywhere_profile" "this" {
  count = local.enable_ira ? 1 : 0

  duration_seconds            = var.ira_profile_duration_seconds
  managed_policy_arns         = var.ira_profile_managed_policy_arns
  name                        = try(coalesce(var.ira_profile_name, var.name), null)
  require_instance_properties = var.ira_profile_require_instance_properties
  role_arns                   = [aws_iam_role.intermediate[0].arn]
  session_policy              = var.ira_profile_session_policy

  tags = var.tags
}

################################################################################
# Roles Anywhere Trust Anchor
################################################################################

resource "aws_rolesanywhere_trust_anchor" "this" {
  count = local.enable_ira ? 1 : 0

  name = try(coalesce(var.ira_trust_anchor_name, var.name), null)

  dynamic "notification_settings" {
    for_each = var.ira_trust_anchor_notification_settings != null ? var.ira_trust_anchor_notification_settings : []

    content {
      channel   = try(notification_settings.value.channel, null)
      enabled   = try(notification_settings.value.enabled, null)
      event     = try(notification_settings.value.event, null)
      threshold = try(notification_settings.value.threshold, null)
    }
  }

  source {
    source_data {
      acm_pca_arn           = var.ira_trust_anchor_acm_pca_arn
      x509_certificate_data = var.ira_trust_anchor_x509_certificate_data
    }
    source_type = var.ira_trust_anchor_source_type
  }

  tags = var.tags
}

################################################################################
# Intermediate IAM Role
################################################################################

data "aws_iam_policy_document" "intermediate_assume_role" {
  count = local.enable_ira ? 1 : 0

  statement {
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
      "sts:SetSourceIdentity",
    ]

    principals {
      type        = "Service"
      identifiers = ["rolesanywhere.amazonaws.com"]
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = concat(var.trust_anchor_arns, aws_rolesanywhere_trust_anchor.this[*].arn)
    }
  }
}

locals {
  intermediate_role_use_name_prefix = coalesce(var.intermediate_role_use_name_prefix, var.use_name_prefix)
  intermediate_role_name            = coalesce(var.intermediate_role_name, "${var.name}-inter")
}

resource "aws_iam_role" "intermediate" {
  count = local.enable_ira ? 1 : 0

  name        = local.intermediate_role_use_name_prefix ? null : local.intermediate_role_name
  name_prefix = local.intermediate_role_use_name_prefix ? "${local.intermediate_role_name}-" : null
  path        = coalesce(var.intermediate_role_path, var.path)
  description = var.intermediate_role_description

  assume_role_policy    = data.aws_iam_policy_document.intermediate_assume_role[0].json
  max_session_duration  = var.max_session_duration
  permissions_boundary  = var.permissions_boundary_arn
  force_detach_policies = true

  tags = var.tags
}

################################################################################
# Intermediate IAM Role Policy
################################################################################

data "aws_iam_policy_document" "intermediate" {
  count = local.enable_ira ? 1 : 0

  statement {
    actions   = ["eks:DescribeCluster"]
    resources = var.cluster_arns
  }

  dynamic "statement" {
    for_each = var.intermediate_policy_statements != null ? var.intermediate_policy_statements : []

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

locals {
  intermediate_policy_use_name_prefix = coalesce(var.intermediate_policy_use_name_prefix, var.policy_use_name_prefix)
  intermediate_policy_name            = coalesce(var.intermediate_policy_name, var.policy_name)
}

resource "aws_iam_policy" "intermediate" {
  count = local.enable_ira ? 1 : 0

  name        = local.intermediate_policy_use_name_prefix ? null : local.intermediate_policy_name
  name_prefix = local.intermediate_policy_use_name_prefix ? "${local.intermediate_policy_name}-" : null
  path        = var.policy_path
  description = var.policy_description
  policy      = data.aws_iam_policy_document.intermediate[0].json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "intermediate" {
  for_each = { for k, v in merge(
    {
      intermediate                       = try(aws_iam_policy.intermediate[0].arn, null)
      AmazonEC2ContainerRegistryPullOnly = "arn:${local.partition}:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
    },
    var.intermediate_role_policies
  ) : k => v if local.enable_ira }

  policy_arn = each.value
  role       = aws_iam_role.this[0].name
}
