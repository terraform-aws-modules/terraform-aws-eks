################################################################################
# Migrations: v19.x -> v20.0
################################################################################

# We can't move the node IAM role from `this` -> `node` AND move the 
# controller IAM role from `irsa` -> `this` at the same time since that
# will cause conflicts. Therefore, we are choosing to save the node IAM role
# since this is what is used by nodes and harder/more disruptive to replace
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
