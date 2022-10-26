variable "region" {
  description = "The AWS region to deploy into (e.g. us-east-1)"
  type        = string
}

variable "outpost_instance_type" {
  description = "Instance type supported by the Outposts instance"
  type        = string
  default     = "m5.large"
}
