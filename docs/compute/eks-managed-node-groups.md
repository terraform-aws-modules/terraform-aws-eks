# EKS Managed Node Groups

EKS managed node groups automate the provisioning and lifecycle management of EC2 instances for your cluster. AWS handles node updates, draining, and replacement — you define the desired state and EKS operates the nodes. See the [AWS documentation](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html) for service-level details.

The [submodule source](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/modules/eks-managed-node-group) is available on GitHub. See also [EKS Reliability Best Practices](https://docs.aws.amazon.com/eks/latest/best-practices/reliability.html).

## Basic usage

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
    kube-proxy             = {}
    vpc-cni                = {
      before_compute = true
    }
  }

  vpc_id                   = "vpc-1234556abcdef"
  subnet_ids = [
    "subnet-abcde012",
    "subnet-bcde012a",
    "subnet-fghi345a",
  ]
  control_plane_subnet_ids = [
    "subnet-xyzde987",
    "subnet-slkjf456",
    "subnet-qeiru789",
  ]

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    example = {
      # AL2023 is the default AMI type for EKS managed node groups (1.30+)
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["m5.xlarge"]

      min_size     = 2
      max_size     = 10
      desired_size = 2
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

## Launch templates

The module creates a custom launch template by default to ensure settings such as tags are propagated to instances. Many customization options are only available when a custom launch template is used.

To use the default launch template provided by the EKS managed node group service instead, set `use_custom_launch_template = false`:

```hcl
eks_managed_node_groups = {
  default = {
    use_custom_launch_template = false
  }
}
```

## AMI types

### AL2023

Amazon Linux 2023 (AL2023) is the default AMI type for EKS managed node groups starting with Kubernetes 1.30. It uses `nodeadm` for bootstrapping and supports cloud-init multi-part documents for user data customization.

### Bottlerocket

Bottlerocket is a Linux-based OS optimized for running containers. It uses a TOML-based configuration format for user data.

Basic Bottlerocket node group (using EKS default launch template):

```hcl
eks_managed_node_groups = {
  bottlerocket_default = {
    use_custom_launch_template = false

    ami_type = "BOTTLEROCKET_x86_64"
  }
}
```

Bottlerocket with custom user data (TOML format):

```hcl
eks_managed_node_groups = {
  bottlerocket_prepend_userdata = {
    ami_type = "BOTTLEROCKET_x86_64"

    bootstrap_extra_args = <<-EOT
      # extra args added
      [settings.kernel]
      lockdown = "integrity"
    EOT
  }
}
```

## Custom AMIs

When using a custom AMI with `ami_id`, you must also set `ami_type` and `enable_bootstrap_user_data = true`. See [User Data & Bootstrapping](../advanced/user-data.md#custom-amis) for configuration details and examples.

## EFA support

For EFA (Elastic Fabric Adapter) support for HPC and ML workloads, see [Elastic Fabric Adapter](../networking/efa.md).

## Common gotchas

`disk_size` and `remote_access` only work without the custom launch template. These attributes are only valid when using the EKS default launch template. Because this module defaults to a custom launch template for tag propagation and security group support, `disk_size` and `remote_access` have no effect unless you set `use_custom_launch_template = false`.

Changes to `desired_size` are ignored after initial creation. The module uses `ignore_changes` on `desired_size` to prevent Terraform from conflicting with cluster autoscaler or Karpenter, which manage node counts independently. Once the node group is created, desired count changes must be made outside of Terraform. See [this workaround](https://github.com/bryantbiggs/eks-desired-size-hack) for an approach to forcing a one-time change via Terraform.

## Example

See [`examples/eks-managed-node-group/`](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/eks-managed-node-group) on GitHub for working configurations including AL2023, Bottlerocket, custom AMIs, and EFA.
