# EKS Managed Node Group Examples

Configuration in this directory creates an AWS EKS cluster with various EKS Managed Node Groups demonstrating the various configurations:

- `eks-al2.tf` demonstrates an EKS cluster using EKS managed node group that utilizes the EKS Amazon Linux 2 optimized AMI
- `eks-al2023.tf` demonstrates an EKS cluster using EKS managed node group that utilizes the EKS Amazon Linux 2023 optimized AMI
- `eks-bottlerocket.tf` demonstrates an EKS cluster using EKS managed node group that utilizes the Bottlerocket EKS optimized AMI

See the [AWS documentation](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html) for further details.
