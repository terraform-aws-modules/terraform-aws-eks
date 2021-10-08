variable "region" {
  description = "AWS region where example will be created"
  type        = string
  default     = "eu-west-1"
}

variable "cluster_version" {
  description = "EKS version"
  type        = string
  default     = "1.20"
}

variable "instance_types" {
  description = "Instance types"
  # Smallest recommended, where ~1.1Gb of 2Gb memory is available for the Kubernetes pods after ‘warming up’ Docker, Kubelet, and OS
  type    = list(string)
  default = ["t3.small"]
}
