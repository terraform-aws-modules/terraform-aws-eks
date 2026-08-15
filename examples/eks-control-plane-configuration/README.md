# EKS Advanced Control Plane Configuration

Configuration in this directory creates EKS clusters demonstrating the advanced Kubernetes control plane configuration parameters:

1. **API server configuration** - Custom event TTL and service node port range
2. **Controller manager configuration** - Faster HPA sync period (requires Provisioned Control Plane)
3. **Combined configuration** - All parameters configured together

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.59 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.59 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_disabled_eks"></a> [disabled\_eks](#module\_disabled\_eks) | ../.. | n/a |
| <a name="module_eks_api_server"></a> [eks\_api\_server](#module\_eks\_api\_server) | ../.. | n/a |
| <a name="module_eks_combined"></a> [eks\_combined](#module\_eks\_combined) | ../.. | n/a |
| <a name="module_eks_hpa_sync"></a> [eks\_hpa\_sync](#module\_eks\_hpa\_sync) | ../.. | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 6.0 |

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_server_kube_api_server_config"></a> [api\_server\_kube\_api\_server\_config](#output\_api\_server\_kube\_api\_server\_config) | The Kubernetes API server configuration |
| <a name="output_combined_kube_api_server_config"></a> [combined\_kube\_api\_server\_config](#output\_combined\_kube\_api\_server\_config) | The Kubernetes API server configuration for the combined cluster |
| <a name="output_combined_kube_controller_manager_config"></a> [combined\_kube\_controller\_manager\_config](#output\_combined\_kube\_controller\_manager\_config) | The Kubernetes controller manager configuration for the combined cluster |
| <a name="output_hpa_kube_controller_manager_config"></a> [hpa\_kube\_controller\_manager\_config](#output\_hpa\_kube\_controller\_manager\_config) | The Kubernetes controller manager configuration |
<!-- END_TF_DOCS -->
