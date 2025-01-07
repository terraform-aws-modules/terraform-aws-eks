# kms.tf
resource "aws_kms_key" "eks_secrets" {
  count                   = var.encryption ? 1 : 0
  description             = "KMS key for encrypting EKS Kubernetes Secrets at rest"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  policy = data.aws_iam_policy_document.kms_key_policy.json
}

data "aws_iam_policy_document" "kms_key_policy" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = [
      "kms:*"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "Allow EKS to use the key"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = ["*"]
  }
}


# iam_policies.tf
resource "aws_iam_policy" "eks_secrets_encryption" {
  count       = var.encryption ? 1 : 0
  name        = "eks-${var.cluster_name}-secrets-encryption-policy"
  description = "Allows EKS to use KMS key for encrypting Kubernetes Secrets at rest"


  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = aws_kms_key.eks_secrets.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_kms_policy" {
  count      = var.encryption ? 1 : 0
  policy_arn = aws_iam_policy.eks_secrets_encryption[0].arn
  role       = local.cluster_iam_role_name
}
