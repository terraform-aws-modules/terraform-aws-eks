locals {
  create_eks              = var.create_eks && length(var.fargate_profiles) > 0
  pod_execution_role_arn  = var.create_fargate_pod_execution_role ? element(concat(aws_iam_role.eks_fargate_pod.*.arn, tolist([""])), 0) : element(concat(data.aws_iam_role.custom_fargate_iam_role.*.arn, tolist([""])), 0)
  pod_execution_role_name = var.create_fargate_pod_execution_role ? element(concat(aws_iam_role.eks_fargate_pod.*.name, tolist([""])), 0) : element(concat(data.aws_iam_role.custom_fargate_iam_role.*.name, tolist([""])), 0)

  fargate_profiles_expanded = { for k, v in var.fargate_profiles : k => merge(
    v,
    { tags = merge(var.tags, lookup(v, "tags", {})) },
  ) if var.create_eks }
}
