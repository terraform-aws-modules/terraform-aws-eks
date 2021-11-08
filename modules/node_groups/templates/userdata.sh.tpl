#!/bin/bash -e
%{ if length(ami_id) == 0 ~}

# Set bootstrap env
printf '#!/bin/bash
%{ for k, v in bootstrap_env ~}
export ${k}="${v}"
%{ endfor ~}
export ADDITIONAL_KUBELET_EXTRA_ARGS="${kubelet_extra_args}"
' > /etc/profile.d/eks-bootstrap-env.sh

# Source extra environment variables in bootstrap script
sed -i '/^set -o errexit/a\\nsource /etc/profile.d/eks-bootstrap-env.sh' /etc/eks/bootstrap.sh

# Merge ADDITIONAL_KUBELET_EXTRA_ARGS into KUBELET_EXTRA_ARGS
sed -i 's/^KUBELET_EXTRA_ARGS="$${KUBELET_EXTRA_ARGS:-}/KUBELET_EXTRA_ARGS="$${KUBELET_EXTRA_ARGS:-} $${ADDITIONAL_KUBELET_EXTRA_ARGS}/' /etc/eks/bootstrap.sh
%{else ~}

# Set variables for custom AMI
API_SERVER_URL=${cluster_endpoint}
B64_CLUSTER_CA=${cluster_auth_base64}
%{ for k, v in bootstrap_env ~}
${k}="${v}"
%{ endfor ~}
KUBELET_EXTRA_ARGS='--node-labels=eks.amazonaws.com/nodegroup-image=${ami_id},eks.amazonaws.com/capacityType=${capacity_type}${append_labels} ${kubelet_extra_args}'
%{endif ~}

# User supplied pre userdata
${pre_userdata}
#Set the proxy hostname and port
PROXY="docker-registry-proxy.mgmt-dev.us-west-2.aws.parsablenet.org:3128/"
MAC=$(curl -s http://169.254.169.254/latest/meta-data/mac/)
VPC_CIDR=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/$MAC/vpc-ipv4-cidr-blocks | xargs | tr ' ' ',')

#Create the docker systemd directory
mkdir -p /etc/systemd/system/docker.service.d

# set the docker proxy
cat << EOF > /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=$PROXY"
Environment="HTTPS_PROXY=$PROXY"
EOF

# Get the CA certificate from the proxy and make it a trusted root.
curl {$PROXY}ca.crt > /etc/pki/ca-trust/source/anchors/docker_registry_proxy.crt
update-ca-trust extract
    
# Reload systemd
systemctl daemon-reload
    
# Restart dockerd
systemctl restart docker.service


#Configure yum to use the proxy
cloud-init-per instance yum_proxy_config cat << EOF >> /etc/yum.conf
proxy=http://$PROXY
EOF

#Set the proxy for future processes, and use as an include file
cloud-init-per instance proxy_config cat << EOF >> /etc/environment
http_proxy=http://$PROXY
https_proxy=http://$PROXY
HTTP_PROXY=http://$PROXY
HTTPS_PROXY=http://$PROXY
no_proxy=$VPC_CIDR,localhost,127.0.0.1,169.254.169.254,.internal,s3.amazonaws.com,.s3.eu-west-1.amazonaws.com,api.ecr.eu-west-1.amazonaws.com,dkr.ecr.eu-west-1.amazonaws.com,ec2.eu-west-1.amazonaws.com
NO_PROXY=$VPC_CIDR,localhost,127.0.0.1,169.254.169.254,.internal,s3.amazonaws.com,.s3.eu-west-1.amazonaws.com,api.ecr.eu-west-1.amazonaws.com,dkr.ecr.eu-west-1.amazonaws.com,ec2.eu-west-1.amazonaws.com
EOF

#Configure docker with the proxy
cloud-init-per instance docker_proxy_config tee <<EOF /etc/systemd/system/docker.service.d/proxy.conf >/dev/null
[Service]
EnvironmentFile=/etc/environment
EOF

#Configure the kubelet with the proxy
cloud-init-per instance kubelet_proxy_config tee <<EOF /etc/systemd/system/kubelet.service.d/proxy.conf >/dev/null
[Service]
EnvironmentFile=/etc/environment
EOF

#Reload the daemon and restart docker to reflect proxy configuration at launch of instance
cloud-init-per instance reload_daemon systemctl daemon-reload 
cloud-init-per instance enable_docker systemctl enable --now --no-block docker
%{ if length(ami_id) > 0 && ami_is_eks_optimized ~}

# Call bootstrap for EKS optimised custom AMI
/etc/eks/bootstrap.sh ${cluster_name} --apiserver-endpoint "$${API_SERVER_URL}" --b64-cluster-ca "$${B64_CLUSTER_CA}" --kubelet-extra-args "$${KUBELET_EXTRA_ARGS}"
%{ endif ~}
