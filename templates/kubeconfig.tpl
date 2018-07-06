apiVersion: v1
preferences: {}
kind: Config

clusters:
- cluster:
    server: ${endpoint}
    certificate-authority-data: ${cluster_auth_base64}
  name: eks_${region}_${cluster_name}

contexts:
- context:
    cluster: eks_${region}_${cluster_name}
    user: eks_${region}_${cluster_name}
  name: eks_${region}_${cluster_name}

current-context: eks_${region}_${cluster_name}

users:
- name: eks_${region}_${cluster_name}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: ${aws_authenticator_command}
      args:
        - "token"
        - "-i"
        - "${cluster_name}"
${aws_authenticator_additional_args}
${aws_authenticator_env_variables}
