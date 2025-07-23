# EKS Hybrid Node Role Module

Terraform module which creates IAM role and policy resources for Amazon EKS Hybrid Node(s).

## Usage

EKS Hybrid nodes use the AWS IAM Authenticator and temporary IAM credentials provisioned by AWS SSM or AWS IAM Roles Anywhere to authenticate with the EKS cluster. This module supports both SSM and IAM Roles Anywhere based IAM permissions.

### SSM

```hcl
module "eks" {
  source = "terraform-aws-modules/eks/aws"

  ...
  access_entries = {
    hybrid-node-role = {
      principal_arn = module.eks_hybrid_node_role.arn
      type          = "HYBRID_LINUX"
    }
  }
}

module "eks_hybrid_node_role" {
  source = "terraform-aws-modules/eks/aws//modules/hybrid-node-role"

  name = "hybrid"

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

### IAM Roles Anywhere

```hcl
module "eks" {
  source = "terraform-aws-modules/eks/aws"

  ...
  access_entries = {
    hybrid-node-role = {
      principal_arn = module.eks_hybrid_node_role.arn
      type          = "HYBRID_LINUX"
    }
  }
}

module "eks_hybrid_node_role" {
  source = "terraform-aws-modules/eks/aws//modules/hybrid-node-role"

  name = "hybrid-ira"

  enable_ira = true

