MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="//"

--//
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash
set -e

# Bootstrap and join the cluster
/etc/eks/bootstrap.sh --b64-cluster-ca '${cluster_auth_base64}' --apiserver-endpoint '${endpoint}' ${bootstrap_extra_args} --kubelet-extra-args "${kubelet_extra_args}" '${cluster_name}'

--//--
