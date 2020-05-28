variable "cluster_name" {
  description = "Name of parent cluster."
  type        = string
}

variable "create_eks" {
  description = "Controls if EKS resources should be created (it affects almost all resources)"
  type        = bool
  default     = true
}

variable "create_fargate_pod_execution_role" {
  description = "Controls if the EKS Fargate pod execution IAM role should be created."
  type        = bool
  default     = true
}

variable "fargate_profiles" {
  description = "Fargate profiles to create."
  type = map(object({
    namespace = string
    labels    = map(string)
  }))
  default = {}
}

variable "subnets" {
  description = "A list of subnets for the EKS Fargate profiles."
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}
