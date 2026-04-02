# Self-Managed Node Groups

Self-managed node groups give you full control over the EC2 Auto Scaling Group that backs your Kubernetes nodes. You manage the node lifecycle, AMI updates, and scaling configuration directly. See the [AWS documentation](https://docs.aws.amazon.com/eks/latest/userguide/worker.html) for service-level details.

The [submodule source](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/modules/self-managed-node-group) is available on GitHub.

## When to use self-managed node groups

Use self-managed node groups when you need capabilities not available in EKS managed node groups:

- Custom ASG lifecycle hooks (e.g., draining nodes before termination via Lambda)
- Instance store volume configurations that require specific block device mappings
- Mixed instance policies with custom weighting or allocation strategies
- Full control over the rolling update strategy (instance refresh parameters, warm pools)
- Launch template configurations that EKS managed node groups do not support

For most workloads, [EKS Managed Node Groups](eks-managed-node-groups.md) are the simpler choice — AWS handles node updates, draining, and replacement. Choose self-managed only when you need the additional control.

## Basic usage

The submodule uses the latest AWS EKS Optimized AMI (AL2023) for the configured Kubernetes version by default:

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "my-cluster"
  kubernetes_version = "1.35"

  addons = {
    coredns                = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni    = {
      before_compute = true
    }
  }

  vpc_id     = "vpc-1234556abcdef"
  subnet_ids = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]

  # Uses the latest AWS EKS Optimized AMI for Kubernetes 1.35
  self_managed_node_groups = {
    default = {}
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

## Bottlerocket

To use Bottlerocket, specify the `ami_type` as one of the `BOTTLEROCKET_*` types and supply a Bottlerocket OS AMI ID. The AMI ID must match the target Kubernetes version and architecture:

```hcl
self_managed_node_groups = {
  bottlerocket = {
    ami_id   = data.aws_ami.bottlerocket_ami.id
    ami_type = "BOTTLEROCKET_x86_64"
  }
}
```

## Custom AMIs

When using a custom AMI, you must provide the bootstrap user data. See [User Data & Bootstrapping](../advanced/user-data.md#self-managed-node-groups-with-custom-amis) for configuration details.

## Common gotchas

- AMI updates are manual — unlike EKS managed node groups, the service does not update your nodes when a new AMI is released. You must update the AMI ID (or let the module resolve a new `latest` AMI) and trigger a rolling replacement yourself, typically via ASG instance refresh.

- Rolling updates require planning — the module does not automatically drain nodes during updates. Configure ASG instance refresh or use a lifecycle hook with a Lambda function to cordon and drain nodes before termination. Without this, pods may be abruptly terminated during updates.

- Access entries are created automatically — the module creates an access entry for the self-managed node group IAM role so that nodes can join the cluster. If you manage access entries separately, set `create_access_entry = false` on the node group to avoid conflicts.

## Example

See [`examples/self-managed-node-group/`](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/self-managed-node-group) on GitHub for working configurations including AL2023, Bottlerocket, and various customization options.
