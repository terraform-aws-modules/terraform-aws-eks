locals {
  aws_account_id = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "assume_role_with_oidc" {

  statement {
    effect = "Allow"

    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"

      identifiers = [
        "arn:aws:iam::${local.aws_account_id}:oidc-provider/${var.provider_url}"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.provider_url}:sub"
      values   = var.oidc_fully_qualified_subjects
    }
  }
}

resource "aws_iam_role" "this" {

  name                 = var.role_name
  path                 = var.role_path
  max_session_duration = var.max_session_duration

  permissions_boundary = var.role_permissions_boundary_arn
  assume_role_policy   = data.aws_iam_policy_document.assume_role_with_oidc.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "custom" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.incoming_policy.arn
}

resource "aws_iam_policy" "incoming_policy" {
  name_prefix = var.role_name
  description = var.role_description
  policy      = var.role_policy_document
}
