resource "local_file" "kubeconfig" {
  count    = var.write_kubeconfig && local.enabled ? 1 : 0
  content  = data.template_file.kubeconfig.rendered
  filename = "${substr(var.config_output_path, -1, 1) == "/" ? "${var.config_output_path}kubeconfig_${var.cluster_name}" : var.config_output_path}"
}
