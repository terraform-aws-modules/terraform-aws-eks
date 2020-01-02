# eks `node_groups` submodule

Helper submodule to create and manage resources related to `eks_node_groups`.

## Assumptions
* Designed for use by the parent module and not directly by end users

## Node Groups' IAM Role
The role ARN specified in `var.default_iam_role_arn` will be used by default. In a simple configuration this will be the worker role created by the parent module.

`iam_role_arn` must be specified in either `var.node_groups_defaults` or `var.node_groups` if the default parent IAM role is not being created for whatever reason, for example if `manage_worker_iam_resources` is set to false in the parent.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| cluster\_name | Name of parent cluster | string | n/a | yes |
| cluster\_version | Kubernetes version of parent cluster | string | n/a | yes |
| create\_eks | Controls if EKS resources should be created (it affects almost all resources) | bool | `"true"` | no |
| default\_iam\_role\_arn | ARN of the default IAM worker role to use if one is not specified in the node_groups | string | n/a | yes |
| node\_groups | Map of maps of `eks_node_groups` to create. See `node_groups_defaults` for valid keys and types. | any | `{}` | no |
| node\_groups\_defaults | map of maps of node groups to create. See default for valid keys and type. See source for extra comments | any | `{ "additional_tags": [ { "key": "" } ], "ami_release_version": "", "ami_type": "", "desired_capacity": 0, "disk_size": 0, "iam_role_arn": "", "instance_type": "", "k8s_labels": [ { "key": "" } ], "key_name": "", "max_capacity": 0, "min_capacity": 0, "source_security_group_ids": [ "" ], "subnets": [ "" ] }` | no |
| tags | A map of tags to add to all resources | map(string) | n/a | yes |
| workers\_group\_defaults | Workers group defaults from parent | any | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| aws\_auth\_roles | Roles for use in aws_auth ConfigMap |
| iam\_role\_arns | IAM role ARNs for EKS node groups. Map, keyed by var.node_groups keys |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
