data "aws_region" "current" {}

data "aws_iam_role" "workers" {
  name = "${local.worker_instance_role_name}"
}

data "aws_iam_instance_profile" "workers" {
  name = "${local.worker_instance_profile_name}"
}

data "aws_iam_policy_document" "workers_assume_role_policy" {
  statement {
    sid = "EKSWorkerAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_ami" "eks_worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon
}

data "aws_iam_role" "cluster" {
  name = "${local.cluster_service_role_name}"
}

data "aws_iam_policy_document" "cluster_assume_role_policy" {
  statement {
    sid = "EKSClusterAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

data "template_file" "userdata" {
  template = "${file("${path.module}/templates/userdata.sh.tpl")}"
  count    = "${var.worker_group_count}"

  vars {
    cluster_name        = "${aws_eks_cluster.this.name}"
    endpoint            = "${aws_eks_cluster.this.endpoint}"
    cluster_auth_base64 = "${aws_eks_cluster.this.certificate_authority.0.data}"
    pre_userdata        = "${lookup(var.worker_groups[count.index], "pre_userdata",lookup(local.workers_group_defaults, "pre_userdata"))}"
    additional_userdata = "${lookup(var.worker_groups[count.index], "additional_userdata",lookup(local.workers_group_defaults, "additional_userdata"))}"
    kubelet_extra_args  = "${lookup(var.worker_groups[count.index], "kubelet_extra_args",lookup(local.workers_group_defaults, "kubelet_extra_args"))}"
  }
}
