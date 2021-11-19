#!/bin/bash -e

/etc/eks/bootstrap.sh ${cluster_name} ${bootstrap_extra_args} \
  --apiserver-endpoint ${cluster_endpoint} \
  --b64-cluster-ca ${cluster_auth_base64}

${post_bootstrap_user_data}
