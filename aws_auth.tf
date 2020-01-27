data "aws_caller_identity" "current" {
}

data "template_file" "launch_template_worker_role_arns" {
  count    = var.create_eks ? local.worker_group_launch_template_count : 0
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
  count    = var.create_eks ? local.worker_group_count : 0
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

data "template_file" "node_group_arns" {
  count    = var.create_eks ? length(module.node_groups.aws_auth_roles) : 0
  template = file("${path.module}/templates/worker-role.tpl")

  vars = module.node_groups.aws_auth_roles[count.index]
}

resource "kubernetes_config_map" "aws_auth" {
  count      = var.create_eks && var.manage_aws_auth ? 1 : 0
  depends_on = [null_resource.wait_for_cluster[0]]

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = <<EOF
${join("", distinct(concat(data.template_file.launch_template_worker_role_arns.*.rendered, data.template_file.worker_role_arns.*.rendered, data.template_file.node_group_arns.*.rendered
)))}
%{if length(var.map_roles) != 0}${yamlencode(var.map_roles)}%{endif}
    EOF
mapUsers    = yamlencode(var.map_users)
mapAccounts = yamlencode(var.map_accounts)
}
}
