# Examples

These examples demonstrate different configurations of the terraform-aws-eks module.

!!! note

    Examples demonstrate module features, not production best practices. Consult the [AWS EKS documentation](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html) for production guidance.

| Example | Description |
|---------|-------------|
| [EKS Auto Mode](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/eks-auto-mode) | EKS cluster with Auto Mode for AWS-managed compute |
| [EKS Managed Node Group](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/eks-managed-node-group) | EKS cluster with managed node groups (AL2023 and Bottlerocket) |
| [Self-Managed Node Group](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/self-managed-node-group) | EKS cluster with self-managed node groups (AL2023 and Bottlerocket) |
| [Karpenter](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/karpenter) | EKS cluster with Karpenter for intelligent autoscaling |
| [EKS Hybrid Nodes](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/eks-hybrid-nodes) | EKS cluster with hybrid on-premises nodes |
| [EKS Capabilities](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/eks-capabilities) | EKS cluster with ACK, ArgoCD, and KRO capabilities |

Fargate profiles are configured as part of the root module (see [Fargate](compute/fargate.md)) and do not have a standalone example. Fargate selectors can be added to any of the above examples.
