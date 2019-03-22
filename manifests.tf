# https://docs.aws.amazon.com/eks/latest/userguide/cni-custom-network.html

resource "local_file" "config_map_eni_config" {
  count = "${length(var.cni_cidr_block) > 0 ? 1 : 0}"

  content  = "${data.template_file.config_map_eni_config.0.rendered}"
  filename = "${local.asset_dir}/manifests/config-map-eni-config.yaml"
}

data "template_file" "patch_aws_node_configmap" {
  count    = "${length(var.cni_cidr_block) > 0 ? 1 : 0}"
  template = "${file("${path.module}/templates/patch-vpc_cni_custom_network.yaml")}"
}

resource "null_resource" "patch_aws_node_configmap" {
  count = "${length(var.cni_cidr_block) > 0 ? 1 : 0}"

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
set -o errexit; \
for i in `seq 1 10`;
do \
  kubectl patch daemonset \
    -n kube-system aws-node --kubeconfig ${null_resource.update_config_map_eni_config.0.triggers.kubeconfig_filename} \
    --patch "$(cat templates/patch-vpc_cni_custom_network.yaml)" && exit 0; \
  sleep 10; \
done; \
exit 1;
EOS
  }

  triggers {
    custom_network_patch_contents = "${data.template_file.patch_aws_node_configmap.0.rendered}"
  }
}

resource "null_resource" "update_config_map_eni_config" {
  count = "${length(var.cni_cidr_block) > 0 ? 1 : 0}"

  provisioner "local-exec" {
    command = <<EOS
set -o errexit; \
for i in `seq 1 10`; do \
  kubectl apply -f ${null_resource.update_config_map_eni_config.0.triggers.config_map_filename} \
  --kubeconfig ${null_resource.update_config_map_eni_config.0.triggers.kubeconfig_filename} && exit 0; \
sleep 10; \
done; \
exit 1;
EOS

    interpreter = ["${var.local_exec_interpreter}"]
  }

  triggers {
    kubeconfig_filename = "${local_file.kubeconfig.filename}"
    config_map_filename = "${local_file.config_map_eni_config.0.filename}"
    endpoint            = "${aws_eks_cluster.this.endpoint}"
  }
}

locals {
  eni_security_groups = ["${local.worker_security_group_id}"]
}

data "template_file" "config_map_eni_config_part" {
  #count = "${length(aws_subnet.kube.*.availability_zone)}"
  count = "${length(var.cni_cidr_block) > 0 ? length(data.aws_availability_zones.available.names) : 0}"

  template = "${file("${path.module}/templates/config-map-eni-config-part.yaml.tpl")}"

  vars {
    zone            = "${element(aws_subnet.kube.*.availability_zone, count.index)}"
    subnet          = "${element(aws_subnet.kube.*.id, count.index)}"
    security_groups = "${join("\n", formatlist("  - %s", local.eni_security_groups))}"
  }
}

data "template_file" "config_map_eni_config" {
  count = "${length(var.cni_cidr_block) > 0 ? 1 : 0}"

  template = <<EOF
$${content}
  EOF

  vars {
    content = "${join("\n", data.template_file.config_map_eni_config_part.*.rendered)}"
  }
}
