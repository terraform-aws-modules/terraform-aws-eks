################################################################################
# Migrations: v20.7 -> v20.8
################################################################################

# Node IAM role policy attachment
# Commercial partition only - `moved` does now allow multiple moves to same target
moved {
  from = aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"]
  to   = aws_iam_role_policy_attachment.this["AmazonEKSWorkerNodePolicy"]
}

moved {
  from = aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]
  to   = aws_iam_role_policy_attachment.this["AmazonEC2ContainerRegistryReadOnly"]
}

moved {
  from = aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]
  to   = aws_iam_role_policy_attachment.this["AmazonEKS_CNI_Policy"]
}
