resource "aws_autoscaling_group" "workers" {
  name_prefix          = "${lookup(var.worker_groups[count.index], "name")}.${var.cluster_name}"
  launch_configuration = "${element(aws_launch_configuration.workers.*.id, count.index)}"
  desired_capacity     = "${lookup(var.worker_groups[count.index], "asg_desired_capacity")}"
  max_size             = "${lookup(var.worker_groups[count.index], "asg_max_size")}"
  min_size             = "${lookup(var.worker_groups[count.index], "asg_min_size")}"
  vpc_zone_identifier  = ["${var.subnets}"]
  count                = "${length(var.worker_groups)}"

  tags = ["${concat(
    list(
      map("key", "Name", "value", "${lookup(var.worker_groups[count.index], "name")}.${var.cluster_name}-eks_asg", "propagate_at_launch", true),
      map("key", "kubernetes.io/cluster/${var.cluster_name}", "value", "owned", "propagate_at_launch", true),
    ),
    local.asg_tags)
  }"]
}

resource "aws_launch_configuration" "workers" {
  name_prefix                 = "${lookup(var.worker_groups[count.index], "name")}.${lookup(var.worker_groups[count.index], "name")}.${var.cluster_name}"
  associate_public_ip_address = true
  iam_instance_profile        = "${var.iam_instance_profile}"
  image_id                    = "${lookup(var.worker_groups[count.index], "ami_id") == "" ? data.aws_ami.eks_worker.id : lookup(var.worker_groups[count.index], "ami_id")}"
  instance_type               = "${lookup(var.worker_groups[count.index], "instance_type")}"
  security_groups             = ["${var.security_group_id}"]
  user_data_base64            = "${base64encode(element(data.template_file.userdata.*.rendered, count.index))}"
  ebs_optimized               = "${var.ebs_optimized_workers ? lookup(local.ebs_optimized_types, lookup(var.worker_groups[count.index], "instance_type"), false) : false}"
  count                       = "${length(var.worker_groups)}"

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    delete_on_termination = true
  }
}

data template_file userdata {
  template = "${file("${path.module}/templates/userdata.sh.tpl")}"
  count    = "${length(var.worker_groups)}"

  vars {
    region              = "${var.aws_region}"
    max_pod_count       = "${lookup(local.max_pod_per_node, lookup(var.worker_groups[count.index], "instance_type"))}"
    cluster_name        = "${var.cluster_name}"
    endpoint            = "${var.endpoint}"
    cluster_auth_base64 = "${var.certificate_authority}"
    additional_userdata = "${var.additional_userdata}"
  }
}

resource "null_resource" "tags_as_list_of_maps" {
  count = "${length(keys(var.tags))}"

  triggers = "${map(
    "key", "${element(keys(var.tags), count.index)}",
    "value", "${element(values(var.tags), count.index)}",
    "propagate_at_launch", "true"
  )}"
}
