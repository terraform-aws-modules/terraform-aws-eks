apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
%{ for role in eks_managed_role_arns ~}
    - rolearn: ${role}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
%{ endfor ~}
%{ for role in self_managed_role_arns ~}
    - rolearn: ${role}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
%{ endfor ~}
%{ for role in win32_self_managed_role_arns ~}
    - rolearn: ${role}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - eks:kube-proxy-windows
        - system:bootstrappers
        - system:nodes
%{ endfor ~}
%{ for role in fargate_profile_pod_execution_role_arns ~}
    - rolearn: ${role}
      username: system:node:{{SessionName}}
      groups:
        - system:bootstrappers
        - system:nodes
        - system:node-proxier
%{ endfor ~}
