#!/bin/bash -e

# Define extra environment variables for bootstrap
printf '#!/bin/bash
export USE_MAX_PODS="%s"
export KUBELET_EXTRA_ARGS="%s"
' "${use_max_pods}" "${kubelet_extra_args}" > /etc/profile.d/bootstrap.sh

# Source extra environment variables in bootstrap script
sed -i '/^set -o errexit/a\\nsource /etc/profile.d/bootstrap.sh' /etc/eks/bootstrap.sh

# Allow user supplied pre userdata code
%{if length(pre_userdata) > 0 ~}
${pre_userdata}
%{endif ~}
