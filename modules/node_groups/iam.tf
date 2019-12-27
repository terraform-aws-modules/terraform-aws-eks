resource "aws_iam_role" "node_groups" {
  count                 = local.create_iam ? 1 : 0
  name_prefix           = var.role_name != "" ? null : "${var.cluster_name}-managed-node-groups-"
  name                  = var.role_name != "" ? var.role_name : null
  assume_role_policy    = data.aws_iam_policy_document.workers_assume_role_policy.json
  permissions_boundary  = var.permissions_boundary
  path                  = var.iam_path
  force_detach_policies = true
  tags                  = var.tags
}

resource "aws_iam_role_policy_attachment" "node_groups_AmazonEKSWorkerNodePolicy" {
  count      = local.create_iam ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_groups[0].name
}

resource "aws_iam_role_policy_attachment" "node_groups_AmazonEKS_CNI_Policy" {
  count      = local.create_iam ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_groups[0].name
}

resource "aws_iam_role_policy_attachment" "node_groups_AmazonEC2ContainerRegistryReadOnly" {
  count      = local.create_iam ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_groups[0].name
}

resource "aws_iam_role_policy_attachment" "node_groups_additional_policies" {
  for_each   = local.create_iam ? toset(var.workers_additional_policies) : []
  role       = aws_iam_role.node_groups[0].name
  policy_arn = each.key
}

resource "aws_iam_role_policy_attachment" "node_groups_autoscaling" {
  count      = local.create_iam && var.manage_worker_autoscaling_policy && var.attach_worker_autoscaling_policy ? 1 : 0
  policy_arn = aws_iam_policy.node_groups_autoscaling[0].arn
  role       = aws_iam_role.node_groups[0].name
}

resource "aws_iam_policy" "node_groups_autoscaling" {
  count       = local.create_iam && var.manage_worker_autoscaling_policy ? 1 : 0
  name_prefix = "eks-worker-autoscaling-${aws_eks_cluster.this[0].name}"
  description = "EKS worker node autoscaling policy for cluster ${aws_eks_cluster.this[0].name}"
  policy      = data.aws_iam_policy_document.worker_autoscaling[0].json
  path        = var.iam_path
}
