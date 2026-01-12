# EKS Capability Module

Configuration in this directory creates the AWS resources required by EKS capabilities

## Usage

```hcl
TODO
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.28 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.28 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eks_capability.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_capability) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_capabilities"></a> [capabilities](#input\_capabilities) | Map of capability definitions to create | <pre>map(object({<br/>    capability_name = optional(string) # will fall back to map key<br/>    configuration = optional(object({<br/>      argo_cd = optional(object({<br/>        aws_idc = object({<br/>          idc_instance_arn = string<br/>          idc_region       = optional(string)<br/>        })<br/>        namespace = optional(string)<br/>        network_access = optional(object({<br/>          vpce_ids = optional(list(string))<br/>        }))<br/>        rbac_role_mapping = optional(object({<br/>          identity = list(object({<br/>            id   = string<br/>            type = string<br/>          }))<br/>          role = string<br/>        }))<br/>      }))<br/>    }))<br/>    delete_propagation_policy = optional(string)<br/>    role_arn                  = string<br/>    type                      = string<br/>    timeouts = optional(object({<br/>      create = optional(string)<br/>      update = optional(string)<br/>      delete = optional(string)<br/>    }))<br/>    tags = optional(map(string))<br/>  }))</pre> | `null` | no |
| <a name="input_create"></a> [create](#input\_create) | Controls if resources should be created (affects nearly all resources) | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## License

Apache 2 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/LICENSE) for full details.
