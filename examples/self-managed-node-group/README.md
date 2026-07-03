# Self-managed Node Group Examples

Configuration in this directory creates Amazon EKS clusters with self-managed node groups demonstrating different configurations:

- `eks-al2023.tf` demonstrates an EKS cluster using self-managed node group that utilizes the EKS Amazon Linux 2023 optimized AMI
- `eks-bottlerocket.tf` demonstrates an EKS cluster using self-managed node group that utilizes the Bottlerocket EKS optimized AMI

The different cluster configuration examples provided are separated per file and independent of the other cluster configurations.

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
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.52 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.52 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_eks_al2023"></a> [eks\_al2023](#module\_eks\_al2023) | terraform-aws-modules/eks/aws | ~> 21.0 |
| <a name="module_eks_bottlerocket"></a> [eks\_bottlerocket](#module\_eks\_bottlerocket) | terraform-aws-modules/eks/aws | ~> 21.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 6.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->
