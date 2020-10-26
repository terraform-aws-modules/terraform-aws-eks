locals {
  create_eks              = var.create_eks && length(var.fargate_profiles) > 0
  pod_execution_role_arn  = var.create_fargate_pod_execution_role ? element(concat(aws_iam_role.eks_fargate_pod.*.arn, list("")), 0) : element(concat(data.aws_iam_role.custom_fargate_iam_role.*.arn, list("")), 0)
  pod_execution_role_name = var.create_fargate_pod_execution_role ? element(concat(aws_iam_role.eks_fargate_pod.*.name, list("")), 0) : element(concat(data.aws_iam_role.custom_fargate_iam_role.*.name, list("")), 0)
}

resource "aws_iam_role" "eks_fargate_pod" {
  count              = local.create_eks && var.create_fargate_pod_execution_role ? 1 : 0
  name_prefix        = format("%s-fargate", var.cluster_name)
  assume_role_policy = data.aws_iam_policy_document.eks_fargate_pod_assume_role[0].json
  tags               = var.tags
  path               = var.iam_path
}

resource "aws_iam_role_policy_attachment" "eks_fargate_pod" {
  count      = local.create_eks && var.create_fargate_pod_execution_role ? 1 : 0
  policy_arn = "${var.iam_policy_arn_prefix}/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.eks_fargate_pod[0].name
}

resource "aws_eks_fargate_profile" "this" {
  for_each               = local.create_eks ? var.fargate_profiles : {}
  cluster_name           = var.cluster_name
  fargate_profile_name   = lookup(each.value, "name", format("%s-fargate-%s", var.cluster_name, replace(each.key, "_", "-")))
  pod_execution_role_arn = local.pod_execution_role_arn
  subnet_ids             = var.subnets
  tags                   = var.tags

  selector {
    namespace = each.value.namespace
    labels    = each.value.labels
  }

  depends_on = [var.eks_depends_on]
}
