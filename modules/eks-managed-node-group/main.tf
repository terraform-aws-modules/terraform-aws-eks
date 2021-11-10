resource "aws_eks_node_group" "this" {
  count = var.create ? 1 : 0

  # Required
  cluster_name  = var.cluster_name
  node_role_arn = var.iam_role_arn
  subnet_ids    = var.subnet_ids

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  # Optional
  node_group_name        = var.use_name_prefix ? null : var.name
  node_group_name_prefix = var.use_name_prefix ? "${var.name}-" : null

  ami_type             = var.ami_type
  release_version      = var.ami_release_version
  capacity_type        = var.capacity_type
  disk_size            = var.disk_size
  force_update_version = var.force_update_version
  instance_types       = var.instance_types
  labels               = var.labels
  version              = var.version

  dynamic "launch_template" {
    for_each = [var.launch_template]
    content {
      id      = lookup(launch_template.value, "id", null)
      name    = lookup(launch_template.value, "name", null)
      version = lookup(launch_template.value, "version", "$Default")
    }
  }

  dynamic "remote_access" {
    for_each = [var.remote_access]
    content {
      ec2_ssh_key               = lookup(remote_access.value, "ec2_ssh_key")
      source_security_group_ids = lookup(remote_access.value, "source_security_group_ids")
    }
  }

  dynamic "taint" {
    for_each = var.taints
    content {
      key    = taint.value.key
      value  = lookup(taint.value, "value")
      effect = taint.value.effect
    }
  }

  dynamic "update_config" {
    for_each = [var.update_config]
    content {
      max_unavailable_percentage = lookup(update_config.value, "max_unavailable_percentage", null)
      max_unavailable            = lookup(update_config.value, "max_unavailable", null)
    }
  }

  timeouts {
    create = lookup(var.timeouts, "create", null)
    update = lookup(var.timeouts, "update", null)
    delete = lookup(var.timeouts, "delete", null)
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      scaling_config[0].desired_size,
    ]
  }

  tags = var.tags
}
