resource "local_file" "config_map_aws_auth" {
  count    = var.write_aws_auth_config ? 1 : 0
  content  = data.template_file.config_map_aws_auth.rendered
  filename = "${var.config_output_path}config-map-aws-auth_${var.cluster_name}.yaml"
}

resource "null_resource" "update_config_map_aws_auth" {
  count      = var.manage_aws_auth ? 1 : 0
  depends_on = [aws_eks_cluster.this]

  provisioner "local-exec" {
    working_dir = path.module

    command = <<EOS
completed_apply=0
for i in `seq 1 10`; do \
echo "${null_resource.update_config_map_aws_auth[0].triggers.kube_config_map_rendered}" > kube_config.yaml && \
echo "${null_resource.update_config_map_aws_auth[0].triggers.config_map_rendered}" > aws_auth_configmap.yaml && \
kubectl apply -f aws_auth_configmap.yaml --kubeconfig kube_config.yaml && \
completed_apply=1 && break || \
sleep 10; \
done; \
rm aws_auth_configmap.yaml kube_config.yaml;
if [ "$completed_apply" = "0" ]; then exit 1; fi;
EOS


    interpreter = var.local_exec_interpreter
  }

  triggers = {
    kube_config_map_rendered = data.template_file.kubeconfig.rendered
    config_map_rendered      = data.template_file.config_map_aws_auth.rendered
    endpoint                 = aws_eks_cluster.this.endpoint
  }
}

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

data "template_file" "config_map_aws_auth" {
  template = file("${path.module}/templates/config-map-aws-auth.yaml.tpl")

  vars = {
    worker_role_arn = join(
      "",
      distinct(
        concat(
          data.template_file.launch_template_worker_role_arns.*.rendered,
          data.template_file.worker_role_arns.*.rendered,
        ),
      ),
    )
    map_users    = yamlencode(var.map_users),
    map_roles    = yamlencode(var.map_roles),
    map_accounts = yamlencode(var.map_accounts)
  }
}
