locals {
  worker_ami_name_filter = var.worker_ami_name_filter != "" ? var.worker_ami_name_filter : "amazon-eks-node-${var.cluster_version}-v*"
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
    values = [local.worker_ami_name_filter]
  }

  most_recent = true

  owners = [var.worker_ami_owner_id]
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
    key = keys(var.kubeconfig_aws_authenticator_env_variables)[count.index]
  }
}

data "aws_iam_role" "custom_cluster_iam_role" {
  count = var.manage_cluster_iam_resources ? 0 : 1
  name = var.cluster_iam_role_name
}
