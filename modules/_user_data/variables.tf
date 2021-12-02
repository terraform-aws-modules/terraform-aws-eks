variable "create" {
  description = "Determines whether to create EKS managed node group or not"
  type        = bool
  default     = true
}

variable "platform" {
  description = "Identifies if the OS platform is `bottlerocket`, `linux`, or `windows` based"
  type        = string
  default     = "linux"
}

variable "enable_bootstrap_user_data" {
  description = "Determines whether the bootstrap configurations are populated within the user data template"
  type        = bool
  default     = false
}

variable "is_eks_managed_node_group" {
  description = "Determines whether the user data is used on nodes in an EKS managed node group"
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "Name of the EKS cluster and default name (prefix) used throughout the resources created"
  type        = string
  default     = ""
}

variable "cluster_endpoint" {
  description = "Endpoint of associated EKS cluster"
  type        = string
  default     = ""
}

variable "cluster_auth_base64" {
  description = "Base64 encoded CA of associated EKS cluster"
  type        = string
  default     = ""
}

variable "pre_bootstrap_user_data" {
  description = "User data that is injected into the user data script ahead of the EKS bootstrap script"
  type        = string
  default     = ""
}

variable "post_bootstrap_user_data" {
  description = "User data that is appended to the user data script after of the EKS bootstrap script. Only valid when using a custom EKS optimized AMI derivative"
  type        = string
  default     = ""
}

variable "bootstrap_extra_args" {
  description = "Additional arguments passed to the bootstrap script"
  type        = string
  default     = ""
}

variable "user_data_template_path" {
  description = "Path to a local, custom user data template file to use when rendering user data"
  type        = string
  default     = ""
}
