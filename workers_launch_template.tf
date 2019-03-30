# Worker Groups using Launch Templates

resource "aws_autoscaling_group" "workers_launch_template" {
  name_prefix       = "${aws_eks_cluster.this.name}-${lookup(var.worker_groups_launch_template[count.index], "name", count.index)}"
  desired_capacity  = "${lookup(var.worker_groups_launch_template[count.index], "asg_desired_capacity", local.workers_group_launch_template_defaults["asg_desired_capacity"])}"
  max_size          = "${lookup(var.worker_groups_launch_template[count.index], "asg_max_size", local.workers_group_launch_template_defaults["asg_max_size"])}"
  min_size          = "${lookup(var.worker_groups_launch_template[count.index], "asg_min_size", local.workers_group_launch_template_defaults["asg_min_size"])}"
  force_delete      = "${lookup(var.worker_groups_launch_template[count.index], "asg_force_delete", local.workers_group_launch_template_defaults["asg_force_delete"])}"
  target_group_arns = ["${compact(split(",", coalesce(lookup(var.worker_groups_launch_template[count.index], "target_group_arns", ""), local.workers_group_launch_template_defaults["target_group_arns"])))}"]

  mixed_instances_policy {
    instances_distribution {
      on_demand_allocation_strategy            = "${lookup(var.worker_groups_launch_template[count.index], "on_demand_allocation_strategy", local.workers_group_launch_template_defaults["on_demand_allocation_strategy"])}"
      on_demand_base_capacity                  = "${lookup(var.worker_groups_launch_template[count.index], "on_demand_base_capacity", local.workers_group_launch_template_defaults["on_demand_base_capacity"])}"
      on_demand_percentage_above_base_capacity = "${lookup(var.worker_groups_launch_template[count.index], "on_demand_percentage_above_base_capacity", local.workers_group_launch_template_defaults["on_demand_percentage_above_base_capacity"])}"
      spot_allocation_strategy                 = "${lookup(var.worker_groups_launch_template[count.index], "spot_allocation_strategy", local.workers_group_launch_template_defaults["spot_allocation_strategy"])}"
      spot_instance_pools                      = "${lookup(var.worker_groups_launch_template[count.index], "spot_instance_pools", local.workers_group_launch_template_defaults["spot_instance_pools"])}"
      spot_max_price                           = "${lookup(var.worker_groups_launch_template[count.index], "spot_max_price", local.workers_group_launch_template_defaults["spot_max_price"])}"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = "${element(aws_launch_template.workers_launch_template.*.id, count.index)}"
        version            = "$Latest"
      }

      override {
        instance_type = "${lookup(var.worker_groups_launch_template[count.index], "instance_type", local.workers_group_launch_template_defaults["instance_type"])}"
      }

      override {
        instance_type = "${lookup(var.worker_groups_launch_template[count.index], "override_instance_type", local.workers_group_launch_template_defaults["override_instance_type"])}"
      }
    }
  }

  vpc_zone_identifier   = ["${split(",", coalesce(lookup(var.worker_groups_launch_template[count.index], "subnets", ""), local.workers_group_launch_template_defaults["subnets"]))}"]
  protect_from_scale_in = "${lookup(var.worker_groups_launch_template[count.index], "protect_from_scale_in", local.workers_group_launch_template_defaults["protect_from_scale_in"])}"
  suspended_processes   = ["${compact(split(",", coalesce(lookup(var.worker_groups_launch_template[count.index], "suspended_processes", ""), local.workers_group_launch_template_defaults["suspended_processes"])))}"]
  enabled_metrics       = ["${compact(split(",", coalesce(lookup(var.worker_groups_launch_template[count.index], "enabled_metrics", ""), local.workers_group_launch_template_defaults["enabled_metrics"])))}"]
  count                 = "${var.worker_group_launch_template_count}"

  tags = ["${concat(
    list(
      map("key", "Name", "value", "${aws_eks_cluster.this.name}-${lookup(var.worker_groups_launch_template[count.index], "name", count.index)}-eks_asg", "propagate_at_launch", true),
      map("key", "kubernetes.io/cluster/${aws_eks_cluster.this.name}", "value", "owned", "propagate_at_launch", true),
      map("key", "k8s.io/cluster-autoscaler/${lookup(var.worker_groups_launch_template[count.index], "autoscaling_enabled", local.workers_group_launch_template_defaults["autoscaling_enabled"]) == 1 ? "enabled" : "disabled"  }", "value", "true", "propagate_at_launch", false),
      map("key", "k8s.io/cluster-autoscaler/${aws_eks_cluster.this.name}", "value", "", "propagate_at_launch", false),
      map("key", "k8s.io/cluster-autoscaler/node-template/resources/ephemeral-storage", "value", "${lookup(var.worker_groups_launch_template[count.index], "root_volume_size", local.workers_group_launch_template_defaults["root_volume_size"])}Gi", "propagate_at_launch", false)
    ),
    local.asg_tags,
    var.worker_group_launch_template_tags[contains(keys(var.worker_group_launch_template_tags), "${lookup(var.worker_groups_launch_template[count.index], "name", count.index)}") ? "${lookup(var.worker_groups_launch_template[count.index], "name", count.index)}" : "default"])
  }"]

  lifecycle {
    create_before_destroy = true

    ignore_changes = ["desired_capacity"]
  }
}

