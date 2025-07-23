variable "create" {
  description = "Controls if resources should be created (affects nearly all resources)"
  type        = bool
  default     = true
}

################################################################################
# Node IAM Role
################################################################################

variable "name" {
  description = "Name of the IAM role"
  type        = string
  default     = "EKSHybridNode"
}

variable "use_name_prefix" {
  description = "Determines whether the name of the IAM role (`name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "path" {
  description = "Path of the IAM role"
  type        = string
  default     = "/"
}

variable "description" {
  description = "IAM role description"
  type        = string
  default     = "EKS Hybrid Node IAM role"
}

variable "max_session_duration" {
  description = "Maximum API session duration in seconds between 3600 and 43200"
  type        = number
  default     = null
}

variable "permissions_boundary_arn" {
  description = "Permissions boundary ARN to use for the IAM role"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of additional tags to add the the IAM role"
  type        = map(string)
  default     = {}
}

variable "enable_ira" {
  description = "Enables IAM Roles Anywhere based IAM permissions on the node"
  type        = bool
  default     = false
}

variable "trust_anchor_arns" {
  description = "List of IAM Roles Anywhere trust anchor ARNs. Required if `enable_ira` is set to `true`"
  type        = list(string)
  default     = []
}

################################################################################
# Node IAM Role Policy
################################################################################

variable "policy_name" {
  description = "Name of the IAM policy"
  type        = string
  default     = "EKSHybridNode"
}

variable "policy_use_name_prefix" {
  description = "Determines whether the name of the IAM policy (`policy_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "policy_path" {
  description = "Path of the IAM policy"
  type        = string
  default     = "/"
}

variable "policy_description" {
  description = "IAM policy description"
  type        = string
  default     = "EKS Hybrid Node IAM role policy"
}

variable "policy_statements" {
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

variable "policies" {
  description = "Policies to attach to the IAM role in `{'static_name' = 'policy_arn'}` format"
  type        = map(string)
  default     = {}
}

variable "cluster_arns" {
  description = "List of EKS cluster ARNs to allow the node to describe"
  type        = list(string)
  default     = ["*"]
}

variable "enable_pod_identity" {
  description = "Enables EKS Pod Identity based IAM permissions on the node"
  type        = bool
  default     = true
}

################################################################################
# IAM Roles Anywhere Profile
################################################################################

variable "ira_profile_name" {
  description = "Name of the Roles Anywhere profile"
  type        = string
  default     = null
}

variable "ira_profile_duration_seconds" {
  description = "The number of seconds the vended session credentials are valid for. Defaults to `3600`"
  type        = number
  default     = null
}

variable "ira_profile_managed_policy_arns" {
  description = "A list of managed policy ARNs that apply to the vended session credentials"
  type        = list(string)
  default     = []
}

variable "ira_profile_require_instance_properties" {
  description = "Specifies whether instance properties are required in [CreateSession](https://docs.aws.amazon.com/rolesanywhere/latest/APIReference/API_CreateSession.html) requests with this profile"
  type        = bool
  default     = null
}

variable "ira_profile_session_policy" {
  description = "A session policy that applies to the trust boundary of the vended session credentials"
  type        = string
  default     = null
}

################################################################################
# Roles Anywhere Trust Anchor
################################################################################

variable "ira_trust_anchor_name" {
  description = "Name of the Roles Anywhere trust anchor"
  type        = string
  default     = null
}

variable "ira_trust_anchor_notification_settings" {
  description = "Notification settings for the trust anchor"
  type = list(object({
    channel   = optional(string)
    enabled   = optional(bool)
    event     = optional(string)
    threshold = optional(number)
  }))
  default = null
}

variable "ira_trust_anchor_acm_pca_arn" {
  description = "The ARN of the ACM PCA that issued the trust anchor certificate"
  type        = string
  default     = null
}

variable "ira_trust_anchor_x509_certificate_data" {
  description = "The X.509 certificate data of the trust anchor"
  type        = string
  default     = null
}

variable "ira_trust_anchor_source_type" {
  description = "The source type of the trust anchor"
  type        = string
  default     = null
}

################################################################################
# Intermediate IAM Role
################################################################################

variable "intermediate_role_name" {
  description = "Name of the IAM role"
  type        = string
  default     = null
}

variable "intermediate_role_use_name_prefix" {
  description = "Determines whether the name of the IAM role (`intermediate_role_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "intermediate_role_path" {
  description = "Path of the IAM role"
  type        = string
  default     = "/"
}

variable "intermediate_role_description" {
  description = "IAM role description"
  type        = string
  default     = "EKS Hybrid Node IAM Roles Anywhere intermediate IAM role"
}

################################################################################
# Intermediate IAM Role Policy
################################################################################

variable "intermediate_policy_name" {
  description = "Name of the IAM policy"
  type        = string
  default     = null
}

variable "intermediate_policy_use_name_prefix" {
  description = "Determines whether the name of the IAM policy (`intermediate_policy_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "intermediate_policy_statements" {
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

variable "intermediate_role_policies" {
  description = "Policies to attach to the IAM role in `{'static_name' = 'policy_arn'}` format"
  type        = map(string)
  default     = {}
}
