data "aws_service_principal" "capabilities" {
  count = var.create ? 1 : 0

  service_name = "capabilities"
}

################################################################################
# Capability
################################################################################

resource "aws_eks_capability" "this" {
  count = var.create ? 1 : 0

  region = var.region

  capability_name = var.name
  cluster_name    = var.cluster_name

  dynamic "configuration" {
    for_each = var.configuration != null ? [var.configuration] : []

    content {
      dynamic "argo_cd" {
        for_each = configuration.value.argo_cd != null ? [configuration.value.argo_cd] : []

        content {
          dynamic "aws_idc" {
            for_each = [argo_cd.value.aws_idc]

            content {
              idc_instance_arn = aws_idc.value.idc_instance_arn
              idc_region       = aws_idc.value.idc_region
            }
          }

          namespace = argo_cd.value.namespace

          dynamic "network_access" {
            for_each = argo_cd.value.network_access != null ? [argo_cd.value.network_access] : []

            content {
              vpce_ids = network_access.value.vpce_ids
            }
          }

          dynamic "rbac_role_mapping" {
            for_each = argo_cd.value.rbac_role_mapping != null ? argo_cd.value.rbac_role_mapping : []

            content {
              dynamic "identity" {
                for_each = rbac_role_mapping.value.identity

                content {
                  id   = identity.value.id
                  type = identity.value.type
                }
              }

              role = rbac_role_mapping.value.role
            }
          }
        }
      }
    }
  }

  delete_propagation_policy = var.delete_propagation_policy
  role_arn                  = var.create_iam_role ? aws_iam_role.this[0].arn : var.iam_role_arn
  type                      = var.type

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      update = timeouts.value.update
    }
  }

  tags = var.tags
}

################################################################################
# IAM Role
################################################################################

locals {
  create_iam_role = var.create && var.create_iam_role
  iam_role_name   = try(coalesce(var.iam_role_name, "${var.name}-${var.cluster_name}"), null)
}

data "aws_iam_policy_document" "assume_role" {
  count = local.create_iam_role ? 1 : 0

  override_policy_documents = var.iam_role_override_assume_policy_documents
  source_policy_documents   = var.iam_role_source_assume_policy_documents

  statement {
    sid = "EKSCapabilitiesAssumeRole"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]

    principals {
      type        = "Service"
      identifiers = [data.aws_service_principal.capabilities[0].name]
    }
  }
}

resource "aws_iam_role" "this" {
  count = local.create_iam_role ? 1 : 0

  name        = var.iam_role_use_name_prefix ? null : local.iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.iam_role_name}-" : null
  path        = var.iam_role_path
  description = coalesce(var.iam_role_description, "EKS Capability IAM role for ${var.type}/${var.name} capability")

  assume_role_policy    = data.aws_iam_policy_document.assume_role[0].json
  max_session_duration  = var.iam_role_max_session_duration
  permissions_boundary  = var.iam_role_permissions_boundary_arn
  force_detach_policies = true

  tags = merge(var.tags, var.iam_role_tags)
}

################################################################################
# IAM Role Policy
################################################################################

locals {
  create_iam_role_policy = local.create_iam_role && var.iam_policy_statements != null
  iam_policy_name        = try(coalesce(var.iam_policy_name, local.iam_role_name), null)
}

data "aws_iam_policy_document" "this" {
  count = local.create_iam_role_policy ? 1 : 0

  dynamic "statement" {
    for_each = var.iam_policy_statements != null ? var.iam_policy_statements : {}

    content {
      sid           = try(coalesce(statement.value.sid, statement.key))
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
  count = local.create_iam_role_policy ? 1 : 0

  name        = var.iam_policy_use_name_prefix ? null : local.iam_policy_name
  name_prefix = var.iam_policy_use_name_prefix ? "${local.iam_policy_name}-" : null
  path        = var.iam_policy_path
  description = coalesce(var.iam_policy_description, "IAM policy for EKS Capability ${var.type}/${var.name}")
  policy      = data.aws_iam_policy_document.this[0].json
}

resource "aws_iam_role_policy_attachment" "this" {
  count = local.create_iam_role_policy ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.this[0].arn
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = { for k, v in var.iam_role_policies : k => v if local.create_iam_role }

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}
