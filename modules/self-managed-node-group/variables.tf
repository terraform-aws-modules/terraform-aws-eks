variable "create" {
  description = "Determines whether to create self managed node group or not"
  type        = bool
  default     = true
  nullable    = false
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration"
  type        = string
  default     = null
}

variable "partition" {
  description = "The AWS partition - pass through value to reduce number of GET requests from data sources"
  type        = string
  default     = ""
}

variable "account_id" {
  description = "The AWS account ID - pass through value to reduce number of GET requests from data sources"
  type        = string
  default     = ""
}

################################################################################
# User Data
################################################################################

variable "cluster_name" {
  description = "Name of associated EKS cluster"
  type        = string
  default     = ""
}

variable "cluster_endpoint" {
  description = "Endpoint of associated EKS cluster"
  type        = string
  default     = null
}

variable "cluster_auth_base64" {
  description = "Base64 encoded CA of associated EKS cluster"
  type        = string
  default     = null
}

variable "cluster_service_cidr" {
  description = "The CIDR block (IPv4 or IPv6) used by the cluster to assign Kubernetes service IP addresses. This is derived from the cluster itself"
  type        = string
  default     = null
}

variable "cluster_ip_family" {
  description = "The IP family used to assign Kubernetes pod and service addresses. Valid values are `ipv4` (default) and `ipv6`"
  type        = string
  default     = null
}

variable "additional_cluster_dns_ips" {
  description = "Additional DNS IP addresses to use for the cluster. Only used when `ami_type` = `BOTTLEROCKET_*`"
  type        = list(string)
  default     = null
}

variable "pre_bootstrap_user_data" {
  description = "User data that is injected into the user data script ahead of the EKS bootstrap script. Not used when `ami_type` = `BOTTLEROCKET_*`"
  type        = string
  default     = null
}

variable "post_bootstrap_user_data" {
  description = "User data that is appended to the user data script after of the EKS bootstrap script. Not used when `ami_type` = `BOTTLEROCKET_*`"
  type        = string
  default     = null
}

variable "bootstrap_extra_args" {
  description = "Additional arguments passed to the bootstrap script. When `ami_type` = `BOTTLEROCKET_*`; these are additional [settings](https://github.com/bottlerocket-os/bottlerocket#settings) that are provided to the Bottlerocket user data"
  type        = string
  default     = null
}

variable "user_data_template_path" {
  description = "Path to a local, custom user data template file to use when rendering user data"
  type        = string
  default     = null
}

variable "cloudinit_pre_nodeadm" {
  description = "Array of cloud-init document parts that are created before the nodeadm document part"
  type = list(object({
    content      = string
    content_type = optional(string)
    filename     = optional(string)
    merge_type   = optional(string)
  }))
  default = null
}

variable "cloudinit_post_nodeadm" {
  description = "Array of cloud-init document parts that are created after the nodeadm document part"
  type = list(object({
    content      = string
    content_type = optional(string)
    filename     = optional(string)
    merge_type   = optional(string)
  }))
  default = null
}

################################################################################
# Launch template
################################################################################

variable "create_launch_template" {
  description = "Determines whether to create launch template or not"
  type        = bool
  default     = true
  nullable    = false
}

variable "launch_template_id" {
  description = "The ID of an existing launch template to use. Required when `create_launch_template` = `false`"
  type        = string
  default     = ""
}

variable "launch_template_name" {
  description = "Name of launch template to be created"
  type        = string
  default     = null
}

variable "launch_template_use_name_prefix" {
  description = "Determines whether to use `launch_template_name` as is or create a unique name beginning with the `launch_template_name` as the prefix"
  type        = bool
  default     = true
  nullable    = false
}

variable "launch_template_description" {
  description = "Description of the launch template"
  type        = string
  default     = null
}

variable "launch_template_default_version" {
  description = "Default Version of the launch template"
  type        = string
  default     = null
}

