# Karpenter Module

Configuration in this directory creates the AWS resources required by Karpenter

## Usage

### All Resources (Default)

In the following example, the Karpenter module will create:
- An IAM role for use with Pod Identity and a scoped IAM policy for the Karpenter controller
- A Pod Identity association to grant Karpenter controller access provided by the IAM Role
- A Node IAM role that Karpenter will use to create an Instance Profile for the nodes to receive IAM permissions
- An access entry for the Node IAM role to allow nodes to join the cluster
- SQS queue and EventBridge event rules for Karpenter to utilize for spot termination handling, capacity re-balancing, etc.

```hcl
module "eks" {
  source = "terraform-aws-modules/eks/aws"

  ...
}

module "karpenter" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"

  cluster_name = module.eks.cluster_name

  # Attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

### Re-Use Existing Node IAM Role

In the following example, the Karpenter module will create:
- An IAM role for use with Pod Identity and a scoped IAM policy for the Karpenter controller
- SQS queue and EventBridge event rules for Karpenter to utilize for spot termination handling, capacity re-balancing, etc.

In this scenario, Karpenter will re-use an existing Node IAM role from the EKS managed node group which already has the necessary access entry permissions:

```hcl
module "eks" {
  source = "terraform-aws-modules/eks"

  # Shown just for connection between cluster and Karpenter sub-module below
  eks_managed_node_groups = {
    initial = {
      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 3
      desired_size = 1
    }
  }
  ...
}

