# Elastic Fabric Adapter (EFA)

[Elastic Fabric Adapter (EFA)](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/efa.html) is a network interface for Amazon EC2 instances that provides high-performance, low-latency inter-node communication. It is used for tightly coupled distributed workloads such as machine learning training and high-performance computing (HPC).

## Configuration

EFA must be enabled at two levels: the cluster level and the node group level.

- Enabling at the **cluster level** adds the required EFA ingress/egress rules to the shared node security group.
- Enabling at the **node group level** does the following per node group:
  1. All EFA interfaces supported by the instance are exposed on the launch template
  2. A placement group with `strategy = "clustered"` is created and passed to the launch template
  3. Availability zone filtering ensures only subnets that support the selected instance type are used, preventing placement group creation in unsupported AZs

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  # Truncated for brevity ...

  # Adds the EFA required security group rules to the shared
  # security group created for the node group(s)
  enable_efa_support = true

  eks_managed_node_groups = {
    example = {
      # The EKS AL2023 NVIDIA AMI provides all of the necessary components
      # for accelerated workloads w/ EFA
      ami_type       = "AL2023_x86_64_NVIDIA"
      instance_types = ["p5.48xlarge"]

      # Exposes all EFA interfaces on the launch template
      # p5.48xlarge exposes all 32 EFA interfaces
      enable_efa_support = true

      # Mount instance store volumes in RAID-0 for kubelet and containerd
      cloudinit_pre_nodeadm = [
        {
          content_type = "application/node.eks.aws"
          content      = <<-EOT
            ---
            apiVersion: node.eks.aws/v1alpha1
            kind: NodeConfig
            spec:
              instance:
                localStorage:
                  strategy: RAID0
          EOT
        }
      ]

      # EFA should only be enabled when connecting 2 or more nodes
      # Do not use EFA on a single node workload
      min_size     = 2
      max_size     = 10
      desired_size = 2
    }
  }
}
```

## How it works

EFA requires the custom launch template — do not set `create_launch_template = false` or `use_custom_launch_template = false`. You must also supply `instance_types` for managed node groups.

For managed node groups with multiple instance types, the first type in the list is used to calculate the number of supported EFA interfaces. Mixing instance types with differing interface counts is not recommended.

!!! tip

    Use the [aws-efa-k8s-device-plugin](https://github.com/aws/eks-charts/tree/master/stable/aws-efa-k8s-device-plugin) Helm chart to expose EFA interfaces as extended resources on nodes and allow pods to request them. The EKS AL2023 NVIDIA AMI comes with the necessary EFA components pre-installed.

