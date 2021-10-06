variable "region" {
  type        = string
  description = "AWS region where example will be created"
  default     = "eu-west-1"
}

variable "example_name" {
  type        = string
  description = "Example name"
  default     = "lt_with_managed_node_groups"
}

variable "cluster_version" {
  type        = string
  description = "EKS version"
  default     = "1.20"
}

variable "instance_types" {
  description = "Instance types"
  # Smallest recommended, where ~1.1Gb of 2Gb memory is available for the Kubernetes pods after ‘warming up’ Docker, Kubelet, and OS
  type    = list(string)
  default = ["t3.small"]
}
