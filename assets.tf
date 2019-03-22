resource "local_file" "kubeconfig" {
  content  = "${data.template_file.kubeconfig.rendered}"
  filename = "${local.asset_dir}/auth/kubeconfig"
}
