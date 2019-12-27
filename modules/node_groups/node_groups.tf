resource "aws_eks_node_group" "workers" {
  for_each = local.node_groups

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
