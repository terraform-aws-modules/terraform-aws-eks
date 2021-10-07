variable "cluster_enabled_log_types" {
  description = "A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)"
  type        = list(string)
  default     = []
}

variable "cluster_log_kms_key_id" {
  description = "If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html)"
  type        = string
  default     = ""
}

variable "cluster_log_retention_in_days" {
  description = "Number of days to retain log events. Default retention - 90 days."
  type        = number
  default     = 90
}

variable "cluster_name" {
  description = "Name of the EKS cluster. Also used as a prefix in names of related resources."
  type        = string
  default     = ""
}

variable "cluster_security_group_id" {
  description = "If provided, the EKS cluster will be attached to this security group. If not given, a security group will be created with necessary ingress/egress to work with the workers"
  type        = string
  default     = ""
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  type        = string
  default     = null
}

variable "kubeconfig_output_path" {
  description = "Where to save the Kubectl config file (if `write_kubeconfig = true`). Assumed to be a directory if the value ends with a forward slash `/`."
  type        = string
  default     = "./"
}

variable "kubeconfig_file_permission" {
  description = "File permission of the Kubectl config file containing cluster configuration saved to `kubeconfig_output_path.`"
  type        = string
  default     = "0600"
}

variable "write_kubeconfig" {
  description = "Whether to write a Kubectl config file containing the cluster configuration. Saved to `kubeconfig_output_path`."
  type        = bool
  default     = true
}

variable "default_platform" {
  description = "Default platform name. Valid options are `linux` and `windows`."
  type        = string
  default     = "linux"
}

variable "manage_aws_auth" {
  description = "Whether to apply the aws-auth configmap file."
  type        = bool
  default     = true
}

variable "aws_auth_additional_labels" {
  description = "Additional kubernetes labels applied on aws-auth ConfigMap"
  default     = {}
  type        = map(string)
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap. See examples/basic/variables.tf for example format."
  type        = list(string)
  default     = []
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap. See examples/basic/variables.tf for example format."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap. See examples/basic/variables.tf for example format."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "fargate_subnets" {
  description = "A list of subnets to place fargate workers within (if different from subnets)."
  type        = list(string)
  default     = []
}

variable "subnets" {
  description = "A list of subnets to place the EKS cluster and workers within."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources. Tags added to launch configuration or templates override these values for ASG Tags only."
  type        = map(string)
  default     = {}
}

variable "cluster_tags" {
  description = "A map of tags to add to just the eks resource."
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC where the cluster and workers will be deployed."
  type        = string
  default     = null
}

variable "worker_groups" {
  description = "A list of maps defining worker group configurations to be defined using AWS Launch Configurations. See workers_group_defaults for valid keys."
  type        = any
  default     = []
}

variable "workers_group_defaults" {
  description = "Override default values for target groups. See workers_group_defaults_defaults in local.tf for valid keys."
  type        = any
  default     = {}
}

variable "worker_groups_launch_template" {
  description = "A list of maps defining worker group configurations to be defined using AWS Launch Templates. See workers_group_defaults for valid keys."
  type        = any
  default     = []
}

variable "worker_security_group_id" {
  description = "If provided, all workers will be attached to this security group. If not given, a security group will be created with necessary ingress/egress to work with the EKS cluster."
  type        = string
  default     = ""
}

variable "worker_ami_name_filter" {
  description = "Name filter for AWS EKS worker AMI. If not provided, the latest official AMI for the specified 'cluster_version' is used."
  type        = string
  default     = ""
}

variable "worker_ami_name_filter_windows" {
  description = "Name filter for AWS EKS Windows worker AMI. If not provided, the latest official AMI for the specified 'cluster_version' is used."
  type        = string
  default     = ""
}

variable "worker_ami_owner_id" {
  description = "The ID of the owner for the AMI to use for the AWS EKS workers. Valid values are an AWS account ID, 'self' (the current account), or an AWS owner alias (e.g. 'amazon', 'aws-marketplace', 'microsoft')."
  type        = string
  default     = "amazon"
}

variable "worker_ami_owner_id_windows" {
  description = "The ID of the owner for the AMI to use for the AWS EKS Windows workers. Valid values are an AWS account ID, 'self' (the current account), or an AWS owner alias (e.g. 'amazon', 'aws-marketplace', 'microsoft')."
  type        = string
  default     = "amazon"
}

variable "worker_additional_security_group_ids" {
  description = "A list of additional security group ids to attach to worker instances"
  type        = list(string)
  default     = []
}

variable "worker_sg_ingress_from_port" {
  description = "Minimum port number from which pods will accept communication. Must be changed to a lower value if some pods in your cluster will expose a port lower than 1025 (e.g. 22, 80, or 443)."
  type        = number
  default     = 1025
}

variable "workers_additional_policies" {
  description = "Additional policies to be added to workers"
  type        = list(string)
  default     = []
}

variable "kubeconfig_aws_authenticator_command" {
  description = "Command to use to fetch AWS EKS credentials."
  type        = string
  default     = "aws-iam-authenticator"
}

variable "kubeconfig_aws_authenticator_command_args" {
  description = "Default arguments passed to the authenticator command. Defaults to [token -i $cluster_name]."
  type        = list(string)
  default     = []
}

variable "kubeconfig_aws_authenticator_additional_args" {
  description = "Any additional arguments to pass to the authenticator such as the role to assume. e.g. [\"-r\", \"MyEksRole\"]."
  type        = list(string)
  default     = []
}

variable "kubeconfig_aws_authenticator_env_variables" {
  description = "Environment variables that should be used when executing the authenticator. e.g. { AWS_PROFILE = \"eks\"}."
  type        = map(string)
  default     = {}
}

variable "kubeconfig_name" {
  description = "Override the default name used for items kubeconfig."
  type        = string
  default     = ""
}

variable "cluster_create_timeout" {
  description = "Timeout value when creating the EKS cluster."
  type        = string
  default     = "30m"
}

variable "cluster_delete_timeout" {
  description = "Timeout value when deleting the EKS cluster."
  type        = string
  default     = "15m"
}

variable "cluster_update_timeout" {
  description = "Timeout value when updating the EKS cluster."
  type        = string
  default     = "60m"
}

variable "cluster_create_security_group" {
  description = "Whether to create a security group for the cluster or attach the cluster to `cluster_security_group_id`."
  type        = bool
  default     = true
}

variable "worker_create_security_group" {
  description = "Whether to create a security group for the workers or attach the workers to `worker_security_group_id`."
  type        = bool
  default     = true
}

variable "worker_create_initial_lifecycle_hooks" {
  description = "Whether to create initial lifecycle hooks provided in worker groups."
  type        = bool
  default     = false
}

variable "worker_create_cluster_primary_security_group_rules" {
  description = "Whether to create security group rules to allow communication between pods on workers and pods using the primary cluster security group."
  type        = bool
  default     = false
}

variable "permissions_boundary" {
  description = "If provided, all IAM roles will be created with this permissions boundary attached."
  type        = string
  default     = null
}

variable "iam_path" {
  description = "If provided, all IAM roles will be created on this path."
  type        = string
  default     = "/"
}

variable "cluster_create_endpoint_private_access_sg_rule" {
  description = "Whether to create security group rules for the access to the Amazon EKS private API server endpoint. When is `true`, `cluster_endpoint_private_access_cidrs` must be setted."
  type        = bool
  default     = false
}

variable "cluster_endpoint_private_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS private API server endpoint. To use this `cluster_endpoint_private_access` and `cluster_create_endpoint_private_access_sg_rule` must be set to `true`."
  type        = list(string)
  default     = null
}

