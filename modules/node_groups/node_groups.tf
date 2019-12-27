resource "aws_iam_role" "node_groups" {
  count                 = var.create_eks && local.worker_group_managed_node_group_count > 0 ? 1 : 0
  name                  = "${var.workers_role_name != "" ? var.workers_role_name : aws_eks_cluster.this[0].name}-managed-node-groups"
  assume_role_policy    = data.aws_iam_policy_document.workers_assume_role_policy.json
  permissions_boundary  = var.permissions_boundary
  path                  = var.iam_path
  force_detach_policies = true
  tags                  = var.tags
}

resource "aws_iam_role_policy_attachment" "node_groups_AmazonEKSWorkerNodePolicy" {
  count      = var.create_eks && local.worker_group_managed_node_group_count > 0 ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_groups[0].name
}

resource "aws_iam_role_policy_attachment" "node_groups_AmazonEKS_CNI_Policy" {
  count      = var.create_eks && local.worker_group_managed_node_group_count > 0 ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_groups[0].name
}

resource "aws_iam_role_policy_attachment" "node_groups_AmazonEC2ContainerRegistryReadOnly" {
  count      = var.create_eks && local.worker_group_managed_node_group_count > 0 ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_groups[0].name
}

resource "aws_iam_role_policy_attachment" "node_groups_additional_policies" {
  for_each = var.create_eks && local.worker_group_managed_node_group_count > 0 ? toset(var.workers_additional_policies) : []

  role       = aws_iam_role.node_groups[0].name
  policy_arn = each.key
}

resource "aws_iam_role_policy_attachment" "node_groups_autoscaling" {
  count      = var.create_eks && var.manage_worker_autoscaling_policy && var.attach_worker_autoscaling_policy && local.worker_group_managed_node_group_count > 0 ? 1 : 0
  policy_arn = aws_iam_policy.node_groups_autoscaling[0].arn
  role       = aws_iam_role.node_groups[0].name
}

resource "aws_iam_policy" "node_groups_autoscaling" {
  count       = var.create_eks && var.manage_worker_autoscaling_policy && local.worker_group_managed_node_group_count > 0 ? 1 : 0
  name_prefix = "eks-worker-autoscaling-${aws_eks_cluster.this[0].name}"
  description = "EKS worker node autoscaling policy for cluster ${aws_eks_cluster.this[0].name}"
  policy      = data.aws_iam_policy_document.worker_autoscaling[0].json
  path        = var.iam_path
}

resource "random_pet" "node_groups" {
  for_each = var.create_eks ? local.node_groups : {}

  separator = "-"
  length    = 2

  keepers = {
    instance_type = lookup(each.value, "instance_type", local.workers_group_defaults["instance_type"])

    ec2_ssh_key = lookup(each.value, "key_name", local.workers_group_defaults["key_name"])

    source_security_group_ids = join("-", compact(
      lookup(each.value, "source_security_group_ids", local.workers_group_defaults["source_security_group_id"]
    )))

    node_group_name = join("-", [var.cluster_name, each.value["name"]])
  }
}

resource "aws_eks_node_group" "workers" {
  for_each = var.create_eks ? local.node_groups : {}

  node_group_name = join("-", [var.cluster_name, each.key, random_pet.node_groups[each.key].id])

  cluster_name  = var.cluster_name
  node_role_arn = lookup(each.value, "iam_role_arn", aws_iam_role.node_groups[0].arn)
  subnet_ids    = lookup(each.value, "subnets", local.workers_group_defaults["subnets"])

  scaling_config {
    desired_size = lookup(each.value, "node_group_desired_capacity", local.workers_group_defaults["asg_desired_capacity"])
    max_size     = lookup(each.value, "node_group_max_capacity", local.workers_group_defaults["asg_max_size"])
    min_size     = lookup(each.value, "node_group_min_capacity", local.workers_group_defaults["asg_min_size"])
  }

  ami_type        = lookup(each.value, "ami_type", null)
  disk_size       = lookup(each.value, "root_volume_size", null)
  instance_types  = [lookup(each.value, "instance_type", null)]
  labels          = lookup(each.value, "node_group_k8s_labels", null)
  release_version = lookup(each.value, "ami_release_version", null)

  dynamic "remote_access" {
    for_each = [
      for node_group in [each.value] : {
        ec2_ssh_key               = node_group["key_name"]
        source_security_group_ids = lookup(node_group, "source_security_group_ids", [])
      }
      if lookup(node_group, "key_name", "") != ""
    ]

    content {
      ec2_ssh_key               = remote_access.value["ec2_ssh_key"]
      source_security_group_ids = remote_access.value["source_security_group_ids"]
    }
  }

  version = aws_eks_cluster.this[0].version

  tags = lookup(each.value, "node_group_additional_tags", null)

  lifecycle {
    create_before_destroy = true
  }
}