variable "update_launch_template_default_version" {
  description = "Whether to update Default Version each update. Conflicts with `launch_template_default_version`"
  type        = bool
  default     = true
  nullable    = false
}

variable "disable_api_termination" {
  description = "If true, enables EC2 instance termination protection"
  type        = bool
  default     = null
}

variable "instance_initiated_shutdown_behavior" {
  description = "Shutdown behavior for the instance. Can be `stop` or `terminate`. (Default: `stop`)"
  type        = string
  default     = null
}

variable "kernel_id" {
  description = "The kernel ID"
  type        = string
  default     = null
}

variable "ram_disk_id" {
  description = "The ID of the ram disk"
  type        = string
  default     = null
}

variable "block_device_mappings" {
  description = "Specify volumes to attach to the instance besides the volumes specified by the AMI"
  type = map(object({
    device_name = optional(string)
    ebs = optional(object({
      delete_on_termination      = optional(bool)
      encrypted                  = optional(bool)
      iops                       = optional(number)
      kms_key_id                 = optional(string)
      snapshot_id                = optional(string)
      throughput                 = optional(number)
      volume_initialization_rate = optional(number)
      volume_size                = optional(number)
      volume_type                = optional(string)
    }))
    no_device    = optional(string)
    virtual_name = optional(string)
  }))
  default = null
}

variable "capacity_reservation_specification" {
  description = "Targeting for EC2 capacity reservations"
  type = object({
    capacity_reservation_preference = optional(string)
    capacity_reservation_target = optional(object({
      capacity_reservation_id                 = optional(string)
      capacity_reservation_resource_group_arn = optional(string)
    }))
  })
  default = null
}

variable "cpu_options" {
  description = "The CPU options for the instance"
  type = object({
    amd_sev_snp      = optional(string)
    core_count       = optional(number)
    threads_per_core = optional(number)
  })
  default = null
}

variable "credit_specification" {
  description = "Customize the credit specification of the instance"
  type = object({
    cpu_credits = optional(string)
  })
  default = null
}

variable "enclave_options" {
  description = "Enable Nitro Enclaves on launched instances"
  type = object({
    enabled = optional(bool)
  })
  default = null
}

variable "instance_market_options" {
  description = "The market (purchasing) option for the instance"
  type = object({
    market_type = optional(string)
    spot_options = optional(object({
      block_duration_minutes         = optional(number)
      instance_interruption_behavior = optional(string)
      max_price                      = optional(string)
      spot_instance_type             = optional(string)
      valid_until                    = optional(string)
    }))
  })
  default = null
}

variable "maintenance_options" {
  description = "The maintenance options for the instance"
  type = object({
    auto_recovery = optional(string)
  })
  default = null
}

variable "license_specifications" {
  description = "A list of license specifications to associate with"
  type = list(object({
    license_configuration_arn = string
  }))
  default = null
}

variable "network_interfaces" {
  description = "Customize network interfaces to be attached at instance boot time"
  type = list(object({
    associate_carrier_ip_address = optional(bool)
    associate_public_ip_address  = optional(bool)
    connection_tracking_specification = optional(object({
      tcp_established_timeout = optional(number)
      udp_stream_timeout      = optional(number)
      udp_timeout             = optional(number)
    }))
    delete_on_termination = optional(bool)
    description           = optional(string)
    device_index          = optional(number)
    ena_srd_specification = optional(object({
      ena_srd_enabled = optional(bool)
      ena_srd_udp_specification = optional(object({
        ena_srd_udp_enabled = optional(bool)
      }))
    }))
    interface_type       = optional(string)
    ipv4_address_count   = optional(number)
    ipv4_addresses       = optional(list(string))
    ipv4_prefix_count    = optional(number)
    ipv4_prefixes        = optional(list(string))
    ipv6_address_count   = optional(number)
    ipv6_addresses       = optional(list(string))
    ipv6_prefix_count    = optional(number)
    ipv6_prefixes        = optional(list(string))
    network_card_index   = optional(number)
    network_interface_id = optional(string)
    primary_ipv6         = optional(bool)
    private_ip_address   = optional(string)
    security_groups      = optional(list(string), [])
    subnet_id            = optional(string)
  }))
  default  = []
  nullable = false
}

