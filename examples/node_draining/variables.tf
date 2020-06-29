variable "region" {
  default = "eu-central-1"
}

variable "cluster_version" {
  default = "1.16"
}

variable "cluster_name" {
  type    = string
  default = "eks-test"
}

// https://docs.aws.amazon.com/de_de/eks/latest/userguide/eks-linux-ami-versions.html
variable "ami_version" {
  default = "v20200423"
  type    = string
}

variable "tags" {
  default = {
    Environment = "test-draining"
  }
  type = map(string)
}

variable "asg_hook_timeout" {
  default     = 360
  description = "timeout in sec to wait until lifecycle is completed. If reached the instance will complete hook and shutdown instance will continue"
}

// drainer variables
variable "drainer_enabled" {
  default = true
  type    = bool
}

variable "drainer_lambda_function_name" {
  default = "node-drainer"
  type    = string
}

variable "drainer_lambda_timeout" {
  type    = number
  default = 120
}
