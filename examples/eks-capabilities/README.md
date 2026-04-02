# EKS Capabilities Example

## Usage

To provision the provided configurations you need to execute:

```bash
terraform init
terraform plan
terraform apply --auto-approve
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ack_eks_capability"></a> [ack\_eks\_capability](#module\_ack\_eks\_capability) | ../../modules/capability | n/a |
| <a name="module_argocd_eks_capability"></a> [argocd\_eks\_capability](#module\_argocd\_eks\_capability) | ../../modules/capability | n/a |
| <a name="module_disabled_eks_capability"></a> [disabled\_eks\_capability](#module\_disabled\_eks\_capability) | ../../modules/capability | n/a |
| <a name="module_eks"></a> [eks](#module\_eks) | ../.. | n/a |
| <a name="module_kro_eks_capability"></a> [kro\_eks\_capability](#module\_kro\_eks\_capability) | ../../modules/capability | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 6.0 |

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_identitystore_group.aws_administrator](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/identitystore_group) | data source |
| [aws_ssoadmin_instances.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ack_argocd_server_url"></a> [ack\_argocd\_server\_url](#output\_ack\_argocd\_server\_url) | URL of the Argo CD server |
| <a name="output_ack_arn"></a> [ack\_arn](#output\_ack\_arn) | The ARN of the EKS Capability |
| <a name="output_ack_iam_role_arn"></a> [ack\_iam\_role\_arn](#output\_ack\_iam\_role\_arn) | The Amazon Resource Name (ARN) specifying the IAM role |
| <a name="output_ack_iam_role_name"></a> [ack\_iam\_role\_name](#output\_ack\_iam\_role\_name) | The name of the IAM role |
| <a name="output_ack_iam_role_unique_id"></a> [ack\_iam\_role\_unique\_id](#output\_ack\_iam\_role\_unique\_id) | Stable and unique string identifying the IAM role |
| <a name="output_ack_version"></a> [ack\_version](#output\_ack\_version) | The version of the EKS Capability |
| <a name="output_argocd_arn"></a> [argocd\_arn](#output\_argocd\_arn) | The ARN of the EKS Capability |
| <a name="output_argocd_iam_role_arn"></a> [argocd\_iam\_role\_arn](#output\_argocd\_iam\_role\_arn) | The Amazon Resource Name (ARN) specifying the IAM role |
| <a name="output_argocd_iam_role_name"></a> [argocd\_iam\_role\_name](#output\_argocd\_iam\_role\_name) | The name of the IAM role |
| <a name="output_argocd_iam_role_unique_id"></a> [argocd\_iam\_role\_unique\_id](#output\_argocd\_iam\_role\_unique\_id) | Stable and unique string identifying the IAM role |
| <a name="output_argocd_server_url"></a> [argocd\_server\_url](#output\_argocd\_server\_url) | URL of the Argo CD server |
| <a name="output_argocd_version"></a> [argocd\_version](#output\_argocd\_version) | The version of the EKS Capability |
| <a name="output_kro_argocd_server_url"></a> [kro\_argocd\_server\_url](#output\_kro\_argocd\_server\_url) | URL of the Argo CD server |
| <a name="output_kro_arn"></a> [kro\_arn](#output\_kro\_arn) | The ARN of the EKS Capability |
| <a name="output_kro_iam_role_arn"></a> [kro\_iam\_role\_arn](#output\_kro\_iam\_role\_arn) | The Amazon Resource Name (ARN) specifying the IAM role |
| <a name="output_kro_iam_role_name"></a> [kro\_iam\_role\_name](#output\_kro\_iam\_role\_name) | The name of the IAM role |
| <a name="output_kro_iam_role_unique_id"></a> [kro\_iam\_role\_unique\_id](#output\_kro\_iam\_role\_unique\_id) | Stable and unique string identifying the IAM role |
| <a name="output_kro_version"></a> [kro\_version](#output\_kro\_version) | The version of the EKS Capability |
<!-- END_TF_DOCS -->
