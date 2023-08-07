data "aws_caller_identity" "current" {
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
${join("", distinct(concat(data.template_file.node_group_arns.*.rendered
)))}
%{if length(var.map_roles) != 0}${yamlencode(var.map_roles)} %{endif}
    EOF
      mapUsers    = yamlencode(var.map_users)
      mapAccounts = yamlencode(var.map_accounts)
      }
      }
