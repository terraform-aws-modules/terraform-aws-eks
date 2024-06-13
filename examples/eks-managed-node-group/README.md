# EKS Managed Node Group Examples

Configuration in this directory creates Amazon EKS clusters with EKS Managed Node Groups demonstrating different configurations:

- `eks-al2.tf` demonstrates an EKS cluster using EKS managed node group that utilizes the EKS Amazon Linux 2 optimized AMI
- `eks-al2023.tf` demonstrates an EKS cluster using EKS managed node group that utilizes the EKS Amazon Linux 2023 optimized AMI
- `eks-bottlerocket.tf` demonstrates an EKS cluster using EKS managed node group that utilizes the Bottlerocket EKS optimized AMI

See the [AWS documentation](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html) for additional details on Amazon EKS managed node groups.

The different cluster configuration examples provided are separated per file and independent of the other cluster configurations.

## Usage

To provision the provided configurations you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply --auto-approve
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.
