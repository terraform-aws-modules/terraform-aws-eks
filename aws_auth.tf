data "aws_caller_identity" "current" {
}

data "template_file" "launch_template_worker_role_arns" {
  count    = local.worker_group_launch_template_count
  template = file("${path.module}/templates/worker-role.tpl")

  vars = {
    worker_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${element(
      coalescelist(
        aws_iam_instance_profile.workers_launch_template.*.role,
        data.aws_iam_instance_profile.custom_worker_group_launch_template_iam_instance_profile.*.role_name,
      ),
      count.index,
    )}"
    platform = lookup(
      var.worker_groups_launch_template[count.index],
      "platform",
      local.workers_group_defaults["platform"]
    )
  }
}

data "template_file" "worker_role_arns" {
  count    = local.worker_group_count
  template = file("${path.module}/templates/worker-role.tpl")

  vars = {
    worker_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${element(
      coalescelist(
        aws_iam_instance_profile.workers.*.role,
        data.aws_iam_instance_profile.custom_worker_group_iam_instance_profile.*.role_name,
        [""]
      ),
      count.index,
    )}"
    platform = lookup(
      var.worker_groups[count.index],
      "platform",
      local.workers_group_defaults["platform"]
    )
  }
}

resource "kubernetes_config_map" "aws_auth" {
  count = var.manage_aws_auth ? 1 : 0

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles    = <<EOF
${join("", distinct(concat(data.template_file.launch_template_worker_role_arns.*.rendered, data.template_file.worker_role_arns.*.rendered)))}
${yamlencode(var.map_roles)}
    EOF
    mapUsers    = yamlencode(var.map_users)
    mapAccounts = yamlencode(var.map_accounts)
  }
}
