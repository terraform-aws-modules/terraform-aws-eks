# Upgrade from v20.x to v21.x

If you have any questions regarding this upgrade process, please consult the [`examples`](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples) directory:
If you find a bug, please open an issue with supporting configuration to reproduce.

## List of backwards incompatible changes

- Terraform `v1.5.7` is now minimum supported version
- AWS provider `v6.0.0` is now minimum supported version
- TLS provider `v4.0.0` is now minimum supported version
- The `aws-auth` sub-module has been removed. Users who wish to utilize its functionality can continue to do so by specifying a `v20.x` version, or `~> v20.0` version constraint in their module source.
- `bootstrap_self_managed_addons` is now hardcoded to `false`. This is a legacy setting and instead users should utilize the EKS addons API, which is what this module does by default. In conjunction with this change, the `bootstrap_self_managed_addons` is now ignored by the module to aid in upgrading without disruption (otherwise it would require cluster re-creation).
- When enabling `enable_efa_support` or creating placement groups within a node group, users must now specify the correct `subnet_ids`; the module no longer tries to automatically select a suitable subnet.
- EKS managed node group:
    - IMDS now default to a hop limit of 1 (previously was 2)
    - `ami_type` now defaults to `AL2023_x86_64_STANDARD`
    - `enable_monitoring` is now set to `false` by default
    - `enable_efa_only` is now set to `true` by default
    - `use_latest_ami_release_version` is now set to `true` by default
    - Support for autoscaling group schedules has been removed
- Self-managed node group:
    - IMDS now default to a hop limit of 1 (previously was 2)
    - `ami_type` now defaults to `AL2023_x86_64_STANDARD`
    - `enable_monitoring` is now set to `false` by default
    - `enable_efa_only` is now set to `true` by default
    - Support for autoscaling group schedules has been removed
- Karpenter:
    - Native support for IAM roles for service accounts (IRSA) has been removed; EKS Pod Identity is now enabled by default
    - Karpenter controller policy for prior to Karpenter `v1` have been removed (i.e. `v0.33`); the `v1` policy is now used by default
    - `create_pod_identity_association` is now set to `true` by default
- `addons.resolve_conflicts_on_create` is now set to `"NONE"` by default (was `"OVERWRITE"`).
- `addons.most_recent` is now set to `true` by default (was `false`).
- `cluster_identity_providers.issuer_url` is now required to be set by users; the prior incorrect default has been removed. See https://github.com/terraform-aws-modules/terraform-aws-eks/pull/3055 and https://github.com/kubernetes/kubernetes/pull/123561 for more details.
- The OIDC issuer URL for IAM roles for service accounts (IRSA) has been changed to use the new dual stack`oidc-eks` endpoint instead of `oidc.eks`. This is to align with https://github.com/aws/containers-roadmap/issues/2038#issuecomment-2278450601
- With the changes to the variable type definition for `encryption_config` (formerly `cluster_encryption_config`), if you wish to disable secret encryption with a custom KMS key you should set `encryption_config = null` (In `v20.x`, you would previously have set `encryption_config = {}` to achieve the same outcome). Secret encryption can no longer be disabled - it is either enabled by default with the AWS managed key (`encryption_config = null`), or with a custom KMS key ( either leaving as is by not specifying or passing your own custom key ARN). EKS now encrypts secrets at rest by default  docs.aws.amazon.com/eks/latest/userguide/envelope-encryption.html and the default secret encryption w/ custom KMS key creation/usage by default was made years prior starting in version `v19.0` of this module. Removing this default behavior will be evaluated at the next breaking change given that secrets are now automatically encrypted at rest by AWS.

## Additional changes

### Added

- Support for `region` parameter to specify the AWS region for the resources created if different from the provider region.
- Both the EKS managed and self-managed node groups now support creating their own security groups (again). This is primarily motivated by the changes for EFA support; previously users would need to specify `enable_efa_support` both at the cluster level (to add the appropriate security group rules to the shared node security group) as well as the node group level. However, its not always desirable to have these rules across ALL node groups when they are really only required on the node group where EFA is utilized. And similarly for other use cases, users can create custom rules for a specific node group instead of apply across ALL node groups.

### Modified

- Variable definitions now contain detailed `object` types in place of the previously used any type.
- The embedded KMS key module definition has been updated to `v4.0` to support the same version requirements as well as the new `region` argument.

### Variable and output changes

