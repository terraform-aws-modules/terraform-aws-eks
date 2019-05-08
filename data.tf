data "aws_region" "current" {}

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
    values = ["amazon-eks-node-${var.cluster_version}-${var.worker_ami_name_filter}"]
  }

  most_recent = true

  # Owner ID of AWS EKS team
  owners = ["602401143452"]
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

data "template_file" "kubeconfig" {
  template = "${file("${path.module}/templates/kubeconfig.tpl")}"

  vars {
    kubeconfig_name                   = "${local.kubeconfig_name}"
    endpoint                          = "${aws_eks_cluster.this.endpoint}"
    region                            = "${data.aws_region.current.name}"
    cluster_auth_base64               = "${aws_eks_cluster.this.certificate_authority.0.data}"
    aws_authenticator_command         = "${var.kubeconfig_aws_authenticator_command}"
    aws_authenticator_command_args    = "${length(var.kubeconfig_aws_authenticator_command_args) > 0 ? "        - ${join("\n        - ", var.kubeconfig_aws_authenticator_command_args)}" : "        - ${join("\n        - ", formatlist("\"%s\"", list("token", "-i", aws_eks_cluster.this.name)))}"}"
    aws_authenticator_additional_args = "${length(var.kubeconfig_aws_authenticator_additional_args) > 0 ? "        - ${join("\n        - ", var.kubeconfig_aws_authenticator_additional_args)}" : ""}"
    aws_authenticator_env_variables   = "${length(var.kubeconfig_aws_authenticator_env_variables) > 0 ? "      env:\n${join("\n", data.template_file.aws_authenticator_env_variables.*.rendered)}" : ""}"
  }
}

data "template_file" "aws_authenticator_env_variables" {
  count = "${length(var.kubeconfig_aws_authenticator_env_variables)}"

  template = <<EOF
        - name: $${key}
          value: $${value}
EOF

  vars {
    value = "${element(values(var.kubeconfig_aws_authenticator_env_variables), count.index)}"
    key   = "${element(keys(var.kubeconfig_aws_authenticator_env_variables), count.index)}"
  }
}

data "template_file" "userdata" {
  count    = "${var.worker_group_count}"
  template = "${file("${path.module}/templates/userdata.sh.tpl")}"

  vars {
    cluster_name         = "${aws_eks_cluster.this.name}"
    endpoint             = "${aws_eks_cluster.this.endpoint}"
    cluster_auth_base64  = "${aws_eks_cluster.this.certificate_authority.0.data}"
    pre_userdata         = "${lookup(var.worker_groups[count.index], "pre_userdata", local.workers_group_defaults["pre_userdata"])}"
    additional_userdata  = "${lookup(var.worker_groups[count.index], "additional_userdata", local.workers_group_defaults["additional_userdata"])}"
    bootstrap_extra_args = "${lookup(var.worker_groups[count.index], "bootstrap_extra_args", local.workers_group_defaults["bootstrap_extra_args"])}"
    kubelet_extra_args   = "${lookup(var.worker_groups[count.index], "kubelet_extra_args", local.workers_group_defaults["kubelet_extra_args"])}"
  }
}

data "template_file" "launch_template_userdata" {
  count    = "${var.worker_group_launch_template_count}"
  template = "${file("${path.module}/templates/userdata.sh.tpl")}"

  vars {
    cluster_name         = "${aws_eks_cluster.this.name}"
    endpoint             = "${aws_eks_cluster.this.endpoint}"
    cluster_auth_base64  = "${aws_eks_cluster.this.certificate_authority.0.data}"
    pre_userdata         = "${lookup(var.worker_groups_launch_template[count.index], "pre_userdata", local.workers_group_defaults["pre_userdata"])}"
    additional_userdata  = "${lookup(var.worker_groups_launch_template[count.index], "additional_userdata", local.workers_group_defaults["additional_userdata"])}"
    bootstrap_extra_args = "${lookup(var.worker_groups_launch_template[count.index], "bootstrap_extra_args", local.workers_group_defaults["bootstrap_extra_args"])}"
    kubelet_extra_args   = "${lookup(var.worker_groups_launch_template[count.index], "kubelet_extra_args", local.workers_group_defaults["kubelet_extra_args"])}"
  }
}

data "template_file" "workers_launch_template_mixed" {
  count    = "${var.worker_group_launch_template_mixed_count}"
  template = "${file("${path.module}/templates/userdata.sh.tpl")}"

  vars {
    cluster_name         = "${aws_eks_cluster.this.name}"
    endpoint             = "${aws_eks_cluster.this.endpoint}"
    cluster_auth_base64  = "${aws_eks_cluster.this.certificate_authority.0.data}"
    pre_userdata         = "${lookup(var.worker_groups_launch_template_mixed[count.index], "pre_userdata", local.workers_group_defaults["pre_userdata"])}"
    additional_userdata  = "${lookup(var.worker_groups_launch_template_mixed[count.index], "additional_userdata", local.workers_group_defaults["additional_userdata"])}"
    bootstrap_extra_args = "${lookup(var.worker_groups_launch_template_mixed[count.index], "bootstrap_extra_args", local.workers_group_defaults["bootstrap_extra_args"])}"
    kubelet_extra_args   = "${lookup(var.worker_groups_launch_template_mixed[count.index], "kubelet_extra_args", local.workers_group_defaults["kubelet_extra_args"])}"
  }
}

data "aws_iam_role" "custom_cluster_iam_role" {
  count = "${var.manage_cluster_iam_resources ? 0 : 1}"
  name  = "${var.cluster_iam_role_name}"
}

data "aws_iam_instance_profile" "custom_worker_group_iam_instance_profile" {
  count = "${var.manage_worker_iam_resources ? 0 : var.worker_group_count}"
  name  = "${lookup(var.worker_groups[count.index], "iam_instance_profile_name", local.workers_group_defaults["iam_instance_profile_name"])}"
}

data "aws_iam_instance_profile" "custom_worker_group_launch_template_iam_instance_profile" {
  count = "${var.manage_worker_iam_resources ? 0 : var.worker_group_launch_template_count}"
  name  = "${lookup(var.worker_groups_launch_template[count.index], "iam_instance_profile_name", local.workers_group_defaults["iam_instance_profile_name"])}"
}

data "aws_iam_instance_profile" "custom_worker_group_launch_template_mixed_iam_instance_profile" {
  count = "${var.manage_worker_iam_resources ? 0 : var.worker_group_launch_template_mixed_count}"
  name  = "${lookup(var.worker_groups_launch_template_mixed[count.index], "iam_instance_profile_name", local.workers_group_defaults["iam_instance_profile_name"])}"
}
