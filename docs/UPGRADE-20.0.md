# Upgrade from v19.x to v20.x

Please consult the `examples` directory for reference example configurations. If you find a bug, please open an issue with supporting configuration to reproduce.

## List of backwards incompatible changes

- Minium supported AWS provider version increased to `v5.34`
- Minimum supported Terraform version increased to `v1.3` to support Terraform state `moved` blocks as well as other advanced features
- The `resolve_conflicts` argument within the `cluster_addons` configuration has been replaced with `resolve_conflicts_on_create` and `resolve_conflicts_on_update` now that `resolve_conflicts` is deprecated
- The default/fallback value for the `preserve` argument of `cluster_addons`is now set to `true`. This has shown to be useful for users deprovisioning clusters while avoiding the situation where the CNI is deleted too early and causes resources to be left orphaned resulting in conflicts.
- The Karpenter sub-module's use of the `irsa` naming convention has been removed, along with an update to the Karpenter controller IAM policy to align with Karpenter's `v1beta1`/`v0.32` changes. Instead of referring to the role as `irsa` or `pod_identity`, its simply just an IAM role used by the Karpenter controller and there is support for use with either IRSA and/or Pod Identity (default) at this time
- The `aws-auth` ConfigMap resources have been moved to a standalone sub-module. This removes the Kubernetes provider requirement from the main module and allows for the `aws-auth` ConfigMap to be managed independently of the main module. This sub-module will be removed entirely in the next major release.
- Support for cluster access management has been added with the default authentication mode set as `API_AND_CONFIG_MAP`. This is a one way change if applied; if you wish to use `CONFIG_MAP`, you will need to set `authentication_mode = "CONFIG_MAP"` explicitly when upgrading.
- Karpenter EventBridge rule key `spot_interrupt` updated to correct mis-spelling (was `spot_interupt`). This will cause the rule to be replaced

### ⚠️ Upcoming Changes Planned in v21.0 ⚠️

To give users advanced notice and provide some future direction for this module, these are the following changes we will be looking to make in the next major release of this module:

