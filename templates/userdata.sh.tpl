#!/bin/bash -xe

# Allow user supplied pre userdata code
${pre_userdata}

# Detect instance life cycle
iid=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
export AWS_DEFAULT_REGION=${AWS::Region}
ilc=`aws ec2 describe-instances --instance-ids  $iid  --query 'Reservations[0].Instances[0].InstanceLifecycle' --output text`

# Bootstrap and join the cluster
if [ "$ilc" == "spot" ]; then
  /etc/eks/bootstrap.sh --b64-cluster-ca '${cluster_auth_base64}' --apiserver-endpoint '${endpoint}' --kubelet-extra-args --node-labels=ondemand=yes '${kubelet_extra_args}' '${cluster_name}'
else
  /etc/eks/bootstrap.sh --b64-cluster-ca '${cluster_auth_base64}' --apiserver-endpoint '${endpoint}' --kubelet-extra-args '--node-labels=spotfleet=yes --register-with-taints=spotInstance=true:PreferNoSchedule' '${kubelet_extra_args}' '${cluster_name}'
end

# Allow user supplied userdata code
${additional_userdata}
