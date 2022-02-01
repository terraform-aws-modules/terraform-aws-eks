variable "name" {
  description = "Name that when provided, is used across all resources created"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "Name of the EKS cluster associated with the OIDC provider"
  type        = string
  default     = ""
}

variable "annotations" {
  description = "A map of annotations to add to all Kubernetes resources (namespace and service account)"
  type        = map(string)
  default     = {}
}

variable "labels" {
  description = "A map of labels to add to all Kubernetes resources (namespace and service account)"
  type        = map(string)
  default     = {}
}

################################################################################
# Kubernetes Namespace
################################################################################

variable "create_namespace" {
  description = "Determines whether to create a Kubernetes namespace"
  type        = bool
  default     = true
}

variable "namespace_name" {
  description = "The name of the Kubernetes namespace - either created or existing"
  type        = string
  default     = ""
}

variable "namespace_annotations" {
  description = "A map of annotations to add to the Kubernetes namespace"
  type        = map(string)
  default     = {}
}

variable "namespace_labels" {
  description = "A map of labels to add to the Kubernetes namespace"
  type        = map(string)
  default     = {}
}

variable "namespace_timeouts" {
  description = "Timeout configurations for the cluster - currently only `delete` is supported"
  type        = map(string)
  default     = {}
}

################################################################################
# Kubernetes Service Account
################################################################################

variable "create_service_account" {
  description = "Determines whether to create a Kubernetes service account"
  type        = bool
  default     = true
}

variable "service_account_name" {
  description = "The name of the Kubernetes namespace - either created or existing"
  type        = string
  default     = ""
}

variable "service_account_namespace" {
  description = "The name of an existing Kubernetes namespace to create the service account in (`create_service_account` must be `false`)"
  type        = string
  default     = null
}

variable "service_account_annotations" {
  description = "A map of annotations to add to the Kubernetes service account"
  type        = map(string)
  default     = {}
}

variable "service_account_labels" {
  description = "A map of labels to add to the Kubernetes service account"
  type        = map(string)
  default     = {}
}

variable "automount_service_account_token" {
  description = "Determines whether to automatically mount the service account token into pods. Defaults to `true`"
  type        = bool
  default     = null
}

variable "image_pull_secrets" {
  description = "A list of image pull secrets to add to the Kubernetes service account"
  type        = list(string)
  default     = []
}

variable "secrets" {
  description = "A list of Kubernetes secrets to add to the Kubernetes service account"
  type        = list(string)
  default     = []
}

################################################################################
# IAM Role
################################################################################

variable "create" {
  description = "Determines whether to create IRSA resources or not (affects all resources)"
  type        = bool
  default     = true
}

variable "iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
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

variable "iam_role_description" {
  description = "Description of the role"
  type        = string
  default     = null
}

variable "iam_role_max_session_duration" {
  description = "Maximum session duration (in seconds) that you want to set for the specified role. If you do not specify a value for this setting, the default maximum of one hour is applied"
  type        = number
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

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
