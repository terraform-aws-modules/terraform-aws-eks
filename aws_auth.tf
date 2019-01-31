resource "local_file" "config_map_aws_auth" {
  content  = "${data.template_file.config_map_aws_auth.rendered}"
  filename = "${var.config_output_path}config-map-aws-auth_${var.cluster_name}.yaml"
  count    = "${var.write_aws_auth_config ? 1 : 0}"
}

resource "null_resource" "update_config_map_aws_auth" {
  depends_on = ["aws_eks_cluster.this"]

  # Cluster may not yet be fully running when this executes, so retry
  # saving config map up to 10 times
  # We use shell tricks to pass both the kubeconfig and config map via
  # heredocs without writing files to disk; we pass them in using file
  # descriptors 3 and 4 respectively
  provisioner "local-exec" {
    command = <<EOT
for i in `seq 1 10`; do kubectl apply -f /dev/fd/3 --kubeconfig /dev/fd/4 3<<'EOF1' 4<<'EOF2' && exit 0 || sleep 10
${data.template_file.config_map_aws_auth.rendered}
EOF1
${data.template_file.kubeconfig.rendered}
EOF2
done; exit 1
EOT

    interpreter = ["${var.local_exec_interpreter}"]
  }

  triggers {
    kube_config_map_rendered = "${data.template_file.kubeconfig.rendered}"
    config_map_rendered      = "${data.template_file.config_map_aws_auth.rendered}"
    endpoint                 = "${aws_eks_cluster.this.endpoint}"
  }

  count = "${var.manage_aws_auth ? 1 : 0}"
}

data "aws_caller_identity" "current" {}

data "template_file" "launch_template_worker_role_arns" {
  count    = "${var.worker_group_launch_template_count}"
  template = "${file("${path.module}/templates/worker-role.tpl")}"

  vars {
    worker_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${element(aws_iam_instance_profile.workers_launch_template.*.role, count.index)}"
  }
}

data "template_file" "worker_role_arns" {
  count    = "${var.worker_group_count}"
  template = "${file("${path.module}/templates/worker-role.tpl")}"

  vars {
    worker_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${element(aws_iam_instance_profile.workers.*.role, count.index)}"
  }
}

data "template_file" "config_map_aws_auth" {
  template = "${file("${path.module}/templates/config-map-aws-auth.yaml.tpl")}"

  vars {
    worker_role_arn = "${join("", distinct(concat(data.template_file.launch_template_worker_role_arns.*.rendered, data.template_file.worker_role_arns.*.rendered)))}"
    map_users       = "${join("", data.template_file.map_users.*.rendered)}"
    map_roles       = "${join("", data.template_file.map_roles.*.rendered)}"
    map_accounts    = "${join("", data.template_file.map_accounts.*.rendered)}"
  }
}

data "template_file" "map_users" {
  count    = "${var.map_users_count}"
  template = "${file("${path.module}/templates/config-map-aws-auth-map_users.yaml.tpl")}"

  vars {
    user_arn = "${lookup(var.map_users[count.index], "user_arn")}"
    username = "${lookup(var.map_users[count.index], "username")}"
    group    = "${lookup(var.map_users[count.index], "group")}"
  }
}

data "template_file" "map_roles" {
  count    = "${var.map_roles_count}"
  template = "${file("${path.module}/templates/config-map-aws-auth-map_roles.yaml.tpl")}"

  vars {
    role_arn = "${lookup(var.map_roles[count.index], "role_arn")}"
    username = "${lookup(var.map_roles[count.index], "username")}"
    group    = "${lookup(var.map_roles[count.index], "group")}"
  }
}

data "template_file" "map_accounts" {
  count    = "${var.map_accounts_count}"
  template = "${file("${path.module}/templates/config-map-aws-auth-map_accounts.yaml.tpl")}"

  vars {
    account_number = "${element(var.map_accounts, count.index)}"
  }
}