variable "placement" {
  description = "The placement of the instance"
  type = object({
    affinity                = optional(string)
    availability_zone       = optional(string)
    group_name              = optional(string)
    host_id                 = optional(string)
    host_resource_group_arn = optional(string)
    partition_number        = optional(number)
    spread_domain           = optional(string)
    tenancy                 = optional(string)
  })
  default = null
}

variable "create_placement_group" {
  description = "Determines whether a placement group is created & used by the node group"
  type        = bool
  default     = false
  nullable    = false
}

variable "private_dns_name_options" {
  description = "The options for the instance hostname. The default values are inherited from the subnet"
  type = object({
    enable_resource_name_dns_aaaa_record = optional(bool)
    enable_resource_name_dns_a_record    = optional(bool)
    hostname_type                        = optional(string)
  })
  default = null
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  type        = bool
  default     = null
}

variable "ami_id" {
  description = "The AMI from which to launch the instance"
  type        = string
  default     = ""
}

variable "ami_type" {
  description = "Type of Amazon Machine Image (AMI) associated with the node group. See the [AWS documentation](https://docs.aws.amazon.com/eks/latest/APIReference/API_Nodegroup.html#AmazonEKS-Type-Nodegroup-amiType) for valid values"
  type        = string
  default     = "AL2023_x86_64_STANDARD"
  nullable    = false
}

variable "kubernetes_version" {
  description = "Kubernetes cluster version - used to lookup default AMI ID if one is not provided"
  type        = string
  default     = null
}

variable "instance_requirements" {
  description = "The attribute requirements for the type of instance. If present then `instance_type` cannot be present"
  type = object({
    accelerator_count = optional(object({
      max = optional(number)
      min = optional(number)
    }))
    accelerator_manufacturers = optional(list(string))
    accelerator_names         = optional(list(string))
    accelerator_total_memory_mib = optional(object({
      max = optional(number)
      min = optional(number)
    }))
    accelerator_types      = optional(list(string))
    allowed_instance_types = optional(list(string))
    bare_metal             = optional(string)
    baseline_ebs_bandwidth_mbps = optional(object({
      max = optional(number)
      min = optional(number)
    }))
    burstable_performance                                   = optional(string)
    cpu_manufacturers                                       = optional(list(string))
    excluded_instance_types                                 = optional(list(string))
    instance_generations                                    = optional(list(string))
    local_storage                                           = optional(string)
    local_storage_types                                     = optional(list(string))
    max_spot_price_as_percentage_of_optimal_on_demand_price = optional(number)
    memory_gib_per_vcpu = optional(object({
      max = optional(number)
      min = optional(number)
    }))
    memory_mib = optional(object({
      max = optional(number)
      min = optional(number)
    }))
    network_bandwidth_gbps = optional(object({
      max = optional(number)
      min = optional(number)
    }))
    network_interface_count = optional(object({
      max = optional(number)
      min = optional(number)
    }))
    on_demand_max_price_percentage_over_lowest_price = optional(number)
    require_hibernate_support                        = optional(bool)
    spot_max_price_percentage_over_lowest_price      = optional(number)
    total_local_storage_gb = optional(object({
      max = optional(number)
      min = optional(number)
    }))
    vcpu_count = optional(object({
      max = optional(number)
      min = string
    }))
  })
  default = null
}

variable "instance_type" {
  description = "The type of the instance to launch"
  type        = string
  default     = "m6i.large"
  nullable    = false
}

variable "key_name" {
  description = "The key name that should be used for the instance"
  type        = string
  default     = null
}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate"
  type        = list(string)
  default     = []
  nullable    = false
}

variable "cluster_primary_security_group_id" {
  description = "The ID of the EKS cluster primary security group to associate with the instance(s). This is the security group that is automatically created by the EKS service"
  type        = string
  default     = null
}

