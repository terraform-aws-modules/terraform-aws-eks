# Upgrade from v19.x to v20.x

Please consult the `examples` directory for reference example configurations. If you find a bug, please open an issue with supporting configuration to reproduce.

## List of backwards incompatible changes

- Minium supported AWS provider version increased to `v5.0`
- The `resolve_conflicts` argument within the `cluster_addons` configuration has been replaced with `resolve_conflicts_on_create` and `resolve_conflicts_on_delete` now that `resolve_conflicts` is deprecated
- The `cluster_addons` `preserve` argument default/fallback value is now set to `true`. This has shown to be useful for users deprovisioning clusters while avoiding the situation where the CNI is deleted too early and causes resources to be left orphaned which results in conflicts.
- The Karpenter sub-module's use of the `irsa` naming convention has been replaced with `pod-identity` along with an update to the Karpenter controller IAM policy to align with the `v1beta1`/`v0.32` changes

## Additional changes

### Added

   - A module tag has been added to the cluster and compute resources created

### Modified

   - For `sts:AssumeRole` permissions by services, the use of dynamically looking up the DNS suffix has been replaced with the static value of `amazonaws.com`. This does not appear to change by partition and instead requires users to set this manually for non-commercial regions.

### Removed

   -

### Variable and output changes

1. Removed variables:

   - Karpenter
      - `irsa_tag_key`
      - `irsa_tag_values`
      - `irsa_subnet_account_id`
      - `enable_karpenter_instance_profile_creation`

2. Renamed variables:

   - Karpenter
      - `create_irsa` -> `create_pod_identity`
      - `irsa_name` -> `pod_identity_role_name`
      - `irsa_use_name_prefix` -> `pod_identity_role_name_prefix`
      - `irsa_path` -> `pod_identity_role_path`
      - `irsa_description` -> `pod_identity_role_description`
      - `irsa_max_session_duration` -> `pod_identity_role_max_session_duration`
      - `irsa_permissions_boundary_arn` -> `pod_identity_role_permissions_boundary_arn`
      - `irsa_tags` -> `pod_identity_role_tags`
      - `policies` -> `pod_identity_role_policies`
      - `irsa_policy_name` -> `pod_identity_policy_name`
      - `irsa_ssm_parameter_arns` -> `ami_id_ssm_parameter_arns`


3. Added variables:

   -

4. Removed outputs:

   -

5. Renamed outputs:

   - Karpenter
      - `irsa_name` -> `pod_identity_role_name`
      - `irsa_arn` -> `pod_identity_role_arn`
      - `irsa_unique_id` -> `pod_identity_role_unique_id`

6. Added outputs:

   -

## Upgrade Migrations

### Diff of Before (v18.x) vs After (v19.x)

```diff
 module "eks" {
   source  = "terraform-aws-modules/eks/aws"
-  version = "~> 19.17.1"
+  version = "~> 20.0"

}
```

## Terraform State Moves
