variable "provider_url" {
  description = "URL of the OIDC Provider"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to IAM role resources"
  type        = map(string)
  default     = {}
}

variable "role_name" {
  description = "IAM role name"
  type        = string
  default     = ""
}

variable "role_description" {
  description = "IAM role description"
  type        = string
  default     = ""
}

variable "role_path" {
  description = "Path of IAM role"
  type        = string
  default     = "/"
}

variable "role_permissions_boundary_arn" {
  description = "Permissions boundary ARN to use for IAM role"
  type        = string
  default     = ""
}

variable "max_session_duration" {
  description = "Maximum CLI/API session duration in seconds between 3600 and 43200"
  type        = number
  default     = 3600
}

variable "role_policy_document" {
  description = "IAM Policy Document to attach"
  type        = string
}

variable "oidc_fully_qualified_subjects" {
  description = "The fully qualified OIDC subjects to be added to the role policy"
  type        = list(string)
  default     = []
}

variable "oidc_subjects_with_wildcards" {
  description = "The OIDC subject using wildcards to be added to the role policy"
  type        = list(string)
  default     = []
}
