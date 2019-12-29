data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "node_groups" {
  count                 = local.create_iam ? 1 : 0
  name_prefix           = var.role_name != "" ? null : substr("${var.cluster_name}-node-groups-", 0, 32)
  name                  = var.role_name != "" ? var.role_name : null
  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy.json
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
  count      = local.create_iam && var.manage_worker_iam_resources && var.manage_worker_autoscaling_policy && var.attach_worker_autoscaling_policy ? 1 : 0
  policy_arn = var.worker_autoscaling_policy_arn
  role       = aws_iam_role.node_groups[0].name
}