module "karpenter" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"

  cluster_name = module.eks.cluster_name

  create_node_iam_role = false
  node_iam_role_arn    = module.eks.eks_managed_node_groups["initial"].iam_role_arn

  # Since the node group role will already have an access entry
  create_access_entry = false

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.61 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.61 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_eks_access_entry.node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_entry) | resource |
| [aws_eks_pod_identity_association.karpenter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_pod_identity_association) | resource |
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.controller_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_sqs_queue.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.controller_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.node_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.v033](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.v1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_entry_type"></a> [access\_entry\_type](#input\_access\_entry\_type) | Type of the access entry. `EC2_LINUX`, `FARGATE_LINUX`, or `EC2_WINDOWS`; defaults to `EC2_LINUX` | `string` | `"EC2_LINUX"` | no |
| <a name="input_ami_id_ssm_parameter_arns"></a> [ami\_id\_ssm\_parameter\_arns](#input\_ami\_id\_ssm\_parameter\_arns) | List of SSM Parameter ARNs that Karpenter controller is allowed read access (for retrieving AMI IDs) | `list(string)` | `[]` | no |
| <a name="input_cluster_ip_family"></a> [cluster\_ip\_family](#input\_cluster\_ip\_family) | The IP family used to assign Kubernetes pod and service addresses. Valid values are `ipv4` (default) and `ipv6`. Note: If `ipv6` is specified, the `AmazonEKS_CNI_IPv6_Policy` must exist in the account. This policy is created by the EKS module with `create_cni_ipv6_iam_policy = true` | `string` | `"ipv4"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the EKS cluster | `string` | `""` | no |
| <a name="input_create"></a> [create](#input\_create) | Controls if resources should be created (affects nearly all resources) | `bool` | `true` | no |
| <a name="input_create_access_entry"></a> [create\_access\_entry](#input\_create\_access\_entry) | Determines whether an access entry is created for the IAM role used by the node IAM role | `bool` | `true` | no |
| <a name="input_create_iam_role"></a> [create\_iam\_role](#input\_create\_iam\_role) | Determines whether an IAM role is created | `bool` | `true` | no |
| <a name="input_create_instance_profile"></a> [create\_instance\_profile](#input\_create\_instance\_profile) | Whether to create an IAM instance profile | `bool` | `false` | no |
| <a name="input_create_node_iam_role"></a> [create\_node\_iam\_role](#input\_create\_node\_iam\_role) | Determines whether an IAM role is created or to use an existing IAM role | `bool` | `true` | no |
| <a name="input_create_pod_identity_association"></a> [create\_pod\_identity\_association](#input\_create\_pod\_identity\_association) | Determines whether to create pod identity association | `bool` | `false` | no |
| <a name="input_enable_irsa"></a> [enable\_irsa](#input\_enable\_irsa) | Determines whether to enable support for IAM role for service accounts | `bool` | `false` | no |
| <a name="input_enable_pod_identity"></a> [enable\_pod\_identity](#input\_enable\_pod\_identity) | Determines whether to enable support for EKS pod identity | `bool` | `true` | no |
| <a name="input_enable_spot_termination"></a> [enable\_spot\_termination](#input\_enable\_spot\_termination) | Determines whether to enable native spot termination handling | `bool` | `true` | no |
| <a name="input_enable_v1_permissions"></a> [enable\_v1\_permissions](#input\_enable\_v1\_permissions) | Determines whether to enable permissions suitable for v1+ (`true`) or for v0.33.x-v0.37.x (`false`) | `bool` | `false` | no |
| <a name="input_iam_policy_description"></a> [iam\_policy\_description](#input\_iam\_policy\_description) | IAM policy description | `string` | `"Karpenter controller IAM policy"` | no |
| <a name="input_iam_policy_name"></a> [iam\_policy\_name](#input\_iam\_policy\_name) | Name of the IAM policy | `string` | `"KarpenterController"` | no |
| <a name="input_iam_policy_path"></a> [iam\_policy\_path](#input\_iam\_policy\_path) | Path of the IAM policy | `string` | `"/"` | no |
| <a name="input_iam_policy_statements"></a> [iam\_policy\_statements](#input\_iam\_policy\_statements) | A list of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) - used for adding specific IAM permissions as needed | `any` | `[]` | no |
| <a name="input_iam_policy_use_name_prefix"></a> [iam\_policy\_use\_name\_prefix](#input\_iam\_policy\_use\_name\_prefix) | Determines whether the name of the IAM policy (`iam_policy_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_iam_role_description"></a> [iam\_role\_description](#input\_iam\_role\_description) | IAM role description | `string` | `"Karpenter controller IAM role"` | no |
| <a name="input_iam_role_max_session_duration"></a> [iam\_role\_max\_session\_duration](#input\_iam\_role\_max\_session\_duration) | Maximum API session duration in seconds between 3600 and 43200 | `number` | `null` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name of the IAM role | `string` | `"KarpenterController"` | no |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | Path of the IAM role | `string` | `"/"` | no |
| <a name="input_iam_role_permissions_boundary_arn"></a> [iam\_role\_permissions\_boundary\_arn](#input\_iam\_role\_permissions\_boundary\_arn) | Permissions boundary ARN to use for the IAM role | `string` | `null` | no |
| <a name="input_iam_role_policies"></a> [iam\_role\_policies](#input\_iam\_role\_policies) | Policies to attach to the IAM role in `{'static_name' = 'policy_arn'}` format | `map(string)` | `{}` | no |
| <a name="input_iam_role_tags"></a> [iam\_role\_tags](#input\_iam\_role\_tags) | A map of additional tags to add the the IAM role | `map(any)` | `{}` | no |
| <a name="input_iam_role_use_name_prefix"></a> [iam\_role\_use\_name\_prefix](#input\_iam\_role\_use\_name\_prefix) | Determines whether the name of the IAM role (`iam_role_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_irsa_assume_role_condition_test"></a> [irsa\_assume\_role\_condition\_test](#input\_irsa\_assume\_role\_condition\_test) | Name of the [IAM condition operator](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_condition_operators.html) to evaluate when assuming the role | `string` | `"StringEquals"` | no |
| <a name="input_irsa_namespace_service_accounts"></a> [irsa\_namespace\_service\_accounts](#input\_irsa\_namespace\_service\_accounts) | List of `namespace:serviceaccount`pairs to use in trust policy for IAM role for service accounts | `list(string)` | <pre>[<br>  "karpenter:karpenter"<br>]</pre> | no |
| <a name="input_irsa_oidc_provider_arn"></a> [irsa\_oidc\_provider\_arn](#input\_irsa\_oidc\_provider\_arn) | OIDC provider arn used in trust policy for IAM role for service accounts | `string` | `""` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to associate with the Karpenter Pod Identity | `string` | `"kube-system"` | no |
| <a name="input_node_iam_role_additional_policies"></a> [node\_iam\_role\_additional\_policies](#input\_node\_iam\_role\_additional\_policies) | Additional policies to be added to the IAM role | `map(string)` | `{}` | no |
| <a name="input_node_iam_role_arn"></a> [node\_iam\_role\_arn](#input\_node\_iam\_role\_arn) | Existing IAM role ARN for the IAM instance profile. Required if `create_iam_role` is set to `false` | `string` | `null` | no |
| <a name="input_node_iam_role_attach_cni_policy"></a> [node\_iam\_role\_attach\_cni\_policy](#input\_node\_iam\_role\_attach\_cni\_policy) | Whether to attach the `AmazonEKS_CNI_Policy`/`AmazonEKS_CNI_IPv6_Policy` IAM policy to the IAM IAM role. WARNING: If set `false` the permissions must be assigned to the `aws-node` DaemonSet pods via another method or nodes will not be able to join the cluster | `bool` | `true` | no |
| <a name="input_node_iam_role_description"></a> [node\_iam\_role\_description](#input\_node\_iam\_role\_description) | Description of the role | `string` | `null` | no |
| <a name="input_node_iam_role_max_session_duration"></a> [node\_iam\_role\_max\_session\_duration](#input\_node\_iam\_role\_max\_session\_duration) | Maximum API session duration in seconds between 3600 and 43200 | `number` | `null` | no |
| <a name="input_node_iam_role_name"></a> [node\_iam\_role\_name](#input\_node\_iam\_role\_name) | Name to use on IAM role created | `string` | `null` | no |
| <a name="input_node_iam_role_path"></a> [node\_iam\_role\_path](#input\_node\_iam\_role\_path) | IAM role path | `string` | `"/"` | no |
| <a name="input_node_iam_role_permissions_boundary"></a> [node\_iam\_role\_permissions\_boundary](#input\_node\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM role | `string` | `null` | no |
| <a name="input_node_iam_role_tags"></a> [node\_iam\_role\_tags](#input\_node\_iam\_role\_tags) | A map of additional tags to add to the IAM role created | `map(string)` | `{}` | no |
| <a name="input_node_iam_role_use_name_prefix"></a> [node\_iam\_role\_use\_name\_prefix](#input\_node\_iam\_role\_use\_name\_prefix) | Determines whether the IAM role name (`iam_role_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_queue_kms_data_key_reuse_period_seconds"></a> [queue\_kms\_data\_key\_reuse\_period\_seconds](#input\_queue\_kms\_data\_key\_reuse\_period\_seconds) | The length of time, in seconds, for which Amazon SQS can reuse a data key to encrypt or decrypt messages before calling AWS KMS again | `number` | `null` | no |
| <a name="input_queue_kms_master_key_id"></a> [queue\_kms\_master\_key\_id](#input\_queue\_kms\_master\_key\_id) | The ID of an AWS-managed customer master key (CMK) for Amazon SQS or a custom CMK | `string` | `null` | no |
| <a name="input_queue_managed_sse_enabled"></a> [queue\_managed\_sse\_enabled](#input\_queue\_managed\_sse\_enabled) | Boolean to enable server-side encryption (SSE) of message content with SQS-owned encryption keys | `bool` | `true` | no |
| <a name="input_queue_name"></a> [queue\_name](#input\_queue\_name) | Name of the SQS queue | `string` | `null` | no |
| <a name="input_rule_name_prefix"></a> [rule\_name\_prefix](#input\_rule\_name\_prefix) | Prefix used for all event bridge rules | `string` | `"Karpenter"` | no |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | Service account to associate with the Karpenter Pod Identity | `string` | `"karpenter"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_event_rules"></a> [event\_rules](#output\_event\_rules) | Map of the event rules created and their attributes |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | The Amazon Resource Name (ARN) specifying the controller IAM role |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | The name of the controller IAM role |
| <a name="output_iam_role_unique_id"></a> [iam\_role\_unique\_id](#output\_iam\_role\_unique\_id) | Stable and unique string identifying the controller IAM role |
| <a name="output_instance_profile_arn"></a> [instance\_profile\_arn](#output\_instance\_profile\_arn) | ARN assigned by AWS to the instance profile |
| <a name="output_instance_profile_id"></a> [instance\_profile\_id](#output\_instance\_profile\_id) | Instance profile's ID |
| <a name="output_instance_profile_name"></a> [instance\_profile\_name](#output\_instance\_profile\_name) | Name of the instance profile |
| <a name="output_instance_profile_unique"></a> [instance\_profile\_unique](#output\_instance\_profile\_unique) | Stable and unique string identifying the IAM instance profile |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Namespace associated with the Karpenter Pod Identity |
| <a name="output_node_access_entry_arn"></a> [node\_access\_entry\_arn](#output\_node\_access\_entry\_arn) | Amazon Resource Name (ARN) of the node Access Entry |
| <a name="output_node_iam_role_arn"></a> [node\_iam\_role\_arn](#output\_node\_iam\_role\_arn) | The Amazon Resource Name (ARN) specifying the node IAM role |
| <a name="output_node_iam_role_name"></a> [node\_iam\_role\_name](#output\_node\_iam\_role\_name) | The name of the node IAM role |
| <a name="output_node_iam_role_unique_id"></a> [node\_iam\_role\_unique\_id](#output\_node\_iam\_role\_unique\_id) | Stable and unique string identifying the node IAM role |
| <a name="output_queue_arn"></a> [queue\_arn](#output\_queue\_arn) | The ARN of the SQS queue |
| <a name="output_queue_name"></a> [queue\_name](#output\_queue\_name) | The name of the created Amazon SQS queue |
| <a name="output_queue_url"></a> [queue\_url](#output\_queue\_url) | The URL for the created Amazon SQS queue |
| <a name="output_service_account"></a> [service\_account](#output\_service\_account) | Service Account associated with the Karpenter Pod Identity |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
