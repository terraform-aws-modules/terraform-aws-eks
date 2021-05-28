variable "k8s_version" {
  description = "k8s cluster version"
  default     = "1.20"
  type        = string
}

variable "enable_admin_container" {
  description = "Enable/disable admin container"
  default     = false
  type        = bool
}

variable "enable_control_container" {
  description = "Enable/disable control container"
  default     = true
  type        = bool
}