# EKS Auto Mode

EKS Auto Mode is a cluster-wide operating mode where AWS manages compute, networking, storage, load balancing, DNS, and identity infrastructure. Unlike managed node groups (which only manage EC2 instances), Auto Mode operates the full cluster infrastructure — AWS provisions and scales EC2 instances, runs core Kubernetes components, and handles operational tasks like patching and upgrades. You focus on deploying applications. You can still add managed node groups or self-managed node groups alongside Auto Mode for workloads that need specific compute configurations.

## Default Node Pools

Use the `compute_config` block with `node_pools = ["general-purpose"]` to enable Auto Mode with the default node pool:

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "example"
  kubernetes_version = "1.35"

  compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

  vpc_id     = "vpc-1234556abcdef"
  subnet_ids = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

## Custom Node Pools Only

To create only the IAM resources required for EKS Auto Mode and manage node pools yourself, use `create_auto_mode_iam_resources = true` with `compute_config = { enabled = true }`:

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "example"
  kubernetes_version = "1.35"

  # Create IAM resources for Auto Mode (for use with custom node pools)
  create_auto_mode_iam_resources = true
  compute_config = {
    enabled = true
  }

  vpc_id     = "vpc-1234556abcdef"
  subnet_ids = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

## Common patterns

### Auto Mode built-in components

Auto Mode automatically provides and manages several capabilities that would otherwise need to be installed as separate add-ons:

- Compute autoscaling (Karpenter) — runs off-cluster, managed by AWS
- Pod networking (VPC CNI) — runs as a systemd process on nodes, not a pod
- Cluster DNS (CoreDNS) — runs as a systemd process on nodes, not a pod
- Block storage (EBS CSI driver) — runs off-cluster, managed by AWS
- Load balancing (AWS Load Balancer Controller) — runs off-cluster, managed by AWS
- Pod identity (EKS Pod Identity Agent) — built-in
- Network proxy (kube-proxy) — managed as a built-in component
- Node monitoring (EKS Node Monitoring Agent) — included in Auto Mode node AMIs

Do NOT install these as separate EKS add-ons when using Auto Mode — doing so can cause conflicts. All other add-ons (cert-manager, external-dns, Prometheus, ArgoCD, etc.) must still be installed and managed by you. See [Add-ons](addons.md) for details. See also the [EKS Auto Mode Best Practices](https://docs.aws.amazon.com/eks/latest/best-practices/automode.html).

### Combining Auto Mode with other compute

Auto Mode can be used alongside EKS managed node groups or self-managed node groups. This is useful when you have specific workloads that require custom AMIs, instance types, or configurations that Auto Mode's node pools do not support.

## Gotchas

### EBS CSI provisioner name differs

Auto Mode nodes register with `ebs.csi.eks.amazonaws.com`, while managed node groups use `ebs.csi.aws.com`. PVCs created with one provisioner cannot be mounted on nodes using the other. If running a mixed cluster (Auto Mode + managed node groups), be aware of this incompatibility.

### Nodes are immutable

Auto Mode nodes use a locked-down Bottlerocket AMI with a read-only root filesystem and SELinux in enforcing mode. You cannot SSH/SSM into nodes or install software directly. Use DaemonSets for host-level tooling.

### Node expiration

Auto Mode node pools have a default node expiration of 14 days — nodes are automatically replaced after this period. This is configurable via custom NodePools (you can raise or lower the value). There is a hard maximum lifetime of 21 days, after which nodes are forcibly replaced regardless of PodDisruptionBudgets or disruption controls. Design workloads to be stateless or use persistent volumes.

### Disabling Auto Mode

!!! warning

    To disable EKS Auto Mode you must explicitly set:

    ```hcl
    compute_config = {
      enabled = false
    }
    ```

    Simply removing the `compute_config` block will not disable Auto Mode. Apply with `enabled = false` first, then you can remove the block.

### "No changes needed for EKS Auto Mode configuration" error on module upgrade

If you upgrade the module version and have never used Auto Mode, you may see this error. This occurs because newer module versions send a `compute_config { enabled = false }` block to the API, and the API rejects setting a configuration to the state it is already in. To resolve this, add the explicit configuration to your code:

```hcl
compute_config = {
  enabled = false
}
```

Apply once, then you can remove the block if desired.

### Tags do not propagate to Auto Mode nodes

Module-level `tags` are not applied to EC2 instances provisioned by Auto Mode node pools. To tag Auto Mode nodes, configure tags in a custom `NodeClass` Kubernetes manifest. See the [Tagging FAQ](../faq.md#tagging) for details.

### IAM resources for custom node pools

When using custom node pools only (without specifying `node_pools` in `compute_config`), you must set `create_auto_mode_iam_resources = true` to ensure the required IAM resources are created. Without these IAM resources, custom node pools will not be able to join the cluster.

## Example

A complete working example is available at [`examples/eks-auto-mode/`](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/eks-auto-mode) on GitHub.
