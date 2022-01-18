#!/bin/bash
set -e
%{ for k, v in user_data_env ~}
export ${k}="${v}"
%{ endfor ~}
${pre_bootstrap_user_data ~}
%{ if enable_bootstrap_user_data ~}
/etc/eks/bootstrap.sh "$${CLUSTER_NAME}" --b64-cluster-ca "$${B64_CLUSTER_CA}" --apiserver-endpoint "$${API_SERVER_URL}" $${BOOTSTRAP_EXTRA_ARGS}
%{ endif ~}
${post_bootstrap_user_data ~}
