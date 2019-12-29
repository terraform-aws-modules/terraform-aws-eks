resource "aws_eks_node_group" "workers" {
  for_each = local.node_groups_keys

  node_group_name = join("-", [var.cluster_name, each.key, random_pet.node_groups[each.key].id])

  cluster_name  = var.cluster_name
  node_role_arn = lookup(local.node_groups_expanded[each.key], "iam_role_arn", var.default_iam_role_arn)
  subnet_ids    = lookup(local.node_groups_expanded[each.key], "subnets", var.workers_group_defaults["subnets"])

  scaling_config {
    desired_size = lookup(local.node_groups_expanded[each.key], "desired_capacity", var.workers_group_defaults["asg_desired_capacity"])
    max_size     = lookup(local.node_groups_expanded[each.key], "max_capacity", var.workers_group_defaults["asg_max_size"])
    min_size     = lookup(local.node_groups_expanded[each.key], "min_capacity", var.workers_group_defaults["asg_min_size"])
  }

  ami_type        = lookup(local.node_groups_expanded[each.key], "ami_type", null)
  disk_size       = lookup(local.node_groups_expanded[each.key], "disk_size", null)
  instance_types  = [lookup(local.node_groups_expanded[each.key], "instance_type", var.workers_group_defaults["instance_type"])]
  labels          = lookup(local.node_groups_expanded[each.key], "k8s_labels", null)
  release_version = lookup(local.node_groups_expanded[each.key], "ami_release_version", null)

  dynamic "remote_access" {
    for_each = [
      for node_group in [local.node_groups_expanded[each.key]] : {
        ec2_ssh_key               = lookup(node_group, "key_name", var.workers_group_defaults["key_name"])
        source_security_group_ids = lookup(node_group, "source_security_group_ids", [])
      }
      if lookup(node_group, "key_name", var.workers_group_defaults["key_name"]) != ""
    ]

    content {
      ec2_ssh_key               = remote_access.value["ec2_ssh_key"]
      source_security_group_ids = remote_access.value["source_security_group_ids"]
    }
  }

  version = var.cluster_version

  tags = merge(
    var.tags,
    lookup(local.node_groups_expanded[each.key], "additional_tags", {}),
  )

  lifecycle {
    create_before_destroy = true
  }
}
