resource "random_pet" "node_groups" {
  for_each = local.node_groups_keys

  separator = "-"
  length    = 2

  keepers = {
    ami_type      = lookup(local.node_groups_expanded[each.key], "ami_type", null)
    disk_size     = lookup(local.node_groups_expanded[each.key], "disk_size", null)
    instance_type = lookup(local.node_groups_expanded[each.key], "instance_type", var.workers_group_defaults["instance_type"])
    node_role_arn = lookup(local.node_groups_expanded[each.key], "iam_role_arn", var.default_iam_role_arn)

    ec2_ssh_key = lookup(local.node_groups_expanded[each.key], "key_name", var.workers_group_defaults["key_name"])

    source_security_group_ids = join("|", compact(
      lookup(local.node_groups_expanded[each.key], "source_security_group_ids", [])
    ))
    subnet_ids      = join("|", lookup(local.node_groups_expanded[each.key], "subnets", var.workers_group_defaults["subnets"]))
    node_group_name = join("-", [var.cluster_name, each.key])
  }
}
