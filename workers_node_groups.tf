resource "aws_iam_role" "managed_node_groups" {
  count                 = local.worker_group_managed_node_group_count > 0 ? 1 : 0
  name                  = "${var.workers_role_name != "" ? var.workers_role_name : aws_eks_cluster.this.name}-managed-node-groups"
  assume_role_policy    = data.aws_iam_policy_document.workers_assume_role_policy.json
  permissions_boundary  = var.permissions_boundary
  path                  = var.iam_path
  force_detach_policies = true
  tags                  = var.tags
}

resource "aws_iam_role_policy_attachment" "managed_node_groups_AmazonEKSWorkerNodePolicy" {
  count      = local.worker_group_managed_node_group_count > 0 ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.managed_node_groups[0].name
}

resource "aws_iam_role_policy_attachment" "managed_node_groups_AmazonEKS_CNI_Policy" {
  count      = local.worker_group_managed_node_group_count > 0 ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.managed_node_groups[0].name
}

resource "aws_iam_role_policy_attachment" "managed_node_groups_AmazonEC2ContainerRegistryReadOnly" {
  count      = local.worker_group_managed_node_group_count > 0 ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.managed_node_groups[0].name
}

resource "aws_iam_role_policy_attachment" "managed_node_groups_additional_policies" {
  count      = local.worker_group_managed_node_group_count > 0 ? length(var.workers_additional_policies) : 0
  role       = aws_iam_role.managed_node_groups[0].name
  policy_arn = var.workers_additional_policies[count.index]
}

resource "aws_iam_role_policy_attachment" "managed_node_groups_autoscaling" {
  count      = var.manage_worker_autoscaling_policy && var.attach_worker_autoscaling_policy && local.worker_group_managed_node_group_count > 0 ? 1 : 0
  policy_arn = aws_iam_policy.managed_node_groups_autoscaling[0].arn
  role       = aws_iam_role.managed_node_groups[0].name
}

resource "aws_iam_policy" "managed_node_groups_autoscaling" {
  count       = var.manage_worker_autoscaling_policy && local.worker_group_managed_node_group_count > 0 ? 1 : 0
  name_prefix = "eks-worker-autoscaling-${aws_eks_cluster.this.name}"
  description = "EKS worker node autoscaling policy for cluster ${aws_eks_cluster.this.name}"
  policy      = data.aws_iam_policy_document.worker_autoscaling.json
  path        = var.iam_path
}

resource "aws_eks_node_group" "workers" {
  count = local.worker_group_managed_node_group_count

  cluster_name = aws_eks_cluster.this.name
  node_group_name = join(
    "-",
    compact(
      [
        aws_eks_cluster.this.name,
        lookup(var.worker_group_managed_node_groups[count.index], "name", count.index),
        lookup(var.worker_group_managed_node_groups[count.index], "asg_recreate_on_change", local.workers_group_defaults["asg_recreate_on_change"]) ? random_pet.workers[count.index].id : ""
      ]
    )
  )

  node_role_arn = lookup(var.worker_group_managed_node_groups[count.index], "iam_role_arn", aws_iam_role.managed_node_groups[0].arn)

  subnet_ids = lookup(
    var.worker_group_managed_node_groups[count.index],
    "subnets",
    local.workers_group_defaults["subnets"]
  )

  scaling_config {
    desired_size = lookup(
      var.worker_group_managed_node_groups[count.index],
      "node_group_desired_capacity",
      local.workers_group_defaults["asg_desired_capacity"],
    )
    max_size = lookup(
      var.worker_group_managed_node_groups[count.index],
      "node_group_max_capacity",
      local.workers_group_defaults["asg_max_size"],
    )
    min_size = lookup(
      var.worker_group_managed_node_groups[count.index],
      "node_group_min_capacity",
      local.workers_group_defaults["asg_min_size"],
    )
  }

  ami_type = lookup(
    var.worker_group_managed_node_groups[count.index],
    "ami_type",
    local.workers_group_defaults["ami_type"],
  )

  disk_size = lookup(
    var.worker_group_managed_node_groups[count.index],
    "root_volume_size",
    local.workers_group_defaults["root_volume_size"],
  )
  instance_types = [lookup(
    var.worker_group_managed_node_groups[count.index],
    "instance_type",
    local.workers_group_defaults["instance_type"],
  )]
  labels = lookup(
    var.worker_group_managed_node_groups[count.index],
    "node_group_k8s_labels",
    local.workers_group_defaults["node_group_k8s_labels"],
  )
  release_version = lookup(
    var.worker_group_managed_node_groups[count.index],
    "ami_release_version",
    local.workers_group_defaults["ami_release_version"]
  )

  remote_access {
    ec2_ssh_key = lookup(
      var.worker_group_managed_node_groups[count.index],
      "key_name",
      local.workers_group_defaults["key_name"],
    )
    source_security_group_ids = lookup(
      var.worker_group_managed_node_groups[count.index],
      "source_security_group_ids",
      local.workers_group_defaults["source_security_group_id"],
    )
  }

  tags = lookup(
    var.worker_group_managed_node_groups[count.index],
    "node_group_additional_tags",
    local.workers_group_defaults["node_group_additional_tags"],
  )

  version = aws_eks_cluster.this.version
}