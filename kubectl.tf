resource "local_file" "kubeconfig" {
  count    = var.create_cluster && var.write_kubeconfig ? 1 : 0
  content  = data.template_file.kubeconfig.0.rendered
  filename = "${substr(var.config_output_path, -1, 1) == "/" ? "${var.config_output_path}kubeconfig_${var.cluster_name}" : var.config_output_path}"
}

