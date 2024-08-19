data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  region     = data.aws_region.current.name
}

################################################################################
# Karpenter controller IAM Role
################################################################################

locals {
  create_iam_role        = var.create && var.create_iam_role
  irsa_oidc_provider_url = replace(var.irsa_oidc_provider_arn, "/^(.*provider/)/", "")
}

data "aws_iam_policy_document" "controller_assume_role" {
  count = local.create_iam_role ? 1 : 0

  # Pod Identity
  dynamic "statement" {
    for_each = var.enable_pod_identity ? [1] : []

    content {
      actions = [
        "sts:AssumeRole",
        "sts:TagSession",
      ]

      principals {
        type        = "Service"
        identifiers = ["pods.eks.amazonaws.com"]
      }
    }
  }

  # IAM Roles for Service Accounts (IRSA)
  dynamic "statement" {
    for_each = var.enable_irsa ? [1] : []

    content {
      actions = ["sts:AssumeRoleWithWebIdentity"]

      principals {
        type        = "Federated"
        identifiers = [var.irsa_oidc_provider_arn]
      }

      condition {
        test     = var.irsa_assume_role_condition_test
        variable = "${local.irsa_oidc_provider_url}:sub"
        values   = [for sa in var.irsa_namespace_service_accounts : "system:serviceaccount:${sa}"]
      }

      # https://aws.amazon.com/premiumsupport/knowledge-center/eks-troubleshoot-oidc-and-irsa/?nc1=h_ls
      condition {
        test     = var.irsa_assume_role_condition_test
        variable = "${local.irsa_oidc_provider_url}:aud"
        values   = ["sts.amazonaws.com"]
      }
    }
  }
}

resource "aws_iam_role" "controller" {
  count = local.create_iam_role ? 1 : 0

  name        = var.iam_role_use_name_prefix ? null : var.iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? "${var.iam_role_name}-" : null
  path        = var.iam_role_path
  description = var.iam_role_description

  assume_role_policy    = data.aws_iam_policy_document.controller_assume_role[0].json
  max_session_duration  = var.iam_role_max_session_duration
  permissions_boundary  = var.iam_role_permissions_boundary_arn
  force_detach_policies = true

  tags = merge(var.tags, var.iam_role_tags)
}

data "aws_iam_policy_document" "controller" {
  count = local.create_iam_role ? 1 : 0

  source_policy_documents = var.enable_v1_permissions ? [data.aws_iam_policy_document.v1[0].json] : [data.aws_iam_policy_document.v033[0].json]
}

resource "aws_iam_policy" "controller" {
  count = local.create_iam_role ? 1 : 0

  name        = var.iam_policy_use_name_prefix ? null : var.iam_policy_name
  name_prefix = var.iam_policy_use_name_prefix ? "${var.iam_policy_name}-" : null
  path        = var.iam_policy_path
  description = var.iam_policy_description
  policy      = data.aws_iam_policy_document.controller[0].json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "controller" {
  count = local.create_iam_role ? 1 : 0

  role       = aws_iam_role.controller[0].name
  policy_arn = aws_iam_policy.controller[0].arn
}

resource "aws_iam_role_policy_attachment" "controller_additional" {
  for_each = { for k, v in var.iam_role_policies : k => v if local.create_iam_role }

  role       = aws_iam_role.controller[0].name
  policy_arn = each.value
}

################################################################################
# Pod Identity Association
################################################################################

resource "aws_eks_pod_identity_association" "karpenter" {
  count = local.create_iam_role && var.enable_pod_identity && var.create_pod_identity_association ? 1 : 0

  cluster_name    = var.cluster_name
  namespace       = var.namespace
  service_account = var.service_account
  role_arn        = aws_iam_role.controller[0].arn

  tags = var.tags
}

################################################################################
# Node Termination Queue
################################################################################

locals {
  enable_spot_termination = var.create && var.enable_spot_termination

  queue_name = coalesce(var.queue_name, "Karpenter-${var.cluster_name}")
}

resource "aws_sqs_queue" "this" {
  count = local.enable_spot_termination ? 1 : 0

  name                              = local.queue_name
  message_retention_seconds         = 300
  sqs_managed_sse_enabled           = var.queue_managed_sse_enabled ? var.queue_managed_sse_enabled : null
  kms_master_key_id                 = var.queue_kms_master_key_id
  kms_data_key_reuse_period_seconds = var.queue_kms_data_key_reuse_period_seconds

  tags = var.tags
}

data "aws_iam_policy_document" "queue" {
  count = local.enable_spot_termination ? 1 : 0

  statement {
    sid       = "SqsWrite"
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.this[0].arn]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "sqs.amazonaws.com",
      ]
    }
  }
  statement {
    sid    = "DenyHTTP"
    effect = "Deny"
    actions = [
      "sqs:*"
    ]
    resources = [aws_sqs_queue.this[0].arn]
    condition {
      test     = "StringEquals"
      variable = "aws:SecureTransport"
      values = [
        "false"
      ]
    }
    principals {
      type = "*"
      identifiers = [
        "*"
      ]
    }
  }
}

resource "aws_sqs_queue_policy" "this" {
  count = local.enable_spot_termination ? 1 : 0

  queue_url = aws_sqs_queue.this[0].url
  policy    = data.aws_iam_policy_document.queue[0].json
}

################################################################################
# Node Termination Event Rules
################################################################################

