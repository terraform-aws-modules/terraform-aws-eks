resource "aws_eks_node_group" "workers" {
  for_each = local.node_groups_keys

  node_group_name = join("-", [var.cluster_name, each.key, random_pet.node_groups[each.key].id])

  cluster_name  = var.cluster_name
  node_role_arn = lookup(var.node_groups[each.key], "iam_role_arn", aws_iam_role.node_groups[0].arn)
  subnet_ids    = lookup(var.node_groups[each.key], "subnets", var.workers_group_defaults["subnets"])

  scaling_config {
    desired_size = lookup(var.node_groups[each.key], "desired_capacity", var.workers_group_defaults["asg_desired_capacity"])
    max_size     = lookup(var.node_groups[each.key], "max_capacity", var.workers_group_defaults["asg_max_size"])
    min_size     = lookup(var.node_groups[each.key], "min_capacity", var.workers_group_defaults["asg_min_size"])
  }

  ami_type        = lookup(var.node_groups[each.key], "ami_type", null)
  disk_size       = lookup(var.node_groups[each.key], "root_volume_size", null)
  instance_types  = lookup(var.node_groups[each.key], "instance_type", null) != null ? [var.node_groups[each.key]["instance_type"]] : null
  labels          = lookup(var.node_groups[each.key], "k8s_labels", null)
  release_version = lookup(var.node_groups[each.key], "ami_release_version", null)

  dynamic "remote_access" {
    for_each = [
      for node_group in [var.node_groups[each.key]] : {
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

  version = var.cluster_version

  tags = lookup(var.node_groups[each.key], "additional_tags", null)

  lifecycle {
    create_before_destroy = true
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.node_groups_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_groups_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_groups_AmazonEC2ContainerRegistryReadOnly,
  ]
}
