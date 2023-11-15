################################################################################
# Migrations: v19.x -> v20.0
################################################################################

moved {
  from = aws_iam_role.irsa
  to   = aws_iam_role.pod_identity
}

moved {
  from = aws_iam_policy.irsa
  to   = aws_iam_policy.pod_identity
}

moved {
  from = aws_iam_role_policy_attachment.irsa
  to   = aws_iam_role_policy_attachment.pod_identity
}
