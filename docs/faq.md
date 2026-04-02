# Frequently Asked Questions

## Compute

### Setting `disk_size` or `remote_access` does not make any changes

`disk_size` and `remote_access` can only be set when using the EKS managed node group default launch template. This module defaults to a custom launch template to allow for custom security groups, tag propagation, and more. Set `use_custom_launch_template = false` to use the default launch template and enable these options. See [EKS Managed Node Groups](compute/eks-managed-node-groups.md).

### Why are there no changes when a node group's `desired_size` is modified?

The module ignores `desired_size` after initial creation to allow autoscalers (cluster autoscaler, Karpenter) to manage node counts without Terraform interference. Use a workaround such as [this one](https://github.com/bryantbiggs/eks-desired-size-hack) to update the value outside of Terraform. See [EKS Managed Node Groups](compute/eks-managed-node-groups.md).

### How do I access compute resource attributes?

Examples of accessing the attributes of the compute resource(s) created by the root module are shown below. These assume your module call is named `eks` as in `module "eks" { ... }`:

- EKS Managed Node Group attributes

```hcl
eks_managed_role_arns = [
  for group in module.eks.eks_managed_node_groups :
  group.iam_role_arn
]
```

- Self-Managed Node Group attributes

```hcl
self_managed_role_arns = [
  for group in module.eks.self_managed_node_groups :
  group.iam_role_arn
]
```

- Fargate Profile attributes

```hcl
fargate_profile_pod_execution_role_arns = [
  for profile in module.eks.fargate_profiles :
  profile.fargate_profile_pod_execution_role_arn
]
```

## Networking

### I received an error: `expect exactly one securityGroup tagged with kubernetes.io/cluster/<CLUSTER_NAME> ...`

> **Warning:** `<CLUSTER_NAME>` would be the name of your cluster

This error occurs when nodes have multiple security groups with the `kubernetes.io/cluster/<CLUSTER_NAME>=owned` tag attached simultaneously. EKS creates a cluster primary security group with this tag; the module creates a shared node security group with the same tag. Attaching both to nodes via `attach_cluster_primary_security_group = true` triggers the conflict.

Resolve it one of two ways:

1. Use the cluster primary security group and disable the module's shared node security group:

```hcl
  create_node_security_group = false # default is true

  eks_managed_node_group = {
    example = {
      attach_cluster_primary_security_group = true # default is false
    }
  }
  # Or for self-managed
  self_managed_node_group = {
    example = {
      attach_cluster_primary_security_group = true # default is false
    }
  }
```

2. Don't attach the cluster primary security group (the default). The module's shared node security group provides the minimum required access for node communication.

If you use [Custom Networking](https://docs.aws.amazon.com/eks/latest/userguide/cni-custom-network.html), attach only the security groups matching your choice above in your ENIConfig resources. See [Security Groups](networking/security-groups.md).

### Why are nodes not being registered?

Node registration failures are almost always networking misconfigurations. See [Network Connectivity](networking/network-connectivity.md) for full details. Key checks:

1. At least one cluster endpoint (public or private) must be enabled. If using a public endpoint, restrict access via `cluster_endpoint_public_access_cidrs` and ensure nodes can reach it.

2. Nodes need outbound internet access to reach the EKS endpoint — via NAT gateway for private subnets, or public IPs for public subnets.

3. The private endpoint can be enabled with `cluster_endpoint_private_access = true`. Ensure VPC DNS resolution and hostnames are enabled.

4. If nodes cannot reach the public internet, add VPC endpoints for EC2, ECR API, ECR DKR, and S3.

## Add-ons

### What add-ons are available?

The available add-ons are listed in the [AWS EKS documentation](https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html). You can also query them directly:

```sh
aws eks describe-addon-versions --query 'addons[*].addonName'
```

See [Cluster Add-ons](cluster/addons.md).

### What configuration values are available for an add-on?

Configuration values vary between add-on versions. Retrieve the schema for a specific version with:

```sh
aws eks describe-addon-configuration \
  --addon-name <value> \
  --addon-version <value> \
  --query 'configurationSchema' \
  --output text | jq
```

For example:

```sh
aws eks describe-addon-configuration \
  --addon-name coredns \
  --addon-version v1.11.1-eksbuild.8 \
  --query 'configurationSchema' \
  --output text | jq
```

See [Cluster Add-ons](cluster/addons.md).

## Tagging

### Why aren't my tags appearing on all resources?

The `tags` variable propagates to resources the module creates directly (EKS cluster, IAM roles, security groups, CloudWatch log group). It does NOT automatically propagate to:

- EKS managed node group EC2 instances: Tags are propagated via the launch template, but the ASG itself may not inherit all tags. Use `tag_propagation_policy = "ALWAYS"` on the node group to ensure tags propagate to the Auto Scaling Group and its instances.
- Auto Mode provisioned nodes: Module-level `tags` do not flow to EC2 instances launched by Auto Mode node pools. Configure tags in your custom `NodeClass` Kubernetes manifest instead.
- ENIs created by the VPC CNI: Network interfaces created by the VPC CNI at runtime are not tagged by the module.

If you need tags on all resources for cost allocation or compliance, configure tagging at each layer.
