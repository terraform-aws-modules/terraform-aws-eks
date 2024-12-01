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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.75 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.16 |
| <a name="requirement_http"></a> [http](#requirement\_http) | >= 3.4 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.5 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.75 |
| <a name="provider_aws.remote"></a> [aws.remote](#provider\_aws.remote) | >= 5.75 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.16 |
| <a name="provider_http"></a> [http](#provider\_http) | >= 3.4 |
| <a name="provider_local"></a> [local](#provider\_local) | >= 2.5 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | >= 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_disabled_eks_hybrid_node_role"></a> [disabled\_eks\_hybrid\_node\_role](#module\_disabled\_eks\_hybrid\_node\_role) | ../../modules/hybrid-node-role | n/a |
| <a name="module_eks"></a> [eks](#module\_eks) | ../.. | n/a |
| <a name="module_eks_hybrid_node_role"></a> [eks\_hybrid\_node\_role](#module\_eks\_hybrid\_node\_role) | ../../modules/hybrid-node-role | n/a |
| <a name="module_ira_eks_hybrid_node_role"></a> [ira\_eks\_hybrid\_node\_role](#module\_ira\_eks\_hybrid\_node\_role) | ../../modules/hybrid-node-role | n/a |
| <a name="module_key_pair"></a> [key\_pair](#module\_key\_pair) | terraform-aws-modules/key-pair/aws | ~> 2.0 |
| <a name="module_remote_node_vpc"></a> [remote\_node\_vpc](#module\_remote\_node\_vpc) | terraform-aws-modules/vpc/aws | ~> 5.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_instance.hybrid_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_route.peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.remote_node_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.remote_node_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_security_group.remote_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ssm_activation.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_activation) | resource |
| [aws_vpc_peering_connection.remote_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection) | resource |
| [aws_vpc_peering_connection_accepter.peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_accepter) | resource |
| [aws_vpc_security_group_egress_rule.remote_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.remote_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [helm_release.cilium](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [local_file.join](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.key_pem](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.key_pub_pem](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [tls_private_key.example](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.example](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |
| [aws_ami.hybrid_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_availability_zones.remote](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [http_http.icanhazip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

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
