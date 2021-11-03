locals {
  create_eks = var.create_eks && length(var.fargate_profiles) > 0

  pod_execution_role_arn  = coalescelist(aws_iam_role.eks_fargate_pod.*.arn, data.aws_iam_role.custom_fargate_iam_role.*.arn, [""])[0]
  pod_execution_role_name = coalescelist(aws_iam_role.eks_fargate_pod.*.name, data.aws_iam_role.custom_fargate_iam_role.*.name, [""])[0]

  fargate_profiles = { for k, v in var.fargate_profiles : k => v if var.create_eks }
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

  name = var.fargate_pod_execution_role_name
}

resource "aws_iam_role" "eks_fargate_pod" {
  count = local.create_eks && var.create_fargate_pod_execution_role ? 1 : 0

  name_prefix          = format("%s-fargate", substr(var.cluster_name, 0, 24))
  assume_role_policy   = data.aws_iam_policy_document.eks_fargate_pod_assume_role[0].json
  permissions_boundary = var.permissions_boundary
  tags                 = var.tags
  path                 = var.iam_path
}

resource "aws_iam_role_policy_attachment" "eks_fargate_pod" {
  count = local.create_eks && var.create_fargate_pod_execution_role ? 1 : 0

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.eks_fargate_pod[0].name
}

resource "aws_eks_fargate_profile" "this" {
  for_each = local.fargate_profiles

  cluster_name           = var.cluster_name
  fargate_profile_name   = lookup(each.value, "name", format("%s-fargate-%s", var.cluster_name, replace(each.key, "_", "-")))
  pod_execution_role_arn = local.pod_execution_role_arn
  subnet_ids             = lookup(each.value, "subnets", var.subnets)

  dynamic "selector" {
    for_each = each.value.selectors

    content {
      namespace = selector.value["namespace"]
      labels    = lookup(selector.value, "labels", {})
    }
  }

  timeouts {
    create = try(each.value["timeouts"].create, null)
    delete = try(each.value["timeouts"].delete, null)
  }

  tags = merge(var.tags, lookup(each.value, "tags", {}))
}
