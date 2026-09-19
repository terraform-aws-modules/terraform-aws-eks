# EKS Managed Node Group Examples

Configuration in this directory creates Amazon EKS clusters with EKS Managed Node Groups demonstrating different configurations:

- `eks-al2023.tf` demonstrates an EKS cluster using EKS managed node group that utilizes the EKS Amazon Linux 2023 optimized AMI with a warm pool
- `eks-bottlerocket.tf` demonstrates an EKS cluster using EKS managed node group that utilizes the Bottlerocket EKS optimized AMI

See the [AWS documentation](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html) for additional details on Amazon EKS managed node groups.

Set `warm_pool_config = {}` to enable a warm pool with default settings, or set it to `null` (the module default) to disable it. The AL2023 example configures a stopped warm pool and reuses instances on scale-in.

Warm pools require EKS optimized AMIs; custom AMIs are not supported. Bottlerocket does not support the `HIBERNATED` pool state or `reuse_on_scale_in`. Review the [AWS warm pool prerequisites and limitations](https://docs.aws.amazon.com/eks/latest/userguide/warm-pools-managed-node-groups.html) before enabling this feature.

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
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.59 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.59 |

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
