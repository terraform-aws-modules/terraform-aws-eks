%{ if enable_bootstrap_user_data ~}
#!/bin/bash
set -e
%{ endif ~}
${pre_bootstrap_user_data ~}
%{ if length(cluster_service_ipv4_cidr) > 0 ~}
export SERVICE_IPV4_CIDR=${cluster_service_ipv4_cidr}
%{ endif ~}
%{ if enable_bootstrap_user_data ~}
%{ if cluster_auth_base64 != "" }B64_CLUSTER_CA=${cluster_auth_base64}%{ endif }
%{ if cluster_endpoint != "" }API_SERVER_URL=${cluster_endpoint}%{ endif }
/etc/eks/bootstrap.sh ${cluster_name} ${bootstrap_extra_args} %{ if cluster_auth_base64 != "" }--b64-cluster-ca $B64_CLUSTER_CA%{ endif } %{ if cluster_endpoint != "" }--apiserver-endpoint $API_SERVER_URL%{ endif }
${post_bootstrap_user_data ~}
%{ endif ~}
