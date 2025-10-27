variable "create" {
  description = "Controls if resources should be created (affects nearly all resources)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = ""
}

variable "region" {
  description = "Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration"
  type        = string
  default     = null
}

################################################################################
# Karpenter controller IAM Role
################################################################################

variable "create_iam_role" {
  description = "Determines whether an IAM role is created"
  type        = bool
  default     = true
}

variable "enable_inline_policy" {
  description = "Determines whether controller role policy is inlined"
  type        = bool
  default     = false
}


variable "iam_role_name" {
  description = "Name of the IAM role"
  type        = string
  default     = "KarpenterController"
}

variable "iam_role_use_name_prefix" {
  description = "Determines whether the name of the IAM role (`iam_role_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "iam_role_path" {
  description = "Path of the IAM role"
  type        = string
  default     = "/"
}

variable "iam_role_description" {
  description = "IAM role description"
  type        = string
  default     = "Karpenter controller IAM role"
}

variable "iam_role_max_session_duration" {
  description = "Maximum API session duration in seconds between 3600 and 43200"
  type        = number
  default     = null
}

variable "iam_role_permissions_boundary_arn" {
  description = "Permissions boundary ARN to use for the IAM role"
  type        = string
  default     = null
}

variable "iam_role_tags" {
  description = "A map of additional tags to add the the IAM role"
  type        = map(string)
  default     = {}
}

variable "iam_policy_name" {
  description = "Name of the IAM policy"
  type        = string
  default     = "KarpenterController"
}

variable "iam_policy_use_name_prefix" {
  description = "Determines whether the name of the IAM policy (`iam_policy_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "iam_policy_path" {
  description = "Path of the IAM policy"
  type        = string
  default     = "/"
}

variable "iam_policy_description" {
  description = "IAM policy description"
  type        = string
  default     = "Karpenter controller IAM policy"
}

variable "iam_role_override_assume_policy_documents" {
  description = "A list of IAM policy documents to override the default assume role policy document for the Karpenter controller IAM role"
  type        = list(string)
  default     = []
}

variable "iam_role_source_assume_policy_documents" {
  description = "A list of IAM policy documents to use as a source for the assume role policy document for the Karpenter controller IAM role"
  type        = list(string)
  default     = []
}

variable "iam_policy_statements" {
  description = "A list of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) - used for adding specific IAM permissions as needed"
  type = list(object({ # TODO - change to `map(object({...}))` in next major version
    sid           = optional(string)
    actions       = optional(list(string))
    not_actions   = optional(list(string))
    effect        = optional(string)
    resources     = optional(list(string))
    not_resources = optional(list(string))
    principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })))
    not_principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })))
    condition = optional(list(object({
      test     = string
      values   = list(string)
      variable = string
    })))
  }))
  default = null
}

variable "iam_role_policies" {
  description = "Policies to attach to the IAM role in `{'static_name' = 'policy_arn'}` format"
  type        = map(string)
  default     = {}
}

variable "ami_id_ssm_parameter_arns" {
  description = "List of SSM Parameter ARNs that Karpenter controller is allowed read access (for retrieving AMI IDs)"
  type        = list(string)
  default     = []
}

################################################################################
# Pod Identity Association
################################################################################

variable "create_pod_identity_association" {
  description = "Determines whether to create pod identity association"
  type        = bool
  default     = true
}

variable "namespace" {
  description = "Namespace to associate with the Karpenter Pod Identity"
  type        = string
  default     = "kube-system"
}

variable "service_account" {
  description = "Service account to associate with the Karpenter Pod Identity"
  type        = string
  default     = "karpenter"
}

################################################################################
# Node Termination Queue
################################################################################

variable "enable_spot_termination" {
  description = "Determines whether to enable native spot termination handling"
  type        = bool
  default     = true
}

variable "queue_name" {
  description = "Name of the SQS queue"
  type        = string
  default     = null
}

variable "queue_managed_sse_enabled" {
  description = "Boolean to enable server-side encryption (SSE) of message content with SQS-owned encryption keys"
  type        = bool
  default     = true
}

variable "queue_kms_master_key_id" {
  description = "The ID of an AWS-managed customer master key (CMK) for Amazon SQS or a custom CMK"
  type        = string
  default     = null
}

variable "queue_kms_data_key_reuse_period_seconds" {
  description = "The length of time, in seconds, for which Amazon SQS can reuse a data key to encrypt or decrypt messages before calling AWS KMS again"
  type        = number
  default     = null
}

variable "queue_policy_statements" {
  description = "A list of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) - used for adding specific SQS queue policy permissions as needed"
  type = map(object({
    sid           = optional(string)
    actions       = optional(list(string))
    not_actions   = optional(list(string))
    effect        = optional(string)
    resources     = optional(list(string))
    not_resources = optional(list(string))
    principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })))
    not_principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })))
    condition = optional(list(object({
      test     = string
      values   = list(string)
      variable = string
    })))
  }))
  default = null
}

################################################################################
# Node IAM Role
################################################################################

variable "create_node_iam_role" {
  description = "Determines whether an IAM role is created or to use an existing IAM role"
  type        = bool
  default     = true
}

variable "cluster_ip_family" {
  description = "The IP family used to assign Kubernetes pod and service addresses. Valid values are `ipv4` (default) and `ipv6`. Note: If `ipv6` is specified, the `AmazonEKS_CNI_IPv6_Policy` must exist in the account. This policy is created by the EKS module with `create_cni_ipv6_iam_policy = true`"
  type        = string
  default     = "ipv4"
}

variable "node_iam_role_arn" {
  description = "Existing IAM role ARN for the IAM instance profile. Required if `create_iam_role` is set to `false`"
  type        = string
  default     = null
}

variable "node_iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
}

variable "node_iam_role_use_name_prefix" {
  description = "Determines whether the Node IAM role name (`node_iam_role_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "node_iam_role_path" {
  description = "IAM role path"
  type        = string
  default     = "/"
}

variable "node_iam_role_description" {
  description = "Description of the role"
  type        = string
  default     = null
}

variable "node_iam_role_max_session_duration" {
  description = "Maximum API session duration in seconds between 3600 and 43200"
  type        = number
  default     = null
}

variable "node_iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "node_iam_role_attach_cni_policy" {
  description = "Whether to attach the `AmazonEKS_CNI_Policy`/`AmazonEKS_CNI_IPv6_Policy` IAM policy to the IAM IAM role. WARNING: If set `false` the permissions must be assigned to the `aws-node` DaemonSet pods via another method or nodes will not be able to join the cluster"
  type        = bool
  default     = true
}

variable "node_iam_role_additional_policies" {
  description = "Additional policies to be added to the IAM role"
  type        = map(string)
  default     = {}
}

variable "node_iam_role_tags" {
  description = "A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
}

################################################################################
# Access Entry
################################################################################

variable "create_access_entry" {
  description = "Determines whether an access entry is created for the IAM role used by the node IAM role"
  type        = bool
  default     = true
}

variable "access_entry_type" {
  description = "Type of the access entry. `EC2_LINUX`, `FARGATE_LINUX`, or `EC2_WINDOWS`; defaults to `EC2_LINUX`"
  type        = string
  default     = "EC2_LINUX"
}

################################################################################
# Node IAM Instance Profile
################################################################################

variable "create_instance_profile" {
  description = "Whether to create an IAM instance profile"
  type        = bool
  default     = false
}

################################################################################
# Event Bridge Rules
################################################################################

variable "rule_name_prefix" {
  description = "Prefix used for all event bridge rules"
  type        = string
  default     = "Karpenter"
}
