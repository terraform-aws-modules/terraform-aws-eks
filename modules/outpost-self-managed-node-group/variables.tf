###############################################################################
# Naming Variables
###############################################################################
variable "name" {
  type        = string
  description = "group name"
}

###############################################################################
# Cluster Vars
###############################################################################
variable "cluster_endpoint" {
  type        = string
  description = "cluster endpoint"
  default     = ""
}

variable "cluster_auth" {
  type        = string
  description = "cluster auth"
  default     = ""
}

variable "cluster_version" {
  type        = string
  description = "cluster version"
  default     = ""
}

variable "cluster_name" {
  type        = string
  description = "override for cluster name"
  default     = ""
}

variable "vpc_id" {
  type        = string
  description = "vpc id"
}

variable "outpost_name" {
  type        = string
  description = "outpost name"
}

###############################################################################
# Node Group Vars
###############################################################################

variable "family" {
  type        = string
  description = "instance family"
  default     = "m5.xlarge"
}

variable "ami_id" {
  type        = string
  description = "AMI id to use for nodes"
  default     = ""
}

variable "max_group_size" {
  type        = number
  description = "the max size of the pg"
  default     = 3
}

variable "min_group_size" {
  type        = number
  description = "minimum node group size"
  default     = 3
}

variable "aws_iam_instance_profile_arn" {
  type        = string
  description = "aws_iam_instance_profile_arn"
}

variable "platform" {
  type        = string
  description = "the ami type for the node group"
  default     = "bottlerocket"
}

/*variable "aws_ram_resource_share_outpost_arn" {
  type        = string
  default     = ""
  description = "name of the ram share"
}*/

variable "placement_group_strategy" {
  type        = string
  description = "placement group strategy"
  default     = "spread"
  validation {
    condition = anytrue([
      var.placement_group_strategy == "cluster",
      var.placement_group_strategy == "spread",
      var.placement_group_strategy == "partition"
    ])
    error_message = "placement group strategy must be one of cluster, spread, or partition"
  }
}

variable "placement_group_spread_level" {
  type        = string
  description = "placement group spread level"
  default     = "host"
}

variable "placement_group_partition_count" {
  type        = number
  description = "placement partition count"
  default     = 3
}

variable "enable_lifecycle_hook" {
  type        = bool
  description = "Create an instance terminating lifecycle hook"
  default     = true
}

variable "add_node_termination_handler_tags" {
  type        = bool
  description = "Add the node termination handler tag to the node group"
  default     = true
}

###############################################################################
# Security Group Vars
###############################################################################

variable "security_group_rules" {
  type = map(object({
    description                   = string
    protocol                      = string
    from_port                     = number
    to_port                       = number
    type                          = string
    cidr_blocks                   = optional(list(string))
    security_group                = optional(string)
    source_cloudfront_prefix_list = optional(bool)
    prefix_list_id                = optional(string)
  }))
  description = "security group rules if desired"
  default     = {}
  nullable    = false
}

variable "shared_security_group_id" {
  type        = string
  description = "id for self access security group"
  default     = ""
}

variable "node_security_group_id" {
  type        = string
  description = "default node sg"
}

variable "cluster_security_group_id" {
  type        = string
  description = "cluster security group id"
}

variable "security_group_ids" {
  type        = list(string)
  description = "extra security groups to add to the node group"
  default     = []
}

variable "node_subnet_id" {
  type        = string
  description = "subnet for the outpost node group"
}

variable "root_volume_size" {
  type        = number
  description = "root volume size"
  default     = 20
}

variable "extra_volume_size" {
  type        = number
  description = "extra volume size"
  default     = 30
}

variable "extra_block_device_mappings" {
  type        = map(any)
  description = "extra block device mappings"
  default     = {}
  nullable    = false
}

###############################################################################
# Other Vars
###############################################################################

variable "tags" {
  type        = map(any)
  description = "tags"
}

variable "additional_tags" {
  type        = map(any)
  description = "tags"
  default     = {}
}

variable "add_autoscaling_group_tags" {
  type        = bool
  description = "not recommended on outposts"
  default     = false
}

variable "taints" {
  type        = map(any)
  description = "taints"
  default     = {}
  nullable    = false
}

variable "extra_labels" {
  type        = map(any)
  description = "extra labels to add"
  default     = {}
  nullable    = false
}
