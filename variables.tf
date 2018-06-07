variable "cluster_name" {
  description = "Name of the EKS cluster."
}

variable "vpc_id" {
  description = "VPC id where the cluster and other resources will be deployed."
}

variable "security_groups" {
  description = "The security groups to attach to the EKS cluster instances"
  type        = "list"
}

variable "subnets" {
  description = "A list of subnets to associate with the cluster's underlying instances."
  type        = "list"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}
