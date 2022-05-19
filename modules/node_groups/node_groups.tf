resource "aws_eks_node_group" "workers" {
  for_each = local.node_groups_expanded

  node_group_name = "${var.is_default ? "" : "${var.cluster_name}_"}${each.value["name"]}"
  version         = lookup(each.value, "version", null)
  capacity_type   = each.value["capacity_type"] # SPOT or ON_DEMAND

  force_update_version = var.force_update_version
  cluster_name         = var.cluster_name
  node_role_arn        = each.value["iam_role_arn"]
  subnet_ids           = each.value["subnets"]

  scaling_config {
    desired_size = each.value["node_group_desired_capacity"]
    max_size     = each.value["max_capacity"]
    min_size     = each.value["min_capacity"]
  }

  instance_types = each.value["instance_types"]

  # These shouldn't be needed as we specify the version
  ami_type        = lookup(each.value, "ami_type", null)
  release_version = lookup(each.value, "ami_release_version", null)
  launch_template {
    id      = aws_launch_template.workers[each.key].id
    version = aws_launch_template.workers[each.key].default_version
  }

  labels = merge(
    lookup(var.node_groups_defaults, "k8s_labels", {}),
    lookup(var.node_groups[each.key], "k8s_labels", {})
  )
  tags = merge(
    {
      Name = "${each.value["name"]}_node"
    },
    var.tags,
    lookup(var.node_groups_defaults, "additional_tags", {}),
    lookup(var.node_groups[each.key], "additional_tags", {}),
  )

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config.0.desired_size]
  }

  depends_on = [aws_launch_template.workers]

}
