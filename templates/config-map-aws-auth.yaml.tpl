apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
${worker_role_arn}
  ${indent(2, map_roles)}
  mapUsers: |
  ${indent(2, map_users)}
  mapAccounts: |
  ${indent(2, map_accounts)}
