variable "tags" {
  description = "A map of tags to add to all resources. Tags added to launch configuration or templates override these values for ASG Tags only"
  type        = map(string)
  default     = {}
}

variable "create" {
  description = "Controls if EKS resources should be created (it affects almost all resources)"
  type        = bool
  default     = true
}

################################################################################
# Cluster
################################################################################

variable "cluster_name" {
  description = "Name of the EKS cluster and default name (prefix) used throughout the resources created"
  type        = string
  default     = ""
}

variable "iam_role_arn" {
  description = "Existing IAM role ARN for the cluster. Required if `create_iam_role` is set to `false`"
  type        = string
  default     = null
}

variable "cluster_version" {
  description = "Kubernetes minor version to use for the EKS cluster (for example 1.21)"
  type        = string
  default     = null
}

variable "cluster_enabled_log_types" {
  description = "A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)"
  type        = list(string)
  default     = ["audit", "api", "authenticator"]
}

variable "cluster_security_group_id" {
  description = "If provided, the EKS cluster will be attached to this security group. If not given, a security group will be created with necessary ingress/egress to work with the workers"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "A list of subnet IDs to place the EKS cluster and workers within"
  type        = list(string)
  default     = []
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. When it's set to `false` ensure to have a proper private access with `cluster_endpoint_private_access = true`"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_service_ipv4_cidr" {
  description = "service ipv4 cidr for the kubernetes cluster"
  type        = string
  default     = null
}

variable "cluster_encryption_config" {
  description = "Configuration block with encryption configuration for the cluster"
  type = list(object({
    provider_key_arn = string
    resources        = list(string)
  }))
  default = []
}

variable "cluster_tags" {
  description = "A map of additional tags to add to the cluster"
  type        = map(string)
  default     = {}
}

variable "cluster_timeouts" {
  description = "Create, update, and delete timeout configurations for the cluster"
  type        = map(string)
  default     = {}
}

################################################################################
# CloudWatch Log Group
################################################################################

variable "create_cloudwatch_log_group" {
  description = "Determines whether a log group is created by this module for the cluster logs. If not, AWS will automatically create one if logging is enabled"
  type        = bool
  default     = true
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days to retain log events. Default retention - 90 days"
  type        = number
  default     = 90
}

variable "cloudwatch_log_group_kms_key_id" {
  description = "If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html)"
  type        = string
  default     = null
}

################################################################################
# Cluster Security Group
################################################################################

variable "create_cluster_security_group" {
  description = "Whether to create a security group for the cluster or use the existing `cluster_security_group_id`"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "ID of the VPC where the cluster and its nodes will be provisioned"
  type        = string
  default     = null
}

variable "cluster_security_group_name" {
  description = "Name to use on cluster security group created"
  type        = string
  default     = null
}

variable "cluster_security_group_use_name_prefix" {
  description = "Determines whether cluster security group name (`cluster_security_group_name`) is used as a prefix"
  type        = string
  default     = true
}

variable "cluster_security_group_description" {
  description = "Description of the cluster security group created"
  type        = string
  default     = "EKS cluster security group"
}

variable "cluster_additional_security_group_rules" {
  description = "List of additional security group rules to add to the cluster security group created"
  type        = map(any)
  default     = {}
}

variable "cluster_security_group_tags" {
  description = "A map of additional tags to add to the cluster security group created"
  type        = map(string)
  default     = {}
}

################################################################################
# Node Security Group
################################################################################

variable "create_node_security_group" {
  description = "Whether to create a security group for the node groups or use the existing `node_security_group_id`"
  type        = bool
  default     = true
}

variable "node_security_group_id" {
  description = "ID of an existing security group to attach to the node groups created"
  type        = string
  default     = ""
}

variable "node_security_group_name" {
  description = "Name to use on node security group created"
  type        = string
  default     = null
}

variable "node_security_group_use_name_prefix" {
  description = "Determines whether node security group name (`node_security_group_name`) is used as a prefix"
  type        = string
  default     = true
}

variable "node_security_group_description" {
  description = "Description of the node security group created"
  type        = string
  default     = "EKS node shared security group"
}

variable "node_additional_security_group_rules" {
  description = "List of additional security group rules to add to the node security group created"
  type        = map(any)
  default     = {}
}

variable "node_security_group_tags" {
  description = "A map of additional tags to add to the node security group created"
  type        = map(string)
  default     = {}
}

################################################################################
# IRSA
################################################################################

variable "enable_irsa" {
  description = "Whether to create OpenID Connect Provider for EKS to enable IRSA"
  type        = bool
  default     = false
}

variable "openid_connect_audiences" {
  description = "List of OpenID Connect audience client IDs to add to the IRSA provider"
  type        = list(string)
  default     = []
}

################################################################################
# Cluster IAM Role
################################################################################

variable "create_iam_role" {
  description = "Determines whether a cluster IAM role is created or to use an existing IAM role"
  type        = bool
  default     = true
}

variable "iam_role_name" {
  description = "Name to use on cluster role created"
  type        = string
  default     = null
}

variable "iam_role_use_name_prefix" {
  description = "Determines whether cluster IAM role name (`iam_role_name`) is used as a prefix"
  type        = string
  default     = true
}

variable "iam_role_path" {
  description = "Cluster IAM role path"
  type        = string
  default     = null
}

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the cluster role"
  type        = string
  default     = null
}

variable "iam_role_tags" {
  description = "A map of additional tags to add to the cluster IAM role created"
  type        = map(string)
  default     = {}
}

################################################################################
# Fargate
################################################################################

variable "fargate_profiles" {
  description = "Map of Fargate Profile definitions to create"
  type        = any
  default     = {}
}

variable "fargate_profile_defaults" {
  description = "Map of Fargate Profile default configurations"
  type        = any
  default     = {}
}

################################################################################
# Self Managed Node Group
################################################################################

variable "self_managed_node_groups" {
  description = "Map of self-managed node group definitions to create"
  type        = any
  default     = {}
}

variable "self_managed_node_group_defaults" {
  description = "Map of self-managed node group default configurations"
  type        = any
  default     = {}
}

################################################################################
# EKS Managed Node Group
################################################################################

variable "eks_managed_node_groups" {
  description = "Map of EKS managed node group definitions to create"
  type        = any
  default     = {}
}

variable "eks_managed_node_group_defaults" {
  description = "Map of EKS managed node group default configurations"
  type        = any
  default     = {}
}
