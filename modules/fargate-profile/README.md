# EKS Fargate Profile Module

Configuration in this directory creates a Fargate EKS Profile

## Usage

```hcl
module "fargate_profile" {
  source = "terraform-aws-modules/eks/aws//modules/fargate-profile"

  name         = "separate-fargate-profile"
  cluster_name = "my-cluster"

  subnet_ids = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]
  selectors = [{
    namespace = "kube-system"
  }]

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eks_fargate_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_fargate_profile) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | The AWS account ID - pass through value to reduce number of GET requests from data sources | `string` | `""` | no |
| <a name="input_cluster_ip_family"></a> [cluster\_ip\_family](#input\_cluster\_ip\_family) | The IP family used to assign Kubernetes pod and service addresses. Valid values are `ipv4` (default) and `ipv6` | `string` | `"ipv4"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `string` | `""` | no |
| <a name="input_create"></a> [create](#input\_create) | Determines whether to create Fargate profile or not | `bool` | `true` | no |
| <a name="input_create_iam_role"></a> [create\_iam\_role](#input\_create\_iam\_role) | Determines whether an IAM role is created or to use an existing IAM role | `bool` | `true` | no |
| <a name="input_create_iam_role_policy"></a> [create\_iam\_role\_policy](#input\_create\_iam\_role\_policy) | Determines whether an IAM role policy is created or not | `bool` | `true` | no |
| <a name="input_iam_role_additional_policies"></a> [iam\_role\_additional\_policies](#input\_iam\_role\_additional\_policies) | Additional policies to be added to the IAM role | `map(string)` | `{}` | no |
| <a name="input_iam_role_arn"></a> [iam\_role\_arn](#input\_iam\_role\_arn) | Existing IAM role ARN for the Fargate profile. Required if `create_iam_role` is set to `false` | `string` | `null` | no |
| <a name="input_iam_role_attach_cni_policy"></a> [iam\_role\_attach\_cni\_policy](#input\_iam\_role\_attach\_cni\_policy) | Whether to attach the `AmazonEKS_CNI_Policy`/`AmazonEKS_CNI_IPv6_Policy` IAM policy to the IAM IAM role. WARNING: If set `false` the permissions must be assigned to the `aws-node` DaemonSet pods via another method or nodes will not be able to join the cluster | `bool` | `true` | no |
| <a name="input_iam_role_description"></a> [iam\_role\_description](#input\_iam\_role\_description) | Description of the role | `string` | `"Fargate profile IAM role"` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name to use on IAM role created | `string` | `""` | no |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | IAM role path | `string` | `null` | no |
| <a name="input_iam_role_permissions_boundary"></a> [iam\_role\_permissions\_boundary](#input\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM role | `string` | `null` | no |
| <a name="input_iam_role_policy_statements"></a> [iam\_role\_policy\_statements](#input\_iam\_role\_policy\_statements) | A list of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) - used for adding specific IAM permissions as needed | <pre>list(object({<br/>    sid           = optional(string)<br/>    actions       = optional(list(string))<br/>    not_actions   = optional(list(string))<br/>    effect        = optional(string)<br/>    resources     = optional(list(string))<br/>    not_resources = optional(list(string))<br/>    principals = optional(list(object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    })))<br/>    not_principals = optional(list(object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    })))<br/>    condition = optional(list(object({<br/>      test     = string<br/>      values   = list(string)<br/>      variable = string<br/>    })))<br/>  }))</pre> | `null` | no |
| <a name="input_iam_role_tags"></a> [iam\_role\_tags](#input\_iam\_role\_tags) | A map of additional tags to add to the IAM role created | `map(string)` | `{}` | no |
| <a name="input_iam_role_use_name_prefix"></a> [iam\_role\_use\_name\_prefix](#input\_iam\_role\_use\_name\_prefix) | Determines whether the IAM role name (`iam_role_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the EKS Fargate Profile | `string` | `""` | no |
| <a name="input_partition"></a> [partition](#input\_partition) | The AWS partition - pass through value to reduce number of GET requests from data sources | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration | `string` | `null` | no |
| <a name="input_selectors"></a> [selectors](#input\_selectors) | Configuration block(s) for selecting Kubernetes Pods to execute with this Fargate Profile | <pre>list(object({<br/>    labels    = optional(map(string))<br/>    namespace = string<br/>  }))</pre> | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of subnet IDs for the EKS Fargate Profile | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Create and delete timeout configurations for the Fargate Profile | <pre>object({<br/>    create = optional(string)<br/>    delete = optional(string)<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_fargate_profile_arn"></a> [fargate\_profile\_arn](#output\_fargate\_profile\_arn) | Amazon Resource Name (ARN) of the EKS Fargate Profile |
| <a name="output_fargate_profile_id"></a> [fargate\_profile\_id](#output\_fargate\_profile\_id) | EKS Cluster name and EKS Fargate Profile name separated by a colon (`:`) |
| <a name="output_fargate_profile_pod_execution_role_arn"></a> [fargate\_profile\_pod\_execution\_role\_arn](#output\_fargate\_profile\_pod\_execution\_role\_arn) | Amazon Resource Name (ARN) of the EKS Fargate Profile Pod execution role ARN |
| <a name="output_fargate_profile_status"></a> [fargate\_profile\_status](#output\_fargate\_profile\_status) | Status of the EKS Fargate Profile |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | The Amazon Resource Name (ARN) specifying the IAM role |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | The name of the IAM role |
| <a name="output_iam_role_unique_id"></a> [iam\_role\_unique\_id](#output\_iam\_role\_unique\_id) | Stable and unique string identifying the IAM role |
<!-- END_TF_DOCS -->
