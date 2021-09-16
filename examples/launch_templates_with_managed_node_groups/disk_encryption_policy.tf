# if you have used ASGs before, that role got auto-created already and you need to import to TF state
resource "aws_iam_service_linked_role" "autoscaling" {
  aws_service_name = "autoscaling.amazonaws.com"
  description      = "Default Service-Linked Role enables access to AWS Services and Resources used or managed by Auto Scaling"
}

#data "aws_caller_identity" "current" {}
#
## This policy is required for the KMS key used for EKS root volumes, so the cluster is allowed to enc/dec/attach encrypted EBS volumes
#data "aws_iam_policy_document" "ebs_decryption" {
#  # Copy of default KMS policy that lets you manage it
#  statement {
#    sid    = "Enable IAM User Permissions"
#    effect = "Allow"
#
#    principals {
#      type        = "AWS"
#      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
#    }
#
#    actions = [
#      "kms:*"
#    ]
#
#    resources = ["*"]
#  }
#
#  # Required for EKS
#  statement {
#    sid    = "Allow service-linked role use of the CMK"
#    effect = "Allow"
#
#    principals {
#      type = "AWS"
#      identifiers = [
#        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling", # required for the ASG to manage encrypted volumes for nodes
#        module.eks.cluster_iam_role_arn,                                                                                                            # required for the cluster / persistentvolume-controller to create encrypted PVCs
#      ]
#    }
#
#    actions = [
#      "kms:Encrypt",
#      "kms:Decrypt",
#      "kms:ReEncrypt*",
#      "kms:GenerateDataKey*",
#      "kms:DescribeKey"
#    ]
#
#    resources = ["*"]
#  }
#
#  statement {
#    sid    = "Allow attachment of persistent resources"
#    effect = "Allow"
#
#    principals {
#      type = "AWS"
#      identifiers = [
#        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling", # required for the ASG to manage encrypted volumes for nodes
#        module.eks.cluster_iam_role_arn,                                                                                                            # required for the cluster / persistentvolume-controller to create encrypted PVCs
#      ]
#    }
#
#    actions = [
#      "kms:CreateGrant"
#    ]
#
#    resources = ["*"]
#
#    condition {
#      test     = "Bool"
#      variable = "kms:GrantIsForAWSResource"
#      values   = ["true"]
#    }
#
#  }
#}
