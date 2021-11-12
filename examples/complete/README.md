# Complete AWS EKS Cluster

Configuration in this directory creates EKS cluster with different features shown all-in-one cluster (e.g. Managed Node Groups, Worker Groups, Fargate, Spot instances, AWS Auth enabled).

This example can be used to do smoke test.

See configurations in other `examples` directories for more specific cases.

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
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.56.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.56.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_disabled_eks"></a> [disabled\_eks](#module\_disabled\_eks) | ../.. | n/a |
| <a name="module_disabled_fargate"></a> [disabled\_fargate](#module\_disabled\_fargate) | ../../modules/fargate | n/a |
| <a name="module_eks"></a> [eks](#module\_eks) | ../.. | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_security_group.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint for EKS control plane. |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | Security group ids attached to the cluster control plane. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
