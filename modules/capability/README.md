# EKS Capability Module

Configuration in this directory creates the AWS resources required by EKS capabilities

## Usage

### ACK

```hcl
module "ack_eks_capability" {
  source = "terraform-aws-modules/eks/aws//modules/capability"

  name         = "example-ack"
  cluster_name = "example"
  type         = "ACK"

  # IAM Role/Policy
  iam_role_policies = {
    AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess"
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

### ArgoCD

```hcl
module "argocd_eks_capability" {
  source = "terraform-aws-modules/eks/aws//modules/capability"

  name         = "example-argocd"
  cluster_name = "example"
  type         = "ARGOCD"

  configuration = {
      argo_cd = {
        aws_idc = {
          idc_instance_arn = "arn:aws:sso:::instance/ssoins-1234567890abcdef0"
        }
        namespace = "argocd"
        rbac_role_mapping = [{
          role = "ADMIN"
          identity = [{
            id   = "686103e0-f051-7068-b225-e6392b959d9e"
            type = "SSO_GROUP"
          }]
        }]
      }
  }

  # IAM Role/Policy
  iam_policy_statements = {
    ECRRead = {
      actions = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
      ]
      resources = ["*"]
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

### KRO

```hcl
module "kro_eks_capability" {
  source = "terraform-aws-modules/eks/aws//modules/capability"

  name         = "example-kro"
  cluster_name = "example"
  type         = "KRO"

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
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.28 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.28 |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.9 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eks_capability.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_capability) | resource |
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [time_sleep.this](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_service_principal.capabilities_eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/service_principal) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the EKS cluster | `string` | `""` | no |
| <a name="input_configuration"></a> [configuration](#input\_configuration) | Configuration for the capability | <pre>object({<br/>    argo_cd = optional(object({<br/>      aws_idc = object({<br/>        idc_instance_arn = string<br/>        idc_region       = optional(string)<br/>      })<br/>      namespace = optional(string)<br/>      network_access = optional(object({<br/>        vpce_ids = optional(list(string))<br/>      }))<br/>      rbac_role_mapping = optional(list(object({<br/>        identity = list(object({<br/>          id   = string<br/>          type = string<br/>        }))<br/>        role = string<br/>      })))<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_create"></a> [create](#input\_create) | Controls if resources should be created (affects nearly all resources) | `bool` | `true` | no |
| <a name="input_create_iam_role"></a> [create\_iam\_role](#input\_create\_iam\_role) | Determines whether an IAM role is created | `bool` | `true` | no |
| <a name="input_delete_propagation_policy"></a> [delete\_propagation\_policy](#input\_delete\_propagation\_policy) | The propagation policy to use when deleting the capability. Valid values: `RETAIN` | `string` | `"RETAIN"` | no |
| <a name="input_iam_policy_description"></a> [iam\_policy\_description](#input\_iam\_policy\_description) | IAM policy description | `string` | `null` | no |
| <a name="input_iam_policy_name"></a> [iam\_policy\_name](#input\_iam\_policy\_name) | Name of the IAM policy | `string` | `null` | no |
| <a name="input_iam_policy_path"></a> [iam\_policy\_path](#input\_iam\_policy\_path) | Path of the IAM policy | `string` | `null` | no |
| <a name="input_iam_policy_statements"></a> [iam\_policy\_statements](#input\_iam\_policy\_statements) | A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) - used for adding specific IAM permissions as needed | <pre>map(object({<br/>    sid           = optional(string)<br/>    actions       = optional(list(string))<br/>    not_actions   = optional(list(string))<br/>    effect        = optional(string)<br/>    resources     = optional(list(string))<br/>    not_resources = optional(list(string))<br/>    principals = optional(list(object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    })))<br/>    not_principals = optional(list(object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    })))<br/>    condition = optional(list(object({<br/>      test     = string<br/>      values   = list(string)<br/>      variable = string<br/>    })))<br/>  }))</pre> | `null` | no |
| <a name="input_iam_policy_use_name_prefix"></a> [iam\_policy\_use\_name\_prefix](#input\_iam\_policy\_use\_name\_prefix) | Determines whether the name of the IAM policy (`iam_policy_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_iam_role_arn"></a> [iam\_role\_arn](#input\_iam\_role\_arn) | The ARN of the IAM role that provides permissions for the capability | `string` | `null` | no |
| <a name="input_iam_role_description"></a> [iam\_role\_description](#input\_iam\_role\_description) | IAM role description | `string` | `null` | no |
| <a name="input_iam_role_max_session_duration"></a> [iam\_role\_max\_session\_duration](#input\_iam\_role\_max\_session\_duration) | Maximum API session duration in seconds between 3600 and 43200 | `number` | `null` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name of the IAM role | `string` | `null` | no |
| <a name="input_iam_role_override_assume_policy_documents"></a> [iam\_role\_override\_assume\_policy\_documents](#input\_iam\_role\_override\_assume\_policy\_documents) | A list of IAM policy documents to override the default assume role policy document for the Karpenter controller IAM role | `list(string)` | `[]` | no |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | Path of the IAM role | `string` | `null` | no |
| <a name="input_iam_role_permissions_boundary_arn"></a> [iam\_role\_permissions\_boundary\_arn](#input\_iam\_role\_permissions\_boundary\_arn) | Permissions boundary ARN to use for the IAM role | `string` | `null` | no |
| <a name="input_iam_role_policies"></a> [iam\_role\_policies](#input\_iam\_role\_policies) | Policies to attach to the IAM role in `{'static_name' = 'policy_arn'}` format | `map(string)` | `{}` | no |
| <a name="input_iam_role_source_assume_policy_documents"></a> [iam\_role\_source\_assume\_policy\_documents](#input\_iam\_role\_source\_assume\_policy\_documents) | A list of IAM policy documents to use as a source for the assume role policy document for the Karpenter controller IAM role | `list(string)` | `[]` | no |
| <a name="input_iam_role_tags"></a> [iam\_role\_tags](#input\_iam\_role\_tags) | A map of additional tags to add the the IAM role | `map(string)` | `{}` | no |
| <a name="input_iam_role_use_name_prefix"></a> [iam\_role\_use\_name\_prefix](#input\_iam\_role\_use\_name\_prefix) | Determines whether the name of the IAM role (`iam_role_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the capability to add to the cluster | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Create, update, and delete timeout configurations for the capability | <pre>object({<br/>    create = optional(string)<br/>    update = optional(string)<br/>    delete = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_type"></a> [type](#input\_type) | Type of the capability. Valid values: `ACK`, `KRO`, `ARGOCD` | `string` | `""` | no |
| <a name="input_wait_duration"></a> [wait\_duration](#input\_wait\_duration) | Duration to wait between creating the IAM role/policy and creating the capability | `string` | `"20s"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_argocd_server_url"></a> [argocd\_server\_url](#output\_argocd\_server\_url) | URL of the Argo CD server |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the EKS Capability |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | The Amazon Resource Name (ARN) specifying the IAM role |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | The name of the IAM role |
| <a name="output_iam_role_unique_id"></a> [iam\_role\_unique\_id](#output\_iam\_role\_unique\_id) | Stable and unique string identifying the IAM role |
| <a name="output_version"></a> [version](#output\_version) | The version of the EKS Capability |
<!-- END_TF_DOCS -->

## License

Apache 2 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/LICENSE) for full details.
