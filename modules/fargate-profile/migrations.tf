################################################################################
# Migrations: v20.8 -> v20.9
################################################################################

# Node IAM role policy attachment
# Commercial partition only - `moved` does now allow multiple moves to same target
moved {
  from = aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"]
  to   = aws_iam_role_policy_attachment.this["AmazonEKSFargatePodExecutionRolePolicy"]
}

moved {
  from = aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]
  to   = aws_iam_role_policy_attachment.this["AmazonEKS_CNI_Policy"]
}
