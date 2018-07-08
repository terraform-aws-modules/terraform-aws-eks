#!/bin/bash -xe

# Allow user supplied pre userdata code
${pre_userdata}

# Certificate Authority config
CA_CERTIFICATE_DIRECTORY=/etc/kubernetes/pki
CA_CERTIFICATE_FILE_PATH=$CA_CERTIFICATE_DIRECTORY/ca.crt
mkdir -p $CA_CERTIFICATE_DIRECTORY
echo "${cluster_auth_base64}" | base64 -d >$CA_CERTIFICATE_FILE_PATH

# Set kubelet --node-labels if kubelet_node_labels were set
KUBELET_NODE_LABELS=${kubelet_node_labels}
if [[ $KUBELET_NODE_LABELS != "" ]]; then sed -i '/INTERNAL_IP/a \ \ --node-labels='"$KUBELET_NODE_LABELS"'\ \\' /etc/systemd/system/kubelet.service; fi

# Authentication
INTERNAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
sed -i s,MASTER_ENDPOINT,${endpoint},g /var/lib/kubelet/kubeconfig
sed -i s,CLUSTER_NAME,${cluster_name},g /var/lib/kubelet/kubeconfig
sed -i s,REGION,${region},g /etc/systemd/system/kubelet.service
sed -i s,MAX_PODS,${max_pod_count},g /etc/systemd/system/kubelet.service
sed -i s,MASTER_ENDPOINT,${endpoint},g /etc/systemd/system/kubelet.service
sed -i s,INTERNAL_IP,$INTERNAL_IP,g /etc/systemd/system/kubelet.service

# DNS cluster configuration
DNS_CLUSTER_IP=10.100.0.10
if [[ $INTERNAL_IP == 10.* ]]; then DNS_CLUSTER_IP=172.20.0.10; fi
sed -i s,DNS_CLUSTER_IP,$DNS_CLUSTER_IP,g /etc/systemd/system/kubelet.service
sed -i s,CERTIFICATE_AUTHORITY_FILE,$CA_CERTIFICATE_FILE_PATH,g /var/lib/kubelet/kubeconfig
sed -i s,CLIENT_CA_FILE,$CA_CERTIFICATE_FILE_PATH,g /etc/systemd/system/kubelet.service

# start services
systemctl daemon-reload
systemctl restart kubelet

# Allow user supplied userdata code
${additional_userdata}
