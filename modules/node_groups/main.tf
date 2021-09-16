resource "aws_eks_node_group" "workers" {
  for_each = local.node_groups_expanded

  node_group_name_prefix = lookup(each.value, "name", null) == null ? local.node_groups_names[each.key] : null
  node_group_name        = lookup(each.value, "name", null)

  cluster_name  = var.cluster_name
  node_role_arn = each.value["iam_role_arn"]
  subnet_ids    = each.value["subnets"]

  scaling_config {
    desired_size = each.value["desired_capacity"]
    max_size     = each.value["max_capacity"]
    min_size     = each.value["min_capacity"]
  }

  ami_type             = lookup(each.value, "ami_type", null)
  disk_size            = each.value["launch_template_id"] != null || each.value["create_launch_template"] ? null : lookup(each.value, "disk_size", null)
  instance_types       = !each.value["set_instance_types_on_lt"] ? each.value["instance_types"] : null
  release_version      = lookup(each.value, "ami_release_version", null)
  capacity_type        = lookup(each.value, "capacity_type", null)
  force_update_version = lookup(each.value, "force_update_version", null)

  dynamic "remote_access" {
    for_each = each.value["key_name"] != "" && each.value["launch_template_id"] == null && !each.value["create_launch_template"] ? [{
      ec2_ssh_key               = each.value["key_name"]
      source_security_group_ids = lookup(each.value, "source_security_group_ids", [])
    }] : []

    content {
      ec2_ssh_key               = remote_access.value["ec2_ssh_key"]
      source_security_group_ids = remote_access.value["source_security_group_ids"]
    }
  }

  dynamic "launch_template" {
    for_each = each.value["launch_template_id"] != null ? [{
      id      = each.value["launch_template_id"]
      version = each.value["launch_template_version"]
    }] : []

    content {
      id      = launch_template.value["id"]
      version = launch_template.value["version"]
    }
  }

  dynamic "launch_template" {
    for_each = each.value["launch_template_id"] == null && each.value["create_launch_template"] ? [{
      id = aws_launch_template.workers[each.key].id
      version = each.value["launch_template_version"] == "$Latest" ? aws_launch_template.workers[each.key].latest_version : (
        each.value["launch_template_version"] == "$Default" ? aws_launch_template.workers[each.key].default_version : each.value["launch_template_version"]
      )
    }] : []

    content {
      id      = launch_template.value["id"]
      version = launch_template.value["version"]
    }
  }

  dynamic "taint" {
    for_each = each.value["taints"]

    content {
      key    = taint.value["key"]
      value  = taint.value["value"]
      effect = taint.value["effect"]
    }
  }

  dynamic "update_config" {
    for_each = try(each.value.update_config.max_unavailable_percentage > 0, each.value.update_config.max_unavailable > 0, false) ? [true] : []

    content {
      max_unavailable_percentage = try(each.value.update_config.max_unavailable_percentage, null)
      max_unavailable            = try(each.value.update_config.max_unavailable, null)
    }
  }

  timeouts {
    create = lookup(each.value["timeouts"], "create", null)
    update = lookup(each.value["timeouts"], "update", null)
    delete = lookup(each.value["timeouts"], "delete", null)
  }

  version = lookup(each.value, "version", null)

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
    ignore_changes        = [scaling_config[0].desired_size]
  }

  depends_on = [var.ng_depends_on]
}
