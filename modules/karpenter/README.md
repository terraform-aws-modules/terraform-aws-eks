# Karpenter Module

Configuration in this directory creates the AWS resources required by Karpenter

## Usage

### All Resources (Default)

In the following example, the Karpenter module will create:
- An IAM role for service accounts (IRSA) with a narrowly scoped IAM policy for the Karpenter controller to utilize
- An IAM role and instance profile for the nodes created by Karpenter to utilize
  - Note: This IAM role ARN will need to be added to the `aws-auth` configmap for nodes to join the cluster successfully
- An SQS queue and Eventbridge event rules for Karpenter to utilize for spot termination handling, capacity rebalancing, etc.

This setup is great for running Karpenter on EKS Fargate:

```hcl
module "eks" {
  source = "terraform-aws-modules/eks"

  # Shown just for connection between cluster and Karpenter sub-module below
  manage_aws_auth_configmap = true
  aws_auth_roles = [
    # We need to add in the Karpenter node IAM role for nodes launched by Karpenter
    {
      rolearn  = module.karpenter.role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = [
        "system:bootstrappers",
        "system:nodes",
      ]
    },
  ]
  ...
}

module "karpenter" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"

  cluster_name = module.eks.cluster_name

  irsa_oidc_provider_arn          = module.eks.oidc_provider_arn
  irsa_namespace_service_accounts = ["karpenter:karpenter"]

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

### External Node IAM Role (Default)

In the following example, the Karpenter module will create:
- An IAM role for service accounts (IRSA) with a narrowly scoped IAM policy for the Karpenter controller to utilize
- An IAM instance profile for the nodes created by Karpenter to utilize
  - Note: This setup will utilize the existing IAM role created by the EKS Managed Node group which means the role is already populated in the `aws-auth` configmap and no further updates are required.
- An SQS queue and Eventbridge event rules for Karpenter to utilize for spot termination handling, capacity rebalancing, etc.

In this scenario, Karpenter would run atop the EKS Managed Node group and scale out nodes as needed from there:

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

  irsa_oidc_provider_arn          = module.eks.oidc_provider_arn
  irsa_namespace_service_accounts = ["karpenter:karpenter"]

  create_iam_role = false
  iam_role_arn    = module.eks.eks_managed_node_groups["initial"].iam_role_arn

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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.47 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.47 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.irsa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.irsa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.irsa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.irsa_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_sqs_queue.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.irsa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.irsa_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_ip_family"></a> [cluster\_ip\_family](#input\_cluster\_ip\_family) | The IP family used to assign Kubernetes pod and service addresses. Valid values are `ipv4` (default) and `ipv6` | `string` | `null` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the EKS cluster | `string` | `""` | no |
| <a name="input_create"></a> [create](#input\_create) | Determines whether to create EKS managed node group or not | `bool` | `true` | no |
| <a name="input_create_iam_role"></a> [create\_iam\_role](#input\_create\_iam\_role) | Determines whether an IAM role is created or to use an existing IAM role | `bool` | `true` | no |
| <a name="input_create_instance_profile"></a> [create\_instance\_profile](#input\_create\_instance\_profile) | Whether to create an IAM instance profile | `bool` | `true` | no |
| <a name="input_create_irsa"></a> [create\_irsa](#input\_create\_irsa) | Determines whether an IAM role for service accounts is created | `bool` | `true` | no |
| <a name="input_enable_spot_termination"></a> [enable\_spot\_termination](#input\_enable\_spot\_termination) | Determines whether to enable native spot termination handling | `bool` | `true` | no |
| <a name="input_iam_role_additional_policies"></a> [iam\_role\_additional\_policies](#input\_iam\_role\_additional\_policies) | Additional policies to be added to the IAM role | `list(string)` | `[]` | no |
| <a name="input_iam_role_arn"></a> [iam\_role\_arn](#input\_iam\_role\_arn) | Existing IAM role ARN for the IAM instance profile. Required if `create_iam_role` is set to `false` | `string` | `null` | no |
| <a name="input_iam_role_attach_cni_policy"></a> [iam\_role\_attach\_cni\_policy](#input\_iam\_role\_attach\_cni\_policy) | Whether to attach the `AmazonEKS_CNI_Policy`/`AmazonEKS_CNI_IPv6_Policy` IAM policy to the IAM IAM role. WARNING: If set `false` the permissions must be assigned to the `aws-node` DaemonSet pods via another method or nodes will not be able to join the cluster | `bool` | `true` | no |
| <a name="input_iam_role_description"></a> [iam\_role\_description](#input\_iam\_role\_description) | Description of the role | `string` | `null` | no |
| <a name="input_iam_role_max_session_duration"></a> [iam\_role\_max\_session\_duration](#input\_iam\_role\_max\_session\_duration) | Maximum API session duration in seconds between 3600 and 43200 | `number` | `null` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name to use on IAM role created | `string` | `null` | no |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | IAM role path | `string` | `"/"` | no |
| <a name="input_iam_role_permissions_boundary"></a> [iam\_role\_permissions\_boundary](#input\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM role | `string` | `null` | no |
| <a name="input_iam_role_tags"></a> [iam\_role\_tags](#input\_iam\_role\_tags) | A map of additional tags to add to the IAM role created | `map(string)` | `{}` | no |
| <a name="input_iam_role_use_name_prefix"></a> [iam\_role\_use\_name\_prefix](#input\_iam\_role\_use\_name\_prefix) | Determines whether the IAM role name (`iam_role_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_irsa_assume_role_condition_test"></a> [irsa\_assume\_role\_condition\_test](#input\_irsa\_assume\_role\_condition\_test) | Name of the [IAM condition operator](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_condition_operators.html) to evaluate when assuming the role | `string` | `"StringEquals"` | no |
| <a name="input_irsa_description"></a> [irsa\_description](#input\_irsa\_description) | IAM role for service accounts description | `string` | `"Karpenter IAM role for service account"` | no |
| <a name="input_irsa_max_session_duration"></a> [irsa\_max\_session\_duration](#input\_irsa\_max\_session\_duration) | Maximum API session duration in seconds between 3600 and 43200 | `number` | `null` | no |
| <a name="input_irsa_name"></a> [irsa\_name](#input\_irsa\_name) | Name of IAM role for service accounts | `string` | `null` | no |
| <a name="input_irsa_namespace_service_accounts"></a> [irsa\_namespace\_service\_accounts](#input\_irsa\_namespace\_service\_accounts) | List of `namespace:serviceaccount`pairs to use in trust policy for IAM role for service accounts | `list(string)` | <pre>[<br>  "karpenter:karpenter"<br>]</pre> | no |
| <a name="input_irsa_oidc_provider_arn"></a> [irsa\_oidc\_provider\_arn](#input\_irsa\_oidc\_provider\_arn) | OIDC provider arn used in trust policy for IAM role for service accounts | `string` | `""` | no |
| <a name="input_irsa_path"></a> [irsa\_path](#input\_irsa\_path) | Path of IAM role for service accounts | `string` | `"/"` | no |
| <a name="input_irsa_permissions_boundary_arn"></a> [irsa\_permissions\_boundary\_arn](#input\_irsa\_permissions\_boundary\_arn) | Permissions boundary ARN to use for IAM role for service accounts | `string` | `null` | no |
| <a name="input_irsa_policy_name"></a> [irsa\_policy\_name](#input\_irsa\_policy\_name) | Name of IAM policy for service accounts | `string` | `null` | no |
| <a name="input_irsa_ssm_parameter_arns"></a> [irsa\_ssm\_parameter\_arns](#input\_irsa\_ssm\_parameter\_arns) | List of SSM Parameter ARNs that contain AMI IDs launched by Karpenter | `list(string)` | <pre>[<br>  "arn:aws:ssm:*:*:parameter/aws/service/*"<br>]</pre> | no |
| <a name="input_irsa_subnet_account_id"></a> [irsa\_subnet\_account\_id](#input\_irsa\_subnet\_account\_id) | Account ID of where the subnets Karpenter will utilize resides. Used when subnets are shared from another account | `string` | `""` | no |
| <a name="input_irsa_tag_key"></a> [irsa\_tag\_key](#input\_irsa\_tag\_key) | Tag key (`{key = value}`) applied to resources launched by Karpenter through the Karpenter provisioner | `string` | `"karpenter.sh/discovery"` | no |
| <a name="input_irsa_tags"></a> [irsa\_tags](#input\_irsa\_tags) | A map of additional tags to add the the IAM role for service accounts | `map(any)` | `{}` | no |
| <a name="input_irsa_use_name_prefix"></a> [irsa\_use\_name\_prefix](#input\_irsa\_use\_name\_prefix) | Determines whether the IAM role for service accounts name (`irsa_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_policies"></a> [policies](#input\_policies) | Policies to attach to the IAM role in `{'static_name' = 'policy_arn'}` format | `map(string)` | `{}` | no |
| <a name="input_queue_kms_data_key_reuse_period_seconds"></a> [queue\_kms\_data\_key\_reuse\_period\_seconds](#input\_queue\_kms\_data\_key\_reuse\_period\_seconds) | The length of time, in seconds, for which Amazon SQS can reuse a data key to encrypt or decrypt messages before calling AWS KMS again | `number` | `null` | no |
| <a name="input_queue_kms_master_key_id"></a> [queue\_kms\_master\_key\_id](#input\_queue\_kms\_master\_key\_id) | The ID of an AWS-managed customer master key (CMK) for Amazon SQS or a custom CMK | `string` | `null` | no |
| <a name="input_queue_managed_sse_enabled"></a> [queue\_managed\_sse\_enabled](#input\_queue\_managed\_sse\_enabled) | Boolean to enable server-side encryption (SSE) of message content with SQS-owned encryption keys | `bool` | `true` | no |
| <a name="input_queue_name"></a> [queue\_name](#input\_queue\_name) | Name of the SQS queue | `string` | `null` | no |
| <a name="input_rule_name_prefix"></a> [rule\_name\_prefix](#input\_rule\_name\_prefix) | Prefix used for all event bridge rules | `string` | `"Karpenter"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_event_rules"></a> [event\_rules](#output\_event\_rules) | Map of the event rules created and their attributes |
| <a name="output_instance_profile_arn"></a> [instance\_profile\_arn](#output\_instance\_profile\_arn) | ARN assigned by AWS to the instance profile |
| <a name="output_instance_profile_id"></a> [instance\_profile\_id](#output\_instance\_profile\_id) | Instance profile's ID |
| <a name="output_instance_profile_name"></a> [instance\_profile\_name](#output\_instance\_profile\_name) | Name of the instance profile |
| <a name="output_instance_profile_unique"></a> [instance\_profile\_unique](#output\_instance\_profile\_unique) | Stable and unique string identifying the IAM instance profile |
| <a name="output_irsa_arn"></a> [irsa\_arn](#output\_irsa\_arn) | The Amazon Resource Name (ARN) specifying the IAM role for service accounts |
| <a name="output_irsa_name"></a> [irsa\_name](#output\_irsa\_name) | The name of the IAM role for service accounts |
| <a name="output_irsa_unique_id"></a> [irsa\_unique\_id](#output\_irsa\_unique\_id) | Stable and unique string identifying the IAM role for service accounts |
| <a name="output_queue_arn"></a> [queue\_arn](#output\_queue\_arn) | The ARN of the SQS queue |
| <a name="output_queue_name"></a> [queue\_name](#output\_queue\_name) | The name of the created Amazon SQS queue |
| <a name="output_queue_url"></a> [queue\_url](#output\_queue\_url) | The URL for the created Amazon SQS queue |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | The Amazon Resource Name (ARN) specifying the IAM role |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | The name of the IAM role |
| <a name="output_role_unique_id"></a> [role\_unique\_id](#output\_role\_unique\_id) | Stable and unique string identifying the IAM role |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
