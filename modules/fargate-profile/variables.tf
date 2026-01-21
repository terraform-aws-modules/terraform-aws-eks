variable "create" {
  description = "Determines whether to create Fargate profile or not"
  type        = bool
  default     = true
  nullable    = false
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
  nullable    = false
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
# IAM Role
################################################################################

variable "create_iam_role" {
  description = "Determines whether an IAM role is created or to use an existing IAM role"
  type        = bool
  default     = true
  nullable    = false
}

variable "cluster_ip_family" {
  description = "The IP family used to assign Kubernetes pod and service addresses. Valid values are `ipv4` (default) and `ipv6`"
  type        = string
  default     = "ipv4"
}

variable "iam_role_arn" {
  description = "Existing IAM role ARN for the Fargate profile. Required if `create_iam_role` is set to `false`"
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
  default     = "Fargate profile IAM role"
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
# Fargate Profile
################################################################################

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = ""
}

variable "name" {
  description = "Name of the EKS Fargate Profile"
  type        = string
  default     = ""
  nullable    = false
}

variable "subnet_ids" {
  description = "A list of subnet IDs for the EKS Fargate Profile"
  type        = list(string)
  default     = []
  nullable    = false
}

variable "selectors" {
  description = "Configuration block(s) for selecting Kubernetes Pods to execute with this Fargate Profile"
  type = list(object({
    labels    = optional(map(string))
    namespace = string
  }))
  default = null
}

variable "timeouts" {
  description = "Create and delete timeout configurations for the Fargate Profile"
  type = object({
    create = optional(string)
    delete = optional(string)
  })
  default = null
}
