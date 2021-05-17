variable "region" {
  default = "us-west-2"
}

variable "aws_node_termination_handler_chart_version" {
  description = "Version of the aws-node-termination-handler Helm chart to install."
  default     = "0.15.0"
}

variable "namespace" {
  description = "Namespace for the aws-node-termination-handler."
  default     = "kube-system"
}

variable "serviceaccount" {
  description = "Serviceaccount for the aws-node-termination-handler."
  default     = "aws-node-termination-handler"
}
