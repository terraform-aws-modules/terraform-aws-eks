#!/bin/bash -e
%{ if length(ami_id) > 0 ~}
/etc/eks/bootstrap.sh ${cluster_name} ${bootstrap_extra_args} \
  --apiserver-endpoint ${cluster_endpoint} \
  --b64-cluster-ca ${cluster_auth_base64}
%{ endif ~}
${post_bootstrap_user_data}
