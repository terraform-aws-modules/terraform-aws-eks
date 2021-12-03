variable "create" {
  description = "Controls if Fargate resources should be created (it affects all resources)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# IAM Role
################################################################################

variable "create_iam_role" {
  description = "Controls if the the IAM Role that provides permissions for the EKS Fargate Profile will be created"
  type        = bool
  default     = true
}

variable "iam_role_arn" {
  description = "Amazon Resource Name (ARN) of an existing IAM role that provides permissions for the Fargate pod executions"
  type        = string
  default     = null
}

variable "iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = ""
}

variable "iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name (`iam_role_name`) is used as a prefix"
  type        = string
  default     = true
}

variable "iam_role_path" {
  description = "IAM role path"
  type        = string
  default     = null
}

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "iam_role_additional_policies" {
  description = "Additional policies to be added to the IAM role"
  type        = list(string)
  default     = []
}

variable "iam_role_tags" {
  description = "A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
}

################################################################################
# Fargate Profile
################################################################################

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = null
}

variable "name" {
  description = "Name of the EKS Fargate Profile"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "A list of subnet IDs for the EKS Fargate Profile"
  type        = list(string)
  default     = []
}

variable "selectors" {
  description = "Configuration block(s) for selecting Kubernetes Pods to execute with this Fargate Profile"
  type        = any
  default     = []
}

variable "timeouts" {
  description = "Create and delete timeout configurations for the Fargate Profile"
  type        = map(string)
  default     = {}
}
