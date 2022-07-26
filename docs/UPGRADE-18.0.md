# Upgrade from v17.x to v18.x

Please consult the `examples` directory for reference example configurations. If you find a bug, please open an issue with supporting configuration to reproduce.

Note: please see https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1744 where users have shared the steps/changes that have worked for their configurations to upgrade. Due to the numerous configuration possibilities, it is difficult to capture specific steps that will work for all; this has proven to be a useful thread to share collective information from the broader community regarding v18.x upgrades.

For most users, adding the following to your v17.x configuration will preserve the state of your cluster control plane when upgrading to v18.x:

```hcl
prefix_separator                   = ""
iam_role_name                      = $CLUSTER_NAME
cluster_security_group_name        = $CLUSTER_NAME
cluster_security_group_description = "EKS cluster security group."
```

See more information [here](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1744#issuecomment-1027359982)

## List of backwards incompatible changes

- Launch configuration support has been removed and only launch template is supported going forward. AWS is no longer adding new features back into launch configuration and their docs state [`We strongly recommend that you do not use launch configurations. They do not provide full functionality for Amazon EC2 Auto Scaling or Amazon EC2. We provide information about launch configurations for customers who have not yet migrated from launch configurations to launch templates.`](https://docs.aws.amazon.com/autoscaling/ec2/userguide/LaunchConfiguration.html)
- Support for managing aws-auth configmap has been removed. This change also removes the dependency on the Kubernetes Terraform provider, the local dependency on aws-iam-authenticator for users, as well as the reliance on the forked http provider to wait and poll on cluster creation. To aid users in this change, an output variable `aws_auth_configmap_yaml` has been provided which renders the aws-auth configmap necessary to support at least the IAM roles used by the module (additional mapRoles/mapUsers definitions to be provided by users)
- Support for managing kubeconfig and its associated `local_file` resources have been removed; users are able to use the awscli provided `aws eks update-kubeconfig --name <cluster_name>` to update their local kubeconfig as necessary
- The terminology used in the module has been modified to reflect that used by the [AWS documentation](https://docs.aws.amazon.com/eks/latest/userguide/eks-compute.html).
  - [AWS EKS Managed Node Group](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html), `eks_managed_node_groups`, was previously referred to as simply node group, `node_groups`
  - [Self Managed Node Group Group](https://docs.aws.amazon.com/eks/latest/userguide/worker.html), `self_managed_node_groups`, was previously referred to as worker group, `worker_groups`
  - [AWS Fargate Profile](https://docs.aws.amazon.com/eks/latest/userguide/fargate.html), `fargate_profiles`, remains unchanged in terms of naming and terminology
- The three different node group types supported by AWS and the module have been refactored into standalone sub-modules that are both used by the root `eks` module as well as available for individual, standalone consumption if desired.
  - The previous `node_groups` sub-module is now named `eks-managed-node-group` and provisions a single AWS EKS Managed Node Group per sub-module definition (previous version utilized `for_each` to create 0 or more node groups)
    - Additional changes for the `eks-managed-node-group` sub-module over the previous `node_groups` module include:
      - Variable name changes defined in section `Variable and output changes` below
      - Support for nearly full control of the IAM role created, or provide the ARN of an existing IAM role, has been added
      - Support for nearly full control of the security group created, or provide the ID of an existing security group, has been added
      - User data has been revamped and all user data logic moved to the `_user_data` internal sub-module; the local `userdata.sh.tpl` has been removed entirely
  - The previous `fargate` sub-module is now named `fargate-profile` and provisions a single AWS EKS Fargate Profile per sub-module definition (previous version utilized `for_each` to create 0 or more profiles)
    - Additional changes for the `fargate-profile` sub-module over the previous `fargate` module include:
      - Variable name changes defined in section `Variable and output changes` below
      - Support for nearly full control of the IAM role created, or provide the ARN of an existing IAM role, has been added
      - Similar to the `eks_managed_node_group_defaults` and `self_managed_node_group_defaults`, a `fargate_profile_defaults` has been provided to allow users to control the default configurations for the Fargate profiles created
  - A sub-module for `self-managed-node-group` has been created and provisions a single self managed node group (autoscaling group) per sub-module definition
    - Additional changes for the `self-managed-node-group` sub-module over the previous `node_groups` variable include:
      - The underlying autoscaling group and launch template have been updated to more closely match that of the [`terraform-aws-autoscaling`](https://github.com/terraform-aws-modules/terraform-aws-autoscaling) module and the features it offers
      - The previous iteration used a count over a list of node group definitions which was prone to disruptive updates; this is now replaced with a map/for_each to align with that of the EKS managed node group and Fargate profile behaviors/style
- The user data configuration supported across the module has been completely revamped. A new `_user_data` internal sub-module has been created to consolidate all user data configuration in one location which provides better support for testability (via the [`examples/user_data`](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/user_data) example). The new sub-module supports nearly all possible combinations including the ability to allow users to provide their own user data template which will be rendered by the module. See the `examples/user_data` example project for the full plethora of example configuration possibilities and more details on the logic of the design can be found in the [`modules/_user_data`](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/modules/_user_data_) directory.
- Resource name changes may cause issues with existing resources. For example, security groups and IAM roles cannot be renamed, they must be recreated. Recreation of these resources may also trigger a recreation of the cluster. To use the legacy (< 18.x) resource naming convention, set `prefix_separator` to "".
- Security group usage has been overhauled to provide only the bare minimum network connectivity required to launch a bare bones cluster. See the [security group documentation section](https://github.com/terraform-aws-modules/terraform-aws-eks#security-groups) for more details. Users upgrading to v18.x will want to review the rules they have in place today versus the rules provisioned by the v18.x module and ensure to make any necessary adjustments for their specific workload.

## Additional changes

### Added

- Support for AWS EKS Addons has been added
- Support for AWS EKS Cluster Identity Provider Configuration has been added
- AWS Terraform provider minimum required version has been updated to 3.64 to support the changes made and additional resources supported
- An example `user_data` project has been added to aid in demonstrating, testing, and validating the various methods of configuring user data with the `_user_data` sub-module as well as the root `eks` module
- Template for rendering the aws-auth configmap output - `aws_auth_cm.tpl`
- Template for Bottlerocket OS user data bootstrapping - `bottlerocket_user_data.tpl`

### Modified

- The previous `fargate` example has been renamed to `fargate_profile`
- The previous `irsa` and `instance_refresh` examples have been merged into one example `irsa_autoscale_refresh`
- The previous `managed_node_groups` example has been renamed to `self_managed_node_group`
- The previously hardcoded EKS OIDC root CA thumbprint value and variable has been replaced with a `tls_certificate` data source that refers to the cluster OIDC issuer url. Thumbprint values should remain unchanged however
- Individual cluster security group resources have been replaced with a single security group resource that takes a map of rules as input. The default ingress/egress rules have had their scope reduced in order to provide the bare minimum of access to permit successful cluster creation and allow users to opt in to any additional network access as needed for a better security posture. This means the `0.0.0.0/0` egress rule has been removed, instead TCP/443 and TCP/10250 egress rules to the node group security group are used instead
- The Linux/bash user data template has been updated to include the bare minimum necessary for bootstrapping AWS EKS Optimized AMI derivative nodes with provisions for providing additional user data and configurations; was named `userdata.sh.tpl` and is now named `linux_user_data.tpl`
- The Windows user data template has been renamed from `userdata_windows.tpl` to `windows_user_data.tpl`

### Removed

- Miscellaneous documents on how to configure Kubernetes cluster internals have been removed. Documentation related to how to configure the AWS EKS Cluster and its supported infrastructure resources provided by the module are supported, while cluster internal configuration is out of scope for this project
- The previous `bottlerocket` example has been removed in favor of demonstrating the use and configuration of Bottlerocket nodes via the respective `eks_managed_node_group` and `self_managed_node_group` examples
- The previous `launch_template` and `launch_templates_with_managed_node_groups` examples have been removed; only launch templates are now supported (default) and launch configuration support has been removed
- The previous `secrets_encryption` example has been removed; the functionality has been demonstrated in several of the new examples rendering this standalone example redundant
- The additional, custom IAM role policy for the cluster role has been removed. The permissions are either now provided in the attached managed AWS permission policies used or are no longer required
- The `kubeconfig.tpl` template; kubeconfig management is no longer supported under this module
- The HTTP Terraform provider (forked copy) dependency has been removed

### Variable and output changes

1. Removed variables:

    - `cluster_create_timeout`, `cluster_update_timeout`, and `cluster_delete_timeout` have been replaced with `cluster_timeouts`
    - `kubeconfig_name`
    - `kubeconfig_output_path`
    - `kubeconfig_file_permission`
    - `kubeconfig_api_version`
    - `kubeconfig_aws_authenticator_command`
    - `kubeconfig_aws_authenticator_command_args`
    - `kubeconfig_aws_authenticator_additional_args`
    - `kubeconfig_aws_authenticator_env_variables`
    - `write_kubeconfig`
    - `default_platform`
    - `manage_aws_auth`
    - `aws_auth_additional_labels`
    - `map_accounts`
    - `map_roles`
    - `map_users`
    - `fargate_subnets`
    - `worker_groups_launch_template`
    - `worker_security_group_id`
    - `worker_ami_name_filter`
    - `worker_ami_name_filter_windows`
    - `worker_ami_owner_id`
    - `worker_ami_owner_id_windows`
    - `worker_additional_security_group_ids`
    - `worker_sg_ingress_from_port`
    - `workers_additional_policies`
    - `worker_create_security_group`
    - `worker_create_initial_lifecycle_hooks`
    - `worker_create_cluster_primary_security_group_rules`
    - `cluster_create_endpoint_private_access_sg_rule`
    - `cluster_endpoint_private_access_cidrs`
    - `cluster_endpoint_private_access_sg`
    - `manage_worker_iam_resources`
    - `workers_role_name`
    - `attach_worker_cni_policy`
    - `eks_oidc_root_ca_thumbprint`
    - `create_fargate_pod_execution_role`
    - `fargate_pod_execution_role_name`
    - `cluster_egress_cidrs`
    - `workers_egress_cidrs`
    - `wait_for_cluster_timeout`
    - EKS Managed Node Group sub-module (was `node_groups`)
      - `default_iam_role_arn`
      - `workers_group_defaults`
      - `worker_security_group_id`
      - `node_groups_defaults`
      - `node_groups`
      - `ebs_optimized_not_supported`
    - Fargate profile sub-module (was `fargate`)
      - `create_eks` and `create_fargate_pod_execution_role` have been replaced with simply `create`

2. Renamed variables:

    - `create_eks` -> `create`
    - `subnets` -> `subnet_ids`
    - `cluster_create_security_group` -> `create_cluster_security_group`
    - `cluster_log_retention_in_days` -> `cloudwatch_log_group_retention_in_days`
    - `cluster_log_kms_key_id` -> `cloudwatch_log_group_kms_key_id`
    - `manage_cluster_iam_resources` -> `create_iam_role`
    - `cluster_iam_role_name` -> `iam_role_name`
    - `permissions_boundary` -> `iam_role_permissions_boundary`
    - `iam_path` -> `iam_role_path`
    - `pre_userdata` -> `pre_bootstrap_user_data`
    - `additional_userdata` -> `post_bootstrap_user_data`
    - `worker_groups` -> `self_managed_node_groups`
    - `workers_group_defaults` -> `self_managed_node_group_defaults`
    - `node_groups` -> `eks_managed_node_groups`
    - `node_groups_defaults` -> `eks_managed_node_group_defaults`
    - EKS Managed Node Group sub-module (was `node_groups`)
      - `create_eks` -> `create`
      - `worker_additional_security_group_ids` -> `vpc_security_group_ids`
    - Fargate profile sub-module
      - `fargate_pod_execution_role_name` -> `name`
      - `create_fargate_pod_execution_role` -> `create_iam_role`
      - `subnets` -> `subnet_ids`
      - `iam_path` -> `iam_role_path`
      - `permissions_boundary` -> `iam_role_permissions_boundary`

3. Added variables:

    - `cluster_additional_security_group_ids` added to allow users to add additional security groups to the cluster as needed
    - `cluster_security_group_name`
    - `cluster_security_group_use_name_prefix` added to allow users to use either the name as specified or default to using the name specified as a prefix
    - `cluster_security_group_description`
    - `cluster_security_group_additional_rules`
    - `cluster_security_group_tags`
    - `create_cloudwatch_log_group` added in place of the logic that checked if any cluster log types were enabled to allow users to opt in as they see fit
    - `create_node_security_group` added to create single security group that connects node groups and cluster in central location
    - `node_security_group_id`
    - `node_security_group_name`
    - `node_security_group_use_name_prefix`
    - `node_security_group_description`
    - `node_security_group_additional_rules`
    - `node_security_group_tags`
    - `iam_role_arn`
    - `iam_role_use_name_prefix`
    - `iam_role_description`
    - `iam_role_additional_policies`
    - `iam_role_tags`
    - `cluster_addons`
    - `cluster_identity_providers`
    - `fargate_profile_defaults`
    - `prefix_separator` added to support legacy behavior of not having a prefix separator
    - EKS Managed Node Group sub-module (was `node_groups`)
      - `platform`
      - `enable_bootstrap_user_data`
      - `pre_bootstrap_user_data`
      - `post_bootstrap_user_data`
      - `bootstrap_extra_args`
      - `user_data_template_path`
      - `create_launch_template`
      - `launch_template_name`
      - `launch_template_use_name_prefix`
      - `description`
      - `ebs_optimized`
      - `ami_id`
      - `key_name`
      - `launch_template_default_version`
      - `update_launch_template_default_version`
      - `disable_api_termination`
      - `kernel_id`
      - `ram_disk_id`
      - `block_device_mappings`
      - `capacity_reservation_specification`
      - `cpu_options`
      - `credit_specification`
      - `elastic_gpu_specifications`
      - `elastic_inference_accelerator`
      - `enclave_options`
      - `instance_market_options`
      - `license_specifications`
      - `metadata_options`
      - `enable_monitoring`
      - `network_interfaces`
      - `placement`
      - `min_size`
      - `max_size`
      - `desired_size`
      - `use_name_prefix`
      - `ami_type`
      - `ami_release_version`
      - `capacity_type`
      - `disk_size`
      - `force_update_version`
      - `instance_types`
      - `labels`
      - `cluster_version`
      - `launch_template_version`
      - `remote_access`
      - `taints`
      - `update_config`
      - `timeouts`
      - `create_security_group`
      - `security_group_name`
      - `security_group_use_name_prefix`
      - `security_group_description`
      - `vpc_id`
      - `security_group_rules`
      - `cluster_security_group_id`
      - `security_group_tags`
      - `create_iam_role`
      - `iam_role_arn`
      - `iam_role_name`
      - `iam_role_use_name_prefix`
      - `iam_role_path`
      - `iam_role_description`
      - `iam_role_permissions_boundary`
      - `iam_role_additional_policies`
      - `iam_role_tags`
    - Fargate profile sub-module (was `fargate`)
      - `iam_role_arn` (for if `create_iam_role` is `false` to bring your own externally created role)
      - `iam_role_name`
      - `iam_role_use_name_prefix`
      - `iam_role_description`
      - `iam_role_additional_policies`
      - `iam_role_tags`
      - `selectors`
      - `timeouts`

4. Removed outputs:

    - `cluster_version`
    - `kubeconfig`
    - `kubeconfig_filename`
    - `workers_asg_arns`
    - `workers_asg_names`
    - `workers_user_data`
    - `workers_default_ami_id`
    - `workers_default_ami_id_windows`
    - `workers_launch_template_ids`
    - `workers_launch_template_arns`
    - `workers_launch_template_latest_versions`
    - `worker_security_group_id`
    - `worker_iam_instance_profile_arns`
    - `worker_iam_instance_profile_names`
    - `worker_iam_role_name`
    - `worker_iam_role_arn`
    - `fargate_profile_ids`
    - `fargate_profile_arns`
    - `fargate_iam_role_name`
    - `fargate_iam_role_arn`
    - `node_groups`
    - `security_group_rule_cluster_https_worker_ingress`
    - EKS Managed Node Group sub-module (was `node_groups`)
      - `node_groups`
      - `aws_auth_roles`
    - Fargate profile sub-module (was `fargate`)
      - `aws_auth_roles`

5. Renamed outputs:

    - `config_map_aws_auth` -> `aws_auth_configmap_yaml`
    - Fargate profile sub-module (was `fargate`)
      - `fargate_profile_ids` -> `fargate_profile_id`
      - `fargate_profile_arns` -> `fargate_profile_arn`

6. Added outputs:

    - `cluster_platform_version`
    - `cluster_status`
    - `cluster_security_group_arn`
    - `cluster_security_group_id`
    - `node_security_group_arn`
    - `node_security_group_id`
    - `cluster_iam_role_unique_id`
    - `cluster_addons`
    - `cluster_identity_providers`
    - `fargate_profiles`
    - `eks_managed_node_groups`
    - `self_managed_node_groups`
    - EKS Managed Node Group sub-module (was `node_groups`)
      - `launch_template_id`
      - `launch_template_arn`
      - `launch_template_latest_version`
      - `node_group_arn`
      - `node_group_id`
      - `node_group_resources`
      - `node_group_status`
      - `security_group_arn`
      - `security_group_id`
      - `iam_role_name`
      - `iam_role_arn`
      - `iam_role_unique_id`
    - Fargate profile sub-module (was `fargate`)
      - `iam_role_unique_id`
      - `fargate_profile_status`

## Upgrade Migrations

### Before 17.x Example

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 17.0"

  cluster_name                    = local.name
  cluster_version                 = local.cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnets

  # Managed Node Groups
  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 50
  }

  node_groups = {
    node_group = {
      min_capacity     = 1
      max_capacity     = 10
      desired_capacity = 1

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"

      update_config = {
        max_unavailable_percentage = 50
      }

      k8s_labels = {
        Environment = "test"
        GithubRepo  = "terraform-aws-eks"
        GithubOrg   = "terraform-aws-modules"
      }

      taints = [
        {
          key    = "dedicated"
          value  = "gpuGroup"
          effect = "NO_SCHEDULE"
        }
      ]

      additional_tags = {
        ExtraTag = "example"
      }
    }
  }

  # Worker groups
  worker_additional_security_group_ids = [aws_security_group.additional.id]

  worker_groups_launch_template = [
    {
      name                    = "worker-group"
      override_instance_types = ["m5.large", "m5a.large", "m5d.large", "m5ad.large"]
      spot_instance_pools     = 4
      asg_max_size            = 5
      asg_desired_capacity    = 2
      kubelet_extra_args      = "--node-labels=node.kubernetes.io/lifecycle=spot"
      public_ip               = true
    },
  ]

  # Fargate
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

  tags = {
    Environment = "test"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }
}
```

### After 18.x Example

```hcl
module "cluster_after" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name                    = local.name
  cluster_version                 = local.cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 50
  }

  eks_managed_node_groups = {
    node_group = {
      min_size     = 1
      max_size     = 10
      desired_size = 1

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"

      update_config = {
        max_unavailable_percentage = 50
      }

      labels = {
        Environment = "test"
        GithubRepo  = "terraform-aws-eks"
        GithubOrg   = "terraform-aws-modules"
      }

      taints = [
        {
          key    = "dedicated"
          value  = "gpuGroup"
          effect = "NO_SCHEDULE"
        }
      ]

      tags = {
        ExtraTag = "example"
      }
    }
  }

  self_managed_node_group_defaults = {
    vpc_security_group_ids = [aws_security_group.additional.id]
  }

  self_managed_node_groups = {
    worker_group = {
      name = "worker-group"

      min_size      = 1
      max_size      = 5
      desired_size  = 2
      instance_type = "m4.large"

      bootstrap_extra_args = "--kubelet-extra-args '--node-labels=node.kubernetes.io/lifecycle=spot'"

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            delete_on_termination = true
            encrypted             = false
            volume_size           = 100
            volume_type           = "gp2"
          }

        }
      }

      use_mixed_instances_policy = true
      mixed_instances_policy = {
        instances_distribution = {
          spot_instance_pools = 4
        }

        override = [
          { instance_type = "m5.large" },
          { instance_type = "m5a.large" },
          { instance_type = "m5d.large" },
          { instance_type = "m5ad.large" },
        ]
      }
    }
  }

  # Fargate
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

  tags = {
    Environment = "test"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }
}
```

### Diff of before <> after

```diff
 module "eks" {
   source  = "terraform-aws-modules/eks/aws"
-  version = "~> 17.0"
+  version = "~> 18.0"

   cluster_name                    = local.name
   cluster_version                 = local.cluster_version
   cluster_endpoint_private_access = true
   cluster_endpoint_public_access  = true

   vpc_id  = module.vpc.vpc_id
-  subnets = module.vpc.private_subnets
+  subnet_ids = module.vpc.private_subnets

-  # Managed Node Groups
-  node_groups_defaults = {
+  eks_managed_node_group_defaults = {
     ami_type  = "AL2_x86_64"
     disk_size = 50
   }

-  node_groups = {
+  eks_managed_node_groups = {
     node_group = {
-      min_capacity     = 1
-      max_capacity     = 10
-      desired_capacity = 1
+      min_size     = 1
+      max_size     = 10
+      desired_size = 1

       instance_types = ["t3.large"]
       capacity_type  = "SPOT"

       update_config = {
         max_unavailable_percentage = 50
       }

-      k8s_labels = {
+      labels = {
         Environment = "test"
         GithubRepo  = "terraform-aws-eks"
         GithubOrg   = "terraform-aws-modules"
       }

       taints = [
         {
           key    = "dedicated"
           value  = "gpuGroup"
           effect = "NO_SCHEDULE"
         }
       ]

-      additional_tags = {
+      tags = {
         ExtraTag = "example"
       }
     }
   }

-  # Worker groups
-  worker_additional_security_group_ids = [aws_security_group.additional.id]
-
-  worker_groups_launch_template = [
-    {
-      name                    = "worker-group"
-      override_instance_types = ["m5.large", "m5a.large", "m5d.large", "m5ad.large"]
-      spot_instance_pools     = 4
-      asg_max_size            = 5
-      asg_desired_capacity    = 2
-      kubelet_extra_args      = "--node-labels=node.kubernetes.io/lifecycle=spot"
-      public_ip               = true
-    },
-  ]
+  self_managed_node_group_defaults = {
+    vpc_security_group_ids = [aws_security_group.additional.id]
+  }
+
+  self_managed_node_groups = {
+    worker_group = {
+      name = "worker-group"
+
+      min_size      = 1
+      max_size      = 5
+      desired_size  = 2
+      instance_type = "m4.large"
+
+      bootstrap_extra_args = "--kubelet-extra-args '--node-labels=node.kubernetes.io/lifecycle=spot'"
+
+      block_device_mappings = {
+        xvda = {
+          device_name = "/dev/xvda"
+          ebs = {
+            delete_on_termination = true
+            encrypted             = false
+            volume_size           = 100
+            volume_type           = "gp2"
+          }
+
+        }
+      }
+
+      use_mixed_instances_policy = true
+      mixed_instances_policy = {
+        instances_distribution = {
+          spot_instance_pools = 4
+        }
+
+        override = [
+          { instance_type = "m5.large" },
+          { instance_type = "m5a.large" },
+          { instance_type = "m5d.large" },
+          { instance_type = "m5ad.large" },
+        ]
+      }
+    }
+  }

   # Fargate
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

   tags = {
     Environment = "test"
     GithubRepo  = "terraform-aws-eks"
     GithubOrg   = "terraform-aws-modules"
   }
 }

```

### Attaching an IAM role policy to a Fargate profile

#### Before 17.x

```hcl
resource "aws_iam_role_policy_attachment" "default" {
  role       = module.eks.fargate_iam_role_name
  policy_arn = aws_iam_policy.default.arn
}
```

#### After 18.x

```hcl
# Attach the policy to an "example" Fargate profile
resource "aws_iam_role_policy_attachment" "default" {
  role       = module.eks.fargate_profiles["example"].iam_role_name
  policy_arn = aws_iam_policy.default.arn
}
```

Or:

```hcl
# Attach the policy to all Fargate profiles
resource "aws_iam_role_policy_attachment" "default" {
  for_each = module.eks.fargate_profiles

  role       = each.value.iam_role_name
  policy_arn = aws_iam_policy.default.arn
}
```
