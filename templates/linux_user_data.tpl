%{ if is_custom_ami ~}
#!/bin/bash
set -e
%{ endif ~}
${pre_bootstrap_user_data ~}
%{ if is_custom_ami ~}
B64_CLUSTER_CA=${cluster_auth_base64}
API_SERVER_URL=${cluster_endpoint}
/etc/eks/bootstrap.sh ${cluster_name} ${bootstrap_extra_args} --b64-cluster-ca $B64_CLUSTER_CA --apiserver-endpoint $API_SERVER_URL
${post_bootstrap_user_data}
%{ endif ~}