  ira_trust_anchor_source_type           = "CERTIFICATE_BUNDLE"
  ira_trust_anchor_x509_certificate_data = <<-EOT
    MIIFMzCCAxugAwIBAgIRAMnVXU7ncv/+Cl16eJbZ9hswDQYJKoZIhvcNAQELBQAw
    ...
    MGx/BMRkrNUVcg3xA0lhECo/olodCkmZo5/mjybbjFQwJzDSKFoW
  EOT

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
| [aws_iam_policy.intermediate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.intermediate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.intermediate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_rolesanywhere_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rolesanywhere_profile) | resource |
| [aws_rolesanywhere_trust_anchor.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rolesanywhere_trust_anchor) | resource |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.intermediate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.intermediate_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_arns"></a> [cluster\_arns](#input\_cluster\_arns) | List of EKS cluster ARNs to allow the node to describe | `list(string)` | <pre>[<br/>  "*"<br/>]</pre> | no |
| <a name="input_create"></a> [create](#input\_create) | Controls if resources should be created (affects nearly all resources) | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | IAM role description | `string` | `"EKS Hybrid Node IAM role"` | no |
| <a name="input_enable_ira"></a> [enable\_ira](#input\_enable\_ira) | Enables IAM Roles Anywhere based IAM permissions on the node | `bool` | `false` | no |
| <a name="input_enable_pod_identity"></a> [enable\_pod\_identity](#input\_enable\_pod\_identity) | Enables EKS Pod Identity based IAM permissions on the node | `bool` | `true` | no |
| <a name="input_intermediate_policy_name"></a> [intermediate\_policy\_name](#input\_intermediate\_policy\_name) | Name of the IAM policy | `string` | `null` | no |
| <a name="input_intermediate_policy_statements"></a> [intermediate\_policy\_statements](#input\_intermediate\_policy\_statements) | A list of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) - used for adding specific IAM permissions as needed | <pre>list(object({<br/>    sid           = optional(string)<br/>    actions       = optional(list(string))<br/>    not_actions   = optional(list(string))<br/>    effect        = optional(string)<br/>    resources     = optional(list(string))<br/>    not_resources = optional(list(string))<br/>    principals = optional(list(object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    })))<br/>    not_principals = optional(list(object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    })))<br/>    condition = optional(list(object({<br/>      test     = string<br/>      values   = list(string)<br/>      variable = string<br/>    })))<br/>  }))</pre> | `null` | no |
| <a name="input_intermediate_policy_use_name_prefix"></a> [intermediate\_policy\_use\_name\_prefix](#input\_intermediate\_policy\_use\_name\_prefix) | Determines whether the name of the IAM policy (`intermediate_policy_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_intermediate_role_description"></a> [intermediate\_role\_description](#input\_intermediate\_role\_description) | IAM role description | `string` | `"EKS Hybrid Node IAM Roles Anywhere intermediate IAM role"` | no |
| <a name="input_intermediate_role_name"></a> [intermediate\_role\_name](#input\_intermediate\_role\_name) | Name of the IAM role | `string` | `null` | no |
| <a name="input_intermediate_role_path"></a> [intermediate\_role\_path](#input\_intermediate\_role\_path) | Path of the IAM role | `string` | `"/"` | no |
| <a name="input_intermediate_role_policies"></a> [intermediate\_role\_policies](#input\_intermediate\_role\_policies) | Policies to attach to the IAM role in `{'static_name' = 'policy_arn'}` format | `map(string)` | `{}` | no |
| <a name="input_intermediate_role_use_name_prefix"></a> [intermediate\_role\_use\_name\_prefix](#input\_intermediate\_role\_use\_name\_prefix) | Determines whether the name of the IAM role (`intermediate_role_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_ira_profile_duration_seconds"></a> [ira\_profile\_duration\_seconds](#input\_ira\_profile\_duration\_seconds) | The number of seconds the vended session credentials are valid for. Defaults to `3600` | `number` | `null` | no |
| <a name="input_ira_profile_managed_policy_arns"></a> [ira\_profile\_managed\_policy\_arns](#input\_ira\_profile\_managed\_policy\_arns) | A list of managed policy ARNs that apply to the vended session credentials | `list(string)` | `[]` | no |
| <a name="input_ira_profile_name"></a> [ira\_profile\_name](#input\_ira\_profile\_name) | Name of the Roles Anywhere profile | `string` | `null` | no |
| <a name="input_ira_profile_require_instance_properties"></a> [ira\_profile\_require\_instance\_properties](#input\_ira\_profile\_require\_instance\_properties) | Specifies whether instance properties are required in [CreateSession](https://docs.aws.amazon.com/rolesanywhere/latest/APIReference/API_CreateSession.html) requests with this profile | `bool` | `null` | no |
| <a name="input_ira_profile_session_policy"></a> [ira\_profile\_session\_policy](#input\_ira\_profile\_session\_policy) | A session policy that applies to the trust boundary of the vended session credentials | `string` | `null` | no |
| <a name="input_ira_trust_anchor_acm_pca_arn"></a> [ira\_trust\_anchor\_acm\_pca\_arn](#input\_ira\_trust\_anchor\_acm\_pca\_arn) | The ARN of the ACM PCA that issued the trust anchor certificate | `string` | `null` | no |
| <a name="input_ira_trust_anchor_name"></a> [ira\_trust\_anchor\_name](#input\_ira\_trust\_anchor\_name) | Name of the Roles Anywhere trust anchor | `string` | `null` | no |
| <a name="input_ira_trust_anchor_notification_settings"></a> [ira\_trust\_anchor\_notification\_settings](#input\_ira\_trust\_anchor\_notification\_settings) | Notification settings for the trust anchor | <pre>list(object({<br/>    channel   = optional(string)<br/>    enabled   = optional(bool)<br/>    event     = optional(string)<br/>    threshold = optional(number)<br/>  }))</pre> | `null` | no |
| <a name="input_ira_trust_anchor_source_type"></a> [ira\_trust\_anchor\_source\_type](#input\_ira\_trust\_anchor\_source\_type) | The source type of the trust anchor | `string` | `null` | no |
| <a name="input_ira_trust_anchor_x509_certificate_data"></a> [ira\_trust\_anchor\_x509\_certificate\_data](#input\_ira\_trust\_anchor\_x509\_certificate\_data) | The X.509 certificate data of the trust anchor | `string` | `null` | no |
| <a name="input_max_session_duration"></a> [max\_session\_duration](#input\_max\_session\_duration) | Maximum API session duration in seconds between 3600 and 43200 | `number` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the IAM role | `string` | `"EKSHybridNode"` | no |
| <a name="input_path"></a> [path](#input\_path) | Path of the IAM role | `string` | `"/"` | no |
| <a name="input_permissions_boundary_arn"></a> [permissions\_boundary\_arn](#input\_permissions\_boundary\_arn) | Permissions boundary ARN to use for the IAM role | `string` | `null` | no |
| <a name="input_policies"></a> [policies](#input\_policies) | Policies to attach to the IAM role in `{'static_name' = 'policy_arn'}` format | `map(string)` | `{}` | no |
| <a name="input_policy_description"></a> [policy\_description](#input\_policy\_description) | IAM policy description | `string` | `"EKS Hybrid Node IAM role policy"` | no |
| <a name="input_policy_name"></a> [policy\_name](#input\_policy\_name) | Name of the IAM policy | `string` | `"EKSHybridNode"` | no |
| <a name="input_policy_path"></a> [policy\_path](#input\_policy\_path) | Path of the IAM policy | `string` | `"/"` | no |
| <a name="input_policy_statements"></a> [policy\_statements](#input\_policy\_statements) | A list of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) - used for adding specific IAM permissions as needed | <pre>list(object({<br/>    sid           = optional(string)<br/>    actions       = optional(list(string))<br/>    not_actions   = optional(list(string))<br/>    effect        = optional(string)<br/>    resources     = optional(list(string))<br/>    not_resources = optional(list(string))<br/>    principals = optional(list(object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    })))<br/>    not_principals = optional(list(object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    })))<br/>    condition = optional(list(object({<br/>      test     = string<br/>      values   = list(string)<br/>      variable = string<br/>    })))<br/>  }))</pre> | `null` | no |
| <a name="input_policy_use_name_prefix"></a> [policy\_use\_name\_prefix](#input\_policy\_use\_name\_prefix) | Determines whether the name of the IAM policy (`policy_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of additional tags to add the the IAM role | `map(string)` | `{}` | no |
| <a name="input_trust_anchor_arns"></a> [trust\_anchor\_arns](#input\_trust\_anchor\_arns) | List of IAM Roles Anywhere trust anchor ARNs. Required if `enable_ira` is set to `true` | `list(string)` | `[]` | no |
| <a name="input_use_name_prefix"></a> [use\_name\_prefix](#input\_use\_name\_prefix) | Determines whether the name of the IAM role (`name`) is used as a prefix | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) specifying the node IAM role |
| <a name="output_intermediate_role_arn"></a> [intermediate\_role\_arn](#output\_intermediate\_role\_arn) | The Amazon Resource Name (ARN) specifying the node IAM role |
| <a name="output_intermediate_role_name"></a> [intermediate\_role\_name](#output\_intermediate\_role\_name) | The name of the node IAM role |
| <a name="output_intermediate_role_unique_id"></a> [intermediate\_role\_unique\_id](#output\_intermediate\_role\_unique\_id) | Stable and unique string identifying the node IAM role |
| <a name="output_name"></a> [name](#output\_name) | The name of the node IAM role |
| <a name="output_unique_id"></a> [unique\_id](#output\_unique\_id) | Stable and unique string identifying the node IAM role |
<!-- END_TF_DOCS -->
