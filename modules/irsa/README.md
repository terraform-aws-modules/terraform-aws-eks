# IAM Roles For Service Account

Configuration in this directory creates an an IAM role, Kubernetes namespace, and Kubernetes service account to provide an [IAM role for service account](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)

## Usage

The most common and straightforward way is quite simply:

```hcl
module "irsa" {
  source = "terraform-aws-modules/eks/aws//modules/irsa"

  # Name will be used across IAM role, namespace, and service account
  name         = "example
  cluster_name = "example-eks-cluster"

  iam_role_additional_policies = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
```

However, the full suite of configuration options are available to users as well:

```hcl
module "irsa" {
  source = "terraform-aws-modules/eks/aws//modules/irsa"

  cluster_name = "example-eks-cluster"
  # Annotations and labels that are not namespace or service account specific
  # are applied across both namespace and service account
  annotations = {
    global = "annotation"
  }
  labels = {
    global = "label"
  }

  # IAM Role
  iam_role_name        = "example"
  iam_role_description = "Example IRSA role"

  iam_role_additional_policies  = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
  iam_role_max_session_duration = 7200

  # Namespace
  namespace_name = "example-ns"
  namespace_annotations = {
    namespace = true
  }
  namespace_labels = {
    namespace = true
  }
  namespace_timeouts = {
    delete = "10m"
  }

  # Service Account
  service_account_name            = "example-sa"
  automount_service_account_token = false
  service_account_annotations = {
    service_account = true
  }
  service_account_labels = {
    service_account = true
  }
  image_pull_secrets = [
    "one",
    "two",
  ]
  secrets = [
    "three",
    "four",
  ]

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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.72 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [kubernetes_namespace_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_service_account_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account_v1) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_annotations"></a> [annotations](#input\_annotations) | A map of annotations to add to all Kubernetes resources (namespace and service account) | `map(string)` | `{}` | no |
| <a name="input_automount_service_account_token"></a> [automount\_service\_account\_token](#input\_automount\_service\_account\_token) | Determines whether to automatically mount the service account token into pods. Defaults to `true` | `bool` | `null` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster associated with the OIDC provider | `string` | `""` | no |
| <a name="input_create"></a> [create](#input\_create) | Determines whether to create IRSA resources or not (affects all resources) | `bool` | `true` | no |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | Determines whether to create a Kubernetes namespace | `bool` | `true` | no |
| <a name="input_create_service_account"></a> [create\_service\_account](#input\_create\_service\_account) | Determines whether to create a Kubernetes service account | `bool` | `true` | no |
| <a name="input_iam_role_additional_policies"></a> [iam\_role\_additional\_policies](#input\_iam\_role\_additional\_policies) | Additional policies to be added to the IAM role | `list(string)` | `[]` | no |
| <a name="input_iam_role_description"></a> [iam\_role\_description](#input\_iam\_role\_description) | Description of the role | `string` | `null` | no |
| <a name="input_iam_role_max_session_duration"></a> [iam\_role\_max\_session\_duration](#input\_iam\_role\_max\_session\_duration) | Maximum session duration (in seconds) that you want to set for the specified role. If you do not specify a value for this setting, the default maximum of one hour is applied | `number` | `null` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name to use on IAM role created | `string` | `null` | no |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | IAM role path | `string` | `null` | no |
| <a name="input_iam_role_permissions_boundary"></a> [iam\_role\_permissions\_boundary](#input\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM role | `string` | `null` | no |
| <a name="input_iam_role_use_name_prefix"></a> [iam\_role\_use\_name\_prefix](#input\_iam\_role\_use\_name\_prefix) | Determines whether the IAM role name (`iam_role_name`) is used as a prefix | `string` | `true` | no |
| <a name="input_image_pull_secrets"></a> [image\_pull\_secrets](#input\_image\_pull\_secrets) | A list of image pull secrets to add to the Kubernetes service account | `list(string)` | `[]` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | A map of labels to add to all Kubernetes resources (namespace and service account) | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Name that when provided, is used across all resources created | `string` | `""` | no |
| <a name="input_namespace_annotations"></a> [namespace\_annotations](#input\_namespace\_annotations) | A map of annotations to add to the Kubernetes namespace | `map(string)` | `{}` | no |
| <a name="input_namespace_labels"></a> [namespace\_labels](#input\_namespace\_labels) | A map of labels to add to the Kubernetes namespace | `map(string)` | `{}` | no |
| <a name="input_namespace_name"></a> [namespace\_name](#input\_namespace\_name) | The name of the Kubernetes namespace - either created or existing | `string` | `""` | no |
| <a name="input_namespace_timeouts"></a> [namespace\_timeouts](#input\_namespace\_timeouts) | Timeout configurations for the cluster - currently only `delete` is supported | `map(string)` | `{}` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | A list of Kubernetes secrets to add to the Kubernetes service account | `list(string)` | `[]` | no |
| <a name="input_service_account_annotations"></a> [service\_account\_annotations](#input\_service\_account\_annotations) | A map of annotations to add to the Kubernetes service account | `map(string)` | `{}` | no |
| <a name="input_service_account_labels"></a> [service\_account\_labels](#input\_service\_account\_labels) | A map of labels to add to the Kubernetes service account | `map(string)` | `{}` | no |
| <a name="input_service_account_name"></a> [service\_account\_name](#input\_service\_account\_name) | The name of the Kubernetes namespace - either created or existing | `string` | `""` | no |
| <a name="input_service_account_namespace"></a> [service\_account\_namespace](#input\_service\_account\_namespace) | The name of an existing Kubernetes namespace to create the service account in (`create_service_account` must be `false`) | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | The Amazon Resource Name (ARN) specifying the IAM role |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | The name of the IAM role |
| <a name="output_iam_role_unique_id"></a> [iam\_role\_unique\_id](#output\_iam\_role\_unique\_id) | Stable and unique string identifying the IAM role |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | The full map of attributes for the namespace created |
| <a name="output_service_account"></a> [service\_account](#output\_service\_account) | The full map of attributes for the service account created |
| <a name="output_service_account_name"></a> [service\_account\_name](#output\_service\_account\_name) | The full map of attributes for the service account created |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
