variable "create" {
  description = "Controls if resources should be created (affects all resources)"
  type        = bool
  default     = true
}

################################################################################
# aws-auth ConfigMap
################################################################################

variable "create_aws_auth_configmap" {
  description = "Determines whether to create the aws-auth configmap. NOTE - this is only intended for scenarios where the configmap does not exist (i.e. - when using only self-managed node groups). Most users should use `manage_aws_auth_configmap`"
  type        = bool
  default     = false
}

variable "manage_aws_auth_configmap" {
  description = "Determines whether to manage the aws-auth configmap"
  type        = bool
  default     = true
}

variable "aws_auth_roles" {
  description = "List of role maps to add to the aws-auth configmap"
  type        = list(any)
  default     = []
}

variable "aws_auth_users" {
  description = "List of user maps to add to the aws-auth configmap"
  type        = list(any)
  default     = []
}

variable "aws_auth_accounts" {
  description = "List of account maps to add to the aws-auth configmap"
  type        = list(any)
  default     = []
}
