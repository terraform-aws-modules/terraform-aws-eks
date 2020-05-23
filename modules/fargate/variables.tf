variable "cluster_name" {
  description = "Name of parent cluster."
  type        = string
}

variable "create_eks" {
  description = "Controls if EKS resources should be created (it affects almost all resources)"
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

variable "cluster_primary_security_group_id" {
  description = "Cluster primary security group ID created by the EKS cluster on 1.14 or later. Referred to as 'Cluster security group' in the EKS console."
  type        = string
}

variable "worker_security_group_id" {
  description = "Security group ID attached to the EKS workers."
  type        = string
}
