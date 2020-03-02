- rolearn: ${worker_role_arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
    %{~ if platform == "windows" ~}
    - eks:kube-proxy-windows
    %{~ endif ~}
