resource "null_resource" "install_kubectl" {
  provisioner "local-exec" {
    working_dir = "${path.module}"
    command     = <<EOH
curl -LO https://storage.googleapis.com/kubernetes-release/release/v${local.kubectl_versions[var.cluster_version]}/bin/linux/amd64/kubectl && \
chmod +x ./kubectl && \
curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.12.7/2019-03-27/bin/linux/amd64/aws-iam-authenticator && \
chmod +x ./aws-iam-authenticator
EOH
  }

  triggers {
    kube_config_map_rendered = "${data.template_file.kubeconfig.rendered}"
    config_map_rendered      = "${data.template_file.config_map_aws_auth.rendered}"
    endpoint                 = "${aws_eks_cluster.this.endpoint}"
  }

  count = "${var.install_kubectl && var.manage_aws_auth ? 1 : 0}"
}

resource "local_file" "kubeconfig" {
  content  = "${data.template_file.kubeconfig.rendered}"
  filename = "${var.config_output_path}kubeconfig_${var.cluster_name}"
  count    = "${var.write_kubeconfig ? 1 : 0}"
}
