variable "cluster_name" {
  description = "Name of parent cluster."
  type        = string
}

variable "profiles" {
  description = "EKS Fargate profiles to create."
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
