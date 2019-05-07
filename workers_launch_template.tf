# Worker Groups using Launch Templates

resource "aws_autoscaling_group" "workers_launch_template" {
  count                   = "${var.worker_group_launch_template_count}"
  name_prefix             = "${aws_eks_cluster.this.name}-${lookup(var.worker_groups_launch_template[count.index], "name", count.index)}"
  desired_capacity        = "${lookup(var.worker_groups_launch_template[count.index], "asg_desired_capacity", local.workers_group_defaults["asg_desired_capacity"])}"
  max_size                = "${lookup(var.worker_groups_launch_template[count.index], "asg_max_size", local.workers_group_defaults["asg_max_size"])}"
  min_size                = "${lookup(var.worker_groups_launch_template[count.index], "asg_min_size", local.workers_group_defaults["asg_min_size"])}"
  force_delete            = "${lookup(var.worker_groups_launch_template[count.index], "asg_force_delete", local.workers_group_defaults["asg_force_delete"])}"
  target_group_arns       = ["${compact(split(",", coalesce(lookup(var.worker_groups_launch_template[count.index], "target_group_arns", ""), local.workers_group_defaults["target_group_arns"])))}"]
  service_linked_role_arn = "${lookup(var.worker_groups_launch_template[count.index], "service_linked_role_arn", local.workers_group_defaults["service_linked_role_arn"])}"
  vpc_zone_identifier     = ["${split(",", coalesce(lookup(var.worker_groups_launch_template[count.index], "subnets", ""), local.workers_group_defaults["subnets"]))}"]
  protect_from_scale_in   = "${lookup(var.worker_groups_launch_template[count.index], "protect_from_scale_in", local.workers_group_defaults["protect_from_scale_in"])}"
  suspended_processes     = ["${compact(split(",", coalesce(lookup(var.worker_groups_launch_template[count.index], "suspended_processes", ""), local.workers_group_defaults["suspended_processes"])))}"]
  enabled_metrics         = ["${compact(split(",", coalesce(lookup(var.worker_groups_launch_template[count.index], "enabled_metrics", ""), local.workers_group_defaults["enabled_metrics"])))}"]
  placement_group         = "${lookup(var.worker_groups_launch_template[count.index], "placement_group", local.workers_group_defaults["placement_group"])}"

  launch_template {
    id      = "${element(aws_launch_template.workers_launch_template.*.id, count.index)}"
    version = "${lookup(var.worker_groups_launch_template[count.index], "launch_template_version", local.workers_group_defaults["launch_template_version"])}"
  }

  tags = ["${concat(
    list(
      map("key", "Name", "value", "${aws_eks_cluster.this.name}-${lookup(var.worker_groups_launch_template[count.index], "name", count.index)}-eks_asg", "propagate_at_launch", true),
      map("key", "kubernetes.io/cluster/${aws_eks_cluster.this.name}", "value", "owned", "propagate_at_launch", true),
      map("key", "k8s.io/cluster-autoscaler/${lookup(var.worker_groups_launch_template[count.index], "autoscaling_enabled", local.workers_group_defaults["autoscaling_enabled"]) == 1 ? "enabled" : "disabled"  }", "value", "true", "propagate_at_launch", false),
      map("key", "k8s.io/cluster-autoscaler/${aws_eks_cluster.this.name}", "value", "", "propagate_at_launch", false),
      map("key", "k8s.io/cluster-autoscaler/node-template/resources/ephemeral-storage", "value", "${lookup(var.worker_groups_launch_template[count.index], "root_volume_size", local.workers_group_defaults["root_volume_size"])}Gi", "propagate_at_launch", false)
    ),
    local.asg_tags,
    var.worker_group_tags[contains(keys(var.worker_group_tags), "${lookup(var.worker_groups_launch_template[count.index], "name", count.index)}") ? "${lookup(var.worker_groups_launch_template[count.index], "name", count.index)}" : "default"])
  }"]

  lifecycle {
    create_before_destroy = true
    ignore_changes        = ["desired_capacity"]
  }
}

