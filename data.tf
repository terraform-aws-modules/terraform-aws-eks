locals {
  worker_ami_name_filter = var.worker_ami_name_filter != "" ? var.worker_ami_name_filter : "amazon-eks-node-${var.cluster_version}-v*"

  # Windows nodes are available from k8s 1.14. If cluster version is less than 1.14, fix ami filter to some constant to not fail on 'terraform plan'.
  worker_ami_name_filter_windows = (var.worker_ami_name_filter_windows != "" ?
    var.worker_ami_name_filter_windows : "Windows_Server-2019-English-Core-EKS_Optimized-${tonumber(var.cluster_version) >= 1.14 ? var.cluster_version : 1.14}-*"
  )
  ec2_principal = "ec2.${data.aws_partition.current.dns_suffix}"
}

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

data "template_file" "kubeconfig" {
  count    = var.create_eks ? 1 : 0
  template = file("${path.module}/templates/kubeconfig.tpl")

  vars = {
    kubeconfig_name           = local.kubeconfig_name
    endpoint                  = aws_eks_cluster.this[0].endpoint
    cluster_auth_base64       = aws_eks_cluster.this[0].certificate_authority[0].data
    aws_authenticator_command = var.kubeconfig_aws_authenticator_command
    aws_authenticator_command_args = length(var.kubeconfig_aws_authenticator_command_args) > 0 ? "        - ${join(
      "\n        - ",
      var.kubeconfig_aws_authenticator_command_args,
      )}" : "        - ${join(
      "\n        - ",
      formatlist("\"%s\"", ["token", "-i", aws_eks_cluster.this[0].name]),
    )}"
    aws_authenticator_additional_args = length(var.kubeconfig_aws_authenticator_additional_args) > 0 ? "        - ${join(
      "\n        - ",
      var.kubeconfig_aws_authenticator_additional_args,
    )}" : ""
    aws_authenticator_env_variables = length(var.kubeconfig_aws_authenticator_env_variables) > 0 ? "      env:\n${join(
      "\n",
      data.template_file.aws_authenticator_env_variables.*.rendered,
    )}" : ""
  }
}

data "template_file" "aws_authenticator_env_variables" {
  count = length(var.kubeconfig_aws_authenticator_env_variables)

  template = <<EOF
        - name: $${key}
          value: $${value}
EOF


  vars = {
    value = values(var.kubeconfig_aws_authenticator_env_variables)[count.index]
    key   = keys(var.kubeconfig_aws_authenticator_env_variables)[count.index]
  }
}

data "template_file" "userdata" {
  count = var.create_eks ? local.worker_group_count : 0
  template = lookup(
    var.worker_groups[count.index],
    "userdata_template_file",
    file(
      lookup(var.worker_groups[count.index], "platform", local.workers_group_defaults["platform"]) == "windows"
      ? "${path.module}/templates/userdata_windows.tpl"
      : "${path.module}/templates/userdata.sh.tpl"
    )
  )

  vars = merge({
    platform            = lookup(var.worker_groups[count.index], "platform", local.workers_group_defaults["platform"])
    cluster_name        = aws_eks_cluster.this[0].name
    endpoint            = aws_eks_cluster.this[0].endpoint
    cluster_auth_base64 = aws_eks_cluster.this[0].certificate_authority[0].data
    pre_userdata = lookup(
      var.worker_groups[count.index],
      "pre_userdata",
      local.workers_group_defaults["pre_userdata"],
    )
    additional_userdata = lookup(
      var.worker_groups[count.index],
      "additional_userdata",
      local.workers_group_defaults["additional_userdata"],
    )
    bootstrap_extra_args = lookup(
      var.worker_groups[count.index],
      "bootstrap_extra_args",
      local.workers_group_defaults["bootstrap_extra_args"],
    )
    kubelet_extra_args = lookup(
      var.worker_groups[count.index],
      "kubelet_extra_args",
      local.workers_group_defaults["kubelet_extra_args"],
    )
    },
    lookup(
      var.worker_groups[count.index],
      "userdata_template_extra_args",
      local.workers_group_defaults["userdata_template_extra_args"]
    )
  )
}

data "template_file" "launch_template_userdata" {
  count = var.create_eks ? local.worker_group_launch_template_count : 0
  template = lookup(
    var.worker_groups_launch_template[count.index],
    "userdata_template_file",
    file(
      lookup(var.worker_groups_launch_template[count.index], "platform", local.workers_group_defaults["platform"]) == "windows"
      ? "${path.module}/templates/userdata_windows.tpl"
      : "${path.module}/templates/userdata.sh.tpl"
    )
  )

  vars = merge({
    platform            = lookup(var.worker_groups_launch_template[count.index], "platform", local.workers_group_defaults["platform"])
    cluster_name        = aws_eks_cluster.this[0].name
    endpoint            = aws_eks_cluster.this[0].endpoint
    cluster_auth_base64 = aws_eks_cluster.this[0].certificate_authority[0].data
    pre_userdata = lookup(
      var.worker_groups_launch_template[count.index],
      "pre_userdata",
      local.workers_group_defaults["pre_userdata"],
    )
    additional_userdata = lookup(
      var.worker_groups_launch_template[count.index],
      "additional_userdata",
      local.workers_group_defaults["additional_userdata"],
    )
    bootstrap_extra_args = lookup(
      var.worker_groups_launch_template[count.index],
      "bootstrap_extra_args",
      local.workers_group_defaults["bootstrap_extra_args"],
    )
    kubelet_extra_args = lookup(
      var.worker_groups_launch_template[count.index],
      "kubelet_extra_args",
      local.workers_group_defaults["kubelet_extra_args"],
    )
    },
    lookup(
      var.worker_groups_launch_template[count.index],
      "userdata_template_extra_args",
      local.workers_group_defaults["userdata_template_extra_args"]
    )
  )
}

data "aws_iam_role" "custom_cluster_iam_role" {
  count = var.manage_cluster_iam_resources ? 0 : 1
  name  = var.cluster_iam_role_name
}

data "aws_iam_instance_profile" "custom_worker_group_iam_instance_profile" {
  count = var.manage_worker_iam_resources ? 0 : local.worker_group_count
  name = lookup(
    var.worker_groups[count.index],
    "iam_instance_profile_name",
    local.workers_group_defaults["iam_instance_profile_name"],
  )
}

data "aws_iam_instance_profile" "custom_worker_group_launch_template_iam_instance_profile" {
  count = var.manage_worker_iam_resources ? 0 : local.worker_group_launch_template_count
  name = lookup(
    var.worker_groups_launch_template[count.index],
    "iam_instance_profile_name",
    local.workers_group_defaults["iam_instance_profile_name"],
  )
}

data "aws_partition" "current" {}
