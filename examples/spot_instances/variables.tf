variable "region" {
  default = "us-west-2"
}

variable "create_eks" {
  default     = true
  description = "Set to false to skip creating EKS cluster."
}
