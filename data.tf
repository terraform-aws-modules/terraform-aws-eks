data "aws_iam_policy_document" "workers_assume_role_policy" {
  statement {
    sid = "EKSWorkerAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = [local.ec2_principal]
    }
  }
}

data "aws_ami" "eks_worker" {
  filter {
    name   = "name"
    values = [local.worker_ami_name_filter]
  }

  most_recent = true

  owners = [var.worker_ami_owner_id]
}

data "aws_ami" "eks_worker_windows" {
  filter {
    name   = "name"
    values = [local.worker_ami_name_filter_windows]
  }

  filter {
    name   = "platform"
    values = ["windows"]
  }

  most_recent = true

  owners = [var.worker_ami_owner_id_windows]
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
  for_each = var.create_eks ? local.worker_groups_with_defaults : {}

  template = (each.value.userdata_template_file != ""
    ? each.value.userdata_template_file
    : file(
      each.value.platform == "windows"
      ? "${path.module}/templates/userdata_windows.tpl"
      : "${path.module}/templates/userdata.sh.tpl"
    )
  )

  vars = merge(
    {
      platform             = each.value.platform
      cluster_name         = coalescelist(aws_eks_cluster.this[*].name, [""])[0]
      endpoint             = coalescelist(aws_eks_cluster.this[*].endpoint, [""])[0]
      cluster_auth_base64  = coalescelist(aws_eks_cluster.this[*].certificate_authority[0].data, [""])[0]
      pre_userdata         = each.value.pre_userdata
      additional_userdata  = each.value.additional_userdata
      bootstrap_extra_args = each.value.bootstrap_extra_args
      kubelet_extra_args   = each.value.kubelet_extra_args
    },
    each.value.userdata_template_extra_args
  )
}

data "template_file" "launch_template_userdata" {
  for_each = var.create_eks ? local.worker_groups_launch_template_with_defaults : {}

  template = (each.value.userdata_template_file != ""
    ? each.value.userdata_template_file
    : file(
      each.value.platform == "windows"
      ? "${path.module}/templates/userdata_windows.tpl"
      : "${path.module}/templates/userdata.sh.tpl"
    )
  )

  vars = merge(
    {
      platform             = each.value.platform
      cluster_name         = coalescelist(aws_eks_cluster.this[*].name, [""])[0]
      endpoint             = coalescelist(aws_eks_cluster.this[*].endpoint, [""])[0]
      cluster_auth_base64  = coalescelist(aws_eks_cluster.this[*].certificate_authority[0].data, [""])[0]
      pre_userdata         = each.value.pre_userdata
      additional_userdata  = each.value.additional_userdata
      bootstrap_extra_args = each.value.bootstrap_extra_args
      kubelet_extra_args   = each.value.kubelet_extra_args
    },
    each.value.userdata_template_extra_args
  )
}

data "aws_iam_role" "custom_cluster_iam_role" {
  count = var.manage_cluster_iam_resources ? 0 : 1
  name  = var.cluster_iam_role_name
}

data "aws_iam_instance_profile" "custom_worker_group_iam_instance_profile" {
  for_each = var.manage_worker_iam_resources ? {} : local.worker_groups_with_defaults
  name     = each.value.iam_instance_profile_name
}

data "aws_iam_instance_profile" "custom_worker_group_launch_template_iam_instance_profile" {
  for_each = var.manage_worker_iam_resources ? {} : local.worker_groups_launch_template_with_defaults
  name     = each.value.iam_instance_profile_name
}

data "aws_partition" "current" {}
