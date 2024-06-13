# Self-managed Node Group Examples

Configuration in this directory creates Amazon EKS clusters with self-managed node groups demonstrating different configurations:

- `eks-al2.tf` demonstrates an EKS cluster using self-managed node group that utilizes the EKS Amazon Linux 2 optimized AMI
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
