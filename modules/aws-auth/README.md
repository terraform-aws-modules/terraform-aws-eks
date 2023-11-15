# `aws-auth` Module

Configuration in this directory creates/updates the `aws-auth` ConfigMap.

## Usage

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.20 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.20 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_config_map.aws_auth](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_config_map_v1_data.aws_auth](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1_data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_auth_accounts"></a> [aws\_auth\_accounts](#input\_aws\_auth\_accounts) | List of account maps to add to the aws-auth configmap | `list(any)` | `[]` | no |
| <a name="input_aws_auth_fargate_profile_pod_execution_role_arns"></a> [aws\_auth\_fargate\_profile\_pod\_execution\_role\_arns](#input\_aws\_auth\_fargate\_profile\_pod\_execution\_role\_arns) | List of Fargate profile pod execution role ARNs to add to the aws-auth configmap | `list(string)` | `[]` | no |
| <a name="input_aws_auth_node_iam_role_arns_non_windows"></a> [aws\_auth\_node\_iam\_role\_arns\_non\_windows](#input\_aws\_auth\_node\_iam\_role\_arns\_non\_windows) | List of non-Windows based node IAM role ARNs to add to the aws-auth configmap | `list(string)` | `[]` | no |
| <a name="input_aws_auth_node_iam_role_arns_windows"></a> [aws\_auth\_node\_iam\_role\_arns\_windows](#input\_aws\_auth\_node\_iam\_role\_arns\_windows) | List of Windows based node IAM role ARNs to add to the aws-auth configmap | `list(string)` | `[]` | no |
| <a name="input_aws_auth_roles"></a> [aws\_auth\_roles](#input\_aws\_auth\_roles) | List of role maps to add to the aws-auth configmap | `list(any)` | `[]` | no |
| <a name="input_aws_auth_users"></a> [aws\_auth\_users](#input\_aws\_auth\_users) | List of user maps to add to the aws-auth configmap | `list(any)` | `[]` | no |
| <a name="input_create"></a> [create](#input\_create) | Controls if resources should be created (affects all resources) | `bool` | `true` | no |
| <a name="input_create_aws_auth_configmap"></a> [create\_aws\_auth\_configmap](#input\_create\_aws\_auth\_configmap) | Determines whether to create the aws-auth configmap. NOTE - this is only intended for scenarios where the configmap does not exist (i.e. - when using only self-managed node groups). Most users should use `manage_aws_auth_configmap` | `bool` | `false` | no |
| <a name="input_manage_aws_auth_configmap"></a> [manage\_aws\_auth\_configmap](#input\_manage\_aws\_auth\_configmap) | Determines whether to manage the aws-auth configmap | `bool` | `true` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
