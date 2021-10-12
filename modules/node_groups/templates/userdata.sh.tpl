#!/bin/bash -e
%{ if length(ami_id) == 0 ~}

# Set variables directly into bootstrap.sh for default AMI
sed -i '/^KUBELET_EXTRA_ARGS=/a KUBELET_EXTRA_ARGS+=" ${kubelet_extra_args}"' /etc/eks/bootstrap.sh
%{else ~}

# Set variables for custom AMI
API_SERVER_URL=${cluster_endpoint}
B64_CLUSTER_CA=${cluster_auth_base64}
KUBELET_EXTRA_ARGS='--node-labels=eks.amazonaws.com/nodegroup-image=${ami_id},eks.amazonaws.com/capacityType=${capacity_type}${append_labels} ${kubelet_extra_args}'
%{endif ~}

# User supplied pre userdata
${pre_userdata}
%{ if length(ami_id) > 0 && ami_is_eks_optimized ~}

# Call bootstrap for EKS optimised custom AMI
/etc/eks/bootstrap.sh ${cluster_name} --apiserver-endpoint "$${API_SERVER_URL}" --b64-cluster-ca "$${B64_CLUSTER_CA}" --kubelet-extra-args "$${KUBELET_EXTRA_ARGS}"
%{ endif ~}
