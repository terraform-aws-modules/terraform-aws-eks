resource "random_pet" "node_groups" {
  for_each = local.node_groups_expanded

  separator = "-"
  length    = 2

  keepers = {
    ami_type      = lookup(each.value, "ami_type", null)
    disk_size     = lookup(each.value, "disk_size", null)
    instance_type = lookup(each.value, "instance_type", var.workers_group_defaults["instance_type"])
    node_role_arn = lookup(each.value, "iam_role_arn", var.default_iam_role_arn)

    ec2_ssh_key = lookup(each.value, "key_name", var.workers_group_defaults["key_name"])

    source_security_group_ids = join("|", compact(
      lookup(each.value, "source_security_group_ids", [])
    ))
    subnet_ids      = join("|", lookup(each.value, "subnets", var.workers_group_defaults["subnets"]))
    node_group_name = join("-", [var.cluster_name, each.key])
  }
}
