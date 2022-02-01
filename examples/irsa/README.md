# IRSA example

Configuration in this directory creates an an IAM role, Kubernetes namespace, and Kubernetes service account to provide an [IAM role for service account](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.72 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_disabled_irsa"></a> [disabled\_irsa](#module\_disabled\_irsa) | ../../modules/irsa | n/a |
| <a name="module_eks"></a> [eks](#module\_eks) | ../.. | n/a |
| <a name="module_irsa"></a> [irsa](#module\_irsa) | ../../modules/irsa | n/a |
| <a name="module_irsa_simple"></a> [irsa\_simple](#module\_irsa\_simple) | ../../modules/irsa | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | The Amazon Resource Name (ARN) specifying the IAM role |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | The name of the IAM role |
| <a name="output_iam_role_unique_id"></a> [iam\_role\_unique\_id](#output\_iam\_role\_unique\_id) | Stable and unique string identifying the IAM role |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | The full map of attributes for the namespace created |
| <a name="output_service_account"></a> [service\_account](#output\_service\_account) | The full map of attributes for the service account created |
| <a name="output_service_account_name"></a> [service\_account\_name](#output\_service\_account\_name) | The full map of attributes for the service account created |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
