variable "create_eks" {
  description = "Controls if EKS resources should be created (it affects almost all resources)"
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "Name of parent cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version of parent cluster"
  type        = string
}

variable "manage_worker_iam_resources" {
  description = "Whether to let the module manage worker IAM resources. If set to false, iam_instance_profile_name must be specified for workers."
  type        = bool
}

variable "manage_worker_autoscaling_policy" {
  description = "Whether to let the module manage the cluster autoscaling iam policy."
  type        = bool
}

variable "attach_worker_autoscaling_policy" {
  description = "Whether to attach the module managed cluster autoscaling iam policy to the default worker IAM role. This requires `manage_worker_autoscaling_policy = true`"
  type        = bool
}

variable "worker_autoscaling_policy_arn" {
  description = "ARN of the worker autoscaling policy."
  type        = string
}

variable "workers_additional_policies" {
  description = "Additional policies to be added to workers"
  type        = list(string)
}

variable "workers_group_defaults" {
  description = "Workers group defaults from parent"
  type        = any
}

variable "role_name" {
  description = "Custom name for IAM role. Otherwise one will be generated"
  type        = string
}

variable "permissions_boundary" {
  description = "If provided, all IAM roles will be created with this permissions boundary attached."
  type        = string
}

variable "iam_path" {
  description = "If provided, all IAM roles will be created on this path."
  type        = string
}

variable "tags" {
  description = "A map of trags to add to all resources"
  type        = map(string)
}

variable "node_groups" {
  description = "map of maps of node groups to create. See default for valid keys and type. See source for extra comments"
  type        = any

  # This will be always be overriden by the value from the top level module
  default = {
    example_ng = {
      iam_role_arn              = ""           # IAM Role ARN for workers. If unset: locally created managed
      subnets                   = [""]         # Subnets to contain workers. If unset: uses parent's local.workers_group_defaults[subnets]
      desired_capacity          = 0            # Desired number of workers. If unset: uses parent's local.workers_group_defaults[asg_desired_capacity]
      max_capacity              = 0            # Max number of workers. If unset: uses parent's local.workers_group_defaults[asg_max_size]
      min_capacity              = 0            # Min number of workers. If unset: uses parent's local.workers_group_defaults[asg_min_size]
      ami_type                  = ""           # AMI type. See Terraform docs. If unset: falls back to provider default behavior
      root_volume_size          = 0            # Workers' disk size. If unset: falls back to provider default behavior
      instance_type             = ""           # Workers' instance type. If unset: falls back to provider default behavior
      k8s_labels                = { key = "" } # Map of Kubernetes labels. If unset: no extra labels set
      ami_release_version       = ""           # AMI version of workers. If unset: falls back to provider default behavior
      key_name                  = ""           # Key name for workers. If unset: key_name is not used and remote management access disabled
      source_security_group_ids = [""]         # List of source security groups for remote access to workers. If unset and key_name is specified: THE REMOTE ACCESS PORT WILL BE OPENED TO THE WORLD
      additional_tags           = { key = "" } # Additional tags to apply to node_group. If unset: none
    }
  }
}
