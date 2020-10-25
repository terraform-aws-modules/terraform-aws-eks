variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

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

variable "fargate_pod_execution_role_name" {
  description = "The IAM Role that provides permissions for the EKS Fargate Profile."
  type        = string
  default     = null
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

# Hack for a homemade `depends_on` https://discuss.hashicorp.com/t/tips-howto-implement-module-depends-on-emulation/2305/2
# Will be removed in Terraform 0.13 with the support of module's `depends_on` https://github.com/hashicorp/terraform/issues/10462
variable "eks_depends_on" {
  description = "List of references to other resources this submodule depends on."
  type        = any
  default     = null
}
