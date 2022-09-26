# Network Connectivity

## Cluster Endpoint

### Public Endpoint w/ Restricted CIDRs

When restricting the clusters public endpoint to only the CIDRs specified by users, it is recommended that you also enable the private endpoint, or ensure that the CIDR blocks that you specify include the addresses that nodes and Fargate pods (if you use them) access the public endpoint from.

Please refer to the [AWS documentation](https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html) for further information

## Security Groups

- Cluster Security Group
  - This module by default creates a cluster security group ("additional" security group when viewed from the console) in addition to the default security group created by the AWS EKS service. This "additional" security group allows users to customize inbound and outbound rules via the module as they see fit
    - The default inbound/outbound rules provided by the module are derived from the [AWS minimum recommendations](https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html) in addition to NTP and HTTPS public internet egress rules (without, these show up in VPC flow logs as rejects - they are used for clock sync and downloading necessary packages/updates)
    - The minimum inbound/outbound rules are provided for cluster and node creation to succeed without errors, but users will most likely need to add the necessary port and protocol for node-to-node communication (this is user specific based on how nodes are configured to communicate across the cluster)
    - Users have the ability to opt out of the security group creation and instead provide their own externally created security group if so desired
    - The security group that is created is designed to handle the bare minimum communication necessary between the control plane and the nodes, as well as any external egress to allow the cluster to successfully launch without error
  - Users also have the option to supply additional, externally created security groups to the cluster as well via the `cluster_additional_security_group_ids` variable
  - Lastly, users are able to opt in to attaching the primary security group automatically created by the EKS service by setting `attach_cluster_primary_security_group` = `true` from the root module for the respective node group (or set it within the node group defaults). This security group is not managed by the module; it is created by the EKS service. It permits all traffic within the domain of the security group as well as all egress traffic to the internet.

- Node Group Security Group(s)
  - Users have the option to assign their own externally created security group(s) to the node group via the `vpc_security_group_ids` variable

See the example snippet below which adds additional security group rules to the cluster security group as well as the shared node security group (for node-to-node access). Users can use this extensibility to open up network access as they see fit using the security groups provided by the module:

```hcl
  ...
  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
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
  ...
```
The security groups created by this module are depicted in the image shown below along with their default inbound/outbound rules:

<p align="center">
  <img src="https://raw.githubusercontent.com/terraform-aws-modules/terraform-aws-eks/master/.github/images/security_groups.svg" alt="Security Groups" width="100%">
</p>
