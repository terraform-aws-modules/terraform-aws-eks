variable "create_vpc_cni_addon" {
  type        = bool
  description = "Controls if vpc cni addon should be deployed"
  default     = true
}

variable "create_kube_proxy_addon" {
  type        = bool
  description = "Controls if kube proxy addon should be deployed"
  default     = true
}

variable "create_coredns_addon" {
  type        = bool
  description = "Controls if coredns addon should be deployed"
  default     = true
}

variable "cluster_name" {
  type        = string
  description = "Name of parent cluster"
}


variable "cluster_version" {
  type        = string
  description = "Kubernetes version to use for the EKS cluster."
}

variable "coredns_versions" {
  # Versions are taken from https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html#updating-coredns-add-on
  type        = map(any)
  description = "The CoreDns plugin version for the corresponding version"
  default = {
    "1.18" = "v1.8.3-eksbuild.1"
    "1.19" = "v1.8.3-eksbuild.1"
    "1.20" = "v1.8.3-eksbuild.1"
  }
}


variable "kube_proxy_versions" {
  # Versions are taken from https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html#updating-kube-proxy-add-on
  type        = map(any)
  description = "The Kube proxy plugin version for the corresponding eks version"
  default = {
    "1.18" = "v1.18.8-eksbuild.1"
    "1.19" = "v1.19.6-eksbuild.2"
    "1.20" = "v1.20.4-eksbuild.2"
  }
}

variable "vpc_cni_versions" {
  # Versions are taken from https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html#updating-vpc-cni-add-on
  # Latest patch version is taken from https://github.com/aws/amazon-vpc-cni-k8s
  type        = map(any)
  description = "The VPC CNI plugin version for the corresponding eks version"
  default = {
    "1.18" = "v1.7.10-eksbuild.1"
    "1.19" = "v1.7.10-eksbuild.1"
    "1.20" = "v1.7.10-eksbuild.1"
  }
}

# Hack for a homemade `depends_on` https://discuss.hashicorp.com/t/tips-howto-implement-module-depends-on-emulation/2305/2
# Will be removed in Terraform 0.13 with the support of module's `depends_on` https://github.com/hashicorp/terraform/issues/10462
variable "eks_depends_on" {
  description = "List of references to other resources this submodule depends on."
  type        = any
  default     = null
}

variable "cluster_oidc_issuer_url" {
  type        = string
  description = "The cluster oidc issuer url"
}

variable "enable_irsa" {
  type        = bool
  description = "Whether to create iam role for vpc cni and attach it to the service account"
  default     = true
}

