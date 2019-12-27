resource "random_pet" "node_groups" {
  for_each = local.node_groups_keys

  separator = "-"
  length    = 2

  keepers = {
    instance_type = lookup(var.node_groups[each.key], "instance_type", var.workers_group_defaults["instance_type"])

    ec2_ssh_key = lookup(var.node_groups[each.key], "key_name", var.workers_group_defaults["key_name"])

    source_security_group_ids = join("-", compact(
      lookup(var.node_groups[each.key], "source_security_group_ids", var.workers_group_defaults["source_security_group_ids"]
    )))

    node_group_name = join("-", [var.cluster_name, each.key])
  }
}
