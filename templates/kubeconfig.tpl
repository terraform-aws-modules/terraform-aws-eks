apiVersion: v1
preferences: {}
kind: Config

clusters:
- cluster:
    server: ${endpoint}
    certificate-authority-data: ${cluster_auth_base64}
  name: ${cluster_name}

contexts:
- context:
    cluster: ${cluster_name}
    user: ${user_name}
  name: ${context_name}
current-context: ${context_name}

users:
- name: ${user_name}
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