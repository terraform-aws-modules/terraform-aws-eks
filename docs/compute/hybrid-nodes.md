# Hybrid Nodes

EKS Hybrid Nodes allow you to join on-premises or edge infrastructure to your EKS cluster. Nodes running outside AWS connect to the EKS control plane over a network link and run Kubernetes workloads alongside cloud-based nodes.

The [submodule source](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/modules/hybrid-node-role) is available on GitHub. See also [EKS Hybrid Deployment Best Practices](https://docs.aws.amazon.com/eks/latest/best-practices/hybrid.html).

## Authentication

Two authentication methods are supported for hybrid nodes connecting to the EKS control plane:

- SSM (default) — uses AWS Systems Manager to issue temporary credentials to on-premises nodes. No certificates to manage; nodes authenticate using their SSM activation.
- IAM Roles Anywhere — certificate-based authentication for environments where SSM is not available or preferred. Requires a certificate authority and trust anchor configuration.

Both methods are supported via the `hybrid-node-role` submodule, which creates the IAM role that hybrid nodes assume when joining the cluster.

## Configuration

```hcl
locals {
  # RFC 1918 IP ranges supported
  remote_network_cidr = "172.16.0.0/16"
  remote_node_cidr    = cidrsubnet(local.remote_network_cidr, 2, 0)
  remote_pod_cidr     = cidrsubnet(local.remote_network_cidr, 2, 1)
}

# SSM and IAM Roles Anywhere supported - SSM is default
module "eks_hybrid_node_role" {
  source  = "terraform-aws-modules/eks/aws//modules/hybrid-node-role"
  version = "~> 21.0"

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "example"
  kubernetes_version = "1.35"

  addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
  }

  create_node_security_group = false
  security_group_additional_rules = {
    hybrid-all = {
      cidr_blocks = [local.remote_network_cidr]
      description = "Allow all traffic from remote node/pod network"
      from_port   = 0
      to_port     = 0
      protocol    = "all"
      type        = "ingress"
    }
  }

  # Optional — enables Auto Mode with the "system" node pool, which runs
  # core cluster components (CoreDNS, kube-proxy) on AWS-managed nodes.
  # Remove this block if you want to run all workloads on hybrid nodes only.
  compute_config = {
    enabled    = true
    node_pools = ["system"]
  }

  access_entries = {
    hybrid-node-role = {
      principal_arn = module.eks_hybrid_node_role.arn
      type          = "HYBRID_LINUX"
    }
  }

  vpc_id     = "vpc-1234556abcdef"
  subnet_ids = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]

  remote_network_config = {
    remote_node_networks = {
      cidrs = [local.remote_node_cidr]
    }
    # Required if running webhooks on Hybrid nodes
    remote_pod_networks = {
      cidrs = [local.remote_pod_cidr]
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

## Key configuration points

- `create_node_security_group = false` — the default node security group is not suitable for hybrid traffic; custom rules must be added to the cluster security group instead
- `security_group_additional_rules` — opens ingress from the remote network CIDR to allow hybrid node and pod traffic to reach the cluster
- `access_entries` with `type = "HYBRID_LINUX"` — registers the hybrid node IAM role so that nodes using that role are authorized to join the cluster
- `remote_network_config` — defines the RFC 1918 CIDR ranges for the remote node network and pod network; EKS uses these to route traffic correctly between cloud and hybrid nodes
- `remote_pod_networks` — required when running admission webhooks on hybrid nodes so that the API server can reach webhook pods running on-premises

## Example

See [`examples/eks-hybrid-nodes/`](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/eks-hybrid-nodes) on GitHub for a complete working configuration.
