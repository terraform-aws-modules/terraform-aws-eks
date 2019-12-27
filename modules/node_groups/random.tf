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
