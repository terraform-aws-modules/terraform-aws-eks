resource "local_file" "kubeconfig" {
  content  = "${data.template_file.kubeconfig.rendered}"
  filename = "${var.config_output_path}/kubeconfig"
  count    = "${var.configure_kubectl_session ? 1 : 0}"
}

resource "local_file" "config_map_aws_auth" {
  content  = "${data.template_file.config_map_aws_auth.rendered}"
  filename = "${var.config_output_path}/config-map-aws-auth.yaml"
  count    = "${var.configure_kubectl_session ? 1 : 0}"
}

resource "null_resource" "configure_kubectl" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${var.config_output_path}/config-map-aws-auth.yaml --kubeconfig ${var.config_output_path}/kubeconfig"
  }

  triggers {
    config_map_rendered = "${data.template_file.config_map_aws_auth.rendered}"
    kubeconfig_rendered = "${data.template_file.kubeconfig.rendered}"
  }

  count = "${var.configure_kubectl_session ? 1 : 0}"
}