resource "aws_launch_template" "workers_launch_template" {
  count       = "${var.worker_group_launch_template_count}"
  name_prefix = "${aws_eks_cluster.this.name}-${lookup(var.worker_groups_launch_template[count.index], "name", count.index)}"

  network_interfaces {
    associate_public_ip_address = "${lookup(var.worker_groups_launch_template[count.index], "public_ip", local.workers_group_defaults["public_ip"])}"
    delete_on_termination       = "${lookup(var.worker_groups_launch_template[count.index], "eni_delete", local.workers_group_defaults["eni_delete"])}"

    security_groups = [
      "${local.worker_security_group_id}",
      "${var.worker_additional_security_group_ids}",
      "${compact(split(",",lookup(var.worker_groups_launch_template[count.index],"additional_security_group_ids", local.workers_group_defaults["additional_security_group_ids"])))}",
    ]
  }

  iam_instance_profile {
    name = "${element(coalescelist(aws_iam_instance_profile.workers_launch_template.*.name, data.aws_iam_instance_profile.custom_worker_group_launch_template_iam_instance_profile.*.name), count.index)}"
  }

  image_id      = "${lookup(var.worker_groups_launch_template[count.index], "ami_id", local.workers_group_defaults["ami_id"])}"
  instance_type = "${lookup(var.worker_groups_launch_template[count.index], "instance_type", local.workers_group_defaults["instance_type"])}"
  key_name      = "${lookup(var.worker_groups_launch_template[count.index], "key_name", local.workers_group_defaults["key_name"])}"
  user_data     = "${base64encode(element(data.template_file.launch_template_userdata.*.rendered, count.index))}"
  ebs_optimized = "${lookup(var.worker_groups_launch_template[count.index], "ebs_optimized", lookup(local.ebs_optimized, lookup(var.worker_groups_launch_template[count.index], "instance_type", local.workers_group_defaults["instance_type"]), false))}"

  monitoring {
    enabled = "${lookup(var.worker_groups_launch_template[count.index], "enable_monitoring", local.workers_group_defaults["enable_monitoring"])}"
  }

  placement {
    tenancy    = "${lookup(var.worker_groups_launch_template[count.index], "launch_template_placement_tenancy", local.workers_group_defaults["launch_template_placement_tenancy"])}"
    group_name = "${lookup(var.worker_groups_launch_template[count.index], "launch_template_placement_group", local.workers_group_defaults["launch_template_placement_group"])}"
  }

  block_device_mappings {
    device_name = "${lookup(var.worker_groups_launch_template[count.index], "root_block_device_name", local.workers_group_defaults["root_block_device_name"])}"

    ebs {
      volume_size           = "${lookup(var.worker_groups_launch_template[count.index], "root_volume_size", local.workers_group_defaults["root_volume_size"])}"
      volume_type           = "${lookup(var.worker_groups_launch_template[count.index], "root_volume_type", local.workers_group_defaults["root_volume_type"])}"
      iops                  = "${lookup(var.worker_groups_launch_template[count.index], "root_iops", local.workers_group_defaults["root_iops"])}"
      encrypted             = "${lookup(var.worker_groups_launch_template[count.index], "root_encrypted", local.workers_group_defaults["root_encrypted"])}"
      kms_key_id            = "${lookup(var.worker_groups_launch_template[count.index], "root_kms_key_id", local.workers_group_defaults["root_kms_key_id"])}"
      delete_on_termination = true
    }
  }

  tags = "${var.tags}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_instance_profile" "workers_launch_template" {
  count       = "${var.manage_worker_iam_resources ? var.worker_group_launch_template_count : 0}"
  name_prefix = "${aws_eks_cluster.this.name}"
  role        = "${lookup(var.worker_groups_launch_template[count.index], "iam_role_id",  lookup(local.workers_group_defaults, "iam_role_id"))}"
  path        = "${var.iam_path}"
}
