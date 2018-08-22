#!/bin/bash -xe

# Allow user supplied pre userdata code
${pre_userdata}

KUBELET_EXTRA_ARGS=${kubelet_extra_args}

# Set kubelet --node-labels if kubelet_node_labels were set
KUBELET_NODE_LABELS=${kubelet_node_labels}
if [[ $KUBELET_NODE_LABELS != "" ]]; then KUBELET_EXTRA_ARGS="$KUBELET_EXTRA_ARGS --node-labels=$KUBELET_NODE_LABELS"; fi

# Bootstrap and join the cluster
/etc/eks/bootstrap.sh --b64-cluster-ca '${cluster_auth_base64}' --apiserver-endpoint '${endpoint}' --kubelet-extra-args "$KUBELET_EXTRA_ARGS" '${cluster_name}'

# Allow user supplied userdata code
${additional_userdata}
