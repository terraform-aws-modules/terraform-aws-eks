variable "create" {
  description = "Controls if resources should be created (affects nearly all resources)"
  type        = bool
  default     = true
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

################################################################################
# Capabilities
################################################################################

variable "name" {
  description = "The name of the capability to add to the cluster"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = ""
}

variable "configuration" {
  description = "Configuration for the capability"
  type = object({
    argo_cd = optional(object({
      aws_idc = object({
        idc_instance_arn = string
        idc_region       = optional(string)
      })
      namespace = optional(string)
      network_access = optional(object({
        vpce_ids = optional(list(string))
      }))
      rbac_role_mapping = optional(list(object({
        identity = list(object({
          id   = string
          type = string
        }))
        role = string
      })))
    }))
  })
  default = null
}

variable "delete_propagation_policy" {
  description = "The propagation policy to use when deleting the capability. Valid values: `RETAIN`"
  type        = string
  default     = "RETAIN"
}

variable "type" {
  description = "Type of the capability. Valid values: `ACK`, `KRO`, `ARGOCD`"
  type        = string
  default     = ""
}

variable "timeouts" {
  description = "Create, update, and delete timeout configurations for the capability"
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}

variable "wait_duration" {
  description = "Duration to wait between creating the IAM role/policy and creating the capability"
  type        = string
  default     = "20s"
}

################################################################################
# IAM Role
################################################################################

variable "create_iam_role" {
  description = "Determines whether an IAM role is created"
  type        = bool
  default     = true
}

variable "iam_role_arn" {
  description = "The ARN of the IAM role that provides permissions for the capability"
  type        = string
  default     = null
}

variable "iam_role_name" {
  description = "Name of the IAM role"
  type        = string
  default     = null
}

variable "iam_role_use_name_prefix" {
  description = "Determines whether the name of the IAM role (`iam_role_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "iam_role_path" {
  description = "Path of the IAM role"
  type        = string
  default     = null
}

variable "iam_role_description" {
  description = "IAM role description"
  type        = string
  default     = null
}

variable "iam_role_max_session_duration" {
  description = "Maximum API session duration in seconds between 3600 and 43200"
  type        = number
  default     = null
}

variable "iam_role_permissions_boundary_arn" {
  description = "Permissions boundary ARN to use for the IAM role"
  type        = string
  default     = null
}

variable "iam_role_tags" {
  description = "A map of additional tags to add the the IAM role"
  type        = map(string)
  default     = {}
}

################################################################################
# IAM Role Policy
################################################################################

variable "iam_policy_name" {
  description = "Name of the IAM policy"
  type        = string
  default     = null
}

variable "iam_policy_use_name_prefix" {
  description = "Determines whether the name of the IAM policy (`iam_policy_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "iam_policy_path" {
  description = "Path of the IAM policy"
  type        = string
  default     = null
}

variable "iam_policy_description" {
  description = "IAM policy description"
  type        = string
  default     = null
}

variable "iam_role_override_assume_policy_documents" {
  description = "A list of IAM policy documents to override the default assume role policy document for the Karpenter controller IAM role"
  type        = list(string)
  default     = []
}

variable "iam_role_source_assume_policy_documents" {
  description = "A list of IAM policy documents to use as a source for the assume role policy document for the Karpenter controller IAM role"
  type        = list(string)
  default     = []
}

variable "iam_policy_statements" {
  description = "A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) - used for adding specific IAM permissions as needed"
  type = map(object({
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

variable "iam_role_policies" {
  description = "Policies to attach to the IAM role in `{'static_name' = 'policy_arn'}` format"
  type        = map(string)
  default     = {}
}
