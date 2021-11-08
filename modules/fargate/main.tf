data "aws_partition" "current" {}

data "aws_iam_policy_document" "eks_fargate_pod_assume_role" {
  count = var.create && var.create_fargate_pod_execution_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks-fargate-pods.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_fargate_pod" {
  count = var.create && var.create_fargate_pod_execution_role ? 1 : 0

  name_prefix = format("%s-fargate", substr(var.cluster_name, 0, 24))
  path        = var.iam_path

  assume_role_policy   = data.aws_iam_policy_document.eks_fargate_pod_assume_role[0].json
  permissions_boundary = var.permissions_boundary
  managed_policy_arns = [
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy",
  ]
  force_detach_policies = true

  tags = var.tags
}

resource "aws_eks_fargate_profile" "this" {
  for_each = var.create ? var.fargate_profiles : {}

  cluster_name           = var.cluster_name
  fargate_profile_name   = lookup(each.value, "name", format("%s-fargate-%s", var.cluster_name, replace(each.key, "_", "-")))
  pod_execution_role_arn = var.create_fargate_pod_execution_role ? aws_iam_role.eks_fargate_pod[0].arn : var.fargate_pod_execution_role_arn
  subnet_ids             = lookup(each.value, "subnet_ids", var.subnet_ids)

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
