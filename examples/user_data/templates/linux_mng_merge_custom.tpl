#!/bin/bash
set -e
# Custom user data template provided for rendering
printf '#!/bin/bash
set -e
%{ for k, v in user_data_env ~}
export ${k}="${v}"
%{ endfor ~}
' > /etc/profile.d/bootstrap-env.sh
if [[ -z "$(grep 'source /etc/profile.d/bootstrap-env.sh' /etc/eks/bootstrap.sh || true)"]]
then
  sed -i '/^IFS=/a\\nsource /etc/profile.d/bootstrap-env.sh' /etc/eks/bootstrap.sh
fi
source /etc/profile.d/bootstrap-env.sh
${pre_bootstrap_user_data ~}
