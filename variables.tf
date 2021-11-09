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

variable "cluster_iam_role_arn" {
  description = "Existing IAM role ARN for the cluster. Required if `create_cluster_iam_role` is set to `false`"
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
  default     = []
}

variable "cluster_security_group_id" {
  description = "If provided, the EKS cluster will be attached to this security group. If not given, a security group will be created with necessary ingress/egress to work with the workers"
  type        = string
  default     = ""
}

# TODO - split out cluster subnets vs workers
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
  description = "Configuration block with encryption configuration for the cluster. See examples/secrets_encryption/main.tf for example format"
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

variable "cluster_log_retention_in_days" {
  description = "Number of days to retain log events. Default retention - 90 days"
  type        = number
  default     = 90
}

variable "cluster_log_kms_key_id" {
  description = "If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html)"
  type        = string
  default     = ""
}

################################################################################
# Cluster Security Group
################################################################################

variable "create_cluster_security_group" {
  description = "Whether to create a security group for the cluster or attach the cluster to `cluster_security_group_id`"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "ID of the VPC where the cluster and workers will be provisioned"
  type        = string
  default     = null
}

variable "cluster_security_group_name" {
  description = "Name to use on cluster role created"
  type        = string
  default     = null
}

variable "cluster_security_group_use_name_prefix" {
  description = "Determines whether cluster IAM role name (`cluster_iam_role_name`) is used as a prefix"
  type        = string
  default     = true
}

variable "cluster_security_group_tags" {
  description = "A map of additional tags to add to the cluster security group created"
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

variable "create_cluster_iam_role" {
  description = "Determines whether a cluster IAM role is created or to use an existing IAM role"
  type        = bool
  default     = true
}

variable "cluster_iam_role_name" {
  description = "Name to use on cluster role created"
  type        = string
  default     = null
}

variable "cluster_iam_role_use_name_prefix" {
  description = "Determines whether cluster IAM role name (`cluster_iam_role_name`) is used as a prefix"
  type        = string
  default     = true
}

variable "cluster_iam_role_path" {
  description = "Cluster IAM role path"
  type        = string
  default     = null
}

variable "cluster_iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the cluster role"
  type        = string
  default     = null
}

variable "cluster_iam_role_tags" {
  description = "A map of additional tags to add to the cluster IAM role created"
  type        = map(string)
  default     = {}
}

################################################################################
# Workers IAM Role
################################################################################

variable "create_worker_iam_role" {
  description = "Determines whether a worker IAM role is created or to use an existing IAM role"
  type        = bool
  default     = true
}

variable "worker_iam_role_name" {
  description = "Name to use on worker role created"
  type        = string
  default     = null
}

variable "worker_iam_role_use_name_prefix" {
  description = "Determines whether worker IAM role name (`worker_iam_role_name`) is used as a prefix"
  type        = string
  default     = true
}

variable "worker_iam_role_path" {
  description = "Worker IAM role path"
  type        = string
  default     = null
}

variable "worker_iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the worker role"
  type        = string
  default     = null
}

variable "worker_iam_role_tags" {
  description = "A map of additional tags to add to the worker IAM role created"
  type        = map(string)
  default     = {}
}

################################################################################
# Fargate
################################################################################

variable "create_fargate" {
  description = "Determines whether Fargate resources are created"
  type        = bool
  default     = false
}

variable "create_fargate_pod_execution_role" {
  description = "Controls if the EKS Fargate pod execution IAM role should be created"
  type        = bool
  default     = true
}

variable "fargate_pod_execution_role_arn" {
  description = "Existing Amazon Resource Name (ARN) of the IAM Role that provides permissions for the EKS Fargate Profile. Required if `create_fargate_pod_execution_role` is `false`"
  type        = string
  default     = null
}

variable "fargate_subnet_ids" {
  description = "A list of subnet IDs to place Fargate workers within (if different from `subnet_ids`)"
  type        = list(string)
  default     = []
}

variable "fargate_iam_role_path" {
  description = "Fargate IAM role path"
  type        = string
  default     = null
}

variable "fargate_iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the Fargate role"
  type        = string
  default     = null
}

variable "fargate_profiles" {
  description = "Fargate profiles to create. See `fargate_profile` keys section in Fargate submodule's README.md for more details"
  type        = any
  default     = {}
}

variable "fargate_tags" {
  description = "A map of additional tags to add to the Fargate resources created"
  type        = map(string)
  default     = {}
}

################################################################################
# Node Groups
################################################################################







variable "default_platform" {
  description = "Default platform name. Valid options are `linux` and `windows`"
  type        = string
  default     = "linux"
}

variable "launch_templates" {
  description = "Map of launch template definitions to create"
  type        = map(any)
  default     = {}
}

variable "worker_groups" {
  description = "A map of maps defining worker group configurations to be defined using AWS Launch Template"
  type        = any
  default     = {}
}

variable "group_default_settings" {
  description = "Override default values for autoscaling group, node group settings"
  type        = any
  default     = {}
}

variable "worker_security_group_id" {
  description = "If provided, all workers will be attached to this security group. If not given, a security group will be created with necessary ingress/egress to work with the EKS cluster"
  type        = string
  default     = ""
}

