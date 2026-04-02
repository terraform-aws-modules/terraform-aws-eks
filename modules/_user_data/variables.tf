variable "create" {
  description = "Determines whether to create user-data or not"
  type        = bool
  default     = true
  nullable    = false
}

variable "ami_type" {
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group. See the [AWS documentation](https://docs.aws.amazon.com/eks/latest/APIReference/API_Nodegroup.html#AmazonEKS-Type-Nodegroup-amiType) for valid values"
  type        = string
  default     = "AL2023_x86_64_STANDARD"
  nullable    = false
}

variable "enable_bootstrap_user_data" {
  description = "Determines whether the bootstrap configurations are populated within the user data template"
  type        = bool
  default     = false
  nullable    = false
}

variable "is_eks_managed_node_group" {
  description = "Determines whether the user data is used on nodes in an EKS managed node group. Used to determine if user data will be appended or not"
  type        = bool
  default     = true
  nullable    = false
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = ""
  nullable    = false
}

variable "cluster_endpoint" {
  description = "Endpoint of associated EKS cluster"
  type        = string
  default     = ""
  nullable    = false
}

variable "cluster_auth_base64" {
  description = "Base64 encoded CA of associated EKS cluster"
  type        = string
  default     = ""
  nullable    = false
}

variable "cluster_service_cidr" {
  description = "The CIDR block (IPv4 or IPv6) used by the cluster to assign Kubernetes service IP addresses. This is derived from the cluster itself"
  type        = string
  default     = ""
  nullable    = false
}

variable "cluster_ip_family" {
  description = "The IP family used to assign Kubernetes pod and service addresses. Valid values are `ipv4` (default) and `ipv6`"
  type        = string
  default     = "ipv4"
  nullable    = false
}

variable "additional_cluster_dns_ips" {
  description = "Additional DNS IP addresses to use for the cluster. Only used when `ami_type` = `BOTTLEROCKET_*`"
  type        = list(string)
  default     = []
  nullable    = false
}

variable "pre_bootstrap_user_data" {
  description = "User data that is injected into the user data script ahead of the EKS bootstrap script. Not used when `ami_type` = `BOTTLEROCKET_*`"
  type        = string
  default     = ""
  nullable    = false
}

variable "post_bootstrap_user_data" {
  description = "User data that is appended to the user data script after of the EKS bootstrap script. Not used when `ami_type` = `BOTTLEROCKET_*`"
  type        = string
  default     = ""
  nullable    = false
}

variable "bootstrap_extra_args" {
  description = "Additional arguments passed to the bootstrap script. When `ami_type` = `BOTTLEROCKET_*`; these are additional [settings](https://github.com/bottlerocket-os/bottlerocket#settings) that are provided to the Bottlerocket user data"
  type        = string
  default     = ""
  nullable    = false
}

variable "user_data_template_path" {
  description = "Path to a local, custom user data template file to use when rendering user data"
  type        = string
  default     = ""
  nullable    = false
}

variable "cloudinit_pre_nodeadm" {
  description = "Array of cloud-init document parts that are created before the nodeadm document part"
  type = list(object({
    content      = string
    content_type = optional(string)
    filename     = optional(string)
    merge_type   = optional(string)
  }))
  default  = []
  nullable = false
}

variable "cloudinit_post_nodeadm" {
  description = "Array of cloud-init document parts that are created after the nodeadm document part"
  type = list(object({
    content      = string
    content_type = optional(string)
    filename     = optional(string)
    merge_type   = optional(string)
  }))
  default  = []
  nullable = false
}