1. The `aws-auth` sub-module will be removed entirely from the project. Since this sub-module is captured in the v20.x releases, users can continue using it even after the module moves forward with the next major version. The long term strategy and direction is cluster access entry and to rely only on the AWS Terraform provider.
2. The default value for `authentication_mode` will change to `API`. Aligning with point 1 above, this is a one way change, but users are free to specify the value of their choosing in place of this default (when the change is made). This module will proceed with an EKS API first strategy.
3. The launch template and autoscaling group usage contained within the EKS managed node group and self-managed node group sub-modules *might be replaced with the [`terraform-aws-autoscaling`](https://github.com/terraform-aws-modules/terraform-aws-autoscaling) module. At minimum, it makes sense to replace most of functionality in the self-managed node group module with this external module, but its not yet clear if there is any benefit of using it in the EKS managed node group sub-module. The interface that users interact with will stay the same, the changes will be internal to the implementation and we will do everything we can to keep the disruption to a minimum.
4. The `platform` variable will be replaced and instead `ami_type` will become the standard across both self-managed node group(s) and EKS managed node group(s). As EKS expands its portfolio of supported operating systems, the `ami_type` is better suited to associate the correct user data format to the respective OS. The `platform` variable is a legacy artifact of self-managed node groups but not as descriptive as the `ami_type`, and therefore it will be removed in favor of `ami_type`.

## Additional changes

### Added

   - A module tag has been added to the cluster control plane
   - Support for cluster access entries. The `bootstrap_cluster_creator_admin_permissions` setting on the control plane has been hardcoded to `false` since this operation is a one time operation only at cluster creation per the EKS API. Instead, users can enable/disable `enable_cluster_creator_admin_permissions` at any time to achieve the same functionality. This takes the identity that Terraform is using to make API calls and maps it into a cluster admin via an access entry. For users on existing clusters, you will need to remove the default cluster administrator that was created by EKS prior to the cluster access entry APIs - see the section [`Removing the default cluster administrator`](https://aws.amazon.com/blogs/containers/a-deep-dive-into-simplified-amazon-eks-access-management-controls/) for more details.
   - Support for specifying the CloudWatch log group class (standard or infrequent access)
   - Native support for Windows based managed node groups similar to AL2 and Bottlerocket
   - Self-managed node groups now support `instance_maintenance_policy` and have added `max_healthy_percentage`, `scale_in_protected_instances`, and `standby_instances` arguments to the `instance_refresh.preferences` block

### Modified

   - For `sts:AssumeRole` permissions by services, the use of dynamically looking up the DNS suffix has been replaced with the static value of `amazonaws.com`. This does not appear to change by partition and instead requires users to set this manually for non-commercial regions.
   - The default value for `kms_key_enable_default_policy` has changed from `false` to `true` to align with the default behavior of the `aws_kms_key` resource
   - The Karpenter default value for `create_instance_profile` has changed from `true` to `false` to align with the changes in Karpenter v0.32
   - The Karpenter variable `create_instance_profile` default value has changed from `true` to `false`. Starting with Karpenter `v0.32.0`, Karpenter accepts an IAM role and creates the EC2 instance profile used by the nodes

### Removed

   - The `complete` example has been removed due to its redundancy with the other examples
   - References to the IRSA sub-module in the IAM repository have been removed. Once https://github.com/clowdhaus/terraform-aws-eks-pod-identity has been updated and moved into the organization, the documentation here will be updated to mention the new module.

### Variable and output changes

1. Removed variables:

   - `cluster_iam_role_dns_suffix` - replaced with a static string of `amazonaws.com`
   - `manage_aws_auth_configmap`
   - `create_aws_auth_configmap`
   - `aws_auth_node_iam_role_arns_non_windows`
   - `aws_auth_node_iam_role_arns_windows`
   - `aws_auth_fargate_profile_pod_execution_role_arn`
   - `aws_auth_roles`
   - `aws_auth_users`
   - `aws_auth_accounts`

   - Karpenter
      - `irsa_tag_key`
      - `irsa_tag_values`
      - `irsa_subnet_account_id`
      - `enable_karpenter_instance_profile_creation`

2. Renamed variables:

   - Karpenter
      - `create_irsa` -> `create_iam_role`
      - `irsa_name` -> `iam_role_name`
      - `irsa_use_name_prefix` -> `iam_role_name_prefix`
      - `irsa_path` -> `iam_role_path`
      - `irsa_description` -> `iam_role_description`
      - `irsa_max_session_duration` -> `iam_role_max_session_duration`
      - `irsa_permissions_boundary_arn` -> `iam_role_permissions_boundary_arn`
      - `irsa_tags` -> `iam_role_tags`
      - `policies` -> `iam_role_policies`
      - `irsa_policy_name` -> `iam_policy_name`
      - `irsa_ssm_parameter_arns` -> `ami_id_ssm_parameter_arns`
      - `create_iam_role` -> `create_node_iam_role`
      - `iam_role_additional_policies` -> `node_iam_role_additional_policies`
      - `policies` -> `iam_role_policies`
      - `iam_role_arn` -> `node_iam_role_arn`
      - `iam_role_name` -> `node_iam_role_name`
      - `iam_role_name_prefix` -> `node_iam_role_name_prefix`
      - `iam_role_path` -> `node_iam_role_path`
      - `iam_role_description` -> `node_iam_role_description`
      - `iam_role_max_session_duration` -> `node_iam_role_max_session_duration`
      - `iam_role_permissions_boundary_arn` -> `node_iam_role_permissions_boundary_arn`
      - `iam_role_attach_cni_policy` -> `node_iam_role_attach_cni_policy`
      - `iam_role_additional_policies` -> `node_iam_role_additional_policies`
      - `iam_role_tags` -> `node_iam_role_tags`

3. Added variables:

   - `create_access_entry`
   - `enable_cluster_creator_admin_permissions`
   - `authentication_mode`
   - `access_entries`
   - `cloudwatch_log_group_class`

   - Karpenter
      - `iam_policy_name`
      - `iam_policy_use_name_prefix`
      - `iam_policy_description`
      - `iam_policy_path`
      - `enable_irsa`
      - `create_access_entry`
      - `access_entry_type`

   - Self-managed node group
      - `instance_maintenance_policy`
      - `create_access_entry`
      - `iam_role_arn`

4. Removed outputs:

   - `aws_auth_configmap_yaml`

5. Renamed outputs:

   - Karpenter
      - `irsa_name` -> `iam_role_name`
      - `irsa_arn` -> `iam_role_arn`
      - `irsa_unique_id` -> `iam_role_unique_id`
      - `role_name` -> `node_iam_role_name`
      - `role_arn` -> `node_iam_role_arn`
      - `role_unique_id` -> `node_iam_role_unique_id`

6. Added outputs:

   - `access_entries`

   - Karpenter
      - `node_access_entry_arn`

   - Self-managed node group
      - `access_entry_arn`

## Upgrade Migrations

### Diff of Before (v19.21) vs After (v20.0)

```diff
 module "eks" {
   source  = "terraform-aws-modules/eks/aws"
-  version = "~> 19.21"
+  version = "~> 20.0"

# If you want to maintain the current default behavior of v19.x
+  kms_key_enable_default_policy = false

-   manage_aws_auth_configmap = true

-   aws_auth_roles = [
-     {
-       rolearn  = "arn:aws:iam::66666666666:role/role1"
-       username = "role1"
-       groups   = ["custom-role-group"]
-     },
-   ]

-   aws_auth_users = [
-     {
-       userarn  = "arn:aws:iam::66666666666:user/user1"
-       username = "user1"
-       groups   = ["custom-users-group"]
-     },
-   ]
}

+ module "eks" {
+   source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
+   version = "~> 20.0"

+   manage_aws_auth_configmap = true

+   aws_auth_roles = [
+     {
+       rolearn  = "arn:aws:iam::66666666666:role/role1"
+       username = "role1"
+       groups   = ["custom-role-group"]
+     },
+   ]

+   aws_auth_users = [
+     {
+       userarn  = "arn:aws:iam::66666666666:user/user1"
+       username = "user1"
+       groups   = ["custom-users-group"]
+     },
+   ]
+ }
```

### Karpenter Diff of Before (v19.21) vs After (v20.0)

```diff
 module "eks" {
   source  = "terraform-aws-modules/eks/aws//modules/karpenter"
-  version = "~> 19.21"
+  version = "~> 20.0"

# If you wish to maintain the current default behavior of v19.x
+  enable_irsa             = true
+  create_instance_profile = true

# To avoid any resource re-creation
+  iam_role_name          = "KarpenterIRSA-${module.eks.cluster_name}"
+  iam_role_description   = "Karpenter IAM role for service account"
+  iam_policy_name        = "KarpenterIRSA-${module.eks.cluster_name}"
+  iam_policy_description = "Karpenter IAM role for service account"
}
```

## Terraform State Moves

#### ⚠️ Authentication Mode Changes ⚠️

Changing the `authentication_mode` is a one-way decision. See [announcement blog](https://aws.amazon.com/blogs/containers/a-deep-dive-into-simplified-amazon-eks-access-management-controls/) for further details:

> Switching authentication modes on an existing cluster is a one-way operation. You can switch from CONFIG_MAP to API_AND_CONFIG_MAP. You can then switch from API_AND_CONFIG_MAP to API. You cannot revert these operations in the opposite direction. Meaning you cannot switch back to CONFIG_MAP or API_AND_CONFIG_MAP from API. And you cannot switch back to CONFIG_MAP from API_AND_CONFIG_MAP.

> [!IMPORTANT]
> If migrating to cluster access entries and you will NOT have any entries that remain in the `aws-auth` ConfigMap, you do not need to remove the configmap from the statefile. You can simply follow the migration guide and once access entries have been created, you can let Terraform remove/delete the `aws-auth` ConfigMap.
>
> If you WILL have entries that remain in the `aws-auth` ConfigMap, then you will need to remove the ConfigMap resources from the statefile to avoid any disruptions. When you add the new `aws-auth` sub-module and apply the changes, the sub-module will upsert the ConfigMap on the cluster. Provided the necessary entries are defined in that sub-module's definition, it will "re-adopt" the ConfigMap under Terraform's control.

### authentication_mode = "CONFIG_MAP"

If using `authentication_mode = "CONFIG_MAP"`, before making any changes, you will first need to remove the configmap from the statefile to avoid any disruptions:

```sh
terraform state rm 'module.eks.kubernetes_config_map_v1_data.aws_auth[0]'
terraform state rm 'module.eks.kubernetes_config_map.aws_auth[0]' # include if Terraform created the original configmap
```

Once the configmap has been removed from the statefile, you can add the new `aws-auth` sub-module and copy the relevant definitions from the EKS module over to the new `aws-auth` sub-module definition (see before after diff above).

> [!CAUTION]
> You will need to add entries to the `aws-auth` sub-module for any IAM roles used by node groups and/or Fargate profiles - the module no longer handles this in the background on behalf of users.
>
> When you apply the changes with the new sub-module, the configmap in the cluster will get updated with the contents provided in the sub-module definition, so please be sure all of the necessary entries are added before applying the changes.

### authentication_mode = "API_AND_CONFIG_MAP"

When using `authentication_mode = "API_AND_CONFIG_MAP"` and there are entries that will remain in the configmap (entries that cannot be replaced by cluster access entry), you will first need to update the `authentication_mode` on the cluster to `"API_AND_CONFIG_MAP"`. To help make this upgrade process easier, a copy of the changes defined in the [`v20.0.0`](https://github.com/terraform-aws-modules/terraform-aws-eks/pull/2858) PR have been captured [here](https://github.com/clowdhaus/terraform-aws-eks-v20-migrate) but with the `aws-auth` components still provided in the module. This means you get the equivalent of the `v20.0.0` module, but it still includes support for the `aws-auth` configmap. You can follow the provided README on that interim migration module for the order of execution and return here once the `authentication_mode` has been updated to `"API_AND_CONFIG_MAP"`. Note - EKS automatically adds access entries for the roles used by EKS managed node groups and Fargate profiles; users do not need to do anything additional for these roles.

Once the `authentication_mode` has been updated, next you will need to remove the configmap from the statefile to avoid any disruptions:

> [!NOTE]
> This is only required if there are entries that will remain in the `aws-auth` ConfigMap after migrating. Otherwise, you can skip this step and let Terraform destroy the ConfigMap.

```sh
terraform state rm 'module.eks.kubernetes_config_map_v1_data.aws_auth[0]'
terraform state rm 'module.eks.kubernetes_config_map.aws_auth[0]' # include if Terraform created the original configmap
```

#### ℹ️ Terraform 1.7+ users

If you are using Terraform `v1.7+`, you can utilize the [`remove`](https://developer.hashicorp.com/terraform/language/resources/syntax#removing-resources) to facilitate both the removal of the configmap through code. You can create a fork/clone of the provided [migration module](https://github.com/clowdhaus/terraform-aws-eks-migrate-v19-to-v20) and add the `remove` blocks and apply those changes before proceeding. We do not want to force users onto the bleeding edge with this module, so we have not included `remove` support at this time.

Once the configmap has been removed from the statefile, you can add the new `aws-auth` sub-module and copy the relevant definitions from the EKS module over to the new `aws-auth` sub-module definition (see before after diff above). When you apply the changes with the new sub-module, the configmap in the cluster will get updated with the contents provided in the sub-module definition, so please be sure all of the necessary entries are added before applying the changes. In the before/example above - the configmap would remove any entries for roles used by node groups and/or Fargate Profiles, but maintain the custom entries for users and roles passed into the module definition.

### authentication_mode = "API"

In order to switch to `API` only using cluster access entry, you first need to update the `authentication_mode` on the cluster to `API_AND_CONFIG_MAP` without modifying the `aws-auth` configmap. To help make this upgrade process easier, a copy of the changes defined in the [`v20.0.0`](https://github.com/terraform-aws-modules/terraform-aws-eks/pull/2858) PR have been captured [here](https://github.com/clowdhaus/terraform-aws-eks-v20-migrate) but with the `aws-auth` components still provided in the module. This means you get the equivalent of the `v20.0.0` module, but it still includes support for the `aws-auth` configmap. You can follow the provided README on that interim migration module for the order of execution and return here once the `authentication_mode` has been updated to `"API_AND_CONFIG_MAP"`. Note - EKS automatically adds access entries for the roles used by EKS managed node groups and Fargate profiles; users do not need to do anything additional for these roles.

Once the `authentication_mode` has been updated, you can update the `authentication_mode` on the cluster to `API` and remove the `aws-auth` configmap components.
