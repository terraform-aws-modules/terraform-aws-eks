data "aws_region" "current" {}

data "aws_ami" "eks_worker" {
  filter {
    name   = "name"
    values = ["eks-worker-*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon
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

data template_file userdata {
  template = "${file("${path.module}/templates/userdata.sh.tpl")}"

  vars {
    region              = "${data.aws_region.current.name}"
    max_pod_count       = "${lookup(local.max_pod_per_node, var.workers_instance_type)}"
    cluster_name        = "${var.cluster_name}"
    endpoint            = "${aws_eks_cluster.this.endpoint}"
    cluster_auth_base64 = "${aws_eks_cluster.this.certificate_authority.0.data}"
    additional_userdata = "${var.additional_userdata}"
  }
}

data template_file kubeconfig {
  template = "${file("${path.module}/templates/kubeconfig.tpl")}"

  vars {
    cluster_name        = "${var.cluster_name}"
    endpoint            = "${aws_eks_cluster.this.endpoint}"
    region              = "${data.aws_region.current.name}"
    cluster_auth_base64 = "${aws_eks_cluster.this.certificate_authority.0.data}"
  }
}

data template_file config_map_aws_auth {
  template = "${file("${path.module}/templates/config-map-aws-auth.yaml.tpl")}"

  vars {
    role_arn = "${aws_iam_role.workers.arn}"
  }
}

module "ebs_optimized" {
  source        = "modules/util/ebs_optimized/"
  instance_type = "${var.workers_instance_type}"
}
