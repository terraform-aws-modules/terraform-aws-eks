# Karpenter

[Karpenter](https://karpenter.sh/) is a Kubernetes node autoscaler that provisions right-sized compute resources in response to pending pods. It selects instance types at scheduling time, supports Spot and On-Demand interchangeably, and consolidates underutilized nodes automatically.

!!! info

    If you are using [EKS Auto Mode](../cluster/auto-mode.md), Karpenter is included as a built-in component managed by AWS. You do not need to install or configure it separately. This page covers standalone Karpenter for provisioned (non-Auto Mode) clusters.

The module provides a Karpenter submodule that creates the required AWS infrastructure: IAM roles, an SQS queue for interruption handling, and EventBridge rules for node lifecycle events. The [submodule source](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/modules/karpenter) is available on GitHub.

## What the submodule creates

- IAM role for the Karpenter controller (with Pod Identity association)
- Node IAM role for EC2 instances launched by Karpenter
- SQS queue for spot interruption and rebalance event handling
- EventBridge rules for spot interruption notices, capacity rebalance recommendations, instance state changes, and EC2 health events

## Basic usage

### All resources (default)

The default configuration creates its own Node IAM role, an access entry for that role, a Pod Identity association for the controller, and SQS/EventBridge resources:

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  ...
}

module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 21.0"

  cluster_name = module.eks.cluster_name

  # Attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

### Re-using existing Node IAM Role

If you already have an EKS managed node group, Karpenter can reuse its Node IAM role. In this case, an access entry already exists for that role, so both `create_node_iam_role` and `create_access_entry` should be disabled:

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  # Shown just for connection between cluster and Karpenter sub-module below
  eks_managed_node_groups = {
    initial = {
      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 3
      desired_size = 1
    }
  }
  ...
}

module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 21.0"

  cluster_name = module.eks.cluster_name

  create_node_iam_role = false
  node_iam_role_arn = module.eks.eks_managed_node_groups["initial"].iam_role_arn

  # Since the node group role will already have an access entry
  create_access_entry = false

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

## Tear down

Because Karpenter manages node resources outside of Terraform, clean up in two steps to avoid orphaned EC2 instances:

1. Remove Karpenter-managed Kubernetes resources first (NodePool, NodeClass, workload deployments). This lets Karpenter drain and terminate nodes it provisioned:
   ```bash
   kubectl delete deployment inflate
   ```

2. Once Karpenter-provisioned nodes are gone, destroy the remaining Terraform resources:
   ```bash
   terraform destroy
   ```

Skipping step 1 and running `terraform destroy` directly will leave EC2 instances running that Terraform has no record of.

## Example

See [`examples/karpenter/`](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/karpenter) on GitHub for a complete working example including Helm-based Karpenter deployment and sample NodeClass/NodePool manifests.