variable "cluster_endpoint_private_access_sg" {
  description = "List of security group IDs which can access the Amazon EKS private API server endpoint. To use this `cluster_endpoint_private_access` and `cluster_create_endpoint_private_access_sg_rule` must be set to `true`."
  type        = list(string)
  default     = null
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. When it's set to `false` ensure to have a proper private access with `cluster_endpoint_private_access = true`."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "manage_cluster_iam_resources" {
  description = "Whether to let the module manage cluster IAM resources. If set to false, cluster_iam_role_name must be specified."
  type        = bool
  default     = true
}

variable "cluster_iam_role_name" {
  description = "IAM role name for the cluster. If manage_cluster_iam_resources is set to false, set this to reuse an existing IAM role. If manage_cluster_iam_resources is set to true, set this to force the created role name."
  type        = string
  default     = ""
}

variable "manage_worker_iam_resources" {
  description = "Whether to let the module manage worker IAM resources. If set to false, iam_instance_profile_name must be specified for workers."
  type        = bool
  default     = true
}

variable "workers_role_name" {
  description = "User defined workers role name."
  type        = string
  default     = ""
}

variable "attach_worker_cni_policy" {
  description = "Whether to attach the Amazon managed `AmazonEKS_CNI_Policy` IAM policy to the default worker IAM role. WARNING: If set `false` the permissions must be assigned to the `aws-node` DaemonSet pods via another method or nodes will not be able to join the cluster."
  type        = bool
  default     = true
}

variable "create_eks" {
  description = "Controls if EKS resources should be created (it affects almost all resources)"
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

variable "enable_irsa" {
  description = "Whether to create OpenID Connect Provider for EKS to enable IRSA"
  type        = bool
  default     = false
}

variable "eks_oidc_root_ca_thumbprint" {
  type        = string
  description = "Thumbprint of Root CA for EKS OIDC, Valid until 2037"
  default     = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
}

variable "cluster_encryption_config" {
  description = "Configuration block with encryption configuration for the cluster. See examples/secrets_encryption/main.tf for example format"
  type = list(object({
    provider_key_arn = string
    resources        = list(string)
  }))
  default = []
}

variable "fargate_profiles" {
  description = "Fargate profiles to create. See `fargate_profile` keys section in fargate submodule's README.md for more details"
  type        = any
  default     = {}
}

variable "create_fargate_pod_execution_role" {
  description = "Controls if the EKS Fargate pod execution IAM role should be created."
  type        = bool
  default     = true
}

variable "fargate_pod_execution_role_name" {
  description = "The IAM Role that provides permissions for the EKS Fargate Profile."
  type        = string
  default     = null
}

variable "cluster_service_ipv4_cidr" {
  description = "service ipv4 cidr for the kubernetes cluster"
  type        = string
  default     = null
}

variable "cluster_egress_cidrs" {
  description = "List of CIDR blocks that are permitted for cluster egress traffic."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "workers_egress_cidrs" {
  description = "List of CIDR blocks that are permitted for workers egress traffic."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "wait_for_cluster_timeout" {
  description = "A timeout (in seconds) to wait for cluster to be available."
  type        = number
  default     = 300
}

variable "openid_connect_audiences" {
  description = "List of OpenID Connect audience client IDs to add to the IRSA provider."
  type        = list(string)
  default     = []
}

