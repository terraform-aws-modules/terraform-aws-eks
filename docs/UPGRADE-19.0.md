# Upgrade from v18.x to v19.x

Please consult the `examples` directory for reference example configurations. If you find a bug, please open an issue with supporting configuration to reproduce.

## List of backwards incompatible changes

- The `cluster_id` output used to output the name of the cluster. This is due to the fact that the cluster name is a unique constraint and therefore its set as the unique identifier within Terraform's state map. However, starting with local EKS clusters created on Outposts, there is now an attribute returned from the `aws eks create-cluster` API named `id`. The `cluster_id` has been updated to return this value which means that for current, standard EKS clusters created in the AWS cloud, no value will be returned (at the time of this writing) for `cluster_id` and only local EKS clusters on Outposts will return a value that looks like a UUID/GUID. Users should switch all instances of `cluster_id` to use `cluster_name` before upgrading to v19. [Reference](https://github.com/hashicorp/terraform-provider-aws/issues/27560)
- Minimum supported version of Terraform AWS provider updated to v4.45 to support the latest features provided via the resources utilized.
- Minimum supported version of Terraform updated to v1.0
- Individual security group created per EKS managed node group or self-managed node group has been removed. This configuration went mostly unused and would often cause confusion ("Why is there an empty security group attached to my nodes?"). This functionality can easily be replicated by user's providing one or more externally created security groups to attach to nodes launched from the node group.
- Previously, `var.iam_role_additional_policies` (one for each of the following: cluster IAM role, EKS managed node group IAM role, self-managed node group IAM role, and Fargate Profile IAM role) accepted a list of strings. This worked well for policies that already existed but failed for policies being created at the same time as the cluster due to the well-known issue of unknown values used in a `for_each` loop. To rectify this issue in `v19.x`, two changes were made:
  1. `var.iam_role_additional_policies` was changed from type `list(string)` to type `map(string)` -> this is a breaking change. More information on managing this change can be found below, under `Terraform State Moves`
  2. The logic used in the root module for this variable was changed to replace the use of `try()` with `lookup()`. More details on why can be found [here](https://github.com/clowdhaus/terraform-for-each-unknown)
- The cluster name has been removed from the Karpenter module event rule names. Due to the use of long cluster names appending to the provided naming scheme, the cluster name has moved to a `ClusterName` tag and the event rule name is now a prefix. This guarantees that users can have multiple instances of Karpenter with their respective event rules/SQS queue without name collisions, while also still being able to identify which queues and event rules belong to which cluster.
- The new variable `node_security_group_enable_recommended_rules` is set to true by default and may conflict with any custom ingress/egress rules. Please ensure that any duplicates from the `node_security_group_additional_rules` are removed before upgrading, or set `node_security_group_enable_recommended_rules` to false. [Reference](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/UPGRADE-19.0.md#added)

## Additional changes

### Added

- Support for setting `preserve` as well as `most_recent` on addons.
  - `preserve` indicates if you want to preserve the created resources when deleting the EKS add-on
  - `most_recent` indicates if you want to use the most recent revision of the add-on or the default version (default)
- Support for setting default node security group rules for common access patterns required:
  - Egress all for `0.0.0.0/0`/`::/0`
  - Ingress from cluster security group for 8443/TCP and 9443/TCP for common applications such as ALB Ingress Controller, Karpenter, OPA Gatekeeper, etc. These are commonly used as webhook ports for validating and mutating webhooks

### Modified

- `cluster_security_group_additional_rules` and `node_security_group_additional_rules` have been modified to use `lookup()` instead of `try()` to avoid the well-known issue of [unknown values within a `for_each` loop](https://github.com/hashicorp/terraform/issues/4149)
- Default cluster security group rules have removed egress rules for TCP/443 and TCP/10250 to node groups since the cluster primary security group includes a default rule for ALL to `0.0.0.0/0`/`::/0`
- Default node security group rules have removed egress rules have been removed since the default security group settings have egress rule for ALL to `0.0.0.0/0`/`::/0`
- `block_device_mappings` previously required a map of maps but has since changed to an array of maps. Users can remove the outer key for each block device mapping and replace the outermost map `{}` with an array `[]`. There are no state changes required for this change.
- `create_kms_key` previously defaulted to `false` and now defaults to `true`. Clusters created with this module now default to enabling secret encryption by default with a customer-managed KMS key created by this module
- `cluster_encryption_config` previously used a type of `list(any)` and now uses a type of `any` -> users can simply remove the outer `[`...`]` brackets on `v19.x`
  - `cluster_encryption_config` previously defaulted to `[]` and now defaults to `{resources = ["secrets"]}` to encrypt secrets by default
- `cluster_endpoint_public_access` previously defaulted to `true` and now defaults to `false`. Clusters created with this module now default to private-only access to the cluster endpoint
  - `cluster_endpoint_private_access` previously defaulted to `false` and now defaults to `true`
- The addon configuration now sets `"OVERWRITE"` as the default value for `resolve_conflicts` to ease add-on upgrade management. Users can opt out of this by instead setting `"NONE"` as the value for `resolve_conflicts`
- The `kms` module used has been updated from `v1.0.2` to `v1.1.0` - no material changes other than updated to latest
- The default value for EKS managed node group `update_config` has been updated to the recommended `{ max_unavailable_percentage = 33 }`
- The default value for the self-managed node group `instance_refresh` has been updated to the recommended:
    ```hcl
    {
      strategy = "Rolling"
      preferences = {
        min_healthy_percentage = 66
      }
    }
    ```

### Removed

- Remove all references of `aws_default_tags` to avoid update conflicts; this is the responsibility of the provider and should be handled at the provider level
  - https://github.com/terraform-aws-modules/terraform-aws-eks/issues?q=is%3Aissue+default_tags+is%3Aclosed
  - https://github.com/terraform-aws-modules/terraform-aws-eks/pulls?q=is%3Apr+default_tags+is%3Aclosed

### Variable and output changes

1. Removed variables:
 
   - `node_security_group_ntp_ipv4_cidr_block` - default security group settings have an egress rule for ALL to `0.0.0.0/0`/`::/0`
   - `node_security_group_ntp_ipv6_cidr_block` - default security group settings have an egress rule for ALL to `0.0.0.0/0`/`::/0`
   - Self-managed node groups:
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

   - N/A

3. Added variables:

   - `provision_on_outpost`for Outposts support
   - `outpost_config` for Outposts support
   - `cluster_addons_timeouts` for setting a common set of timeouts for all addons (unless a specific value is provided within the addon configuration)
   - `service_ipv6_cidr` for setting the IPv6 CIDR block for the Kubernetes service addresses
   - `node_security_group_enable_recommended_rules` for enabling recommended node security group rules for common access patterns

   - Self-managed node groups:
     - `launch_template_id` for use when using an existing/externally created launch template (Ref: https://github.com/terraform-aws-modules/terraform-aws-autoscaling/pull/204)
     - `maintenance_options`
     - `private_dns_name_options`
     - `instance_requirements`
     - `context`
     - `default_instance_warmup`
     - `force_delete_warm_pool`
   - EKS managed node groups:
     - `use_custom_launch_template` was added to better clarify how users can switch between a custom launch template or the default launch template provided by the EKS managed node group. Previously, to achieve this same functionality of using the default launch template, users needed to set `create_launch_template = false` and `launch_template_name = ""` which is not very intuitive.
     - `launch_template_id` for use when using an existing/externally created launch template (Ref: https://github.com/terraform-aws-modules/terraform-aws-autoscaling/pull/204)
     - `maintenance_options`
     - `private_dns_name_options`
     -
4. Removed outputs:

   - Self-managed node groups:
     - `security_group_arn`
     - `security_group_id`
   - EKS managed node groups:
     - `security_group_arn`
     - `security_group_id`

5. Renamed outputs:

   - `cluster_id` is not renamed but the value it returns is now different. For standard EKS clusters created in the AWS cloud, the value returned at the time of this writing is `null`/empty. For local EKS clusters created on Outposts, the value returned will look like a UUID/GUID. Users should switch all instances of `cluster_id` to use `cluster_name` before upgrading to v19. [Reference](https://github.com/hashicorp/terraform-provider-aws/issues/27560)

6. Added outputs:

   - `cluster_name` - The `cluster_id` currently set by the AWS provider is actually the cluster name, but in the future, this will change and there will be a distinction between the `cluster_name` and `cluster_id`. [Reference](https://github.com/hashicorp/terraform-provider-aws/issues/27560)

## Upgrade Migrations

1. Before upgrading your module definition to `v19.x`, please see below for both EKS managed node group(s) and self-managed node groups and remove the node group(s) security group prior to upgrading.

### Self-Managed Node Groups

Self-managed node groups on `v18.x` by default create a security group that does not specify any rules. In `v19.x`, this security group has been removed due to the predominant lack of usage (most users rely on the shared node security group). While still using version `v18.x` of your module definition, remove this security group from your node groups by setting `create_security_group = false`.

- If you are currently utilizing this security group, it is recommended to create an additional security group that matches the rules/settings of the security group created by the node group, and specify that security group ID in `vpc_security_group_ids`. Once this is in place, you can proceed with the original security group removal.
- For most users, the security group is not used and can be safely removed. However, deployed instances will have the security group attached to nodes and require the security group to be disassociated before the security group can be deleted. Because instances are deployed via autoscaling groups, we cannot simply remove the security group from the code and have those changes reflected on the instances. Instead, we have to update the code and then trigger the autoscaling groups to cycle the instances deployed so that new instances are provisioned without the security group attached. You can utilize the `instance_refresh` parameter of Autoscaling groups to force nodes to re-deploy when removing the security group since changes to launch templates automatically trigger an instance refresh. An example configuration is provided below.
  - Add the following to either/or `self_managed_node_group_defaults` or the individual self-managed node group definitions:
    ```hcl
    create_security_group = false
    instance_refresh = {
      strategy = "Rolling"
      preferences = {
        min_healthy_percentage = 66
      }
    }
    ```
- It is recommended to use the `aws-node-termination-handler` while performing this update. Please refer to the [`irsa-autoscale-refresh` example](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/20af82846b4a1f23f3787a8c455f39c0b6164d80/examples/irsa_autoscale_refresh/charts.tf#L86) for usage. This will ensure that pods are safely evicted in a controlled manner to avoid service disruptions.
- Once the necessary configurations are in place, you can apply the changes which will:
  1. Create a new launch template (version) without the self-managed node group security group
  2. Replace instances based on the `instance_refresh` configuration settings
  3. New instances will launch without the self-managed node group security group, and prior instances will be terminated
  4. Once the self-managed node group has cycled, the security group will be deleted

### EKS Managed Node Groups

EKS managed node groups on `v18.x` by default create a security group that does not specify any rules. In `v19.x`, this security group has been removed due to the predominant lack of usage (most users rely on the shared node security group). While still using version `v18.x` of your module definition, remove this security group from your node groups by setting `create_security_group = false`.

- If you are currently utilizing this security group, it is recommended to create an additional security group that matches the rules/settings of the security group created by the node group, and specify that security group ID in `vpc_security_group_ids`. Once this is in place, you can proceed with the original security group removal.
- EKS managed node groups rollout changes using a [rolling update strategy](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-update-behavior.html) that can be influenced through `update_config`. No additional changes are required for removing the security group created by node groups (unlike self-managed node groups which should utilize the `instance_refresh` setting of Autoscaling groups).
- Once `create_security_group = false` has been set, you can apply the changes which will:
  1. Create a new launch template (version) without the EKS managed node group security group
  2. Replace instances based on the `update_config` configuration settings
  3. New instances will launch without the EKS managed node group security group, and prior instances will be terminated
  4. Once the EKS managed node group has cycled, the security group will be deleted

2. Once the node group security group(s) have been removed, you can update your module definition to specify the `v19.x` version of the module
3. Run `terraform init -upgrade=true` to update your configuration and pull in the v19 changes
4. Using the documentation provided above, update your module definition to reflect the changes in the module from `v18.x` to `v19.x`. You can utilize `terraform plan` as you go to help highlight any changes that you wish to make. See below for `terraform state mv ...` commands related to the use of `iam_role_additional_policies`. If you are not providing any values to these variables, you can skip this section.
5. Once you are satisfied with the changes and the `terraform plan` output, you can apply the changes to sync your infrastructure with the updated module definition (or vice versa).

### Diff of Before (v18.x) vs After (v19.x)

```diff
 module "eks" {
   source  = "terraform-aws-modules/eks/aws"
-  version = "~> 18.0"
+  version = "~> 19.0"

  cluster_name                    = local.name
+ cluster_endpoint_public_access  = true
- cluster_endpoint_private_access = true # now the default

  cluster_addons = {
-   resolve_conflicts = "OVERWRITE" # now the default
+   preserve          = true
+   most_recent       = true

+   timeouts = {
+     create = "25m"
+     delete = "10m"
    }
    kube-proxy = {}
    vpc-cni = {
-     resolve_conflicts = "OVERWRITE" # now the default
    }
  }

  # Encryption key
  create_kms_key = true
- cluster_encryption_config = [{
-   resources = ["secrets"]
- }]
+ cluster_encryption_config = {
+   resources = ["secrets"]
+ }
  kms_key_deletion_window_in_days = 7
  enable_kms_key_rotation         = true

- iam_role_additional_policies = [aws_iam_policy.additional.arn]
+ iam_role_additional_policies = {
+   additional = aws_iam_policy.additional.arn
+ }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  # Extend node-to-node security group rules
- node_security_group_ntp_ipv4_cidr_block = ["169.254.169.123/32"] # now the default
  node_security_group_additional_rules = {
-    ingress_self_ephemeral = {
-      description = "Node to node ephemeral ports"
-      protocol    = "tcp"
-      from_port   = 0
-      to_port     = 0
-      type        = "ingress"
-      self        = true
-    }
-    egress_all = {
-      description      = "Node all egress"
-      protocol         = "-1"
-      from_port        = 0
-      to_port          = 0
-      type             = "egress"
-      cidr_blocks      = ["0.0.0.0/0"]
-      ipv6_cidr_blocks = ["::/0"]
-    }
  }

  # Self-Managed Node Group(s)
  self_managed_node_group_defaults = {
    vpc_security_group_ids = [aws_security_group.additional.id]
-   iam_role_additional_policies = [aws_iam_policy.additional.arn]
+   iam_role_additional_policies = {
+     additional = aws_iam_policy.additional.arn
+   }
  }

  self_managed_node_groups = {
    spot = {
      instance_type = "m5.large"
      instance_market_options = {
        market_type = "spot"
      }

      pre_bootstrap_user_data = <<-EOT
        echo "foo"
        export FOO=bar
      EOT

      bootstrap_extra_args = "--kubelet-extra-args '--node-labels=node.kubernetes.io/lifecycle=spot'"

      post_bootstrap_user_data = <<-EOT
        cd /tmp
        sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
        sudo systemctl enable amazon-ssm-agent
        sudo systemctl start amazon-ssm-agent
      EOT

-     create_security_group          = true
-     security_group_name            = "eks-managed-node-group-complete-example"
-     security_group_use_name_prefix = false
-     security_group_description     = "EKS managed node group complete example security group"
-     security_group_rules = {}
-     security_group_tags = {}
    }
  }

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]

    attach_cluster_primary_security_group = true
    vpc_security_group_ids                = [aws_security_group.additional.id]
-   iam_role_additional_policies = [aws_iam_policy.additional.arn]
+   iam_role_additional_policies = {
+     additional = aws_iam_policy.additional.arn
+   }
  }

  eks_managed_node_groups = {
    blue = {}
    green = {
      min_size     = 1
      max_size     = 10
      desired_size = 1

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"
      labels = {
        Environment = "test"
        GithubRepo  = "terraform-aws-eks"
        GithubOrg   = "terraform-aws-modules"
      }

      taints = {
        dedicated = {
          key    = "dedicated"
          value  = "gpuGroup"
          effect = "NO_SCHEDULE"
        }
      }

      update_config = {
        max_unavailable_percentage = 33 # or set `max_unavailable`
      }

-     create_security_group          = true
-     security_group_name            = "eks-managed-node-group-complete-example"
-     security_group_use_name_prefix = false
-     security_group_description     = "EKS managed node group complete example security group"
-     security_group_rules = {}
-     security_group_tags = {}

      tags = {
        ExtraTag = "example"
      }
    }
  }

  # Fargate Profile(s)
  fargate_profile_defaults = {
-   iam_role_additional_policies = [aws_iam_policy.additional.arn]
+   iam_role_additional_policies = {
+     additional = aws_iam_policy.additional.arn
+   }
  }

  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "kube-system"
          labels = {
            k8s-app = "kube-dns"
          }
        },
        {
          namespace = "default"
        }
      ]

      tags = {
        Owner = "test"
      }

      timeouts = {
        create = "20m"
        delete = "20m"
      }
    }
  }

  # OIDC Identity provider
  cluster_identity_providers = {
    sts = {
      client_id = "sts.amazonaws.com"
    }
  }

  # aws-auth configmap
  manage_aws_auth_configmap = true

  aws_auth_node_iam_role_arns_non_windows = [
    module.eks_managed_node_group.iam_role_arn,
    module.self_managed_node_group.iam_role_arn,
  ]
  aws_auth_fargate_profile_pod_execution_role_arns = [
    module.fargate_profile.fargate_profile_pod_execution_role_arn
  ]

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::66666666666:role/role1"
      username = "role1"
      groups   = ["system:masters"]
    },
  ]

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::66666666666:user/user1"
      username = "user1"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::66666666666:user/user2"
      username = "user2"
      groups   = ["system:masters"]
    },
  ]

  aws_auth_accounts = [
    "777777777777",
    "888888888888",
  ]

  tags = local.tags
}
```

## Terraform State Moves

The following Terraform state move commands are optional but recommended if you are providing additional IAM policies that are to be attached to IAM roles created by this module (cluster IAM role, node group IAM role, Fargate profile IAM role). Because the resources affected are `aws_iam_role_policy_attachment`, in theory, you could get away with simply applying the configuration and letting Terraform detach and re-attach the policies. However, during this brief period of update, you could experience permission failures as the policy is detached and re-attached, and therefore the state move route is recommended.

Where `"<POLICY_ARN>"` is specified, this should be replaced with the full ARN of the policy, and `"<POLICY_MAP_KEY>"` should be replaced with the key used in the `iam_role_additional_policies` map for the associated policy. For example, if you have the following`v19.x` configuration:

```hcl
  ...
  # This is demonstrating the cluster IAM role additional policies
  iam_role_additional_policies = {
    additional = aws_iam_policy.additional.arn
  }
  ...
```

The associated state move command would look similar to (albeit with your correct policy ARN):

```sh
terraform state mv 'module.eks.aws_iam_role_policy_attachment.this["arn:aws:iam::111111111111:policy/ex-complete-additional"]' 'module.eks.aws_iam_role_policy_attachment.additional["additional"]'
```

If you are not providing any additional IAM policies, no actions are required.

### Cluster IAM Role

Repeat for each policy provided in `iam_role_additional_policies`:

```sh
terraform state mv 'module.eks.aws_iam_role_policy_attachment.this["<POLICY_ARN>"]' 'module.eks.aws_iam_role_policy_attachment.additional["<POLICY_MAP_KEY>"]'
```

### EKS Managed Node Group IAM Role

Where `"<NODE_GROUP_KEY>"` is the key used in the `eks_managed_node_groups` map for the associated node group. Repeat for each policy provided in `iam_role_additional_policies` in either/or `eks_managed_node_group_defaults` or the individual node group definitions:

```sh
terraform state mv 'module.eks.module.eks_managed_node_group["<NODE_GROUP_KEY>"].aws_iam_role_policy_attachment.this["<POLICY_ARN>"]' 'module.eks.module.eks_managed_node_group["<NODE_GROUP_KEY>"].aws_iam_role_policy_attachment.additional["<POLICY_MAP_KEY>"]'
```

### Self-Managed Node Group IAM Role

Where `"<NODE_GROUP_KEY>"` is the key used in the `self_managed_node_groups` map for the associated node group. Repeat for each policy provided in `iam_role_additional_policies` in either/or `self_managed_node_group_defaults` or the individual node group definitions:

```sh
terraform state mv 'module.eks.module.self_managed_node_group["<NODE_GROUP_KEY>"].aws_iam_role_policy_attachment.this["<POLICY_ARN>"]' 'module.eks.module.self_managed_node_group["<NODE_GROUP_KEY>"].aws_iam_role_policy_attachment.additional["<POLICY_MAP_KEY>"]'
```

### Fargate Profile IAM Role

Where `"<FARGATE_PROFILE_KEY>"` is the key used in the `fargate_profiles` map for the associated profile. Repeat for each policy provided in `iam_role_additional_policies` in either/or `fargate_profile_defaults` or the individual profile definitions:

```sh
terraform state mv 'module.eks.module.fargate_profile["<FARGATE_PROFILE_KEY>"].aws_iam_role_policy_attachment.this["<POLICY_ARN>"]' 'module.eks.module.fargate_profile["<FARGATE_PROFILE_KEY>"].aws_iam_role_policy_attachment.additional["<POLICY_MAP_KEY>"]'
```
