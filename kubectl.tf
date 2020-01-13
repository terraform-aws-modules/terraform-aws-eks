resource "local_file" "kubeconfig" {
  count           = var.write_kubeconfig && var.create_eks ? 1 : 0
  content         = data.template_file.kubeconfig[0].rendered
  file_permission = var.config_file_permissions
  filename        = substr(var.config_output_path, -1, 1) == "/" ? "${var.config_output_path}kubeconfig_${var.cluster_name}" : var.config_output_path
}
