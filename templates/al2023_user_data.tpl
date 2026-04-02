%{ if enable_bootstrap_user_data ~}
---
apiVersion: node.eks.aws/v1alpha1
kind: NodeConfig
spec:
  cluster:
    name: ${cluster_name}
    apiServerEndpoint: ${cluster_endpoint}
    certificateAuthority: ${cluster_auth_base64}
    cidr: ${cluster_service_cidr}
%{ endif ~}
