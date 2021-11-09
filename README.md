# AWS EKS Terraform module

[![Lint Status](https://github.com/terraform-aws-modules/terraform-aws-eks/workflows/Lint/badge.svg)](https://github.com/terraform-aws-modules/terraform-aws-eks/actions)
[![LICENSE](https://img.shields.io/github/license/terraform-aws-modules/terraform-aws-eks)](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/LICENSE)

Terraform module which creates Kubernetes cluster resources on AWS EKS.

## Features

- Create an EKS cluster
- All node types are supported:
  - [Managed Node Groups](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html)
  - [Self-managed Nodes](https://docs.aws.amazon.com/eks/latest/userguide/worker.html)
  - [Fargate](https://docs.aws.amazon.com/eks/latest/userguide/fargate.html)
- Support AWS EKS Optimized or Custom AMI
- Create or manage security groups that allow communication and coordination

## Important note

Kubernetes is evolving a lot, and each minor version includes new features, fixes, or changes.

**Always check [Kubernetes Release Notes](https://kubernetes.io/docs/setup/release/notes/) before updating the major version, and [CHANGELOG.md](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/CHANGELOG.md) for all changes in this EKS module.**

You also need to ensure that your applications and add ons are updated, or workloads could fail after the upgrade is complete. For action, you may need to take before upgrading, see the steps in the [EKS documentation](https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html).

## Usage example

```hcl
data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"

  cluster_version = "1.21"
  cluster_name    = "my-cluster"
  vpc_id          = "vpc-1234556abcdef"
  subnet_ids      = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]

  worker_groups = {
    one = {
      instance_type = "m4.large"
      asg_max_size  = 5
    }
  }
}
```

There is also a [complete example](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/complete) which shows large set of features available in the module.

## Submodules

Root module calls these modules which can also be used separately to create independent resources:

- [fargate](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/modules/fargate) - creates Fargate profiles, see [examples/fargate](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/fargate) for detailed examples.
<!--
- [node_groups](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/modules/node_groups) - creates Managed Node Group resources
-->

## Notes

- By default, this module manages the `aws-auth` configmap for you (`manage_aws_auth=true`). To avoid the following [issue](https://github.com/aws/containers-roadmap/issues/654) where the EKS creation is `ACTIVE` but not ready. We implemented a "retry" logic with a [fork of the http provider](https://github.com/terraform-aws-modules/terraform-provider-http). This fork adds the support of a self-signed CA certificate. The original PR can be found [here](https://github.com/hashicorp/terraform-provider-http/pull/29).

- Setting `instance_refresh_enabled = true` will recreate your worker nodes without draining them first. It is recommended to install [aws-node-termination-handler](https://github.com/aws/aws-node-termination-handler) for proper node draining. Find the complete example here [instance_refresh](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/instance_refresh).

## Documentation

### Official docs

- [Amazon Elastic Kubernetes Service (Amazon EKS)](https://docs.aws.amazon.com/eks/latest/userguide/).

### Module docs

- [Autoscaling](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/autoscaling.md): How to enable worker node autoscaling.
- [Enable Docker Bridge Network](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/enable-docker-bridge-network.md): How to enable the docker bridge network when using the EKS-optimized AMI, which disables it by default.
- [Spot instances](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/spot-instances.md): How to use spot instances with this module.
- [IAM Permissions](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/iam-permissions.md): Minimum IAM permissions needed to setup EKS Cluster.
- [FAQ](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/faq.md): Frequently Asked Questions

## Examples

There are detailed examples available for you to see how certain features of this module can be used in a straightforward way. Make sure to check them and run them before opening an issue. [Here](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/iam-permissions.md) you can find the list of the minimum IAM Permissions required to create EKS cluster.

- [Complete](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/complete) - Create EKS Cluster with all available workers types in various combinations with many of supported features.
- [Bottlerocket](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/bottlerocket) - Create EKS cluster using [Bottlerocket AMI](https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami-bottlerocket.html).
- [Fargate](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/fargate) - Create EKS cluster with [Fargate profiles](https://docs.aws.amazon.com/eks/latest/userguide/fargate.html) and attach Fargate profiles to an existing EKS cluster.

## Contributing

Report issues/questions/feature requests on in the [issues](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/new) section.

Full contributing [guidelines are covered here](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/.github/CONTRIBUTING.md).

## Authors

This module has been originally created by [Brandon O'Connor](https://github.com/brandoconnor), and was maintained by [Max Williams](https://github.com/max-rocket-internet), [Thierno IB. BARRY](https://github.com/barryib) and many more [contributors listed here](https://github.com/terraform-aws-modules/terraform-aws-eks/graphs/contributors)!

## License

Apache 2 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/LICENSE) for full details.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.56.0 |
| <a name="requirement_cloudinit"></a> [cloudinit](#requirement\_cloudinit) | >= 2.0.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 2.2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.56.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | >= 2.2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_fargate"></a> [fargate](#module\_fargate) | ./modules/fargate | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [aws_iam_instance_profile.worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_openid_connect_provider.oidc_provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_policy.cluster_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_security_group.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.cluster_egress_internet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.cluster_https_worker_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.cluster_primary_ingress_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.cluster_private_access_cidrs_source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.cluster_private_access_sg_source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.worker_egress_internet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.worker_ingress_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.worker_ingress_cluster_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.worker_ingress_cluster_kubelet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.worker_ingress_cluster_primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.worker_ingress_self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ami.eks_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.cluster_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cluster_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.worker_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [tls_certificate.this](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attach_worker_cni_policy"></a> [attach\_worker\_cni\_policy](#input\_attach\_worker\_cni\_policy) | Whether to attach the Amazon managed `AmazonEKS_CNI_Policy` IAM policy to the default worker IAM role. WARNING: If set `false` the permissions must be assigned to the `aws-node` DaemonSet pods via another method or nodes will not be able to join the cluster | `bool` | `true` | no |
| <a name="input_cluster_create_endpoint_private_access_sg_rule"></a> [cluster\_create\_endpoint\_private\_access\_sg\_rule](#input\_cluster\_create\_endpoint\_private\_access\_sg\_rule) | Whether to create security group rules for the access to the Amazon EKS private API server endpoint. When is `true`, `cluster_endpoint_private_access_cidrs` must be setted | `bool` | `false` | no |
| <a name="input_cluster_egress_cidrs"></a> [cluster\_egress\_cidrs](#input\_cluster\_egress\_cidrs) | List of CIDR blocks that are permitted for cluster egress traffic | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_cluster_enabled_log_types"></a> [cluster\_enabled\_log\_types](#input\_cluster\_enabled\_log\_types) | A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html) | `list(string)` | `[]` | no |
| <a name="input_cluster_encryption_config"></a> [cluster\_encryption\_config](#input\_cluster\_encryption\_config) | Configuration block with encryption configuration for the cluster. See examples/secrets\_encryption/main.tf for example format | <pre>list(object({<br>    provider_key_arn = string<br>    resources        = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_cluster_endpoint_private_access"></a> [cluster\_endpoint\_private\_access](#input\_cluster\_endpoint\_private\_access) | Indicates whether or not the Amazon EKS private API server endpoint is enabled | `bool` | `false` | no |
| <a name="input_cluster_endpoint_private_access_cidrs"></a> [cluster\_endpoint\_private\_access\_cidrs](#input\_cluster\_endpoint\_private\_access\_cidrs) | List of CIDR blocks which can access the Amazon EKS private API server endpoint. To use this `cluster_endpoint_private_access` and `cluster_create_endpoint_private_access_sg_rule` must be set to `true` | `list(string)` | `null` | no |
| <a name="input_cluster_endpoint_private_access_sg"></a> [cluster\_endpoint\_private\_access\_sg](#input\_cluster\_endpoint\_private\_access\_sg) | List of security group IDs which can access the Amazon EKS private API server endpoint. To use this `cluster_endpoint_private_access` and `cluster_create_endpoint_private_access_sg_rule` must be set to `true` | `list(string)` | `null` | no |
| <a name="input_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#input\_cluster\_endpoint\_public\_access) | Indicates whether or not the Amazon EKS public API server endpoint is enabled. When it's set to `false` ensure to have a proper private access with `cluster_endpoint_private_access = true` | `bool` | `true` | no |
| <a name="input_cluster_endpoint_public_access_cidrs"></a> [cluster\_endpoint\_public\_access\_cidrs](#input\_cluster\_endpoint\_public\_access\_cidrs) | List of CIDR blocks which can access the Amazon EKS public API server endpoint | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_cluster_iam_role_arn"></a> [cluster\_iam\_role\_arn](#input\_cluster\_iam\_role\_arn) | Existing IAM role ARN for the cluster. Required if `create_cluster_iam_role` is set to `false` | `string` | `null` | no |
| <a name="input_cluster_iam_role_name"></a> [cluster\_iam\_role\_name](#input\_cluster\_iam\_role\_name) | Name to use on cluster role created | `string` | `null` | no |
| <a name="input_cluster_iam_role_path"></a> [cluster\_iam\_role\_path](#input\_cluster\_iam\_role\_path) | Cluster IAM role path | `string` | `null` | no |
| <a name="input_cluster_iam_role_permissions_boundary"></a> [cluster\_iam\_role\_permissions\_boundary](#input\_cluster\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the cluster role | `string` | `null` | no |
| <a name="input_cluster_iam_role_tags"></a> [cluster\_iam\_role\_tags](#input\_cluster\_iam\_role\_tags) | A map of additional tags to add to the cluster IAM role created | `map(string)` | `{}` | no |
| <a name="input_cluster_iam_role_use_name_prefix"></a> [cluster\_iam\_role\_use\_name\_prefix](#input\_cluster\_iam\_role\_use\_name\_prefix) | Determines whether cluster IAM role name (`cluster_iam_role_name`) is used as a prefix | `string` | `true` | no |
| <a name="input_cluster_log_kms_key_id"></a> [cluster\_log\_kms\_key\_id](#input\_cluster\_log\_kms\_key\_id) | If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html) | `string` | `""` | no |
| <a name="input_cluster_log_retention_in_days"></a> [cluster\_log\_retention\_in\_days](#input\_cluster\_log\_retention\_in\_days) | Number of days to retain log events. Default retention - 90 days | `number` | `90` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster and default name (prefix) used throughout the resources created | `string` | `""` | no |
| <a name="input_cluster_security_group_id"></a> [cluster\_security\_group\_id](#input\_cluster\_security\_group\_id) | If provided, the EKS cluster will be attached to this security group. If not given, a security group will be created with necessary ingress/egress to work with the workers | `string` | `""` | no |
| <a name="input_cluster_security_group_name"></a> [cluster\_security\_group\_name](#input\_cluster\_security\_group\_name) | Name to use on cluster role created | `string` | `null` | no |
| <a name="input_cluster_security_group_tags"></a> [cluster\_security\_group\_tags](#input\_cluster\_security\_group\_tags) | A map of additional tags to add to the cluster security group created | `map(string)` | `{}` | no |
| <a name="input_cluster_security_group_use_name_prefix"></a> [cluster\_security\_group\_use\_name\_prefix](#input\_cluster\_security\_group\_use\_name\_prefix) | Determines whether cluster IAM role name (`cluster_iam_role_name`) is used as a prefix | `string` | `true` | no |
| <a name="input_cluster_service_ipv4_cidr"></a> [cluster\_service\_ipv4\_cidr](#input\_cluster\_service\_ipv4\_cidr) | service ipv4 cidr for the kubernetes cluster | `string` | `null` | no |
| <a name="input_cluster_tags"></a> [cluster\_tags](#input\_cluster\_tags) | A map of additional tags to add to the cluster | `map(string)` | `{}` | no |
| <a name="input_cluster_timeouts"></a> [cluster\_timeouts](#input\_cluster\_timeouts) | Create, update, and delete timeout configurations for the cluster | `map(string)` | `{}` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Kubernetes minor version to use for the EKS cluster (for example 1.21) | `string` | `null` | no |
| <a name="input_create"></a> [create](#input\_create) | Controls if EKS resources should be created (it affects almost all resources) | `bool` | `true` | no |
| <a name="input_create_cluster_iam_role"></a> [create\_cluster\_iam\_role](#input\_create\_cluster\_iam\_role) | Determines whether a cluster IAM role is created or to use an existing IAM role | `bool` | `true` | no |
| <a name="input_create_cluster_security_group"></a> [create\_cluster\_security\_group](#input\_create\_cluster\_security\_group) | Whether to create a security group for the cluster or attach the cluster to `cluster_security_group_id` | `bool` | `true` | no |
| <a name="input_create_fargate"></a> [create\_fargate](#input\_create\_fargate) | Determines whether Fargate resources are created | `bool` | `false` | no |
| <a name="input_create_fargate_pod_execution_role"></a> [create\_fargate\_pod\_execution\_role](#input\_create\_fargate\_pod\_execution\_role) | Controls if the EKS Fargate pod execution IAM role should be created | `bool` | `true` | no |
| <a name="input_create_worker_iam_role"></a> [create\_worker\_iam\_role](#input\_create\_worker\_iam\_role) | Determines whether a worker IAM role is created or to use an existing IAM role | `bool` | `true` | no |
| <a name="input_default_platform"></a> [default\_platform](#input\_default\_platform) | Default platform name. Valid options are `linux` and `windows` | `string` | `"linux"` | no |
| <a name="input_enable_irsa"></a> [enable\_irsa](#input\_enable\_irsa) | Whether to create OpenID Connect Provider for EKS to enable IRSA | `bool` | `false` | no |
| <a name="input_fargate_iam_role_path"></a> [fargate\_iam\_role\_path](#input\_fargate\_iam\_role\_path) | Fargate IAM role path | `string` | `null` | no |
| <a name="input_fargate_iam_role_permissions_boundary"></a> [fargate\_iam\_role\_permissions\_boundary](#input\_fargate\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the Fargate role | `string` | `null` | no |
| <a name="input_fargate_pod_execution_role_arn"></a> [fargate\_pod\_execution\_role\_arn](#input\_fargate\_pod\_execution\_role\_arn) | Existing Amazon Resource Name (ARN) of the IAM Role that provides permissions for the EKS Fargate Profile. Required if `create_fargate_pod_execution_role` is `false` | `string` | `null` | no |
| <a name="input_fargate_profiles"></a> [fargate\_profiles](#input\_fargate\_profiles) | Fargate profiles to create. See `fargate_profile` keys section in Fargate submodule's README.md for more details | `any` | `{}` | no |
| <a name="input_fargate_subnet_ids"></a> [fargate\_subnet\_ids](#input\_fargate\_subnet\_ids) | A list of subnet IDs to place Fargate workers within (if different from `subnet_ids`) | `list(string)` | `[]` | no |
| <a name="input_fargate_tags"></a> [fargate\_tags](#input\_fargate\_tags) | A map of additional tags to add to the Fargate resources created | `map(string)` | `{}` | no |
| <a name="input_group_default_settings"></a> [group\_default\_settings](#input\_group\_default\_settings) | Override default values for autoscaling group, node group settings | `any` | `{}` | no |
| <a name="input_iam_path"></a> [iam\_path](#input\_iam\_path) | If provided, all IAM roles will be created on this path | `string` | `"/"` | no |
| <a name="input_kubeconfig_api_version"></a> [kubeconfig\_api\_version](#input\_kubeconfig\_api\_version) | KubeConfig API version. Defaults to client.authentication.k8s.io/v1alpha1 | `string` | `"client.authentication.k8s.io/v1alpha1"` | no |
| <a name="input_kubeconfig_aws_authenticator_additional_args"></a> [kubeconfig\_aws\_authenticator\_additional\_args](#input\_kubeconfig\_aws\_authenticator\_additional\_args) | Any additional arguments to pass to the authenticator such as the role to assume. e.g. ["-r", "MyEksRole"] | `list(string)` | `[]` | no |
| <a name="input_kubeconfig_aws_authenticator_command"></a> [kubeconfig\_aws\_authenticator\_command](#input\_kubeconfig\_aws\_authenticator\_command) | Command to use to fetch AWS EKS credentials | `string` | `"aws-iam-authenticator"` | no |
| <a name="input_kubeconfig_aws_authenticator_command_args"></a> [kubeconfig\_aws\_authenticator\_command\_args](#input\_kubeconfig\_aws\_authenticator\_command\_args) | Default arguments passed to the authenticator command. Defaults to [token -i $cluster\_name] | `list(string)` | `[]` | no |
| <a name="input_kubeconfig_aws_authenticator_env_variables"></a> [kubeconfig\_aws\_authenticator\_env\_variables](#input\_kubeconfig\_aws\_authenticator\_env\_variables) | Environment variables that should be used when executing the authenticator. e.g. { AWS\_PROFILE = "eks"} | `map(string)` | `{}` | no |
| <a name="input_kubeconfig_name"></a> [kubeconfig\_name](#input\_kubeconfig\_name) | Override the default name used for items kubeconfig | `string` | `""` | no |
| <a name="input_launch_templates"></a> [launch\_templates](#input\_launch\_templates) | Map of launch template definitions to create | `map(any)` | `{}` | no |
| <a name="input_manage_worker_iam_resources"></a> [manage\_worker\_iam\_resources](#input\_manage\_worker\_iam\_resources) | Whether to let the module manage worker IAM resources. If set to false, iam\_instance\_profile\_name must be specified for workers | `bool` | `true` | no |
| <a name="input_node_groups"></a> [node\_groups](#input\_node\_groups) | Map of map of node groups to create. See `node_groups` module's documentation for more details | `any` | `{}` | no |
| <a name="input_node_groups_defaults"></a> [node\_groups\_defaults](#input\_node\_groups\_defaults) | Map of values to be applied to all node groups. See `node_groups` module's documentation for more details | `any` | `{}` | no |
| <a name="input_openid_connect_audiences"></a> [openid\_connect\_audiences](#input\_openid\_connect\_audiences) | List of OpenID Connect audience client IDs to add to the IRSA provider | `list(string)` | `[]` | no |
| <a name="input_permissions_boundary"></a> [permissions\_boundary](#input\_permissions\_boundary) | If provided, all IAM roles will be created with this permissions boundary attached | `string` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of subnet IDs to place the EKS cluster and workers within | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. Tags added to launch configuration or templates override these values for ASG Tags only | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where the cluster and workers will be provisioned | `string` | `null` | no |
| <a name="input_worker_additional_policies"></a> [worker\_additional\_policies](#input\_worker\_additional\_policies) | Additional policies to be added to workers | `list(string)` | `[]` | no |
| <a name="input_worker_ami_name_filter"></a> [worker\_ami\_name\_filter](#input\_worker\_ami\_name\_filter) | Name filter for AWS EKS worker AMI. If not provided, the latest official AMI for the specified 'cluster\_version' is used | `string` | `""` | no |
| <a name="input_worker_ami_name_filter_windows"></a> [worker\_ami\_name\_filter\_windows](#input\_worker\_ami\_name\_filter\_windows) | Name filter for AWS EKS Windows worker AMI. If not provided, the latest official AMI for the specified 'cluster\_version' is used | `string` | `""` | no |
| <a name="input_worker_ami_owner_id"></a> [worker\_ami\_owner\_id](#input\_worker\_ami\_owner\_id) | The ID of the owner for the AMI to use for the AWS EKS workers. Valid values are an AWS account ID, 'self' (the current account), or an AWS owner alias (e.g. 'amazon', 'aws-marketplace', 'microsoft') | `string` | `"amazon"` | no |
| <a name="input_worker_ami_owner_id_windows"></a> [worker\_ami\_owner\_id\_windows](#input\_worker\_ami\_owner\_id\_windows) | The ID of the owner for the AMI to use for the AWS EKS Windows workers. Valid values are an AWS account ID, 'self' (the current account), or an AWS owner alias (e.g. 'amazon', 'aws-marketplace', 'microsoft') | `string` | `"amazon"` | no |
| <a name="input_worker_create_cluster_primary_security_group_rules"></a> [worker\_create\_cluster\_primary\_security\_group\_rules](#input\_worker\_create\_cluster\_primary\_security\_group\_rules) | Whether to create security group rules to allow communication between pods on workers and pods using the primary cluster security group | `bool` | `false` | no |
| <a name="input_worker_create_security_group"></a> [worker\_create\_security\_group](#input\_worker\_create\_security\_group) | Whether to create a security group for the workers or attach the workers to `worker_security_group_id` | `bool` | `true` | no |
| <a name="input_worker_egress_cidrs"></a> [worker\_egress\_cidrs](#input\_worker\_egress\_cidrs) | List of CIDR blocks that are permitted for workers egress traffic | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_worker_groups"></a> [worker\_groups](#input\_worker\_groups) | A map of maps defining worker group configurations to be defined using AWS Launch Template | `any` | `{}` | no |
| <a name="input_worker_iam_role_name"></a> [worker\_iam\_role\_name](#input\_worker\_iam\_role\_name) | Name to use on worker role created | `string` | `null` | no |
| <a name="input_worker_iam_role_path"></a> [worker\_iam\_role\_path](#input\_worker\_iam\_role\_path) | Worker IAM role path | `string` | `null` | no |
| <a name="input_worker_iam_role_permissions_boundary"></a> [worker\_iam\_role\_permissions\_boundary](#input\_worker\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the worker role | `string` | `null` | no |
| <a name="input_worker_iam_role_tags"></a> [worker\_iam\_role\_tags](#input\_worker\_iam\_role\_tags) | A map of additional tags to add to the worker IAM role created | `map(string)` | `{}` | no |
| <a name="input_worker_iam_role_use_name_prefix"></a> [worker\_iam\_role\_use\_name\_prefix](#input\_worker\_iam\_role\_use\_name\_prefix) | Determines whether worker IAM role name (`worker_iam_role_name`) is used as a prefix | `string` | `true` | no |
| <a name="input_worker_role_name"></a> [worker\_role\_name](#input\_worker\_role\_name) | User defined workers role name | `string` | `""` | no |
| <a name="input_worker_security_group_id"></a> [worker\_security\_group\_id](#input\_worker\_security\_group\_id) | If provided, all workers will be attached to this security group. If not given, a security group will be created with necessary ingress/egress to work with the EKS cluster | `string` | `""` | no |
| <a name="input_worker_sg_ingress_from_port"></a> [worker\_sg\_ingress\_from\_port](#input\_worker\_sg\_ingress\_from\_port) | Minimum port number from which pods will accept communication. Must be changed to a lower value if some pods in your cluster will expose a port lower than 1025 (e.g. 22, 80, or 443) | `number` | `1025` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | Arn of cloudwatch log group created |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | Name of cloudwatch log group created |
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | The Amazon Resource Name (ARN) of the cluster. |
| <a name="output_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#output\_cluster\_certificate\_authority\_data) | Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster. |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | The endpoint for your EKS Kubernetes API. |
| <a name="output_cluster_iam_role_arn"></a> [cluster\_iam\_role\_arn](#output\_cluster\_iam\_role\_arn) | IAM role ARN of the EKS cluster. |
| <a name="output_cluster_iam_role_name"></a> [cluster\_iam\_role\_name](#output\_cluster\_iam\_role\_name) | IAM role name of the EKS cluster. |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | The name/id of the EKS cluster. Will block on cluster creation until the cluster is really ready. |
| <a name="output_cluster_oidc_issuer_url"></a> [cluster\_oidc\_issuer\_url](#output\_cluster\_oidc\_issuer\_url) | The URL on the EKS cluster OIDC Issuer |
| <a name="output_cluster_primary_security_group_id"></a> [cluster\_primary\_security\_group\_id](#output\_cluster\_primary\_security\_group\_id) | The cluster primary security group ID created by the EKS cluster on 1.14 or later. Referred to as 'Cluster security group' in the EKS console. |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | Security group ID attached to the EKS cluster. On 1.14 or later, this is the 'Additional security groups' in the EKS console. |
| <a name="output_cluster_version"></a> [cluster\_version](#output\_cluster\_version) | The Kubernetes server version for the EKS cluster. |
| <a name="output_fargate_iam_role_arn"></a> [fargate\_iam\_role\_arn](#output\_fargate\_iam\_role\_arn) | IAM role ARN for EKS Fargate pods |
| <a name="output_fargate_iam_role_name"></a> [fargate\_iam\_role\_name](#output\_fargate\_iam\_role\_name) | IAM role name for EKS Fargate pods |
| <a name="output_fargate_profile_arns"></a> [fargate\_profile\_arns](#output\_fargate\_profile\_arns) | Amazon Resource Name (ARN) of the EKS Fargate Profiles. |
| <a name="output_fargate_profile_ids"></a> [fargate\_profile\_ids](#output\_fargate\_profile\_ids) | EKS Cluster name and EKS Fargate Profile names separated by a colon (:). |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | The ARN of the OIDC Provider if `enable_irsa = true`. |
| <a name="output_security_group_rule_cluster_https_worker_ingress"></a> [security\_group\_rule\_cluster\_https\_worker\_ingress](#output\_security\_group\_rule\_cluster\_https\_worker\_ingress) | Security group rule responsible for allowing pods to communicate with the EKS cluster API. |
| <a name="output_worker_iam_instance_profile_arns"></a> [worker\_iam\_instance\_profile\_arns](#output\_worker\_iam\_instance\_profile\_arns) | default IAM instance profile ARN for EKS worker groups |
| <a name="output_worker_iam_instance_profile_names"></a> [worker\_iam\_instance\_profile\_names](#output\_worker\_iam\_instance\_profile\_names) | default IAM instance profile name for EKS worker groups |
| <a name="output_worker_iam_role_arn"></a> [worker\_iam\_role\_arn](#output\_worker\_iam\_role\_arn) | default IAM role ARN for EKS worker groups |
| <a name="output_worker_iam_role_name"></a> [worker\_iam\_role\_name](#output\_worker\_iam\_role\_name) | default IAM role name for EKS worker groups |
| <a name="output_worker_security_group_id"></a> [worker\_security\_group\_id](#output\_worker\_security\_group\_id) | Security group ID attached to the EKS workers. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
