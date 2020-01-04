resource "aws_eks_node_group" "workers" {
  for_each = random_pet.node_groups

  node_group_name = join("-", [var.cluster_name, each.key, each.value.id])

  cluster_name  = var.cluster_name
  node_role_arn = each.value.keepers.node_role_arn
  subnet_ids    = split("|", each.value.keepers.subnet_ids)

  scaling_config {
    desired_size = lookup(local.node_groups_expanded[each.key], "desired_capacity", var.workers_group_defaults["asg_desired_capacity"])
    max_size     = lookup(local.node_groups_expanded[each.key], "max_capacity", var.workers_group_defaults["asg_max_size"])
    min_size     = lookup(local.node_groups_expanded[each.key], "min_capacity", var.workers_group_defaults["asg_min_size"])
  }

  ami_type        = lookup(each.value.keepers, "ami_type", null)
  disk_size       = lookup(each.value.keepers, "disk_size", null)
  instance_types  = [each.value.keepers.instance_type]
  release_version = lookup(local.node_groups_expanded[each.key], "ami_release_version", null)

  dynamic "remote_access" {
    for_each = each.value.keepers.ec2_ssh_key != "" ? [{
      ec2_ssh_key               = each.value.keepers.ec2_ssh_key
      source_security_group_ids = compact(split("|", each.value.keepers.source_security_group_ids))
    }] : []

    content {
      ec2_ssh_key               = remote_access.value["ec2_ssh_key"]
      source_security_group_ids = remote_access.value["source_security_group_ids"]
    }
  }

  version = var.cluster_version

  labels = merge(
    lookup(var.node_groups_defaults, "k8s_labels", {}),
    lookup(var.node_groups[each.key], "k8s_labels", {})
  )

  tags = merge(
    var.tags,
    lookup(var.node_groups_defaults, "additional_tags", {}),
    lookup(var.node_groups[each.key], "additional_tags", {}),
  )

  lifecycle {
    create_before_destroy = true
  }
}
