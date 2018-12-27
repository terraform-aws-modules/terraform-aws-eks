#!/bin/bash -xe

# Allow user supplied pre userdata code
${pre_userdata}

# Install and start SSM Agent
yum install -y amazon-ssm-agent
systemctl start amazon-ssm-agent
systemctl enable amazon-ssm-agent

# Bootstrap and join the cluster
/etc/eks/bootstrap.sh --b64-cluster-ca '${cluster_auth_base64}' --apiserver-endpoint '${endpoint}' --kubelet-extra-args '${kubelet_extra_args}' '${cluster_name}'

# Allow user supplied userdata code
${additional_userdata}