variable "enable_monitoring" {
  description = "Enables/disables detailed monitoring"
  type        = bool
  default     = false
  nullable    = false
}

variable "enable_efa_support" {
  description = "Determines whether to enable Elastic Fabric Adapter (EFA) support"
  type        = bool
  default     = false
  nullable    = false
}

variable "enable_efa_only" {
  description = "Determines whether to enable EFA (`false`, default) or EFA and EFA-only (`true`) network interfaces. Note: requires vpc-cni version `v1.18.4` or later"
  type        = bool
  default     = true
  nullable    = false
}

variable "efa_indices" {
  description = "The indices of the network interfaces that should be EFA-enabled. Only valid when `enable_efa_support` = `true`"
  type        = list(number)
  default     = [0]
  nullable    = false
}

variable "metadata_options" {
  description = "Customize the metadata options for the instance"
  type = object({
    http_endpoint               = optional(string, "enabled")
    http_protocol_ipv6          = optional(string)
    http_put_response_hop_limit = optional(number, 1)
    http_tokens                 = optional(string, "required")
    instance_metadata_tags      = optional(string)
  })
  default = {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }
  nullable = false
}

variable "launch_template_tags" {
  description = "A map of additional tags to add to the tag_specifications of launch template created"
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "tag_specifications" {
  description = "The tags to apply to the resources during launch"
  type        = list(string)
  default     = ["instance", "volume", "network-interface"]
  nullable    = false
}

################################################################################
# Autoscaling group
################################################################################

variable "create_autoscaling_group" {
  description = "Determines whether to create autoscaling group or not"
  type        = bool
  default     = true
  nullable    = false
}

variable "name" {
  description = "Name of the Self managed Node Group"
  type        = string
  default     = ""
}

variable "use_name_prefix" {
  description = "Determines whether to use `name` as is or create a unique name beginning with the `name` as the prefix"
  type        = bool
  default     = true
  nullable    = false
}

variable "launch_template_version" {
  description = "Launch template version. Can be version number, `$Latest`, or `$Default`"
  type        = string
  default     = null
}

variable "availability_zones" {
  description = "A list of one or more availability zones for the group. Used for EC2-Classic and default subnets when not specified with `subnet_ids` argument. Conflicts with `subnet_ids`"
  type        = list(string)
  default     = null
}

variable "subnet_ids" {
  description = "A list of subnet IDs to launch resources in. Subnets automatically determine which availability zones the group will reside. Conflicts with `availability_zones`"
  type        = list(string)
  default     = null
}

variable "min_size" {
  description = "The minimum size of the autoscaling group"
  type        = number
  default     = 1
  nullable    = false
}

variable "max_size" {
  description = "The maximum size of the autoscaling group"
  type        = number
  default     = 3
  nullable    = false
}

variable "desired_size" {
  description = "The number of Amazon EC2 instances that should be running in the autoscaling group"
  type        = number
  default     = 1
  nullable    = false
}

variable "desired_size_type" {
  description = "The unit of measurement for the value specified for `desired_size`. Supported for attribute-based instance type selection only. Valid values: `units`, `vcpu`, `memory-mib`"
  type        = string
  default     = null
}

variable "ignore_failed_scaling_activities" {
  description = "Whether to ignore failed Auto Scaling scaling activities while waiting for capacity"
  type        = bool
  default     = null
}

variable "context" {
  description = "Reserved"
  type        = string
  default     = null
}

variable "capacity_rebalance" {
  description = "Indicates whether capacity rebalance is enabled"
  type        = bool
  default     = null
}

variable "default_instance_warmup" {
  description = "Amount of time, in seconds, until a newly launched instance can contribute to the Amazon CloudWatch metrics. This delay lets an instance finish initializing before Amazon EC2 Auto Scaling aggregates instance metrics, resulting in more reliable usage data"
  type        = number
  default     = null
}

variable "protect_from_scale_in" {
  description = "Allows setting instance protection. The autoscaling group will not select instances with this setting for termination during scale in events"
  type        = bool
  default     = false
  nullable    = false
}

variable "placement_group" {
  description = "The name of the placement group into which you'll launch your instances"
  type        = string
  default     = null
}

variable "health_check_type" {
  description = "`EC2` or `ELB`. Controls how health checking is done"
  type        = string
  default     = null
}

variable "health_check_grace_period" {
  description = "Time (in seconds) after instance comes into service before checking health"
  type        = number
  default     = null
}

variable "force_delete" {
  description = "Allows deleting the Auto Scaling Group without waiting for all instances in the pool to terminate. You can force an Auto Scaling Group to delete even if it's in the process of scaling a resource. Normally, Terraform drains all the instances before deleting the group. This bypasses that behavior and potentially leaves resources dangling"
  type        = bool
  default     = null
}

variable "termination_policies" {
  description = "A list of policies to decide how the instances in the Auto Scaling Group should be terminated. The allowed values are `OldestInstance`, `NewestInstance`, `OldestLaunchConfiguration`, `ClosestToNextInstanceHour`, `OldestLaunchTemplate`, `AllocationStrategy`, `Default`"
  type        = list(string)
  default     = []
  nullable    = false
}

variable "suspended_processes" {
  description = "A list of processes to suspend for the Auto Scaling Group. The allowed values are `Launch`, `Terminate`, `HealthCheck`, `ReplaceUnhealthy`, `AZRebalance`, `AlarmNotification`, `ScheduledActions`, `AddToLoadBalancer`. Note that if you suspend either the `Launch` or `Terminate` process types, it can prevent your Auto Scaling Group from functioning properly"
  type        = list(string)
  default     = []
  nullable    = false
}

variable "max_instance_lifetime" {
  description = "The maximum amount of time, in seconds, that an instance can be in service, values must be either equal to 0 or between 604800 and 31536000 seconds"
  type        = number
  default     = null
}

variable "enabled_metrics" {
  description = "A list of metrics to collect. The allowed values are `GroupDesiredCapacity`, `GroupInServiceCapacity`, `GroupPendingCapacity`, `GroupMinSize`, `GroupMaxSize`, `GroupInServiceInstances`, `GroupPendingInstances`, `GroupStandbyInstances`, `GroupStandbyCapacity`, `GroupTerminatingCapacity`, `GroupTerminatingInstances`, `GroupTotalCapacity`, `GroupTotalInstances`"
  type        = list(string)
  default     = []
  nullable    = false
}

variable "metrics_granularity" {
  description = "The granularity to associate with the metrics to collect. The only valid value is `1Minute`"
  type        = string
  default     = null
}

variable "initial_lifecycle_hooks" {
  description = "One or more Lifecycle Hooks to attach to the Auto Scaling Group before instances are launched. The syntax is exactly the same as the separate `aws_autoscaling_lifecycle_hook` resource, without the `autoscaling_group_name` attribute. Please note that this will only work when creating a new Auto Scaling Group. For all other use-cases, please use `aws_autoscaling_lifecycle_hook` resource"
  type = list(object({
    default_result          = optional(string)
    heartbeat_timeout       = optional(number)
    lifecycle_transition    = string
    name                    = string
    notification_metadata   = optional(string)
    notification_target_arn = optional(string)
    role_arn                = optional(string)
  }))
  default = null
}

variable "instance_maintenance_policy" {
  description = "If this block is configured, add a instance maintenance policy to the specified Auto Scaling group"
  type = object({
    max_healthy_percentage = number
    min_healthy_percentage = number
  })
  default = null
}

variable "instance_refresh" {
  description = "If this block is configured, start an Instance Refresh when this Auto Scaling Group is updated"
  type = object({
    preferences = optional(object({
      alarm_specification = optional(object({
        alarms = optional(list(string))
      }))
      auto_rollback                = optional(bool)
      checkpoint_delay             = optional(number)
      checkpoint_percentages       = optional(list(number))
      instance_warmup              = optional(number)
      max_healthy_percentage       = optional(number)
      min_healthy_percentage       = optional(number, 33)
      scale_in_protected_instances = optional(string)
      skip_matching                = optional(bool)
      standby_instances            = optional(string)
    }))
    strategy = optional(string, "Rolling")
    triggers = optional(list(string))
  })
  default = {
    strategy = "Rolling"
    preferences = {
      min_healthy_percentage = 66
    }
  }
  nullable = false
}

variable "use_mixed_instances_policy" {
  description = "Determines whether to use a mixed instances policy in the autoscaling group or not"
  type        = bool
  default     = false
  nullable    = false
}

variable "mixed_instances_policy" {
  description = "Configuration block containing settings to define launch targets for Auto Scaling groups"
  type = object({
    instances_distribution = optional(object({
      on_demand_allocation_strategy            = optional(string)
      on_demand_base_capacity                  = optional(number)
      on_demand_percentage_above_base_capacity = optional(number)
      spot_allocation_strategy                 = optional(string)
      spot_instance_pools                      = optional(number)
      spot_max_price                           = optional(string)
    }))
    launch_template = object({
      override = optional(list(object({
        instance_requirements = optional(object({
          accelerator_count = optional(object({
            max = optional(number)
            min = optional(number)
          }))
          accelerator_manufacturers = optional(list(string))
          accelerator_names         = optional(list(string))
          accelerator_total_memory_mib = optional(object({
            max = optional(number)
            min = optional(number)
          }))
          accelerator_types      = optional(list(string))
          allowed_instance_types = optional(list(string))
          bare_metal             = optional(string)
          baseline_ebs_bandwidth_mbps = optional(object({
            max = optional(number)
            min = optional(number)
          }))
          burstable_performance                                   = optional(string)
          cpu_manufacturers                                       = optional(list(string))
          excluded_instance_types                                 = optional(list(string))
          instance_generations                                    = optional(list(string))
          local_storage                                           = optional(string)
          local_storage_types                                     = optional(list(string))
          max_spot_price_as_percentage_of_optimal_on_demand_price = optional(number)
          memory_gib_per_vcpu = optional(object({
            max = optional(number)
            min = optional(number)
          }))
          memory_mib = optional(object({
            max = optional(number)
            min = optional(number)
          }))
          network_bandwidth_gbps = optional(object({
            max = optional(number)
            min = optional(number)
          }))
          network_interface_count = optional(object({
            max = optional(number)
            min = optional(number)
          }))
          on_demand_max_price_percentage_over_lowest_price = optional(number)
          require_hibernate_support                        = optional(bool)
          spot_max_price_percentage_over_lowest_price      = optional(number)
          total_local_storage_gb = optional(object({
            max = optional(number)
            min = optional(number)
          }))
          vcpu_count = optional(object({
            max = optional(number)
            min = optional(number)
          }))
        }))
        instance_type = optional(string)
        launch_template_specification = optional(object({
          launch_template_id   = optional(string)
          launch_template_name = optional(string)
          version              = optional(string)
        }))
        weighted_capacity = optional(string)
      })))
    })
  })
  default = null
}

variable "timeouts" {
  description = "Timeout configurations for the autoscaling group"
  type = object({
    delete = optional(string)
  })
  default = null
}

variable "autoscaling_group_tags" {
  description = "A map of additional tags to add to the autoscaling group created. Tags are applied to the autoscaling group only and are NOT propagated to instances"
  type        = map(string)
  default     = {}
  nullable    = false
}

################################################################################
# IAM Role
################################################################################

variable "create_iam_instance_profile" {
  description = "Determines whether an IAM instance profile is created or to use an existing IAM instance profile"
  type        = bool
  default     = true
  nullable    = false
}

variable "iam_instance_profile_arn" {
  description = "Amazon Resource Name (ARN) of an existing IAM instance profile that provides permissions for the node group. Required if `create_iam_instance_profile` = `false`"
  type        = string
  default     = null
}

variable "iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
}

