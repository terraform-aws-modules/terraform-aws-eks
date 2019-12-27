# eks `node_groups` submodule

Helper submodule to create and manage resources related to `eks_node_groups`.

## Assumptions
* Designed for use by the parent module and not directly by end users

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| attach\_worker\_autoscaling\_policy | Whether to attach the module managed cluster autoscaling iam policy to the default worker IAM role. This requires `manage_worker_autoscaling_policy = true` | bool | n/a | yes |
| cluster\_name | Name of parent cluster | string | n/a | yes |
| cluster\_version | Kubernetes version of parent cluster | string | n/a | yes |
| create\_eks | Controls if EKS resources should be created (it affects almost all resources) | bool | `"true"` | no |
| iam\_path | If provided, all IAM roles will be created on this path. | string | n/a | yes |
| manage\_worker\_autoscaling\_policy | Whether to let the module manage the cluster autoscaling iam policy. | bool | n/a | yes |
| manage\_worker\_iam\_resources | Whether to let the module manage worker IAM resources. If set to false, iam_instance_profile_name must be specified for workers. | bool | n/a | yes |
| node\_groups | map of maps of node groups to create. See default for valid keys and type. See source for extra comments | any | `{ "example_ng": [ { "additional_tags": [ { "key": "" } ], "ami_release_version": "", "ami_type": "", "desired_capacity": 0, "iam_role_arn": "", "instance_type": "", "k8s_labels": [ { "key": "" } ], "key_name": "", "max_capacity": 0, "min_capacity": 0, "root_volume_size": 0, "source_security_group_ids": [ "" ], "subnets": [ "" ] } ] }` | no |
| permissions\_boundary | If provided, all IAM roles will be created with this permissions boundary attached. | string | n/a | yes |
| role\_name | Custom name for IAM role. Otherwise one will be generated | string | n/a | yes |
| tags | A map of trags to add to all resources | map(string) | n/a | yes |
| worker\_autoscaling\_policy\_arn | ARN of the worker autoscaling policy. | string | n/a | yes |
| workers\_additional\_policies | Additional policies to be added to workers | list(string) | n/a | yes |
| workers\_group\_defaults | Workers group defaults from parent | any | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| aws\_auth\_snippet | Snippet for use in aws_auth ConfigMap |
| iam\_role\_arns | IAM role ARNs for EKS node groups. Map, keyed by var.node_groups keys |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