1. Removed variables:

    - `enable_efa_support` - users only need to set this within the node group configuration, as the module no longer manages EFA support at the cluster level.
    - `enable_security_groups_for_pods` - users can instead attach the `arn:aws:iam::aws:policy/AmazonEKSVPCResourceController` policy via `iam_role_additional_policies` if using security groups for pods.
    - `eks-managed-node-group` sub-module
        - `cluster_service_ipv4_cidr` - users should use `cluster_service_cidr` instead (for either IPv4 or IPv6).
        - `elastic_gpu_specifications`
        - `elastic_inference_accelerator`
        - `platform` - this is superseded by `ami_type`
        - `placement_group_strategy` - set to `cluster` by the module
        - `placement_group_az` - users will need to specify the correct subnet in `subnet_ids`
        - `create_schedule`
        - `schedules`
    - `self-managed-node-group` sub-module
        - `elastic_gpu_specifications`
        - `elastic_inference_accelerator`
        - `platform` - this is superseded by `ami_type`
        - `create_schedule`
        - `schedules`
        - `placement_group_az` - users will need to specify the correct subnet in `subnet_ids`
        - `hibernation_options` - not valid in EKS
        - `min_elb_capacity` - not valid in EKS
        - `wait_for_elb_capacity` - not valid in EKS
        - `wait_for_capacity_timeout` - not valid in EKS
        - `default_cooldown` - not valid in EKS
        - `target_group_arns` - not valid in EKS
        - `service_linked_role_arn` - not valid in EKS
        - `warm_pool` - not valid in EKS
    - `fargate-profile` sub-module
        - None
    - `karpenter` sub-module
        - `enable_v1_permissions` - v1 permissions are now the default
        - `enable_irsa`
        - `irsa_oidc_provider_arn`
        - `irsa_namespace_service_accounts`
        - `irsa_assume_role_condition_test`

2. Renamed variables:

    - Variables prefixed with `cluster_*` have been stripped of the prefix to better match the underlying API:
        - `cluster_name` -> `name`
        - `cluster_version` -> `kubernetes_version`
        - `cluster_enabled_log_types` -> `enabled_log_types`
        - `cluster_force_update_version` -> `force_update_version`
        - `cluster_compute_config` -> `compute_config`
        - `cluster_upgrade_policy` -> `upgrade_policy`
        - `cluster_remote_network_config` -> `remote_network_config`
        - `cluster_zonal_shift_config` -> `zonal_shift_config`
        - `cluster_additional_security_group_ids` -> `additional_security_group_ids`
        - `cluster_endpoint_private_access` -> `endpoint_private_access`
        - `cluster_endpoint_public_access` -> `endpoint_public_access`
        - `cluster_endpoint_public_access_cidrs` -> `endpoint_public_access_cidrs`
        - `cluster_ip_family` -> `ip_family`
        - `cluster_service_ipv4_cidr` -> `service_ipv4_cidr`
        - `cluster_service_ipv6_cidr` -> `service_ipv6_cidr`
        - `cluster_encryption_config` -> `encryption_config`
        - `create_cluster_primary_security_group_tags` -> `create_primary_security_group_tags`
        - `cluster_timeouts` -> `timeouts`
        - `create_cluster_security_group` -> `create_security_group`
        - `cluster_security_group_id` -> `security_group_id`
        - `cluster_security_group_name` -> `security_group_name`
        - `cluster_security_group_use_name_prefix` -> `security_group_use_name_prefix`
        - `cluster_security_group_description` -> `security_group_description`
        - `cluster_security_group_additional_rules` -> `security_group_additional_rules`
        - `cluster_security_group_tags` -> `security_group_tags`
        - `cluster_encryption_policy_use_name_prefix` -> `encryption_policy_use_name_prefix`
        - `cluster_encryption_policy_name` -> `encryption_policy_name`
        - `cluster_encryption_policy_description` -> `encryption_policy_description`
        - `cluster_encryption_policy_path` -> `encryption_policy_path`
        - `cluster_encryption_policy_tags` -> `encryption_policy_tags`
        - `cluster_addons` -> `addons`
        - `cluster_addons_timeouts` -> `addons_timeouts`
        - `cluster_identity_providers` -> `identity_providers`
    - `eks-managed-node-group` sub-module
        - `cluster_version` -> `kubernetes_version`
    - `self-managed-node-group` sub-module
        - `cluster_version` -> `kubernetes_version`
        - `delete_timeout` -> `timeouts`
    - `fargate-profile` sub-module
        - None
    - `karpenter` sub-module
        - None

