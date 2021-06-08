#!/bin/bash -e

# Define extra environment variables for bootstrap
printf '#!/bin/bash
export CONTAINER_RUNTIME="%s"
export USE_MAX_PODS="%s"
export ADDITIONAL_KUBELET_EXTRA_ARGS="%s"
' "${container_runtime}" "${use_max_pods}" "${kubelet_extra_args}" > /etc/profile.d/eks-bootstrap.sh

# Source extra environment variables in bootstrap script
sed -i '/^set -o errexit/a\\nsource /etc/profile.d/eks-bootstrap.sh' /etc/eks/bootstrap.sh

# Merge ADDITIONAL_KUBELET_EXTRA_ARGS into KUBELET_EXTRA_ARGS
sed -i 's/^KUBELET_EXTRA_ARGS="$${KUBELET_EXTRA_ARGS:-}/KUBELET_EXTRA_ARGS="$${KUBELET_EXTRA_ARGS:-} $${ADDITIONAL_KUBELET_EXTRA_ARGS}/' /etc/eks/bootstrap.sh
%{if length(pre_userdata) > 0 ~}

# User supplied pre userdata code
${pre_userdata}
%{endif ~}
%{ if run_bootstrap_script ~}

# The launch template has supplied the AMI ID so bootstrap needs calling manually
/etc/eks/bootstrap.sh ${cluster_name}
%{ endif ~}