variable "iam_role_use_name_prefix" {
  description = "Determines whether cluster IAM role name (`iam_role_name`) is used as a prefix"
  type        = bool
  default     = true
  nullable    = false
}

variable "iam_role_path" {
  description = "IAM role path"
  type        = string
  default     = null
}

variable "iam_role_description" {
  description = "Description of the role"
  type        = string
  default     = "Self managed node group IAM role"
  nullable    = false
}

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "iam_role_attach_cni_policy" {
  description = "Whether to attach the `AmazonEKS_CNI_Policy`/`AmazonEKS_CNI_IPv6_Policy` IAM policy to the IAM IAM role. WARNING: If set `false` the permissions must be assigned to the `aws-node` DaemonSet pods via another method or nodes will not be able to join the cluster"
  type        = bool
  default     = true
  nullable    = false
}

variable "iam_role_additional_policies" {
  description = "Additional policies to be added to the IAM role"
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "iam_role_tags" {
  description = "A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
  nullable    = false
}

################################################################################
# IAM Role Policy
################################################################################

variable "create_iam_role_policy" {
  description = "Determines whether an IAM role policy is created or not"
  type        = bool
  default     = true
  nullable    = false
}

variable "iam_role_policy_statements" {
  description = "A list of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) - used for adding specific IAM permissions as needed"
  type = list(object({
    sid           = optional(string)
    actions       = optional(list(string))
    not_actions   = optional(list(string))
    effect        = optional(string)
    resources     = optional(list(string))
    not_resources = optional(list(string))
    principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })))
    not_principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })))
    condition = optional(list(object({
      test     = string
      values   = list(string)
      variable = string
    })))
  }))
  default = null
}

