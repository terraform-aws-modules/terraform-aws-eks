variable "cluster_enabled_log_types" {
  default     = []
  description = "A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)"
  type        = "list"
}

variable "cluster_name" {
  description = "Name of the EKS cluster. Also used as a prefix in names of related resources."
}

variable "cluster_security_group_id" {
  description = "If provided, the EKS cluster will be attached to this security group. If not given, a security group will be created with necessary ingres/egress to work with the workers and provide API access to your current IP/32."
  default     = ""
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  default     = "1.12"
}

variable "config_output_path" {
  description = "Where to save the Kubectl config file (if `write_kubeconfig = true`). Should end in a forward slash `/` ."
  default     = "./"
}

variable "write_kubeconfig" {
  description = "Whether to write a Kubectl config file containing the cluster configuration. Saved to `config_output_path`."
  default     = true
}

variable "manage_aws_auth" {
  description = "Whether to apply the aws-auth configmap file."
  default     = true
}

variable "write_aws_auth_config" {
  description = "Whether to write the aws-auth configmap file."
  default     = true
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap. See examples/basic/variables.tf for example format."
  type        = "list"
  default     = []
}

variable "map_accounts_count" {
  description = "The count of accounts in the map_accounts list."
  type        = "string"
  default     = 0
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap. See examples/basic/variables.tf for example format."
  type        = "list"
  default     = []
}

variable "map_roles_count" {
  description = "The count of roles in the map_roles list."
  type        = "string"
  default     = 0
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap. See examples/basic/variables.tf for example format."
  type        = "list"
  default     = []
}

variable "map_users_count" {
  description = "The count of roles in the map_users list."
  type        = "string"
  default     = 0
}

variable "subnets" {
  description = "A list of subnets to place the EKS cluster and workers within."
  type        = "list"
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = "map"
  default     = {}
}

variable "vpc_id" {
  description = "VPC where the cluster and workers will be deployed."
}

variable "worker_groups" {
  description = "A list of maps defining worker group configurations to be defined using AWS Launch Configurations. See workers_group_defaults for valid keys."
  type        = "list"

  default = [
    {
      "name" = "default"
    },
  ]
}

variable "worker_group_count" {
  description = "The number of maps contained within the worker_groups list."
  type        = "string"
  default     = "1"
}

variable "workers_group_defaults" {
  description = "Override default values for target groups. See workers_group_defaults_defaults in local.tf for valid keys."
  type        = "map"
  default     = {}
}

variable "worker_group_tags" {
  description = "A map defining extra tags to be applied to the worker group ASG."
  type        = "map"

  default = {
    default = []
  }
}

variable "worker_groups_launch_template" {
  description = "A list of maps defining worker group configurations to be defined using AWS Launch Templates. See workers_group_defaults for valid keys."
  type        = "list"

  default = [
    {
      "name" = "default"
    },
  ]
}

variable "worker_groups_launch_template_mixed" {
  description = "A list of maps defining worker group configurations to be defined using AWS Launch Templates. See workers_group_defaults for valid keys."
  type        = "list"

  default = [
    {
      "name" = "default"
    },
  ]
}

variable "worker_group_launch_template_mixed_count" {
  description = "The number of maps contained within the worker_groups_launch_template_mixed list."
  type        = "string"
  default     = "0"
}

variable "worker_group_launch_template_count" {
  description = "The number of maps contained within the worker_groups_launch_template list."
  type        = "string"
  default     = "0"
}

variable "worker_security_group_id" {
  description = "If provided, all workers will be attached to this security group. If not given, a security group will be created with necessary ingres/egress to work with the EKS cluster."
  default     = ""
}

variable "worker_ami_name_filter" {
  description = "Additional name filter for AWS EKS worker AMI. Default behaviour will get latest for the cluster_version but could be set to a release from amazon-eks-ami, e.g. \"v20190220\""
  default     = "v*"
}

variable "worker_additional_security_group_ids" {
  description = "A list of additional security group ids to attach to worker instances"
  type        = "list"
  default     = []
}

variable "worker_sg_ingress_from_port" {
  description = "Minimum port number from which pods will accept communication. Must be changed to a lower value if some pods in your cluster will expose a port lower than 1025 (e.g. 22, 80, or 443)."
  default     = "1025"
}

variable "workers_additional_policies" {
  description = "Additional policies to be added to workers"
  type        = "list"
  default     = []
}

variable "workers_additional_policies_count" {
  default = 0
}

variable "kubeconfig_aws_authenticator_command" {
  description = "Command to use to fetch AWS EKS credentials."
  default     = "aws-iam-authenticator"
}

variable "kubeconfig_aws_authenticator_command_args" {
  description = "Default arguments passed to the authenticator command. Defaults to [token -i $cluster_name]."
  type        = "list"
  default     = []
}

variable "kubeconfig_aws_authenticator_additional_args" {
  description = "Any additional arguments to pass to the authenticator such as the role to assume. e.g. [\"-r\", \"MyEksRole\"]."
  type        = "list"
  default     = []
}

variable "kubeconfig_aws_authenticator_env_variables" {
  description = "Environment variables that should be used when executing the authenticator. e.g. { AWS_PROFILE = \"eks\"}."
  type        = "map"
  default     = {}
}

variable "kubeconfig_name" {
  description = "Override the default name used for items kubeconfig."
  default     = ""
}

variable "cluster_create_timeout" {
  description = "Timeout value when creating the EKS cluster."
  default     = "15m"
}

variable "cluster_delete_timeout" {
  description = "Timeout value when deleting the EKS cluster."
  default     = "15m"
}

variable "local_exec_interpreter" {
  description = "Command to run for local-exec resources. Must be a shell-style interpreter. If you are on Windows Git Bash is a good choice."
  type        = "list"
  default     = ["/bin/sh", "-c"]
}

variable "cluster_create_security_group" {
  description = "Whether to create a security group for the cluster or attach the cluster to `cluster_security_group_id`."
  default     = true
}

variable "worker_create_security_group" {
  description = "Whether to create a security group for the workers or attach the workers to `worker_security_group_id`."
  default     = true
}

variable "permissions_boundary" {
  description = "If provided, all IAM roles will be created with this permissions boundary attached."
  default     = ""
}

variable "iam_path" {
  description = "If provided, all IAM roles will be created on this path."
  default     = "/"
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
  default     = false
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled."
  default     = true
}

variable "manage_cluster_iam_resources" {
  description = "Whether to let the module manage cluster IAM resources. If set to false, cluster_iam_role_name must be specified."
  default     = true
}

variable "cluster_iam_role_name" {
  description = "IAM role name for the cluster. Only applicable if manage_cluster_iam_resources is set to false."
  default     = ""
}

variable "manage_worker_iam_resources" {
  description = "Whether to let the module manage worker IAM resources. If set to false, iam_instance_profile_name must be specified for workers."
  default     = true
}
