locals {
  cluster_endpoint = element(concat(aws_eks_cluster.this.*.endpoint, list("")), 0)
}
resource "null_resource" "cluster_patch_kube_proxy_cm" {
  depends_on = [local.cluster_endpoint]
  count      = var.create_eks ? 1 : 0

  provisioner "local-exec" {

    interpreter = ["bash", "-c"]

    command = <<EOS
for i in `seq 1 20`; do \
  echo "Patching, attempt $i..."; \
  tmpdir="$(mktemp -d)"; \
  cd "$tmpdir"; \
  kubectl --kubeconfig <(echo "${concat(data.template_file.kubeconfig[*].rendered, [""])[0]}") \
    get configmap kube-proxy-config \
    -n kube-system \
    -o jsonpath --template='{.data.config}' \
    > config \
  && \
  sed -i -e 's/metricsBindAddress: 127.0.0.1/metricsBindAddress: 0.0.0.0/' config \
  && \
  kubectl --kubeconfig <(echo "${concat(data.template_file.kubeconfig[*].rendered, [""])[0]}") \
  -n kube-system \
  patch configmap kube-proxy-config -p \
  "$(kubectl --kubeconfig <(echo "${concat(data.template_file.kubeconfig[*].rendered, [""])[0]}") create -n kube-system --dry-run configmap kube-proxy-config --from-file=config -o yaml)" \
  && \
  kubectl \
  --kubeconfig <(echo "${concat(data.template_file.kubeconfig[*].rendered, [""])[0]}") \
  -n kube-system \
  rollout restart daemonset kube-proxy \
  && \
  exit 0 \
  || sleep 10; \
done; \
echo "GIVING UP..."; exit 1
EOS
  }

  triggers = {
    endpoint = local.cluster_endpoint
  }
}
