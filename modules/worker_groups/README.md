# eks `worker_groups` submodule

Helper submodule to create and manage resources related to `eks_worker_groups`.

## Assumptions

* Designed for use by the parent module and not directly by end users

## Worker Groups' IAM Role

The role ARN specified in `var.default_iam_role_arn` will be used by default. In a simple configuration this will be the worker role created by the parent module.

`iam_role_arn` must be specified in either `var.worker_groups_defaults` or `var.worker_groups` if the default parent IAM role is not being created for whatever reason, for example if `manage_worker_iam_resources` is set to false in the parent.

## `worker_groups` and `worker_groups_defaults` keys

`worker_groups_defaults` is a map that can take the below keys. Values will be used if not specified in individual worker groups.

`worker_groups` is a map of maps. Key of first level will be used as unique value for `for_each` resources and in the `aws_autoscaling_group` and `aws_launch_template`. Inner map can take alle the values from `workers_group_defaults_defaults` map.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_iam_instance_profile.workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_launch_template.workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_ami.eks_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.eks_worker_windows](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_instance_profile.custom_worker_group_iam_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_instance_profile) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_auth_base64"></a> [cluster\_auth\_base64](#input\_cluster\_auth\_base64) | Cluster auth data | `string` | n/a | yes |
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | Cluster endpojnt | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Cluster name | `string` | n/a | yes |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Kubernetes version to use for the EKS cluster. | `string` | n/a | yes |
| <a name="input_create_workers"></a> [create\_workers](#input\_create\_workers) | Controls if EKS resources should be created (it affects almost all resources) | `bool` | `true` | no |
| <a name="input_default_iam_role_id"></a> [default\_iam\_role\_id](#input\_default\_iam\_role\_id) | ARN of the default IAM worker role to use if one is not specified in `var.node_groups` or `var.node_groups_defaults` | `string` | n/a | yes |
| <a name="input_iam_path"></a> [iam\_path](#input\_iam\_path) | If provided, all IAM roles will be created on this path. | `string` | `"/"` | no |
| <a name="input_manage_worker_iam_resources"></a> [manage\_worker\_iam\_resources](#input\_manage\_worker\_iam\_resources) | Whether to let the module manage worker IAM resources. If set to false, iam\_instance\_profile\_name must be specified for workers. | `bool` | `true` | no |
| <a name="input_ng_depends_on"></a> [ng\_depends\_on](#input\_ng\_depends\_on) | List of references to other resources this submodule depends on | `any` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC where the cluster and workers will be deployed. | `string` | n/a | yes |
| <a name="input_worker_ami_name_filter"></a> [worker\_ami\_name\_filter](#input\_worker\_ami\_name\_filter) | Name filter for AWS EKS worker AMI. If not provided, the latest official AMI for the specified 'cluster\_version' is used. | `string` | `""` | no |
| <a name="input_worker_ami_name_filter_windows"></a> [worker\_ami\_name\_filter\_windows](#input\_worker\_ami\_name\_filter\_windows) | Name filter for AWS EKS Windows worker AMI. If not provided, the latest official AMI for the specified 'cluster\_version' is used. | `string` | `""` | no |
| <a name="input_worker_ami_owner_id"></a> [worker\_ami\_owner\_id](#input\_worker\_ami\_owner\_id) | The ID of the owner for the AMI to use for the AWS EKS workers. Valid values are an AWS account ID, 'self' (the current account), or an AWS owner alias (e.g. 'amazon', 'aws-marketplace', 'microsoft'). | `string` | `"602401143452"` | no |
| <a name="input_worker_ami_owner_id_windows"></a> [worker\_ami\_owner\_id\_windows](#input\_worker\_ami\_owner\_id\_windows) | The ID of the owner for the AMI to use for the AWS EKS Windows workers. Valid values are an AWS account ID, 'self' (the current account), or an AWS owner alias (e.g. 'amazon', 'aws-marketplace', 'microsoft'). | `string` | `"801119661308"` | no |
| <a name="input_worker_create_initial_lifecycle_hooks"></a> [worker\_create\_initial\_lifecycle\_hooks](#input\_worker\_create\_initial\_lifecycle\_hooks) | Whether to create initial lifecycle hooks provided in worker groups. | `bool` | `false` | no |
| <a name="input_worker_groups"></a> [worker\_groups](#input\_worker\_groups) | A map of maps defining worker group configurations to be defined using AWS Launch Templates. See workers\_group\_defaults for valid keys. | `any` | `{}` | no |
| <a name="input_worker_security_group_ids"></a> [worker\_security\_group\_ids](#input\_worker\_security\_group\_ids) | A list of security group ids to attach to worker instances | `list(string)` | `[]` | no |
| <a name="input_workers_group_defaults"></a> [workers\_group\_defaults](#input\_workers\_group\_defaults) | Workers group defaults from parent | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_auth_roles"></a> [aws\_auth\_roles](#output\_aws\_auth\_roles) | Roles for use in aws-auth ConfigMap |
| <a name="output_worker_groups"></a> [worker\_groups](#output\_worker\_groups) | Outputs from EKS worker groups. Map of maps, keyed by `var.worker_groups` keys. |
| <a name="output_worker_iam_instance_profile_arns"></a> [worker\_iam\_instance\_profile\_arns](#output\_worker\_iam\_instance\_profile\_arns) | default IAM instance profile ARN for EKS worker groups |
| <a name="output_worker_iam_instance_profile_names"></a> [worker\_iam\_instance\_profile\_names](#output\_worker\_iam\_instance\_profile\_names) | default IAM instance profile name for EKS worker groups |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
