variable "region" {
  type        = string
  description = "AWS region where example will be created"
  default     = "eu-west-1"
}

variable "example_name" {
  type        = string
  description = "Example name"
  default     = "instance_refresh"
}

variable "cluster_version" {
  type        = string
  description = "EKS version"
  default     = "1.20"
}

variable "aws_node_termination_handler_chart_version" {
  description = "Version of the aws-node-termination-handler Helm chart to install."
  type        = string
  default     = "0.15.0"
}

variable "namespace" {
  description = "Namespace for the aws-node-termination-handler."
  type        = string
  default     = "kube-system"
}

variable "serviceaccount" {
  description = "Serviceaccount for the aws-node-termination-handler."
  type        = string
  default     = "aws-node-termination-handler"
}
