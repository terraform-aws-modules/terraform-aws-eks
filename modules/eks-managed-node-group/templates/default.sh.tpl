### Default user data
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="//"

--//
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash
set -ex
B64_CLUSTER_CA=xxx
API_SERVER_URL=xxx
K8S_CLUSTER_DNS_IP=172.20.0.10
/etc/eks/bootstrap.sh <CLUSTER> --kubelet-extra-args '--node-labels=eks.amazonaws.com/nodegroup-image=ami-0caf35bc73450c396,eks.amazonaws.com/capacityType=ON_DEMAND,eks.amazonaws.com/nodegroup=default_node_group' --b64-cluster-ca $B64_CLUSTER_CA --apiserver-endpoint $API_SERVER_URL --dns-cluster-ip $K8S_CLUSTER_DNS_IP

--//--


### Custom launch template with user added user data
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="//"

--//
Content-Transfer-Encoding: 7bit
Content-Type: text/x-shellscript
Mime-Version: 1.0

echo 'hello world!'
--//
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash
set -ex
B64_CLUSTER_CA=xxx
API_SERVER_URL=xxx
K8S_CLUSTER_DNS_IP=172.20.0.10
/etc/eks/bootstrap.sh <CLUSTER> --kubelet-extra-args '--node-labels=eks.amazonaws.com/sourceLaunchTemplateVersion=1,eks.amazonaws.com/nodegroup-image=ami-0caf35bc73450c396,eks.amazonaws.com/capacityType=ON_DEMAND,eks.amazonaws.com/nodegroup=create_launch_template,eks.amazonaws.com/sourceLaunchTemplateId=lt-003a9022005aa0062' --b64-cluster-ca $B64_CLUSTER_CA --apiserver-endpoint $API_SERVER_URL --dns-cluster-ip $K8S_CLUSTER_DNS_IP


--//--

### Custom AMI - even when using EKS AMI
Content-Type: multipart/mixed; boundary="//"
MIME-Version: 1.0

--//
Content-Transfer-Encoding: 7bit
Content-Type: text/x-shellscript
Mime-Version: 1.0

echo 'hello world!'
--//--
