# Provisioned Control Plane

EKS Provisioned Control Plane allows you to provision a control plane with increased capacity for larger workloads — use it when hitting API server rate limits or running clusters with large node counts that generate high volumes of API requests. Use the `control_plane_scaling_config` variable with the `tier` setting to select the control plane size (`standard` is the default and suitable for most workloads).

!!! info

    Provisioned control plane tiers above `standard` incur additional cost. See the [EKS pricing page](https://aws.amazon.com/eks/pricing/) for details.

Valid tier values:

- `standard` (default) — suitable for most workloads
- `tier-xl` — for clusters approaching API server rate limits or running 100+ nodes
- `tier-2xl` — for large clusters with high API request volumes
- `tier-4xl` — for very large clusters or high-throughput automation
- `tier-8xl` — maximum capacity for the largest clusters

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "my-cluster"
  kubernetes_version = "1.35"

  # EKS Provisioned Control Plane configuration
  control_plane_scaling_config = {
    tier = "tier-xl"
  }

  vpc_id     = "vpc-1234556abcdef"
  subnet_ids = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

## Example

The [Karpenter example](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/karpenter) on GitHub demonstrates provisioned control plane configuration alongside Karpenter.
