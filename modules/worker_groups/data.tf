data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "aws_iam_instance_profile" "custom_worker_group_iam_instance_profile" {
  for_each = var.manage_worker_iam_resources ? {} : local.worker_group_configurations

  name = each.value["iam_instance_profile_name"]
}

data "aws_ami" "eks_worker" {
  count = local.worker_has_linux_ami ? 1 : 0

  filter {
    name   = "name"
    values = [local.worker_ami_name_filter]
  }

  most_recent = true

  owners = [var.worker_ami_owner_id]
}

data "aws_ami" "eks_worker_windows" {
  count = local.worker_has_windows_ami ? 1 : 0

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
