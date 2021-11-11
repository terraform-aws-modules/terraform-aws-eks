#!/bin/bash -ex

/etc/eks/bootstrap.sh ${cluster_name} ${bootstrap_extra_args} \
%{ if length(kubelet_extra_args) > 0 ~}
  --kubelet-extra-args '${kubelet_extra_args}' \
%{ endif ~}
%{ if length(cluster_dns_ip) > 0 ~}
  --dns-cluster-ip ${cluster_dns_ip} \
%{ endif ~}
  --apiserver-endpoint ${cluster_endpoint} \
  --b64-cluster-ca ${cluster_auth_base64}

${post_bootstrap_user_data}
