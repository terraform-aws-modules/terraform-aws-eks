# EKS Fargate Pod Execution Role

data "aws_iam_policy_document" "eks_fargate_pod_assume_role" {
  count = var.create_eks && var.create_fargate_pod_execution_role ? 1 : 0
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
  count              = var.create_eks && var.create_fargate_pod_execution_role ? 1 : 0
  name               = format("%s-fargate", var.cluster_name)
  assume_role_policy = data.aws_iam_policy_document.eks_fargate_pod_assume_role[0].json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "eks_fargate_pod" {
  count      = var.create_eks && var.create_fargate_pod_execution_role ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.eks_fargate_pod[0].name
}


# EKS Fargate profiles

resource "aws_eks_fargate_profile" "this" {
  for_each               = var.create_eks ? var.fargate_profiles : {}
  cluster_name           = var.cluster_name
  fargate_profile_name   = lookup(each.value, "name", format("%s-fargate-%s", var.cluster_name, replace(each.key, "_", "-")))
  pod_execution_role_arn = aws_iam_role.eks_fargate_pod[0].arn
  subnet_ids             = var.subnets
  tags                   = var.tags

  selector {
    namespace = each.value.namespace
    labels    = each.value.labels
  }
}
