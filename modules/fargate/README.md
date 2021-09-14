# EKS `fargate` submodule

Helper submodule to create and manage resources related to `aws_eks_fargate_profile`.

## `fargate_profile` keys

`fargate_profile` is a map of maps. Key of first level will be used as unique value for `for_each` resources and in the `aws_eks_fargate_profile` name. Inner map can take the below values.

## Example

See example code in `examples/fargate`.

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Fargate profile name | `string` | Auto generated in the following format `[cluster_name]-fargate-[fargate_profile_map_key]`| no |
| selectors | A list of Kubernetes selectors. See examples/fargate/main.tf for example format. | <pre>list(map({<br>namespace = string<br>labels = map(string)<br>}))</pre>| `[]` | no |
| subnets | List of subnet IDs. Will replace the root module subnets. | `list(string)` | `var.subnets` | no |
| tags | Key-value map of resource tags. Will be merged with root module tags. | `map(string)` | `var.tags` | no |

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.40.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.40.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eks_fargate_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_fargate_profile) | resource |
| [aws_iam_role.eks_fargate_pod](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.eks_fargate_pod](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.eks_fargate_pod_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_role.custom_fargate_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster. | `string` | `""` | no |
| <a name="input_create_eks"></a> [create\_eks](#input\_create\_eks) | Controls if EKS resources should be created (it affects almost all resources) | `bool` | `true` | no |
| <a name="input_create_fargate_pod_execution_role"></a> [create\_fargate\_pod\_execution\_role](#input\_create\_fargate\_pod\_execution\_role) | Controls if the the IAM Role that provides permissions for the EKS Fargate Profile should be created. | `bool` | `true` | no |
| <a name="input_fargate_pod_execution_role_name"></a> [fargate\_pod\_execution\_role\_name](#input\_fargate\_pod\_execution\_role\_name) | The IAM Role that provides permissions for the EKS Fargate Profile. | `string` | `null` | no |
| <a name="input_fargate_profiles"></a> [fargate\_profiles](#input\_fargate\_profiles) | Fargate profiles to create. See `fargate_profile` keys section in README.md for more details | `any` | `{}` | no |
| <a name="input_iam_path"></a> [iam\_path](#input\_iam\_path) | IAM roles will be created on this path. | `string` | `"/"` | no |
| <a name="input_permissions_boundary"></a> [permissions\_boundary](#input\_permissions\_boundary) | If provided, all IAM roles will be created with this permissions boundary attached. | `string` | `null` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | A list of subnets for the EKS Fargate profiles. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_auth_roles"></a> [aws\_auth\_roles](#output\_aws\_auth\_roles) | Roles for use in aws-auth ConfigMap |
| <a name="output_fargate_profile_arns"></a> [fargate\_profile\_arns](#output\_fargate\_profile\_arns) | Amazon Resource Name (ARN) of the EKS Fargate Profiles. |
| <a name="output_fargate_profile_ids"></a> [fargate\_profile\_ids](#output\_fargate\_profile\_ids) | EKS Cluster name and EKS Fargate Profile names separated by a colon (:). |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | IAM role ARN for EKS Fargate pods |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | IAM role name for EKS Fargate pods |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
