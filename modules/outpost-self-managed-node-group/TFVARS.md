# Usage

Automated tfvars output for the outpost slef-managed node group module. Use this to find all of the available input flags and created resources.

<!--- BEGIN_TF_DOCS --->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| random | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| add\_autoscaling\_group\_tags | not recommended on outposts | `bool` | `false` | no |
| add\_node\_termination\_handler\_tags | Add the node termination handler tag to the node group | `bool` | `true` | no |
| additional\_tags | tags | `map(any)` | `{}` | no |
| ami\_id | AMI id to use for nodes | `string` | `""` | no |
| aws\_iam\_instance\_profile\_arn | aws\_iam\_instance\_profile\_arn | `string` | n/a | yes |
| cluster\_auth | cluster auth | `string` | `""` | no |
| cluster\_endpoint | cluster endpoint | `string` | `""` | no |
| cluster\_name | override for cluster name | `string` | `""` | no |
| cluster\_security\_group\_id | cluster security group id | `string` | n/a | yes |
| cluster\_version | cluster version | `string` | `""` | no |
| domain | vertical | `string` | n/a | yes |
| enable\_lifecycle\_hook | Create an instance terminating lifecycle hook | `bool` | `true` | no |
| environment | class of environment | `string` | n/a | yes |
| extra\_block\_device\_mappings | extra block device mappings | `map(any)` | `{}` | no |
| extra\_labels | extra labels to add | `map(any)` | `{}` | no |
| extra\_volume\_size | extra volume size | `number` | `30` | no |
| family | instance family | `string` | `"m5.xlarge"` | no |
| location | long name for the cluster location | `string` | `""` | no |
| max\_group\_size | the max size of the pg | `number` | `3` | no |
| min\_group\_size | minimum node group size | `number` | `3` | no |
| name | group name | `string` | n/a | yes |
| node\_security\_group\_id | default node sg | `string` | n/a | yes |
| node\_subnet\_id | subnet for the outpost node group | `string` | n/a | yes |
| outpost\_name | outpost name | `string` | n/a | yes |
| placement\_group\_partition\_count | placement partition count | `number` | `3` | no |
| placement\_group\_spread\_level | placement group spread level | `string` | `"host"` | no |
| placement\_group\_strategy | placement group strategy | `string` | `"spread"` | no |
| platform | the ami type for the node group | `string` | `"bottlerocket"` | no |
| region | long name for the cluster location (depricated) | `string` | `""` | no |
| root\_volume\_size | root volume size | `number` | `20` | no |
| security\_group\_ids | extra security groups to add to the node group | `list(string)` | `[]` | no |
| security\_group\_rules | security group rules if desired | <pre>map(object({<br>    description                   = string<br>    protocol                      = string<br>    from_port                     = number<br>    to_port                       = number<br>    type                          = string<br>    cidr_blocks                   = optional(list(string))<br>    security_group                = optional(string)<br>    source_cloudfront_prefix_list = optional(bool)<br>    prefix_list_id                = optional(string)<br>  }))</pre> | `{}` | no |
| shared\_security\_group\_id | id for self access security group | `string` | `""` | no |
| site | overrides location to site mapping | `string` | `""` | no |
| tags | tags | `map(any)` | n/a | yes |
| taints | taints | `map(any)` | `{}` | no |
| vpc\_id | vpc id | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| placement\_group\_arn | Node asg group id |
| placement\_group\_name | Node placement group name |
| security\_group\_id | Node asg group name |
| self\_managed\_node\_group\_iam\_role | Node asg group name |

<!--- END_TF_DOCS --->
