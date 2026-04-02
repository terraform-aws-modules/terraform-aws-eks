# Security Groups

The module manages security groups for cluster and node communication. Understanding how these interact is important for cluster networking. Refer to [EKS security group requirements](https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html).

## Cluster security group

By default, the module creates an "additional" cluster security group (visible as an additional security group in the AWS console, separate from the primary security group created by the EKS service). This security group is created with the minimum required inbound and outbound rules derived from [AWS recommendations](https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html), and also includes NTP and HTTPS public internet egress rules (without these, rejected traffic shows up in VPC flow logs — they are used for clock sync and downloading necessary packages and updates).

The default rules provide the minimum required access for cluster and node creation to succeed. Users will likely need to add additional rules for node-to-node communication based on their workload requirements.

Users can customize the rules on this security group using the `security_group_additional_rules` variable. To opt out of the module-managed cluster security group entirely, set `create_cluster_security_group = false` and provide your own security group.

Users can also attach additional externally-created security groups to the cluster via the `cluster_additional_security_group_ids` variable.

## Node security group

The module creates a shared node security group that is attached to all nodes in the cluster, enabling node-to-node communication. Customize its rules using the `node_security_group_additional_rules` variable.

The following example extends both the cluster security group and the shared node security group to open additional access:

```hcl
# Extend cluster security group rules
security_group_additional_rules = {
  egress_nodes_ephemeral_ports_tcp = {
    description                = "To node 1025-65535"
    protocol                   = "tcp"
    from_port                  = 1025
    to_port                    = 65535
    type                       = "egress"
    source_node_security_group = true
  }
}

# Extend node-to-node security group rules
node_security_group_additional_rules = {
  ingress_self_all = {
    description = "Node to node all ports/protocols"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    type        = "ingress"
    self        = true
  }
  egress_all = {
    description      = "Node all egress"
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    type             = "egress"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
```

## Primary security group

EKS automatically creates a primary (default) cluster security group outside of the module and tags it with `{ "kubernetes.io/cluster/<CLUSTER_NAME>" = "owned" }`. This security group permits all traffic within the security group and all egress to the internet.

Users can opt in to attaching this primary security group to nodes by setting `attach_cluster_primary_security_group = true` on the node group.

When both the primary security group and the module's node security group are attached to nodes in the same cluster, the `kubernetes.io/cluster/<NAME>` tag appears on multiple security groups attached to the same nodes. This causes errors with add-ons such as the AWS Load Balancer Controller.

There are two ways to resolve this:

1. Use only the cluster primary security group — Disable the module's node security group and attach the primary security group:

```hcl
create_node_security_group = false # default is true

eks_managed_node_group = {
  example = {
    attach_cluster_primary_security_group = true # default is false
  }
}
```

2. Do not attach the primary security group (default behavior) — The module's node security group provides the minimum required access. Users are encouraged to open up additional access as needed to support their workloads rather than relying on the broad access granted by the primary security group.

If you choose to use [Custom Networking](https://docs.aws.amazon.com/eks/latest/userguide/cni-custom-network.html), ensure that your ENIConfig resources only reference the security groups matching your choice above. This will avoid redundant tags across security groups.

## External security groups

Users can attach their own externally-created security groups to individual node groups using the `vpc_security_group_ids` variable on the node group definition. This is in addition to the security groups managed by the module.

## Common gotchas

The shared node security group does not include a self-referencing rule for node-to-node communication. Add the `ingress_self_all` rule shown in the [Node security group](#node-security-group) example above. This is the most common cause of pod-to-pod connectivity failures across nodes.

The module's shared node security group provides only the minimum rules required for control plane to node communication — it does NOT include a self-referencing rule allowing all traffic between nodes. Many workloads require this — including the AWS Load Balancer Controller, service meshes (Istio, Linkerd), and any pod-to-pod communication on non-standard ports.

See [EKS Security Best Practices](https://docs.aws.amazon.com/eks/latest/best-practices/security.html) for further guidance.
