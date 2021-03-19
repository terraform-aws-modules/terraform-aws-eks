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
