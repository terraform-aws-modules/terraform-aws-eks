# Cluster

When you create an EKS cluster with this module, the control plane and its supporting infrastructure are provisioned: an EKS cluster, a cluster IAM role, a CloudWatch log group for control plane logs, an OIDC provider for IRSA, and a shared node security group. This page covers the core cluster-level settings. Compute, networking, and add-on configuration are covered in their respective sections.

## Minimal configuration

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "my-cluster"
  kubernetes_version = "1.35"

  vpc_id     = "vpc-1234556abcdef"
  subnet_ids = [
    "subnet-abcde012",
    "subnet-bcde012a",
    "subnet-fghi345a",
  ]
}
```

This creates a cluster with sensible defaults: private API endpoint enabled, public endpoint disabled, control plane logging for audit, API, and authenticator events, a KMS key for secrets encryption, and an OIDC provider for IRSA.

## API server endpoints

The cluster API server can be reached publicly, privately, or both. The module defaults to private-only access:

| Setting | Default | Description |
|---|---|---|
| `endpoint_private_access` | `true` | API server reachable within the VPC |
| `endpoint_public_access` | `false` | API server reachable from the internet |
| `endpoint_public_access_cidrs` | `["0.0.0.0/0"]` | CIDRs allowed to reach the public endpoint |

The recommended configuration is both endpoints enabled. Nodes communicate over the private endpoint (keeping traffic in the VPC), while operators can reach the API server from outside the VPC via the public endpoint:

```hcl
endpoint_private_access = true
endpoint_public_access  = true

# Restrict public access to your IP or office CIDR
endpoint_public_access_cidrs = ["203.0.113.0/24"]
```

When restricting public access CIDRs, ensure the private endpoint is also enabled — otherwise nodes in private subnets cannot reach the API server. See [Network Connectivity](../networking/network-connectivity.md) for detailed guidance.

## Cluster creator admin permissions

`enable_cluster_creator_admin_permissions = true` adds the current IAM caller as a cluster administrator via an access entry. This is the simplest way to get kubectl access after cluster creation.

This is distinct from the EKS `bootstrap_cluster_creator_admin_permissions` API setting, which is a one-time operation at cluster creation that cannot be changed afterward. The module hardcodes the bootstrap setting to `false` and uses an access entry instead, giving you the ability to enable or disable admin access at any time without recreating the cluster.

```hcl
enable_cluster_creator_admin_permissions = true
```

See [Access Entries](access-entries.md) for configuring access for other IAM principals.

## Secrets encryption

The module creates a KMS key and enables envelope encryption for Kubernetes secrets by default (`create_kms_key = true`). To use an existing KMS key instead:

```hcl
create_kms_key = false

encryption_config = {
  provider_key_arn = "arn:aws:kms:us-west-2:111122223333:key/..."
  resources        = ["secrets"]
}
```

To disable encryption entirely, set `create_kms_key = false` and leave `encryption_config` empty.

## Choosing a compute approach

EKS offers two operating models for the cluster, and both are covered in sub-pages:

- [Auto Mode](auto-mode.md) — AWS manages compute, networking, storage, load balancing, DNS, and identity. You deploy applications; AWS handles the infrastructure. Best for teams that want minimal operational overhead.
- [Provisioned Control Plane](provisioned-control-plane.md) — you manage compute by provisioning [EKS Managed Node Groups](../compute/eks-managed-node-groups.md), [Self-Managed Node Groups](../compute/self-managed-node-groups.md), or [Karpenter](../compute/karpenter.md). This gives you full control over instance types, AMIs, and node configuration.
