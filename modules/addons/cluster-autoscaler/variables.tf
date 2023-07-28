variable "install" {
  description = "Enable (if true) or disable (if false) the installation of the Cluster Autoscaler."
  type        = bool
  default     = true
}

variable "time_wait" {
  description = "Time wait after cluster creation for access API Server for resource deploy."
  type        = string
  default     = "30s"
}

variable "irsa_role_name" {
  description = "Name of IAM role to Cluster Autoscaler IRSA."
  type        = string
  default     = null
}

variable "cluster_name" {
  description = "Name of associated EKS cluster"
  type        = string
  default     = null
}

variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.25`)."
  type        = string
  default     = null
}

variable "cluster_oidc_provider_arn" {
  description = "Cluster OIDC provider ARN."
  type        = string
  default     = null
}

variable "namespace" {
  description = "Namespace to install the Cluster Autoscaler release into."
  type        = string
  default     = "kube-system"
}

variable "image_tag" {
  description = "Image tag used on Cluster Autoscaler helm deploy."
  type        = string
  default     = null
}

variable "helm_release_values" {
  description = "List of values in raw yaml to pass to helm. Values will be merged, in order, as Helm does with multiple -f options."
  type        = string
  default     = null
}

variable "helm_release_version" {
  description = "Specify the exact chart version to install. If this is not specified, the latest version is installed."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}
