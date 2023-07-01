# Outpost node group

## Autoscaling group types

This module will generate a self-managed node group, with custom configurations to run on an aws outpost.

## Auth

Nodes use the shared `aws_auth_role` for permission to connect to the cluster, which allows this module to be detached from the eks module. Seperate node group modules loosen up the terraform dependecies and allow for more customization and management outside of the eks module (even in seperate repos). If you wish to manage a node group outside of your eks pipeline, leave the cluster auth and endpoint variables blank and use the data resources in this module. 

## Security groups

By default a node gets the provided `base rules` + `additional rules` security groups. This is a good default configuration and matches what would be deployed using the cluster module.
For more customization you can provide a list of your own custom rules to make a custom security group. That will be added along with a bare minimum rule set (allowing node-to-node and node-to-cluster communication, and access from the fanduel vpn endpoints)
Unless otherwise specified, those rules will apply to any pod eni's on that node.

## Outpost-specific customizations

- The node group is defined with a single subnet to allow for flexibility and support deploying to specific parts of an outpost. This also allows deployment of outpost node groups on multiple outposts and az's.
- A placement group is created for each node group, you may configure the placement group spread settings.
- An outpost label is added to each node group to denote which outpost a node is running on, and differntiate it from cloud node groups attached to the same cluster. This can be used to keep certain applications confined to a specific outpost.
- Only encrypted gp2 volumes are created for the instances in the node group, this is required for instances on an Outpost.

You can create an example node group like this:

## Outpost self-managed-node-group

```hcl
module "outpost_self_managed_node_groups" {
  source                                    = "../../outpost-self-managed-node-group"
  cluster_name                              = module.eks.cluster_name
  outpost_name                              = var.outpost_name
  name                                      = var.outpost_groups[count.index].name
  aws_iam_instance_profile_arn              = aws_iam_instance_profile.default_node_instance_profile.arn
  security_group_rules                      = var.outpost_groups[count.index].security_group_rules
  node_subnet_id                            = var.outpost_groups[count.index].node_subnet_id
  placement_group_spread_level              = var.outpost_groups[count.index].placement_group_spread_level
  placement_group_strategy                  = var.outpost_groups[count.index].placement_group_strategy
  default_additional_node_security_group_id = aws_security_group.default_additional_node_security_group.id
  limited_additional_node_security_group_id = aws_security_group.limited_additional_node_security_group.id
  node_security_group_id                    = module.eks.node_security_group_id
  cluster_security_group_id                 = module.eks.cluster_security_group_id
  family                                    = var.outpost_groups[count.index].family
  min_group_size                            = var.outpost_groups[count.index].min_group_size
  max_group_size                            = var.outpost_groups[count.index].max_group_size
  extra_labels                              = var.outpost_groups[count.index].labels
  add_autoscaling_group_tags                = var.outpost_groups[count.index].add_autoscaling_group_tags
  taints                                    = var.outpost_groups[count.index].taints
  additional_tags                           = var.outpost_groups[count.index].additional_tags
  vpc_id                                    = local.vpc_id
  tags = local.tags
}
```

TF Vars [here](modules/outpost-self-managed-node-group/TFVARS.md)
