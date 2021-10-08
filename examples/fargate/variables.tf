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
