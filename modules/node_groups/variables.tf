variable "create_eks" {
  description = "Controls if EKS resources should be created (it affects almost all resources)"
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "Name of parent cluster"
  type        = string
  default     = ""
}

variable "default_iam_role_arn" {
  description = "ARN of the default IAM worker role to use if one is not specified in `var.node_groups` or `var.node_groups_defaults`"
  type        = string
  default     = ""
}

variable "workers_group_defaults" {
  description = "Workers group defaults from parent"
  type        = any
  default     = {}
}

variable "worker_security_group_id" {
  description = "If provided, all workers will be attached to this security group. If not given, a security group will be created with necessary ingress/egress to work with the EKS cluster."
  type        = string
  default     = ""
}

variable "worker_additional_security_group_ids" {
  description = "A list of additional security group ids to attach to worker instances"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "node_groups_defaults" {
  description = "map of maps of node groups to create. See \"`node_groups` and `node_groups_defaults` keys\" section in README.md for more details"
  type        = any
  default     = {}
}

variable "node_groups" {
  description = "Map of maps of `eks_node_groups` to create. See \"`node_groups` and `node_groups_defaults` keys\" section in README.md for more details"
  type        = any
  default     = {}
}

# Hack for a homemade `depends_on` https://discuss.hashicorp.com/t/tips-howto-implement-module-depends-on-emulation/2305/2
# Will be removed in Terraform 0.13 with the support of module's `depends_on` https://github.com/hashicorp/terraform/issues/10462
variable "ng_depends_on" {
  description = "List of references to other resources this submodule depends on"
  type        = any
  default     = null
}

variable "ebs_optimized_not_supported" {
  description = "List of instance types that do not support EBS optimization"
  type        = list(string)
  default     = []
}
