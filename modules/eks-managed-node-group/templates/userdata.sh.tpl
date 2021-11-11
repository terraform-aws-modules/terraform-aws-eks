#!/bin/bash -e
%{ if length(ami_id) == 0 ~}
# Inject custom environment variables and kubelet args into bootstrap process
# for both EKS optimized/managed AMI or custom EKS AMI
printf '#!/bin/bash
%{ for k, v in bootstrap_environment_variables ~}
export ${k}="${v}"
%{ endfor ~}
export ADDITIONAL_KUBELET_EXTRA_ARGS="${kubelet_extra_args}"
' > /etc/profile.d/eks-bootstrap-env.sh

# Source extra environment variables in bootstrap script
sed -i '/^set -o errexit/a\\nsource /etc/profile.d/eks-bootstrap-env.sh' /etc/eks/bootstrap.sh

# Merge ADDITIONAL_KUBELET_EXTRA_ARGS into KUBELET_EXTRA_ARGS
sed -i 's/^KUBELET_EXTRA_ARGS="$${KUBELET_EXTRA_ARGS:-}/KUBELET_EXTRA_ARGS="$${KUBELET_EXTRA_ARGS:-} $${ADDITIONAL_KUBELET_EXTRA_ARGS}/' /etc/eks/bootstrap.sh
%{else ~}

# Set additional boostrap environment variables for custom AMI
%{ for k, v in bootstrap_environment_variables ~}
${k}="${v}"
%{ endfor ~}
KUBELET_EXTRA_ARGS='--node-labels=eks.amazonaws.com/nodegroup-image=${ami_id},eks.amazonaws.com/capacityType=${capacity_type}${append_labels} ${kubelet_extra_args}'
%{endif ~}




%{ if length(ami_id) > 0 && ami_is_eks_optimized ~}
# Custom AMI bootstrap configurations

${user_data_pre_bootstrap}

# Set required environment variables for custom AMI
API_SERVER_URL=${cluster_endpoint}
B64_CLUSTER_CA=${cluster_auth_base64}

# Call bootstrap for EKS optimised custom AMI
/etc/eks/bootstrap.sh ${cluster_name} --apiserver-endpoint "$${API_SERVER_URL}" --b64-cluster-ca "$${B64_CLUSTER_CA}" --kubelet-extra-args "$${KUBELET_EXTRA_ARGS}"
%{ endif ~}

${user_data_post_bootstrap}
