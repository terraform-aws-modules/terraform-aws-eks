resource "null_resource" "install_kubectl" {
  provisioner "local-exec" {
    working_dir = "${path.module}"
    command     = "${local.install_kubectl_command}"
  }

  triggers {
    kube_config_map_rendered = "${data.template_file.kubeconfig.rendered}"
    config_map_rendered      = "${data.template_file.config_map_aws_auth.rendered}"
    endpoint                 = "${aws_eks_cluster.this.endpoint}"
  }

  count = "${var.install_kubectl ? 1 : 0}"
}

resource "local_file" "kubeconfig" {
  content  = "${data.template_file.kubeconfig.rendered}"
  filename = "${var.config_output_path}kubeconfig_${var.cluster_name}"
  count    = "${var.write_kubeconfig ? 1 : 0}"
}