variable "worker_ami_name_filter" {
  description = "Name filter for AWS EKS worker AMI. If not provided, the latest official AMI for the specified 'cluster_version' is used"
  type        = string
  default     = ""
}

variable "worker_ami_name_filter_windows" {
  description = "Name filter for AWS EKS Windows worker AMI. If not provided, the latest official AMI for the specified 'cluster_version' is used"
  type        = string
  default     = ""
}

variable "worker_ami_owner_id" {
  description = "The ID of the owner for the AMI to use for the AWS EKS workers. Valid values are an AWS account ID, 'self' (the current account), or an AWS owner alias (e.g. 'amazon', 'aws-marketplace', 'microsoft')"
  type        = string
  default     = "amazon"
}

variable "worker_ami_owner_id_windows" {
  description = "The ID of the owner for the AMI to use for the AWS EKS Windows workers. Valid values are an AWS account ID, 'self' (the current account), or an AWS owner alias (e.g. 'amazon', 'aws-marketplace', 'microsoft')"
  type        = string
  default     = "amazon"
}

# variable "worker_additional_security_group_ids" {
#   description = "A list of additional security group ids to attach to worker instances"
#   type        = list(string)
#   default     = []
# }

variable "worker_sg_ingress_from_port" {
  description = "Minimum port number from which pods will accept communication. Must be changed to a lower value if some pods in your cluster will expose a port lower than 1025 (e.g. 22, 80, or 443)"
  type        = number
  default     = 1025
}

variable "worker_additional_policies" {
  description = "Additional policies to be added to workers"
  type        = list(string)
  default     = []
}
variable "kubeconfig_api_version" {
  description = "KubeConfig API version. Defaults to client.authentication.k8s.io/v1alpha1"
  type        = string
  default     = "client.authentication.k8s.io/v1alpha1"

}
variable "kubeconfig_aws_authenticator_command" {
  description = "Command to use to fetch AWS EKS credentials"
  type        = string
  default     = "aws-iam-authenticator"
}

variable "kubeconfig_aws_authenticator_command_args" {
  description = "Default arguments passed to the authenticator command. Defaults to [token -i $cluster_name]"
  type        = list(string)
  default     = []
}

variable "kubeconfig_aws_authenticator_additional_args" {
  description = "Any additional arguments to pass to the authenticator such as the role to assume. e.g. [\"-r\", \"MyEksRole\"]"
  type        = list(string)
  default     = []
}

variable "kubeconfig_aws_authenticator_env_variables" {
  description = "Environment variables that should be used when executing the authenticator. e.g. { AWS_PROFILE = \"eks\"}"
  type        = map(string)
  default     = {}
}

variable "kubeconfig_name" {
  description = "Override the default name used for items kubeconfig"
  type        = string
  default     = ""
}



variable "worker_create_security_group" {
  description = "Whether to create a security group for the workers or attach the workers to `worker_security_group_id`"
  type        = bool
  default     = true
}

variable "worker_create_cluster_primary_security_group_rules" {
  description = "Whether to create security group rules to allow communication between pods on workers and pods using the primary cluster security group"
  type        = bool
  default     = false
}

variable "permissions_boundary" {
  description = "If provided, all IAM roles will be created with this permissions boundary attached"
  type        = string
  default     = null
}

variable "iam_path" {
  description = "If provided, all IAM roles will be created on this path"
  type        = string
  default     = "/"
}

variable "cluster_create_endpoint_private_access_sg_rule" {
  description = "Whether to create security group rules for the access to the Amazon EKS private API server endpoint. When is `true`, `cluster_endpoint_private_access_cidrs` must be setted"
  type        = bool
  default     = false
}

variable "cluster_endpoint_private_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS private API server endpoint. To use this `cluster_endpoint_private_access` and `cluster_create_endpoint_private_access_sg_rule` must be set to `true`"
  type        = list(string)
  default     = null
}

variable "cluster_endpoint_private_access_sg" {
  description = "List of security group IDs which can access the Amazon EKS private API server endpoint. To use this `cluster_endpoint_private_access` and `cluster_create_endpoint_private_access_sg_rule` must be set to `true`"
  type        = list(string)
  default     = null
}



variable "manage_worker_iam_resources" {
  description = "Whether to let the module manage worker IAM resources. If set to false, iam_instance_profile_name must be specified for workers"
  type        = bool
  default     = true
}

variable "worker_role_name" {
  description = "User defined workers role name"
  type        = string
  default     = ""
}

variable "attach_worker_cni_policy" {
  description = "Whether to attach the Amazon managed `AmazonEKS_CNI_Policy` IAM policy to the default worker IAM role. WARNING: If set `false` the permissions must be assigned to the `aws-node` DaemonSet pods via another method or nodes will not be able to join the cluster"
  type        = bool
  default     = true
}

variable "node_groups_defaults" {
  description = "Map of values to be applied to all node groups. See `node_groups` module's documentation for more details"
  type        = any
  default     = {}
}

variable "node_groups" {
  description = "Map of map of node groups to create. See `node_groups` module's documentation for more details"
  type        = any
  default     = {}
}

variable "cluster_egress_cidrs" {
  description = "List of CIDR blocks that are permitted for cluster egress traffic"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "worker_egress_cidrs" {
  description = "List of CIDR blocks that are permitted for workers egress traffic"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
