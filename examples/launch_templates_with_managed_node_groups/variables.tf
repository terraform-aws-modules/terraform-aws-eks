variable "region" {
  default = "eu-central-1"
}

variable "instance_type" {
  default = "t3.small" // smallest recommended, where ~1.1Gb of 2Gb memory is available for the Kubernetes pods after ‘warming up’ Docker, Kubelet, and OS
  type    = string
}

variable "kms_key_arn" {
  default     = ""
  description = "KMS key ARN to use if you want to encrypt EKS node root volumes"
  type        = string
}
