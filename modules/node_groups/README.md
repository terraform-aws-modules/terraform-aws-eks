# EKS `node_groups` submodule

Helper submodule to create and manage resources related to `eks_node_groups`.

## Node Groups' IAM Role

The role ARN specified in `var.default_iam_role_arn` will be used by default. In a simple configuration this will be the worker role created by the parent module.

`iam_role_arn` must be specified in either `var.node_groups_defaults` or `var.node_groups` if the default parent IAM role is not being created for whatever reason, for example if `manage_worker_iam_resources` is set to false in the parent.

## `node_groups` and `node_groups_defaults` keys
`node_groups_defaults` is a map that can take the below keys. Values will be used if not specified in individual node groups.

`node_groups` is a map of maps. Key of first level will be used as unique value for `for_each` resources and in the `aws_eks_node_group` name. Inner map can take the below values.

| Name | Description | Type | If unset |
|------|-------------|:----:|:-----:|
| additional\_tags | Additional tags to apply to node group | map(string) | Only `var.tags` applied |
| ami\_release\_version | AMI version of workers | string | Provider default behavior |
| ami\_type | AMI Type. See Terraform or AWS docs | string | Provider default behavior |
| ami\_id | ID of custom AMI. If you use a custom AMI, you need to supply bootstrap script via user-data or as AMI built-in. | string | Provider default behavior |
| capacity\_type | Type of instance capacity to provision. Options are `ON_DEMAND` and `SPOT` | string | Provider default behavior |
| create_launch_template | Create and use a default launch template | bool |  `false` |
| desired\_capacity | Desired number of workers | number | `var.workers_group_defaults[asg_desired_capacity]` |
| disk\_encrypted | Whether the root disk will be encrypyted. Requires `create_launch_template` to be `true` and `disk_kms_key_id` to be set | bool | false |
| disk\_kms\_key\_id | KMS Key used to encrypt the root disk. Requires both `create_launch_template` and `disk_encrypted` to be `true` | string | "" |
| disk\_size | Workers' disk size | number | Provider default behavior |
| disk\_type | Workers' disk type. Require `create_launch_template` to be `true`| number | `gp3` |
| ebs\_optimized | Enables/disables EBS optimization. Require `create_launch_template` to be `true` | bool | `true` if defined `instance\_types` are not present in `var.ebs\_optimized\_not\_supported` |
| enable_monitoring | Enables/disables detailed monitoring. Require `create_launch_template` to be `true`| bool | `true` |
| eni_delete | Delete the Elastic Network Interface (ENI) on termination (if set to false you will have to manually delete before destroying) | bool | `true` |
| force\_update\_version | Force version update if existing pods are unable to be drained due to a pod disruption budget issue. | bool | Provider default behavior |
| iam\_role\_arn | IAM role ARN for workers | string | `var.default_iam_role_arn` |
| instance\_types | Node group's instance type(s). Multiple types can be specified when `capacity_type="SPOT"`. | list | `[var.workers_group_defaults[instance_type]]` |
| k8s\_labels | Kubernetes labels | map(string) | No labels applied |
| key\_name | Key name for workers. Set to empty string to disable remote access | string | `var.workers_group_defaults[key_name]` |
| kubelet_extra_args | This string is passed directly to kubelet if set. Useful for adding labels or taints. Require `create_launch_template` to be `true`| string | "" |
| launch_template_id | The id of a aws_launch_template to use | string | No LT used |
| launch\_template_version | The version of the LT to use | string | none |
| max\_capacity | Max number of workers | number | `var.workers_group_defaults[asg_max_size]` |
| min\_capacity | Min number of workers | number | `var.workers_group_defaults[asg_min_size]` |
| update_config.max\_unavailable\_percentage | Max percentage of unavailable nodes during update. (e.g. 25, 50, etc) | number | `null` if `update_config.max_unavailable` is set |
| update_config.max\_unavailable | Max number of unavailable nodes during update  | number | `null` if `update_config.max_unavailable_percentage` is set |
| name | Name of the node group. If you don't really need this, we recommend you to use `name_prefix` instead. | string | Will use the autogenerate name prefix |
| name_prefix | Name prefix of the node group | string | Auto generated |
| pre_userdata | userdata to pre-append to the default userdata. Require `create_launch_template` to be `true`| string | "" |
| public_ip | Associate a public ip address with a worker. Require `create_launch_template` to be `true`| string | `false`
| source\_security\_group\_ids | Source security groups for remote access to workers | list(string) | If key\_name is specified: THE REMOTE ACCESS WILL BE OPENED TO THE WORLD |
| subnets | Subnets to contain workers | list(string) | `var.workers_group_defaults[subnets]` |
| version | Kubernetes version | string | Provider default behavior |
| taints | Kubernetes node taints | list(map) | empty |
| timeouts | A map of timeouts for create/update/delete operations. | `map(string)` | Provider default behavior |
| update_default_version | Whether or not to set the new launch template version the Default | bool | `true` |
| metadata_http_endpoint | The state of the instance metadata service. Requires `create_launch_template` to be `true` | string | `var.workers_group_defaults[metadata_http_endpoint]` |
| metadata_http_tokens | If session tokens are required. Requires `create_launch_template` to be `true` | string | `var.workers_group_defaults[metadata_http_tokens]` |
| metadata_http_put_response_hop_limit | The desired HTTP PUT response hop limit for instance metadata requests. Requires `create_launch_template` to be `true` | number | `var.workers_group_defaults[metadata_http_put_response_hop_limit]` |

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.56.0 |
| <a name="requirement_cloudinit"></a> [cloudinit](#requirement\_cloudinit) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.56.0 |
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | >= 2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eks_node_group.workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_launch_template.workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [cloudinit_config.workers_userdata](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of parent cluster | `string` | `""` | no |
| <a name="input_create_eks"></a> [create\_eks](#input\_create\_eks) | Controls if EKS resources should be created (it affects almost all resources) | `bool` | `true` | no |
| <a name="input_default_iam_role_arn"></a> [default\_iam\_role\_arn](#input\_default\_iam\_role\_arn) | ARN of the default IAM worker role to use if one is not specified in `var.node_groups` or `var.node_groups_defaults` | `string` | `""` | no |
| <a name="input_ebs_optimized_not_supported"></a> [ebs\_optimized\_not\_supported](#input\_ebs\_optimized\_not\_supported) | List of instance types that do not support EBS optimization | `list(string)` | `[]` | no |
| <a name="input_ng_depends_on"></a> [ng\_depends\_on](#input\_ng\_depends\_on) | List of references to other resources this submodule depends on | `any` | `null` | no |
| <a name="input_node_groups"></a> [node\_groups](#input\_node\_groups) | Map of maps of `eks_node_groups` to create. See "`node_groups` and `node_groups_defaults` keys" section in README.md for more details | `any` | `{}` | no |
| <a name="input_node_groups_defaults"></a> [node\_groups\_defaults](#input\_node\_groups\_defaults) | map of maps of node groups to create. See "`node_groups` and `node_groups_defaults` keys" section in README.md for more details | `any` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_worker_additional_security_group_ids"></a> [worker\_additional\_security\_group\_ids](#input\_worker\_additional\_security\_group\_ids) | A list of additional security group ids to attach to worker instances | `list(string)` | `[]` | no |
| <a name="input_worker_security_group_id"></a> [worker\_security\_group\_id](#input\_worker\_security\_group\_id) | If provided, all workers will be attached to this security group. If not given, a security group will be created with necessary ingress/egress to work with the EKS cluster. | `string` | `""` | no |
| <a name="input_workers_group_defaults"></a> [workers\_group\_defaults](#input\_workers\_group\_defaults) | Workers group defaults from parent | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_auth_roles"></a> [aws\_auth\_roles](#output\_aws\_auth\_roles) | Roles for use in aws-auth ConfigMap |
| <a name="output_node_groups"></a> [node\_groups](#output\_node\_groups) | Outputs from EKS node groups. Map of maps, keyed by `var.node_groups` keys. See `aws_eks_node_group` Terraform documentation for values |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