resource "aws_launch_template" "workers_launch_template" {
  name_prefix = "${aws_eks_cluster.this.name}-${lookup(var.worker_groups_launch_template[count.index], "name", count.index)}"

  network_interfaces {
    associate_public_ip_address = "${lookup(var.worker_groups_launch_template[count.index], "public_ip", local.workers_group_launch_template_defaults["public_ip"])}"
    security_groups             = ["${local.worker_security_group_id}", "${var.worker_additional_security_group_ids}", "${compact(split(",",lookup(var.worker_groups_launch_template[count.index],"additional_security_group_ids", local.workers_group_launch_template_defaults["additional_security_group_ids"])))}"]
  }

  iam_instance_profile = {
    name = "${element(aws_iam_instance_profile.workers_launch_template.*.name, count.index)}"
  }

  image_id      = "${lookup(var.worker_groups_launch_template[count.index], "ami_id", local.workers_group_launch_template_defaults["ami_id"])}"
  instance_type = "${lookup(var.worker_groups_launch_template[count.index], "instance_type", local.workers_group_launch_template_defaults["instance_type"])}"
  key_name      = "${lookup(var.worker_groups_launch_template[count.index], "key_name", local.workers_group_launch_template_defaults["key_name"])}"
  user_data     = "${base64encode(element(data.template_file.launch_template_userdata.*.rendered, count.index))}"
  ebs_optimized = "${lookup(var.worker_groups_launch_template[count.index], "ebs_optimized", lookup(local.ebs_optimized, lookup(var.worker_groups_launch_template[count.index], "instance_type", local.workers_group_launch_template_defaults["instance_type"]), false))}"

  monitoring {
    enabled = "${lookup(var.worker_groups_launch_template[count.index], "enable_monitoring", local.workers_group_launch_template_defaults["enable_monitoring"])}"
  }

  placement {
    tenancy = "${lookup(var.worker_groups_launch_template[count.index], "placement_tenancy", local.workers_group_launch_template_defaults["placement_tenancy"])}"
  }

  count = "${var.worker_group_launch_template_count}"

  lifecycle {
    create_before_destroy = true
  }

  block_device_mappings {
    device_name = "${data.aws_ami.eks_worker.root_device_name}"

    ebs {
      volume_size           = "${lookup(var.worker_groups_launch_template[count.index], "root_volume_size", local.workers_group_launch_template_defaults["root_volume_size"])}"
      volume_type           = "${lookup(var.worker_groups_launch_template[count.index], "root_volume_type", local.workers_group_launch_template_defaults["root_volume_type"])}"
      iops                  = "${lookup(var.worker_groups_launch_template[count.index], "root_iops", local.workers_group_launch_template_defaults["root_iops"])}"
      encrypted             = "${lookup(var.worker_groups_launch_template[count.index], "root_encrypted", local.workers_group_launch_template_defaults["root_encrypted"])}"
      kms_key_id            = "${lookup(var.worker_groups_launch_template[count.index], "kms_key_id", local.workers_group_launch_template_defaults["kms_key_id"])}"
      delete_on_termination = true
    }
  }
}

resource "aws_iam_instance_profile" "workers_launch_template" {
  name_prefix = "${aws_eks_cluster.this.name}"
  role        = "${lookup(var.worker_groups_launch_template[count.index], "iam_role_id",  lookup(local.workers_group_launch_template_defaults, "iam_role_id"))}"
  count       = "${var.worker_group_launch_template_count}"
  path        = "${var.iam_path}"
}
