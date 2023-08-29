# Karpenter requires a node instance profile created to be passed to the helmfile
resource "aws_iam_role" "karpenter_role" {
  count                 = var.manage_worker_iam_resources && var.create_eks ? 1 : 0
  name                  = "karpenter_role_${var.stage}"
  permissions_boundary  = var.permissions_boundary
  path                  = var.iam_path
  force_detach_policies = true
  tags                  = var.tags
  assume_role_policy    = data.aws_iam_policy_document.workers_assume_role_policy.json
}

resource "aws_iam_instance_profile" "karpenter_node_instance_profile" {
  name = "karpenter_node_instance_profile_${var.stage}"
  role = aws_iam_role.karpenter_role[0].name
}

resource "aws_iam_role_policy_attachment" "karpenter_policy_attachments" {
  count      = var.manage_worker_iam_resources && var.create_eks ? length(local.worker_policy_list) : 0
  policy_arn = local.worker_policy_list[count.index]
  role       = aws_iam_role.workers[0].name
}
