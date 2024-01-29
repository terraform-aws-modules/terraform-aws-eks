# Upgrade from v19.x to v20.x

Please consult the `examples` directory for reference example configurations. If you find a bug, please open an issue with supporting configuration to reproduce.

## List of backwards incompatible changes

- Minium supported AWS provider version increased to `v5.34`
- Minimum supported Terraform version increased to `v1.3` to support Terraform state `moved` blocks as well as other advanced features
- The `resolve_conflicts` argument within the `cluster_addons` configuration has been replaced with `resolve_conflicts_on_create` and `resolve_conflicts_on_delete` now that `resolve_conflicts` is deprecated
- The default/fallback value for the `preserve` argument of `cluster_addons`is now set to `true`. This has shown to be useful for users deprovisioning clusters while avoiding the situation where the CNI is deleted too early and causes resources to be left orphaned resulting in conflicts.
- The Karpenter sub-module's use of the `irsa` naming convention has been removed, along with an update to the Karpenter controller IAM policy to align with Karpenter's `v1beta1`/`v0.32` changes. Instead of referring to the role as `irsa` or `pod_identity`, its simply just an IAM role used by the Karpenter controller and there is support for use with either IRSA and/or Pod Identity (default) at this time
- The `aws-auth` ConfigMap resources have been moved to a standalone sub-module. This removes the Kubernetes provider requirement from the main module and allows for the `aws-auth` ConfigMap to be managed independently of the main module. This sub-module will be removed entirely in the next major release.
- Support for cluster access management has been added with the default authentication mode set as `API_AND_CONFIG_MAP`. This is a one way change if applied; if you wish to use `CONFIG_MAP`, you will need to set `authentication_mode = "CONFIG_MAP"` explicitly when upgrading.
- Karpenter EventBridge rule key `spot_interrupt` updated to correct mis-spelling (was `spot_interupt`). This will cause the rule to be replaced

### ⚠️ Upcoming Changes Planned in v21.0 ⚠️

To give users advanced notice and provide some future direction for this module, these are the following changes we will be looking to make in the next major release of this module:

1. The `aws-auth` sub-module will be removed entirely from the project. Since this sub-module is captured in the v20.x releases, users can continue using it even after the module moves forward with the next major version. The long term strategy and direction is cluster access entry and to rely only on the AWS Terraform provider.
2. The default value for `authentication_mode` will change to `API`. Aligning with point 1 above, this is a one way change, but users are free to specify the value of their choosing in place of this default (when the change is made). This module will proceed with an EKS API first strategy.

## Additional changes

### Added

   - A module tag has been added to the cluster control plane
   - Support for cluster access entries. The `bootstrap_cluster_creator_admin_permissions` setting on the control plane has been hardcoded to `false` since this operation is a one time operation only at cluster creation per the EKS API. Instead, users can enable/disable `enable_cluster_creator_admin_permissions` at any time to achieve the same functionality. This takes the identity that Terraform is using to make API calls and maps it into a cluster admin via an access entry. For users on existing clusters, you will need to remove the default cluster administrator that was created by EKS prior to the cluster access entry APIs - see the section [`Removing the default cluster administrator`](https://aws.amazon.com/blogs/containers/a-deep-dive-into-simplified-amazon-eks-access-management-controls/) for more details.
   - Support for specifying the CloudWatch log group class (standard or infrequent access)
   - Native support for Windows based managed nodegroups similar to AL2 and Bottlerocket
   - Self-managed nodegroups now support `instance_maintenance_policy` and have added `max_healthy_percentage`, `scale_in_protected_instances`, and `standby_instances` arguments to the `instance_refresh.preferences` block

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

   - EKS managed nodegroup
      - `create_access_entry`

   - Fargate Profile
      - `create_access_entry`

   - Karpenter
      - `iam_policy_name`
      - `iam_policy_use_name_prefix`
      - `iam_policy_description`
      - `iam_policy_path`
      - `enable_irsa`
      - `create_access_entry`
      - `access_entry_type`

   - Self-managed nodegroup
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

   - EKS managed nodegroup
      - `access_entry_arn`

   - Fargate Profile
      - `access_entry_arn`

   - Karpenter
      - `node_access_entry_arn`

   - Self-managed nodegroup
      - `access_entry_arn`

## Upgrade Migrations

## Terraform State Moves