locals {
  events = {
    health_event = {
      name        = "HealthEvent"
      description = "Karpenter interrupt - AWS health event"
      event_pattern = {
        source      = ["aws.health"]
        detail-type = ["AWS Health Event"]
      }
    }
    spot_interrupt = {
      name        = "SpotInterrupt"
      description = "Karpenter interrupt - EC2 spot instance interruption warning"
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Spot Instance Interruption Warning"]
      }
    }
    instance_rebalance = {
      name        = "InstanceRebalance"
      description = "Karpenter interrupt - EC2 instance rebalance recommendation"
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Instance Rebalance Recommendation"]
      }
    }
    instance_state_change = {
      name        = "InstanceStateChange"
      description = "Karpenter interrupt - EC2 instance state-change notification"
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Instance State-change Notification"]
      }
    }
  }
}

resource "aws_cloudwatch_event_rule" "this" {
  for_each = { for k, v in local.events : k => v if local.enable_spot_termination }

  name_prefix   = "${var.rule_name_prefix}${each.value.name}-"
  description   = each.value.description
  event_pattern = jsonencode(each.value.event_pattern)

  tags = merge(
    { "ClusterName" : var.cluster_name },
    var.tags,
  )
}

resource "aws_cloudwatch_event_target" "this" {
  for_each = { for k, v in local.events : k => v if local.enable_spot_termination }

  rule      = aws_cloudwatch_event_rule.this[each.key].name
  target_id = "KarpenterInterruptionQueueTarget"
  arn       = aws_sqs_queue.this[0].arn
}

################################################################################
# Node IAM Role
# This is used by the nodes launched by Karpenter
################################################################################

locals {
  create_node_iam_role = var.create && var.create_node_iam_role

  node_iam_role_name          = coalesce(var.node_iam_role_name, "Karpenter-${var.cluster_name}")
  node_iam_role_policy_prefix = "arn:${local.partition}:iam::aws:policy"

  ipv4_cni_policy = { for k, v in {
    AmazonEKS_CNI_Policy = "${local.node_iam_role_policy_prefix}/AmazonEKS_CNI_Policy"
  } : k => v if var.node_iam_role_attach_cni_policy && var.cluster_ip_family == "ipv4" }
  ipv6_cni_policy = { for k, v in {
    AmazonEKS_CNI_IPv6_Policy = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:policy/AmazonEKS_CNI_IPv6_Policy"
  } : k => v if var.node_iam_role_attach_cni_policy && var.cluster_ip_family == "ipv6" }
}

data "aws_iam_policy_document" "node_assume_role" {
  count = local.create_node_iam_role ? 1 : 0

  statement {
    sid     = "EKSNodeAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "node" {
  count = local.create_node_iam_role ? 1 : 0

  name        = var.node_iam_role_use_name_prefix ? null : local.node_iam_role_name
  name_prefix = var.node_iam_role_use_name_prefix ? "${local.node_iam_role_name}-" : null
  path        = var.node_iam_role_path
  description = var.node_iam_role_description

  assume_role_policy    = data.aws_iam_policy_document.node_assume_role[0].json
  max_session_duration  = var.node_iam_role_max_session_duration
  permissions_boundary  = var.node_iam_role_permissions_boundary
  force_detach_policies = true

  tags = merge(var.tags, var.node_iam_role_tags)
}

# Policies attached ref https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group
resource "aws_iam_role_policy_attachment" "node" {
  for_each = { for k, v in merge(
    {
      AmazonEKSWorkerNodePolicy          = "${local.node_iam_role_policy_prefix}/AmazonEKSWorkerNodePolicy"
      AmazonEC2ContainerRegistryReadOnly = "${local.node_iam_role_policy_prefix}/AmazonEC2ContainerRegistryReadOnly"
    },
    local.ipv4_cni_policy,
    local.ipv6_cni_policy
  ) : k => v if local.create_node_iam_role }

  policy_arn = each.value
  role       = aws_iam_role.node[0].name
}

resource "aws_iam_role_policy_attachment" "node_additional" {
  for_each = { for k, v in var.node_iam_role_additional_policies : k => v if local.create_node_iam_role }

  policy_arn = each.value
  role       = aws_iam_role.node[0].name
}

################################################################################
# Access Entry
################################################################################

resource "aws_eks_access_entry" "node" {
  count = var.create && var.create_access_entry ? 1 : 0

  cluster_name  = var.cluster_name
  principal_arn = var.create_node_iam_role ? aws_iam_role.node[0].arn : var.node_iam_role_arn
  type          = var.access_entry_type

  tags = var.tags

  depends_on = [
    # If we try to add this too quickly, it fails. So .... we wait
    aws_sqs_queue_policy.this,
  ]
}

################################################################################
# Node IAM Instance Profile
# This is used by the nodes launched by Karpenter
# Starting with Karpenter 0.32 this is no longer required as Karpenter will
# create the Instance Profile
################################################################################

locals {
  external_role_name = try(replace(var.node_iam_role_arn, "/^(.*role/)/", ""), null)
}

resource "aws_iam_instance_profile" "this" {
  count = var.create && var.create_instance_profile ? 1 : 0

  name        = var.node_iam_role_use_name_prefix ? null : local.node_iam_role_name
  name_prefix = var.node_iam_role_use_name_prefix ? "${local.node_iam_role_name}-" : null
  path        = var.node_iam_role_path
  role        = var.create_node_iam_role ? aws_iam_role.node[0].name : local.external_role_name

  tags = merge(var.tags, var.node_iam_role_tags)
}
