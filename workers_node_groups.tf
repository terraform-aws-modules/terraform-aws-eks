resource "aws_eks_node_group" "workers" {
  count = local.worker_group_managed_node_group_count

  cluster_name = aws_eks_cluster.this.name
  node_group_name = join(
    "-",
    compact(
      [
        aws_eks_cluster.this.name,
        lookup(var.worker_group_managed_node_groups[count.index], "name", count.index),
        lookup(var.worker_group_managed_node_groups[count.index], "asg_recreate_on_change", local.workers_group_defaults["asg_recreate_on_change"]) ? random_pet.workers[count.index].id : ""
      ]
    )
  )

  node_role_arn = lookup(
    var.worker_group_managed_node_groups[count.index],
    "iam_role_id",
    local.default_iam_role_id,
  )
  subnet_ids = lookup(
    var.worker_group_managed_node_groups[count.index],
    "subnets",
    local.workers_group_defaults["subnets"]
  )

  scaling_config {
    desired_size = lookup(
      var.worker_group_managed_node_groups[count.index],
      "node_group_desired_capacity",
      local.workers_group_defaults["asg_desired_capacity"],
    )
    max_size = lookup(
      var.worker_group_managed_node_groups[count.index],
      "node_group_max_capacity",
      local.workers_group_defaults["asg_max_size"],
    )
    min_size = lookup(
      var.worker_group_managed_node_groups[count.index],
      "node_group_min_capacity",
      local.workers_group_defaults["asg_min_size"],
    )
  }

  ami_type = lookup(
    var.worker_group_managed_node_groups[count.index],
    "ami_type",
    local.workers_group_defaults["ami_type"],
  )

  disk_size = lookup(
    var.worker_group_managed_node_groups[count.index],
    "root_volume_size",
    local.workers_group_defaults["root_volume_size"],
  )
  instance_types = [lookup(
    var.worker_group_managed_node_groups[count.index],
    "instance_type",
    local.workers_group_defaults["instance_type"],
  )]
  labels = lookup(
  var.worker_group_managed_node_groups[count.index],
  "node_group_k8s_labels",
  local.workers_group_defaults["node_group_k8s_labels"],
  )
  release_version = lookup(
    var.worker_group_managed_node_groups[count.index],
    "ami_release_version",
    local.workers_group_defaults["ami_release_version"]
  )

  remote_access {
    ec2_ssh_key = lookup(
      var.worker_group_managed_node_groups[count.index],
      "key_name",
      local.workers_group_defaults["key_name"],
    )
    source_security_group_ids = lookup(
      var.worker_group_managed_node_groups[count.index],
      "source_security_group_ids",
      local.workers_group_defaults["source_security_group_id"],
    )
  }

  tags    = var.tags
  version = aws_eks_cluster.this.version
}