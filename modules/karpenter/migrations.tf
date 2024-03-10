################################################################################
# Migrations: v19.21 -> v20.0
################################################################################

# Node IAM role
moved {
  from = aws_iam_role.this
  to   = aws_iam_role.node
}

moved {
  from = aws_iam_policy.this
  to   = aws_iam_policy.node
}

moved {
  from = aws_iam_role_policy_attachment.this
  to   = aws_iam_role_policy_attachment.node
}

moved {
  from = aws_iam_role_policy_attachment.additional
  to   = aws_iam_role_policy_attachment.node_additional
}

# Controller IAM role
moved {
  from = aws_iam_role.irsa
  to   = aws_iam_role.controller
}

moved {
  from = aws_iam_policy.irsa
  to   = aws_iam_policy.controller
}

moved {
  from = aws_iam_role_policy_attachment.irsa
  to   = aws_iam_role_policy_attachment.controller
}

moved {
  from = aws_iam_role_policy_attachment.irsa_additional
  to   = aws_iam_role_policy_attachment.controller_additional
}

# Spelling correction
moved {
  from = aws_cloudwatch_event_target.this["spot_interupt"]
  to   = aws_cloudwatch_event_target.this["spot_interrupt"]
}

moved {
  from = aws_cloudwatch_event_rule.this["spot_interupt"]
  to   = aws_cloudwatch_event_rule.this["spot_interrupt"]
}

################################################################################
# Migrations: v20.7 -> v20.8
################################################################################

# Node IAM role policy attachment
# Commercial partition only - `moved` does now allow multiple moves to same target
moved {
  from = aws_iam_role_policy_attachment.node["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"]
  to   = aws_iam_role_policy_attachment.node["AmazonEKSWorkerNodePolicy"]
}

moved {
  from = aws_iam_role_policy_attachment.node["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]
  to   = aws_iam_role_policy_attachment.node["AmazonEC2ContainerRegistryReadOnly"]
}

moved {
  from = aws_iam_role_policy_attachment.node["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]
  to   = aws_iam_role_policy_attachment.node["AmazonEKS_CNI_Policy"]
}
