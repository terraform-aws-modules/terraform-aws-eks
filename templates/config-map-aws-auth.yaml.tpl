apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
${worker_role_arn}
  %{if chomp(map_roles) != "[]" }
    ${indent(4, map_roles)}
  %{ endif }
  %{if chomp(map_users) != "[]" }
  mapUsers: |
    ${indent(4, map_users)}
  %{ endif }
  %{if chomp(map_accounts) != "[]" }
  mapAccounts: |
    ${indent(4, map_accounts)}
  %{ endif }
