apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
${worker_role_arn}
${map_roles}
  mapUsers: |
${map_users}
  mapAccounts: |
${map_accounts}
