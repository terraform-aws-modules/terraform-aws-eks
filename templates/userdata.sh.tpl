#!/bin/bash -xe

# Allow user supplied pre userdata code
${pre_userdata}

# Bootstrap and join the cluster
/etc/eks/bootstrap.sh --b64-cluster-ca '${cluster_auth_base64}' --apiserver-endpoint '${endpoint}' --kubelet-extra-args '${kubelet_extra_args}' --use-max-pods '${use_max_pods}' '${cluster_name}'

# Allow user supplied userdata code
${additional_userdata}