################################################################################
# Access Entry
################################################################################

variable "create_access_entry" {
  description = "Determines whether an access entry is created for the IAM role used by the node group"
  type        = bool
  default     = true
  nullable    = false
}

variable "iam_role_arn" {
  description = "ARN of the IAM role used by the instance profile. Required when `create_access_entry = true` and `create_iam_instance_profile = false`"
  type        = string
  default     = null
}

################################################################################
# Security Group
################################################################################

variable "create_security_group" {
  description = "Determines if a security group is created"
  type        = bool
  default     = true
  nullable    = false
}

variable "security_group_name" {
  description = "Name to use on security group created"
  type        = string
  default     = null
}

variable "security_group_use_name_prefix" {
  description = "Determines whether the security group name (`security_group_name`) is used as a prefix"
  type        = bool
  default     = true
  nullable    = false
}

variable "security_group_description" {
  description = "Description of the security group created"
  type        = string
  default     = null
}

variable "security_group_ingress_rules" {
  description = "Security group ingress rules to add to the security group created"
  type = map(object({
    name = optional(string)

    cidr_ipv4                    = optional(string)
    cidr_ipv6                    = optional(string)
    description                  = optional(string)
    from_port                    = optional(string)
    ip_protocol                  = optional(string, "tcp")
    prefix_list_id               = optional(string)
    referenced_security_group_id = optional(string)
    self                         = optional(bool, false)
    tags                         = optional(map(string), {})
    to_port                      = optional(string)
  }))
  default  = {}
  nullable = false
}

variable "security_group_egress_rules" {
  description = "Security group egress rules to add to the security group created"
  type = map(object({
    name = optional(string)

    cidr_ipv4                    = optional(string)
    cidr_ipv6                    = optional(string)
    description                  = optional(string)
    from_port                    = optional(string)
    ip_protocol                  = optional(string, "tcp")
    prefix_list_id               = optional(string)
    referenced_security_group_id = optional(string)
    self                         = optional(bool, false)
    tags                         = optional(map(string), {})
    to_port                      = optional(string)
  }))
  default  = {}
  nullable = false
}

variable "security_group_tags" {
  description = "A map of additional tags to add to the security group created"
  type        = map(string)
  default     = {}
  nullable    = false
}
