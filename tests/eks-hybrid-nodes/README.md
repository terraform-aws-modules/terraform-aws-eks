# EKS Hybrid Node IAM Role

## Usage

To provision the provided configurations you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply --auto-approve
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_tls"></a> [tls](#provider\_tls) | >= 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_disabled_eks_hybrid_node_role"></a> [disabled\_eks\_hybrid\_node\_role](#module\_disabled\_eks\_hybrid\_node\_role) | ../../modules/hybrid-node-role | n/a |
| <a name="module_eks_hybrid_node_role"></a> [eks\_hybrid\_node\_role](#module\_eks\_hybrid\_node\_role) | ../../modules/hybrid-node-role | n/a |
| <a name="module_ira_eks_hybrid_node_role"></a> [ira\_eks\_hybrid\_node\_role](#module\_ira\_eks\_hybrid\_node\_role) | ../../modules/hybrid-node-role | n/a |

## Resources

| Name | Type |
|------|------|
| [tls_private_key.example](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.example](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) specifying the node IAM role |
| <a name="output_intermediate_role_arn"></a> [intermediate\_role\_arn](#output\_intermediate\_role\_arn) | The Amazon Resource Name (ARN) specifying the node IAM role |
| <a name="output_intermediate_role_name"></a> [intermediate\_role\_name](#output\_intermediate\_role\_name) | The name of the node IAM role |
| <a name="output_intermediate_role_unique_id"></a> [intermediate\_role\_unique\_id](#output\_intermediate\_role\_unique\_id) | Stable and unique string identifying the node IAM role |
| <a name="output_ira_arn"></a> [ira\_arn](#output\_ira\_arn) | The Amazon Resource Name (ARN) specifying the node IAM role |
| <a name="output_ira_intermediate_role_arn"></a> [ira\_intermediate\_role\_arn](#output\_ira\_intermediate\_role\_arn) | The Amazon Resource Name (ARN) specifying the node IAM role |
| <a name="output_ira_intermediate_role_name"></a> [ira\_intermediate\_role\_name](#output\_ira\_intermediate\_role\_name) | The name of the node IAM role |
| <a name="output_ira_intermediate_role_unique_id"></a> [ira\_intermediate\_role\_unique\_id](#output\_ira\_intermediate\_role\_unique\_id) | Stable and unique string identifying the node IAM role |
| <a name="output_ira_name"></a> [ira\_name](#output\_ira\_name) | The name of the node IAM role |
| <a name="output_ira_unique_id"></a> [ira\_unique\_id](#output\_ira\_unique\_id) | Stable and unique string identifying the node IAM role |
| <a name="output_name"></a> [name](#output\_name) | The name of the node IAM role |
| <a name="output_unique_id"></a> [unique\_id](#output\_unique\_id) | Stable and unique string identifying the node IAM role |
<!-- END_TF_DOCS -->
