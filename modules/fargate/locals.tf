locals {
  pod_execution_role_arn  = concat(aws_iam_role.eks_fargate_pod.*.arn, data.aws_iam_role.custom_fargate_iam_role.*.arn)[0]
  pod_execution_role_name = concat(aws_iam_role.eks_fargate_pod.*.name, data.aws_iam_role.custom_fargate_iam_role.*.name)[0]

  fargate_profiles_expanded = { for k, v in var.fargate_profiles : k => merge(
    v,
    { tags = merge(var.tags, lookup(v, "tags", {})) },
  ) if var.create_eks }
}
