locals {
  create_eks = var.create_eks && length(var.fargate_profiles) > 0

  policy_arn_prefix = "arn:${data.aws_partition.current.partition}:iam::aws:policy"

  pod_execution_role_arn  = var.create_fargate_pod_execution_role ? element(concat(aws_iam_role.eks_fargate_pod.*.arn, [""]), 0) : element(concat(data.aws_iam_role.custom_fargate_iam_role.*.arn, [""]), 0)
  pod_execution_role_name = var.create_fargate_pod_execution_role ? element(concat(aws_iam_role.eks_fargate_pod.*.name, [""]), 0) : element(concat(data.aws_iam_role.custom_fargate_iam_role.*.name, [""]), 0)

  fargate_profiles_expanded = { for k, v in var.fargate_profiles : k => merge(
    v,
    { tags = merge(var.tags, lookup(v, "tags", {})) },
  ) if var.create_eks }
}

data "aws_partition" "current" {}

data "aws_iam_policy_document" "eks_fargate_pod_assume_role" {
  count = local.create_eks && var.create_fargate_pod_execution_role ? 1 : 0
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks-fargate-pods.amazonaws.com"]
    }
  }
}

data "aws_iam_role" "custom_fargate_iam_role" {
  count = local.create_eks && !var.create_fargate_pod_execution_role ? 1 : 0
  name  = var.fargate_pod_execution_role_name
}

resource "aws_iam_role" "eks_fargate_pod" {
  count                = local.create_eks && var.create_fargate_pod_execution_role ? 1 : 0
  name_prefix          = format("%s-fargate", substr(var.cluster_name, 0, 24))
  assume_role_policy   = data.aws_iam_policy_document.eks_fargate_pod_assume_role[0].json
  permissions_boundary = var.permissions_boundary
  tags                 = var.tags
  path                 = var.iam_path
}

resource "aws_iam_role_policy_attachment" "eks_fargate_pod" {
  count      = local.create_eks && var.create_fargate_pod_execution_role ? 1 : 0
  policy_arn = "${local.policy_arn_prefix}/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.eks_fargate_pod[0].name
}

resource "aws_eks_fargate_profile" "this" {
  for_each               = local.create_eks ? local.fargate_profiles_expanded : {}
  cluster_name           = var.cluster_name
  fargate_profile_name   = lookup(each.value, "name", format("%s-fargate-%s", var.cluster_name, replace(each.key, "_", "-")))
  pod_execution_role_arn = local.pod_execution_role_arn
  subnet_ids             = lookup(each.value, "subnets", var.subnets)
  tags                   = each.value.tags

  dynamic "selector" {
    for_each = each.value.selectors
    content {
      namespace = selector.value["namespace"]
      labels    = lookup(selector.value, "labels", {})
    }
  }
}
