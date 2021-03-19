# eks `fargate` submodule

Helper submodule to create and manage resources related to `aws_eks_fargate_profile`.

## Assumptions
* Designed for use by the parent module and not directly by end users

## `fargate_profile` keys
`fargate_profile` is a map of maps. Key of first level will be used as unique value for `for_each` resources and in the `aws_eks_fargate_profile` name. Inner map can take the below values.

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Fargate profile name | `string` | Auto generated in the following format `[cluster_name]-fargate-[fargate_profile_map_key]`| no |
| namespace | Kubernetes namespace for selection | `string` | n/a | yes |
| labels | Key-value map of Kubernetes labels for selection | `map(string)` | `{}` | no |
| tags | Key-value map of resource tags. Will be merged with root module tags. | `map(string)` | `var.tags` | no |
| subnets | List of subnet IDs. Will replace the root module subnets. | `list(string)` | `var.subnets` | no |

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_name | Name of the EKS cluster. | `string` | n/a | yes |
| create\_eks | Controls if EKS resources should be created (it affects almost all resources) | `bool` | `true` | no |
| create\_fargate\_pod\_execution\_role | Controls if the the IAM Role that provides permissions for the EKS Fargate Profile should be created. | `bool` | `true` | no |
| eks\_depends\_on | List of references to other resources this submodule depends on. | `any` | `null` | no |
| fargate\_pod\_execution\_role\_name | The IAM Role that provides permissions for the EKS Fargate Profile. | `string` | `null` | no |
| fargate\_profiles | Fargate profiles to create. See `fargate_profile` keys section in README.md for more details | `any` | `{}` | no |
| iam\_path | IAM roles will be created on this path. | `string` | `"/"` | no |
| iam\_policy\_arn\_prefix | IAM policy prefix with the correct AWS partition. | `string` | n/a | yes |
| permissions\_boundary | If provided, all IAM roles will be created with this permissions boundary attached. | `string` | `null` | no |
| subnets | A list of subnets for the EKS Fargate profiles. | `list(string)` | `[]` | no |
| tags | A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| aws\_auth\_roles | Roles for use in aws-auth ConfigMap |
| fargate\_profile\_arns | Amazon Resource Name (ARN) of the EKS Fargate Profiles. |
| fargate\_profile\_ids | EKS Cluster name and EKS Fargate Profile names separated by a colon (:). |
| iam\_role\_arn | IAM role ARN for EKS Fargate pods |
| iam\_role\_name | IAM role name for EKS Fargate pods |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
