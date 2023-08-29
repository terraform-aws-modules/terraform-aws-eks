locals {
  asg_tags = [
    for item in keys(var.tags) :
    tomap({
      "key"                 = item,
      "value"               = element(values(var.tags), index(keys(var.tags), item)),
      "propagate_at_launch" = "true"
    })
  ]
  worker_policy_list = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  cluster_security_group_id = var.cluster_security_group_id == "" ? join("", aws_security_group.cluster.*.id) : var.cluster_security_group_id
  cluster_iam_role_name     = var.manage_cluster_iam_resources ? join("", aws_iam_role.cluster.*.name) : var.cluster_iam_role_name
  cluster_iam_role_arn      = var.manage_cluster_iam_resources ? join("", aws_iam_role.cluster.*.arn) : join("", data.aws_iam_role.custom_cluster_iam_role.*.arn)
  worker_security_group_id  = var.worker_security_group_id == "" ? join("", aws_security_group.workers.*.id) : var.worker_security_group_id

  default_iam_role_id = concat(aws_iam_role.workers.*.id, [""])[0]
  kubeconfig_name     = var.kubeconfig_name == "" ? "eks_${var.cluster_name}" : var.kubeconfig_name

  default_ami_id_linux = data.aws_ami.eks_worker.id

  # workers_group_defaults = {
  #   name                          = "count.index"               # Name of the worker group. Literal count.index will never be used but if name is not set, the count.index interpolation will be used.
  #   tags                          = []                          # A list of map defining extra tags to be applied to the worker group autoscaling group.
  #   ami_id                        = ""                          # AMI ID for the eks workers. If none is provided, Terraform will search for the latest version of their EKS optimized worker AMI based on platform.
  #   asg_desired_capacity          = "1"                         # Desired worker capacity in the autoscaling group and changing its value will not affect the autoscaling group's desired capacity because the cluster-autoscaler manages up and down scaling of the nodes. Cluster-autoscaler add nodes when pods are in pending state and remove the nodes when they are not required by modifying the desirec_capacity of the autoscaling group. Although an issue exists in which if the value of the asg_min_size is changed it modifies the value of asg_desired_capacity.
  #   asg_max_size                  = "3"                         # Maximum worker capacity in the autoscaling group.
  #   asg_min_size                  = "1"                         # Minimum worker capacity in the autoscaling group. NOTE: Change in this paramater will affect the asg_desired_capacity, like changing its value to 2 will change asg_desired_capacity value to 2 but bringing back it to 1 will not affect the asg_desired_capacity.
  #   asg_force_delete              = false                       # Enable forced deletion for the autoscaling group.
  #   asg_initial_lifecycle_hooks   = []                          # Initital lifecycle hook for the autoscaling group.
  #   instance_type                 = ""                          # Size of the workers (non-managed).
  #   instance_types                = []                          # Size of the spot node group instances.
  #   capacity_type                 = null                        # Capacity type of node group; Can be SPOT, ONDEMAND (default is null, which creates ONDEMAND)
  #   spot_price                    = ""                          # Cost of spot instance.
  #   placement_tenancy             = ""                          # The tenancy of the instance. Valid values are "default" or "dedicated".
  #   node_disk_size                = ""                          # root volume size of nodes.
  #   root_volume_size              = "20"                       # root volume size of workers instances.
  #   root_volume_type              = "gp3"                       # root volume type of workers instances, can be 'standard', 'gp2', 'gp3', or 'io1'
  #   root_iops                     = "0"                         # The amount of provisioned IOPS. This must be set with a volume_type of "io1".
  #   key_name                      = ""                          # The key name that should be used for the instances in the autoscaling group
  #   pre_userdata                  = ""                          # userdata to pre-append to the default userdata.
  #   userdata_template_file        = ""                          # alternate template to use for userdata
  #   userdata_template_extra_args  = {}                          # Additional arguments to use when expanding the userdata template file
  #   bootstrap_extra_args          = ""                          # Extra arguments passed to the bootstrap.sh script from the EKS AMI (Amazon Machine Image).
  #   additional_userdata           = ""                          # userdata to append to the default userdata.
  #   ebs_optimized                 = true                        # sets whether to use ebs optimization on supported types.
  #   enable_monitoring             = true                        # Enables/disables detailed monitoring.
  #   public_ip                     = false                       # Associate a public ip address with a worker
  #   kubelet_extra_args            = "--pod-max-pids=${var.pod_max_pids}"                          # This string is passed directly to kubelet if set. Useful for adding labels or taints.
  #   subnets                       = var.subnets                 # A list of subnets to place the worker nodes in. i.e. ["subnet-123", "subnet-456", "subnet-789"]
  #   additional_security_group_ids = []                          # A list of additional security group ids to include in worker launch config
  #   protect_from_scale_in         = false                       # Prevent AWS from scaling in, so that cluster-autoscaler is solely responsible.
  #   iam_instance_profile_name     = ""                          # A custom IAM instance profile name. Used when manage_worker_iam_resources is set to false. Incompatible with iam_role_id.
  #   iam_role_id                   = "local.default_iam_role_id" # A custom IAM role id. Incompatible with iam_instance_profile_name.  Literal local.default_iam_role_id will never be used but if iam_role_id is not set, the local.default_iam_role_id interpolation will be used.
  #   suspended_processes           = ["AZRebalance"]             # A list of processes to suspend. i.e. ["AZRebalance", "HealthCheck", "ReplaceUnhealthy"]
  #   target_group_arns             = null                        # A list of Application LoadBalancer (ALB) target group ARNs to be associated to the autoscaling group
  #   enabled_metrics               = []                          # A list of metrics to be collected i.e. ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity"]
  #   placement_group               = ""                          # The name of the placement group into which to launch the instances, if any.
  #   service_linked_role_arn       = ""                          # Arn of custom service linked role that Auto Scaling group will use. Useful when you have encrypted EBS
  #   termination_policies          = []                          # A list of policies to decide how the instances in the auto scale group should be terminated.
  #   platform                      = "linux"                     # Platform of workers. either "linux" or "windows"
  #   # Settings for launch templates
  #   root_block_device_name            = data.aws_ami.eks_worker.root_device_name # Root device name for workers. If non is provided, will assume default AMI was used.
  #   root_kms_key_id                   = ""                                       # The KMS key to use when encrypting the root storage device
  #   launch_template_id                = ""                                       # The ID of the launch template to use in the autoscaling group/node group
  #   launch_template_version           = "$Latest"                                # The lastest version of the launch template to use in the autoscaling group
  #   root_encrypted                    = ""                                       # Whether the volume should be encrypted or not
  #   eni_delete                        = true                                     # Delete the Elastic Network Interface (ENI) on termination (if set to false you will have to manually delete before destroying)
  # }

  nodes_groups_defaults = merge(
    { node_sg_group_id = aws_security_group.workers.*.id },
    var.node_groups_defaults,
    #{node_instance_profile = concat(aws_iam_instance_profile.node_group_instance_profile.*.arn, [null])[0]}
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
