locals {
  asg_tags = [
    for item in keys(var.tags) :
    map(
      "key", item,
      "value", element(values(var.tags), index(keys(var.tags), item)),
      "propagate_at_launch", "true"
    )
  ]

  cluster_security_group_id = var.cluster_create_security_group ? join("", aws_security_group.cluster.*.id) : var.cluster_security_group_id
  cluster_iam_role_name     = var.manage_cluster_iam_resources ? join("", aws_iam_role.cluster.*.name) : var.cluster_iam_role_name
  cluster_iam_role_arn      = var.manage_cluster_iam_resources ? join("", aws_iam_role.cluster.*.arn) : join("", data.aws_iam_role.custom_cluster_iam_role.*.arn)
  worker_security_group_id  = var.worker_create_security_group ? join("", aws_security_group.workers.*.id) : var.worker_security_group_id

  default_iam_role_id = concat(aws_iam_role.workers.*.id, [""])[0]
  kubeconfig_name     = var.kubeconfig_name == "" ? "eks_${var.cluster_name}" : var.kubeconfig_name

  worker_group_count                 = length(var.worker_groups)
  worker_group_launch_template_count = length(var.worker_groups_launch_template)

  default_ami_id_linux   = coalesce(local.workers_group_defaults.ami_id, data.aws_ami.eks_worker.id)
  default_ami_id_windows = coalesce(local.workers_group_defaults.ami_id_windows, data.aws_ami.eks_worker_windows.id)

  policy_arn_prefix = "arn:${data.aws_partition.current.partition}:iam::aws:policy"
  workers_group_defaults_defaults = {
    name                          = "count.index"               # Name of the worker group. Literal count.index will never be used but if name is not set, the count.index interpolation will be used.
    tags                          = []                          # A list of map defining extra tags to be applied to the worker group autoscaling group.
    ami_id                        = ""                          # AMI ID for the eks linux based workers. If none is provided, Terraform will search for the latest version of their EKS optimized worker AMI based on platform.
    ami_id_windows                = ""                          # AMI ID for the eks windows based workers. If none is provided, Terraform will search for the latest version of their EKS optimized worker AMI based on platform.
    asg_desired_capacity          = "1"                         # Desired worker capacity in the autoscaling group and changing its value will not affect the autoscaling group's desired capacity because the cluster-autoscaler manages up and down scaling of the nodes. Cluster-autoscaler add nodes when pods are in pending state and remove the nodes when they are not required by modifying the desirec_capacity of the autoscaling group. Although an issue exists in which if the value of the asg_min_size is changed it modifies the value of asg_desired_capacity.
    asg_max_size                  = "3"                         # Maximum worker capacity in the autoscaling group.
    asg_min_size                  = "1"                         # Minimum worker capacity in the autoscaling group. NOTE: Change in this paramater will affect the asg_desired_capacity, like changing its value to 2 will change asg_desired_capacity value to 2 but bringing back it to 1 will not affect the asg_desired_capacity.
    asg_force_delete              = false                       # Enable forced deletion for the autoscaling group.
    asg_initial_lifecycle_hooks   = []                          # Initital lifecycle hook for the autoscaling group.
    asg_recreate_on_change        = false                       # Recreate the autoscaling group when the Launch Template or Launch Configuration change.
    default_cooldown              = null                        # The amount of time, in seconds, after a scaling activity completes before another scaling activity can start.
    health_check_grace_period     = null                        # Time in seconds after instance comes into service before checking health.
    instance_type                 = "m4.large"                  # Size of the workers instances.
    spot_price                    = ""                          # Cost of spot instance.
    placement_tenancy             = ""                          # The tenancy of the instance. Valid values are "default" or "dedicated".
    root_volume_size              = "100"                       # root volume size of workers instances.
    root_volume_type              = "gp2"                       # root volume type of workers instances, can be 'standard', 'gp2', or 'io1'
    root_iops                     = "0"                         # The amount of provisioned IOPS. This must be set with a volume_type of "io1".
    key_name                      = ""                          # The key name that should be used for the instances in the autoscaling group
    pre_userdata                  = ""                          # userdata to pre-append to the default userdata.
    userdata_template_file        = ""                          # alternate template to use for userdata
    userdata_template_extra_args  = {}                          # Additional arguments to use when expanding the userdata template file
    bootstrap_extra_args          = ""                          # Extra arguments passed to the bootstrap.sh script from the EKS AMI (Amazon Machine Image).
    additional_userdata           = ""                          # userdata to append to the default userdata.
    ebs_optimized                 = true                        # sets whether to use ebs optimization on supported types.
    enable_monitoring             = true                        # Enables/disables detailed monitoring.
    public_ip                     = false                       # Associate a public ip address with a worker
    kubelet_extra_args            = ""                          # This string is passed directly to kubelet if set. Useful for adding labels or taints.
    subnets                       = var.subnets                 # A list of subnets to place the worker nodes in. i.e. ["subnet-123", "subnet-456", "subnet-789"]
    additional_security_group_ids = []                          # A list of additional security group ids to include in worker launch config
    protect_from_scale_in         = false                       # Prevent AWS from scaling in, so that cluster-autoscaler is solely responsible.
    iam_instance_profile_name     = ""                          # A custom IAM instance profile name. Used when manage_worker_iam_resources is set to false. Incompatible with iam_role_id.
    iam_role_id                   = "local.default_iam_role_id" # A custom IAM role id. Incompatible with iam_instance_profile_name.  Literal local.default_iam_role_id will never be used but if iam_role_id is not set, the local.default_iam_role_id interpolation will be used.
    suspended_processes           = ["AZRebalance"]             # A list of processes to suspend. i.e. ["AZRebalance", "HealthCheck", "ReplaceUnhealthy"]
    target_group_arns             = null                        # A list of Application LoadBalancer (ALB) target group ARNs to be associated to the autoscaling group
    enabled_metrics               = []                          # A list of metrics to be collected i.e. ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity"]
    placement_group               = ""                          # The name of the placement group into which to launch the instances, if any.
    service_linked_role_arn       = ""                          # Arn of custom service linked role that Auto Scaling group will use. Useful when you have encrypted EBS
    termination_policies          = []                          # A list of policies to decide how the instances in the auto scale group should be terminated.
    platform                      = "linux"                     # Platform of workers. either "linux" or "windows"
    additional_ebs_volumes        = []                          # A list of additional volumes to be attached to the instances on this Auto Scaling group. Each volume should be an object with the following: block_device_name (required), volume_size, volume_type, iops, encrypted, kms_key_id (only on launch-template), delete_on_termination. Optional values are grabbed from root volume or from defaults
    # Settings for launch templates
    root_block_device_name            = data.aws_ami.eks_worker.root_device_name # Root device name for workers. If non is provided, will assume default AMI was used.
    root_kms_key_id                   = ""                                       # The KMS key to use when encrypting the root storage device
    launch_template_version           = "$Latest"                                # The lastest version of the launch template to use in the autoscaling group
    launch_template_placement_tenancy = "default"                                # The placement tenancy for instances
    launch_template_placement_group   = ""                                       # The name of the placement group into which to launch the instances, if any.
    root_encrypted                    = false                                    # Whether the volume should be encrypted or not
    eni_delete                        = true                                     # Delete the Elastic Network Interface (ENI) on termination (if set to false you will have to manually delete before destroying)
    cpu_credits                       = "standard"                               # T2/T3 unlimited mode, can be 'standard' or 'unlimited'. Used 'standard' mode as default to avoid paying higher costs
    market_type                       = null
    # Settings for launch templates with mixed instances policy
    override_instance_types                  = ["m5.large", "m5a.large", "m5d.large", "m5ad.large"] # A list of override instance types for mixed instances policy
    on_demand_allocation_strategy            = null                                                 # Strategy to use when launching on-demand instances. Valid values: prioritized.
    on_demand_base_capacity                  = "0"                                                  # Absolute minimum amount of desired capacity that must be fulfilled by on-demand instances
    on_demand_percentage_above_base_capacity = "0"                                                  # Percentage split between on-demand and Spot instances above the base on-demand capacity
    spot_allocation_strategy                 = "lowest-price"                                       # Valid options are 'lowest-price' and 'capacity-optimized'. If 'lowest-price', the Auto Scaling group launches instances using the Spot pools with the lowest price, and evenly allocates your instances across the number of Spot pools. If 'capacity-optimized', the Auto Scaling group launches instances using Spot pools that are optimally chosen based on the available Spot capacity.
    spot_instance_pools                      = 10                                                   # "Number of Spot pools per availability zone to allocate capacity. EC2 Auto Scaling selects the cheapest Spot pools and evenly allocates Spot capacity across the number of Spot pools that you specify."
    spot_max_price                           = ""                                                   # Maximum price per unit hour that the user is willing to pay for the Spot instances. Default is the on-demand price
    max_instance_lifetime                    = 0                                                    # Maximum number of seconds instances can run in the ASG. 0 is unlimited.
  }

  workers_group_defaults = merge(
    local.workers_group_defaults_defaults,
    var.workers_group_defaults,
  )

  ebs_optimized_not_supported = [
    "c1.medium",
    "c3.8xlarge",
    "c3.large",
    "c5d.12xlarge",
    "c5d.24xlarge",
    "c5d.metal",
    "cc2.8xlarge",
    "cr1.8xlarge",
    "g2.8xlarge",
    "g4dn.metal",
    "hs1.8xlarge",
    "i2.8xlarge",
    "m1.medium",
    "m1.small",
    "m2.xlarge",
    "m3.large",
    "m3.medium",
    "m5ad.16xlarge",
    "m5ad.8xlarge",
    "m5dn.metal",
    "m5n.metal",
    "r3.8xlarge",
    "r3.large",
    "r5ad.16xlarge",
    "r5ad.8xlarge",
    "r5dn.metal",
    "r5n.metal",
    "t1.micro",
    "t2.2xlarge",
    "t2.large",
    "t2.medium",
    "t2.micro",
    "t2.nano",
    "t2.small",
    "t2.xlarge"
  ]
}
