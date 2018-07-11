resource "local_file" "config_map_aws_auth" {
  content  = "${data.template_file.config_map_aws_auth.rendered}"
  filename = "${var.config_output_path}/config-map-aws-auth.yaml"
  count    = "${var.manage_aws_auth ? 1 : 0}"
}

resource "null_resource" "update_config_map_aws_auth" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${var.config_output_path}/config-map-aws-auth.yaml --kubeconfig ${var.config_output_path}/kubeconfig"
  }

  triggers {
    config_map_rendered = "${data.template_file.config_map_aws_auth.rendered}"
  }

  count = "${var.manage_aws_auth ? 1 : 0}"
}
