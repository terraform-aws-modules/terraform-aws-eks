# Allow Fargate pods and EC2 workers to communicate

resource "aws_security_group_rule" "eks_fargate1" {
  count                    = var.create ? 1 : 0
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "all"
  security_group_id        = var.worker_security_group_id
  source_security_group_id = var.cluster_primary_security_group_id
}

resource "aws_security_group_rule" "eks_fargate2" {
  count                    = var.create ? 1 : 0
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "all"
  security_group_id        = var.cluster_primary_security_group_id
  source_security_group_id = var.worker_security_group_id
}


# EKS Fargate Pod Execution Role

data "aws_iam_policy_document" "eks_fargate_pod_assume_role" {
  count = var.create ? 1 : 0
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
  count              = var.create ? 1 : 0
  name               = format("%s-fargate", var.cluster_name)
  assume_role_policy = join("", data.aws_iam_policy_document.eks_fargate_pod_assume_role.*.json)
  tags               = merge(var.tags, { "kubernetes.io/cluster/${var.cluster_name}" = "owned" })
}

resource "aws_iam_role_policy_attachment" "eks_fargate_pod" {
  count      = var.create ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = join("", aws_iam_role.eks_fargate_pod.*.name)
}


# EKS Fargate profiles

resource "aws_eks_fargate_profile" "this" {
  count                  = var.create ? local.profile_count : 0
  cluster_name           = var.cluster_name
  fargate_profile_name   = format("%s-fargate-%s", var.cluster_name, var.profiles[count.index].namespace)
  pod_execution_role_arn = join("", aws_iam_role.eks_fargate_pod.*.arn)
  subnet_ids             = var.subnets
  tags                   = merge(var.tags, { "kubernetes.io/cluster/${var.cluster_name}" = "owned" })

  selector {
    namespace = var.profiles[count.index].namespace
    labels    = var.profiles[count.index].labels
  }
}