3. Added variables:

    - `region`
    - `eks-managed-node-group` sub-module
        - `region`
        - `partition` - added to reduce number of `GET` requests from data sources when possible
        - `account_id` - added to reduce number of `GET` requests from data sources when possible
        - `create_security_group`
        - `security_group_name`
        - `security_group_use_name_prefix`
        - `security_group_description`
        - `security_group_ingress_rules`
        - `security_group_egress_rules`
        - `security_group_tags`
    - `self-managed-node-group` sub-module
        - `region`
        - `partition` - added to reduce number of `GET` requests from data sources when possible
        - `account_id` - added to reduce number of `GET` requests from data sources when possible
        - `create_security_group`
        - `security_group_name`
        - `security_group_use_name_prefix`
        - `security_group_description`
        - `security_group_ingress_rules`
        - `security_group_egress_rules`
        - `security_group_tags`
    - `fargate-profile` sub-module
        - `region`
        - `partition` - added to reduce number of `GET` requests from data sources when possible
        - `account_id` - added to reduce number of `GET` requests from data sources when possible
    - `karpenter` sub-module
        - `region`

4. Removed outputs:

    - `eks-managed-node-group` sub-module
        - `platform` - this is superseded by `ami_type`
        - `autoscaling_group_schedule_arns`
    - `self-managed-node-group` sub-module
        - `platform` - this is superseded by `ami_type`
        - `autoscaling_group_schedule_arns`
    - `fargate-profile` sub-module
        - None
    - `karpenter` sub-module
        - None

5. Renamed outputs:

    - `eks-managed-node-group` sub-module
        - None
    - `self-managed-node-group` sub-module
        - None
    - `fargate-profile` sub-module
        - None
    - `karpenter` sub-module
        - None

6. Added outputs:

    - `eks-managed-node-group` sub-module
        - `security_group_arn`
        - `security_group_id`
    - `self-managed-node-group` sub-module
        - `security_group_arn`
        - `security_group_id`
    - `fargate-profile` sub-module
        - None
    - `karpenter` sub-module
        - None

## Upgrade Migrations

### Before 20.x Example

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  # Truncated for brevity ...
  # Renamed variables are not shown here, please refer to the full list above.

  enable_efa_support = true

  eks_managed_node_group_defaults = {
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
  }

  eks_managed_node_groups = {
    efa = {
      ami_type       = "AL2023_x86_64_NVIDIA"
      instance_types = ["p5e.48xlarge"]

      enable_efa_support = true
      enable_efa_only    = true
    }
  }

  self_managed_node_groups = {
    example = {
      use_mixed_instances_policy = true
      mixed_instances_policy = {
        instances_distribution = {
          on_demand_base_capacity                  = 0
          on_demand_percentage_above_base_capacity = 0
          on_demand_allocation_strategy            = "lowest-price"
          spot_allocation_strategy                 = "price-capacity-optimized"
        }

        # ASG configuration
        override = [
          {
            instance_requirements = {
              cpu_manufacturers                           = ["intel"]
              instance_generations                        = ["current", "previous"]
              spot_max_price_percentage_over_lowest_price = 100

              vcpu_count = {
                min = 1
              }

              allowed_instance_types = ["t*", "m*"]
            }
          }
        ]
      }
    }
  }
}
```

### After 21.x Example

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  # Truncated for brevity ...
  # Renamed variables are not shown here, please refer to the full list above.

  eks_managed_node_groups = {
    efa = {
      ami_type       = "AL2023_x86_64_NVIDIA"
      instance_types = ["p5e.48xlarge"]

      iam_role_additional_policies = {
        AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }

      enable_efa_support = true

      subnet_ids = element(module.vpc.private_subnets, 0)
    }
  }

  self_managed_node_groups = {
    example = {
      use_mixed_instances_policy = true
      mixed_instances_policy = {
        instances_distribution = {
          on_demand_base_capacity                  = 0
          on_demand_percentage_above_base_capacity = 0
          on_demand_allocation_strategy            = "lowest-price"
          spot_allocation_strategy                 = "price-capacity-optimized"
        }

        # ASG configuration
        # Need to wrap in `launch_template` now
        launch_template = {
          override = [
            {
              instance_requirements = {
                cpu_manufacturers                           = ["intel"]
                instance_generations                        = ["current", "previous"]
                spot_max_price_percentage_over_lowest_price = 100

                vcpu_count = {
                  min = 1
                }

                allowed_instance_types = ["t*", "m*"]
              }
            }
          ]
        }
      }
    }
  }
}
```

### State Changes

No state changes required.
