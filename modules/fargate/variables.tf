variable "create" {
  description = "Controls if Fargate resources should be created (it affects all resources)"
  type        = bool
  default     = true
}

variable "create_fargate_pod_execution_role" {
  description = "Controls if the the IAM Role that provides permissions for the EKS Fargate Profile should be created"
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = ""
}

variable "iam_path" {
  description = "Path to the role"
  type        = string
  default     = null
}

variable "permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the role"
  type        = string
  default     = null
}

variable "fargate_profiles" {
  description = "Fargate profiles to create. See `fargate_profile` keys section in README.md for more details"
  type        = any
  default     = {}
}

variable "fargate_pod_execution_role_arn" {
  description = "Existing Amazon Resource Name (ARN) of the IAM Role that provides permissions for the EKS Fargate Profile. Required if `create_fargate_pod_execution_role` is `false`"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "A list of subnet IDs for the EKS Fargate profiles"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
