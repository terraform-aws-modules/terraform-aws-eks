variable "create_eks" {
  description = "Controls if EKS resources should be created (it affects almost all resources)"
  type        = bool
  default     = true
}

variable "create_fargate_pod_execution_role" {
  description = "Controls if the the IAM Role that provides permissions for the EKS Fargate Profile should be created."
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
  default     = ""
}

variable "iam_path" {
  description = "IAM roles will be created on this path."
  type        = string
  default     = "/"
}

variable "fargate_pod_execution_role_name" {
  description = "The IAM Role that provides permissions for the EKS Fargate Profile."
  type        = string
  default     = null
}

variable "fargate_profiles" {
  description = "Fargate profiles to create. See `fargate_profile` keys section in README.md for more details"
  type        = any
  default     = {}
}

variable "permissions_boundary" {
  description = "If provided, all IAM roles will be created with this permissions boundary attached."
  type        = string
  default     = null
}

variable "subnets" {
  description = "A list of subnets for the EKS Fargate profiles."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}
