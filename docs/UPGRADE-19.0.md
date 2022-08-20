# Upgrade from v18.x to v19.x

Please consult the `examples` directory for reference example configurations. If you find a bug, please open an issue with supporting configuration to reproduce.

## List of backwards incompatible changes

- Minimum supported version of Terraform AWS provider updated to v4.7 to support latest features in autoscaling groups
- Individual security group created per EKS managed node group or self managed node group has been removed. This feature was largely un-used, often caused confusion, and can readily be replaced by a user provided security group that was externally created

## Additional changes

### Added

-

### Modified

- `block_device_mappings` previously required a map of maps but has since changed to an array of maps. Users can remove the outer key for each block device mapping and replace the outermost map `{}` with an array `[]`. There are not state changes required for this change

### Removed

-

### Variable and output changes

1. Removed variables:

    - Self managed node groups:
      - `create_security_group`
      - `security_group_name`
      - `security_group_use_name_prefix`
      - `security_group_description`
      - `security_group_rules`
      - `security_group_tags`
      - `cluster_security_group_id`
      - `vpc_id`
    - EKS managed node groups:
      - `create_security_group`
      - `security_group_name`
      - `security_group_use_name_prefix`
      - `security_group_description`
      - `security_group_rules`
      - `security_group_tags`
      - `cluster_security_group_id`
      - `vpc_id`

2. Renamed variables:

    -

3. Added variables:

    - Self managed node groups:
      -
    - EKS managed node groups:
      -

4. Removed outputs:

    - Self managed node groups:
      - `security_group_arn`
      - `security_group_id`
    - EKS managed node groups:
      - `security_group_arn`
      - `security_group_id`

5. Renamed outputs:

    -

6. Added outputs:

    -

## Upgrade Migrations

### Self Managed Node Groups

#### 1. [v18.x] Remove Security Group Created by Node Group

Self managed node groups on `v18.x` by default create a security group that does not specify any rules. In `v19.x`, this security group has been removed due to the predominant lack of usage (most users rely on the cluster security group and/or the shared node security group). While still on the `v18.x` of your module definition, remove this security group from your node groups.

- If you are currently utilizing this security group, it is recommended to create an additional security group that matches the rules/settings of the security group created by the node group, and specify that security group ID in `vpc_security_group_ids`. Once this is in place, you can proceed with the original security group removal.
- For most users, the security group is not used and can be safely removed. However, deployed instances will have the security group attached and require removal of the security group. Because instances are deployed via autoscaling groups, we cannot simply remove the security group from code and have those changes reflected on the instances. Instead, we have to update the code and then force the autoscaling groups to refresh so that new instances are provisioned without the security group attached. You can utilize the `instance_refresh` parameter to force nodes to re-deploy when removing the security group since changes to launch templates automatically trigger an instance refresh. An example configuration is provided below.
  - Add the following to either/or `self_managed_node_group_defaults`/`eks_managed_node_group_defaults`:
    ```hcl
    create_security_group = false
    instance_refresh = {
      strategy = "Rolling"
      preferences = {
        min_healthy_percentage = 100
      }
    }
    ```
  - It is recommended to use the `aws-node-termination-handler` while performing this update. Please refer to the [`irsa-autoscale-refresh` example](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/20af82846b4a1f23f3787a8c455f39c0b6164d80/examples/irsa_autoscale_refresh/charts.tf#L86) for usage. This will ensure that pods are safely evicted in a controlled manner to avoid service disruptions.
  - The alternative is to manually detach the security groups from instances so that they can be deleted. Note: security groups cannot be deleted if they are still attached to an ENI.

#### EKS Managed Node Groups

EKS managed node groups on `v18.x` by default create a security group that does not specify any rules. In `v19.x`, this security group has been removed due to the predominant lack of usage (most users rely on the cluster security group and/or the shared node security group). However, unlike self managed node groups, EKS managed node groups by default rollout changes using a [rolling update strategy](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-update-behavior.html) that can be influenced through `update_config`. No additional changes are required for removing the the security group created by node groups.
