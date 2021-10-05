variable "region" {
  type        = string
  description = "AWS region where example will be created"
  default     = "eu-west-1"
}

variable "example_name" {
  type        = string
  description = "Example name"
  default     = "fargate"
}

variable "cluster_version" {
  type        = string
  description = "EKS version"
  default     = "1.20"
}
