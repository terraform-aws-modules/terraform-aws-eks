# EKS Fargate Pod Execution Role

data "aws_iam_policy_document" "eks_fargate_pod_assume_role" {
  count = var.create_eks && var.create_eks_fargate ? 1 : 0
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
  count              = var.create_eks && var.create_eks_fargate ? 1 : 0
  name               = format("%s-fargate", var.cluster_name)
  assume_role_policy = join("", data.aws_iam_policy_document.eks_fargate_pod_assume_role.*.json)
  tags = merge(var.tags, {"kubernetes.io/cluster/${aws_eks_cluster.this[0].name}" = "owned"})
}

resource "aws_iam_role_policy_attachment" "eks_fargate_pod" {
  count      = var.create_eks && var.create_eks_fargate ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = join("", aws_iam_role.eks_fargate_pod.*.name)
}


# EKS Fargate profiles

resource "aws_eks_fargate_profile" "this" {
  count                  = var.create_eks && var.create_eks_fargate ? local.eks_fargate_profile_count : 0
  cluster_name           = aws_eks_cluster.this[0].name
  fargate_profile_name   = format("%s-fargate-%s", aws_eks_cluster.this[0].name, var.eks_fargate_profiles[count.index].namespace)
  pod_execution_role_arn = join("", aws_iam_role.eks_fargate_pod.*.arn)
  subnet_ids             = var.subnets
  tags = merge(var.tags, {"kubernetes.io/cluster/${aws_eks_cluster.this[0].name}" = "owned"})

  selector {
    namespace = var.eks_fargate_profiles[count.index].namespace
    labels    = var.eks_fargate_profiles[count.index].labels
  }
}
