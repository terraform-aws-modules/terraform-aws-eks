#!/bin/bash
set -e
printf '#!/bin/bash
set -e
%{ for k, v in user_data_env ~}
export %{ if k == "KUBELET_EXTRA_ARGS" }KUBELET_EXTRA_ARGS_ENV%{ else }${k}%{ endif }="${v}"
%{ endfor ~}
' > /etc/profile.d/bootstrap-env.sh
if [[ -z "$(grep 'source /etc/profile.d/bootstrap-env.sh' /etc/eks/bootstrap.sh || true)"]]
then
  sed -i '/^IFS=/a\\nsource /etc/profile.d/bootstrap-env.sh' /etc/eks/bootstrap.sh
fi
if [[ -z "$(grep 'KUBELET_EXTRA_ARGS_ENV="$${KUBELET_EXTRA_ARGS}"' /etc/eks/bootstrap.sh || true)"]]
then
  sed -i 's/^KUBELET_EXTRA_ARGS="$${KUBELET_EXTRA_ARGS:-}/KUBELET_EXTRA_ARGS="$${KUBELET_EXTRA_ARGS:-} $${KUBELET_EXTRA_ARGS_ENV:-}/' /etc/eks/bootstrap.sh
fi
source /etc/profile.d/bootstrap-env.sh
${pre_bootstrap_user_data ~}
