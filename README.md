# terraform-aws-eks

[![Lint Status](https://github.com/terraform-aws-modules/terraform-aws-eks/workflows/Lint/badge.svg)](https://github.com/terraform-aws-modules/terraform-aws-eks/actions)
[![LICENSE](https://img.shields.io/github/license/terraform-aws-modules/terraform-aws-eks)](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/LICENSE)

A terraform module to create a managed Kubernetes cluster on AWS EKS. Available
through the [Terraform registry](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws).
Inspired by and adapted from [this doc](https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html)
and its [source code](https://github.com/terraform-providers/terraform-provider-aws/tree/master/examples/eks-getting-started).
Read the [AWS docs on EKS to get connected to the k8s dashboard](https://docs.aws.amazon.com/eks/latest/userguide/dashboard-tutorial.html).

## Assumptions

* You want to create an EKS cluster and an autoscaling group of workers for the cluster.
* You want these resources to exist within security groups that allow communication and coordination. These can be user provided or created within the module.
* You've created a Virtual Private Cloud (VPC) and subnets where you intend to put the EKS resources. The VPC satisfies [EKS requirements](https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html).

## Important note

The `cluster_version` is the required variable. Kubernetes is evolving a lot, and each major version includes new features, fixes, or changes.

**Always check [Kubernetes Release Notes](https://kubernetes.io/docs/setup/release/notes/) before updating the major version.**

You also need to ensure your applications and add ons are updated, or workloads could fail after the upgrade is complete. For action, you may need to take before upgrading, see the steps in the [EKS documentation](https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html).

An example of harming update was the removal of several commonly used, but deprecated  APIs, in Kubernetes 1.16. More information on the API removals, see the [Kubernetes blog post](https://kubernetes.io/blog/2019/07/18/api-deprecations-in-1-16/).

By default, this module manages the `aws-auth` configmap for you (`manage_aws_auth=true`). To avoid the following [issue](https://github.com/aws/containers-roadmap/issues/654) where the EKS creation is `ACTIVE` but not ready, we implemented a retry logic with an `local-exec` provisioner and `wget` (by default) with failover to `curl`.

**If you want to manage your `aws-auth` configmap, ensure you have `wget` (or `curl`) and `/bin/sh` installed where you're running Terraform or set `wait_for_cluster_cmd` and `wait_for_cluster_interpreter` to match your needs.**

For windows users, please read the following [doc](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/faq.md#deploying-from-windows-binsh-file-does-not-exist).

## Usage example

A full example leveraging other community modules is contained in the [examples/basic directory](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/basic).

```hcl
data "aws_eks_cluster" "cluster" {
  name = module.my-cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.my-cluster.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.9"
}

module "my-cluster" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "my-cluster"
  cluster_version = "1.17"
  subnets         = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]
  vpc_id          = "vpc-1234556abcdef"

  worker_groups = [
    {
      instance_type = "m4.large"
      asg_max_size  = 5
    }
  ]
}
```
## Conditional creation

Sometimes you need to have a way to create EKS resources conditionally but Terraform does not allow to use `count` inside `module` block, so the solution is to specify argument `create_eks`.

Using this feature _and_ having `manage_aws_auth=true` (the default) requires to set up the kubernetes provider in a way that allows the data sources to not exist.

```hcl
data "aws_eks_cluster" "cluster" {
  count = var.create_eks ? 1 : 0
  name  = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  count = var.create_eks ? 1 : 0
  name  = module.eks.cluster_id
}

# In case of not creating the cluster, this will be an incompletely configured, unused provider, which poses no problem.
provider "kubernetes" {
  host                   = element(concat(data.aws_eks_cluster.cluster[*].endpoint, [""]), 0)
  cluster_ca_certificate = base64decode(element(concat(data.aws_eks_cluster.cluster[*].certificate_authority.0.data, [""]), 0))
  token                  = element(concat(data.aws_eks_cluster_auth.cluster[*].token, [""]), 0)
  load_config_file       = false
  version                = "1.10"
}

# This cluster will not be created
module "eks" {
  source = "terraform-aws-modules/eks/aws"

  create_eks = false
  # ... omitted
}
```

## Other documentation

* [Autoscaling](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/autoscaling.md): How to enable worker node autoscaling.
* [Enable Docker Bridge Network](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/enable-docker-bridge-network.md): How to enable the docker bridge network when using the EKS-optimized AMI, which disables it by default.
* [Spot instances](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/spot-instances.md): How to use spot instances with this module.
* [IAM Permissions](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/iam-permissions.md): Minimum IAM permissions needed to setup EKS Cluster.
* [FAQ](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/faq.md): Frequently Asked Questions

## Doc generation

Code formatting and documentation for variables and outputs is generated using [pre-commit-terraform hooks](https://github.com/antonbabenko/pre-commit-terraform) which uses [terraform-docs](https://github.com/segmentio/terraform-docs).

Follow [these instructions](https://github.com/antonbabenko/pre-commit-terraform#how-to-install) to install pre-commit locally.

And install `terraform-docs` with `go get github.com/segmentio/terraform-docs` or `brew install terraform-docs`.

## Contributing

Report issues/questions/feature requests on in the [issues](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/new) section.

Full contributing [guidelines are covered here](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/.github/CONTRIBUTING.md).

## Change log

- The [changelog](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/CHANGELOG.md) captures all important release notes from v11.0.0
- For older release notes, refer to [changelog.pre-v11.0.0.md](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/CHANGELOG.pre-v11.0.0.md)

## Authors

Created by [Brandon O'Connor](https://github.com/brandoconnor) - brandon@atscale.run.
Maintained by [Max Williams](https://github.com/max-rocket-internet) and [Thierno IB. BARRY](https://github.com/barryib).
Many thanks to [the contributors listed here](https://github.com/terraform-aws-modules/terraform-aws-eks/graphs/contributors)!

## License

MIT Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/LICENSE) for full details.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.22.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 1.11.1 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 1.4 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 2.1 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 2.1 |
| <a name="requirement_template"></a> [template](#requirement\_template) | >= 2.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.22.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 1.11.1 |
| <a name="provider_local"></a> [local](#provider\_local) | >= 1.4 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 2.1 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 2.1 |
| <a name="provider_template"></a> [template](#provider\_template) | >= 2.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_fargate"></a> [fargate](#module\_fargate) | ./modules/fargate |  |
| <a name="module_node_groups"></a> [node\_groups](#module\_node\_groups) | ./modules/node_groups |  |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_autoscaling_group.workers_launch_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [aws_iam_instance_profile.workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_instance_profile.workers_launch_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_openid_connect_provider.oidc_provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_policy.cluster_elb_sl_role_creation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cluster_AmazonEKSServicePolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceControllerPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cluster_elb_sl_role_creation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.workers_AmazonEC2ContainerRegistryReadOnly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.workers_AmazonEKSWorkerNodePolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.workers_AmazonEKS_CNI_Policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.workers_additional_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_configuration.workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_configuration) | resource |
| [aws_launch_template.workers_launch_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_security_group.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.cluster_egress_internet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.cluster_https_worker_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.cluster_primary_ingress_workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.cluster_private_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.workers_egress_internet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.workers_ingress_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.workers_ingress_cluster_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.workers_ingress_cluster_kubelet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.workers_ingress_cluster_primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.workers_ingress_self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [kubernetes_config_map.aws_auth](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [local_file.kubeconfig](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [null_resource.wait_for_cluster](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_pet.workers](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [random_pet.workers_launch_template](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [aws_ami.eks_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.eks_worker_windows](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_instance_profile.custom_worker_group_iam_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_instance_profile) | data source |
| [aws_iam_instance_profile.custom_worker_group_launch_template_iam_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_instance_profile) | data source |
| [aws_iam_policy_document.cluster_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cluster_elb_sl_role_creation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.workers_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_role.custom_cluster_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [template_file.launch_template_userdata](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.userdata](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attach_worker_cni_policy"></a> [attach\_worker\_cni\_policy](#input\_attach\_worker\_cni\_policy) | Whether to attach the Amazon managed `AmazonEKS_CNI_Policy` IAM policy to the default worker IAM role. WARNING: If set `false` the permissions must be assigned to the `aws-node` DaemonSet pods via another method or nodes will not be able to join the cluster. | `bool` | `true` | no |
| <a name="input_aws_auth_additional_labels"></a> [aws\_auth\_additional\_labels](#input\_aws\_auth\_additional\_labels) | Additional kubernetes labels applied on aws-auth ConfigMap | `map(string)` | `{}` | no |
| <a name="input_cluster_create_endpoint_private_access_sg_rule"></a> [cluster\_create\_endpoint\_private\_access\_sg\_rule](#input\_cluster\_create\_endpoint\_private\_access\_sg\_rule) | Whether to create security group rules for the access to the Amazon EKS private API server endpoint. | `bool` | `false` | no |
| <a name="input_cluster_create_security_group"></a> [cluster\_create\_security\_group](#input\_cluster\_create\_security\_group) | Whether to create a security group for the cluster or attach the cluster to `cluster_security_group_id`. | `bool` | `true` | no |
| <a name="input_cluster_create_timeout"></a> [cluster\_create\_timeout](#input\_cluster\_create\_timeout) | Timeout value when creating the EKS cluster. | `string` | `"30m"` | no |
| <a name="input_cluster_delete_timeout"></a> [cluster\_delete\_timeout](#input\_cluster\_delete\_timeout) | Timeout value when deleting the EKS cluster. | `string` | `"15m"` | no |
| <a name="input_cluster_egress_cidrs"></a> [cluster\_egress\_cidrs](#input\_cluster\_egress\_cidrs) | List of CIDR blocks that are permitted for cluster egress traffic. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_cluster_enabled_log_types"></a> [cluster\_enabled\_log\_types](#input\_cluster\_enabled\_log\_types) | A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html) | `list(string)` | `[]` | no |
| <a name="input_cluster_encryption_config"></a> [cluster\_encryption\_config](#input\_cluster\_encryption\_config) | Configuration block with encryption configuration for the cluster. See examples/secrets\_encryption/main.tf for example format | <pre>list(object({<br>    provider_key_arn = string<br>    resources        = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_cluster_endpoint_private_access"></a> [cluster\_endpoint\_private\_access](#input\_cluster\_endpoint\_private\_access) | Indicates whether or not the Amazon EKS private API server endpoint is enabled. | `bool` | `false` | no |
| <a name="input_cluster_endpoint_private_access_cidrs"></a> [cluster\_endpoint\_private\_access\_cidrs](#input\_cluster\_endpoint\_private\_access\_cidrs) | List of CIDR blocks which can access the Amazon EKS private API server endpoint. | `list(string)` | `null` | no |
| <a name="input_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#input\_cluster\_endpoint\_public\_access) | Indicates whether or not the Amazon EKS public API server endpoint is enabled. | `bool` | `true` | no |
| <a name="input_cluster_endpoint_public_access_cidrs"></a> [cluster\_endpoint\_public\_access\_cidrs](#input\_cluster\_endpoint\_public\_access\_cidrs) | List of CIDR blocks which can access the Amazon EKS public API server endpoint. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_cluster_iam_role_name"></a> [cluster\_iam\_role\_name](#input\_cluster\_iam\_role\_name) | IAM role name for the cluster. If manage\_cluster\_iam\_resources is set to false, set this to reuse an existing IAM role. If manage\_cluster\_iam\_resources is set to true, set this to force the created role name. | `string` | `""` | no |
| <a name="input_cluster_log_kms_key_id"></a> [cluster\_log\_kms\_key\_id](#input\_cluster\_log\_kms\_key\_id) | If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html) | `string` | `""` | no |
| <a name="input_cluster_log_retention_in_days"></a> [cluster\_log\_retention\_in\_days](#input\_cluster\_log\_retention\_in\_days) | Number of days to retain log events. Default retention - 90 days. | `number` | `90` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster. Also used as a prefix in names of related resources. | `string` | n/a | yes |
| <a name="input_cluster_security_group_id"></a> [cluster\_security\_group\_id](#input\_cluster\_security\_group\_id) | If provided, the EKS cluster will be attached to this security group. If not given, a security group will be created with necessary ingress/egress to work with the workers | `string` | `""` | no |
| <a name="input_cluster_service_ipv4_cidr"></a> [cluster\_service\_ipv4\_cidr](#input\_cluster\_service\_ipv4\_cidr) | service ipv4 cidr for the kubernetes cluster | `string` | `null` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Kubernetes version to use for the EKS cluster. | `string` | n/a | yes |
| <a name="input_config_output_path"></a> [config\_output\_path](#input\_config\_output\_path) | Where to save the Kubectl config file (if `write_kubeconfig = true`). Assumed to be a directory if the value ends with a forward slash `/`. | `string` | `"./"` | no |
| <a name="input_create_eks"></a> [create\_eks](#input\_create\_eks) | Controls if EKS resources should be created (it affects almost all resources) | `bool` | `true` | no |
| <a name="input_create_fargate_pod_execution_role"></a> [create\_fargate\_pod\_execution\_role](#input\_create\_fargate\_pod\_execution\_role) | Controls if the EKS Fargate pod execution IAM role should be created. | `bool` | `true` | no |
| <a name="input_eks_oidc_root_ca_thumbprint"></a> [eks\_oidc\_root\_ca\_thumbprint](#input\_eks\_oidc\_root\_ca\_thumbprint) | Thumbprint of Root CA for EKS OIDC, Valid until 2037 | `string` | `"9e99a48a9960b14926bb7f3b02e22da2b0ab7280"` | no |
| <a name="input_enable_irsa"></a> [enable\_irsa](#input\_enable\_irsa) | Whether to create OpenID Connect Provider for EKS to enable IRSA | `bool` | `false` | no |
| <a name="input_fargate_pod_execution_role_name"></a> [fargate\_pod\_execution\_role\_name](#input\_fargate\_pod\_execution\_role\_name) | The IAM Role that provides permissions for the EKS Fargate Profile. | `string` | `null` | no |
| <a name="input_fargate_profiles"></a> [fargate\_profiles](#input\_fargate\_profiles) | Fargate profiles to create. See `fargate_profile` keys section in fargate submodule's README.md for more details | `any` | `{}` | no |
| <a name="input_iam_path"></a> [iam\_path](#input\_iam\_path) | If provided, all IAM roles will be created on this path. | `string` | `"/"` | no |
| <a name="input_kubeconfig_aws_authenticator_additional_args"></a> [kubeconfig\_aws\_authenticator\_additional\_args](#input\_kubeconfig\_aws\_authenticator\_additional\_args) | Any additional arguments to pass to the authenticator such as the role to assume. e.g. ["-r", "MyEksRole"]. | `list(string)` | `[]` | no |
| <a name="input_kubeconfig_aws_authenticator_command"></a> [kubeconfig\_aws\_authenticator\_command](#input\_kubeconfig\_aws\_authenticator\_command) | Command to use to fetch AWS EKS credentials. | `string` | `"aws-iam-authenticator"` | no |
| <a name="input_kubeconfig_aws_authenticator_command_args"></a> [kubeconfig\_aws\_authenticator\_command\_args](#input\_kubeconfig\_aws\_authenticator\_command\_args) | Default arguments passed to the authenticator command. Defaults to [token -i $cluster\_name]. | `list(string)` | `[]` | no |
| <a name="input_kubeconfig_aws_authenticator_env_variables"></a> [kubeconfig\_aws\_authenticator\_env\_variables](#input\_kubeconfig\_aws\_authenticator\_env\_variables) | Environment variables that should be used when executing the authenticator. e.g. { AWS\_PROFILE = "eks"}. | `map(string)` | `{}` | no |
| <a name="input_kubeconfig_name"></a> [kubeconfig\_name](#input\_kubeconfig\_name) | Override the default name used for items kubeconfig. | `string` | `""` | no |
| <a name="input_manage_aws_auth"></a> [manage\_aws\_auth](#input\_manage\_aws\_auth) | Whether to apply the aws-auth configmap file. | `bool` | `true` | no |
| <a name="input_manage_cluster_iam_resources"></a> [manage\_cluster\_iam\_resources](#input\_manage\_cluster\_iam\_resources) | Whether to let the module manage cluster IAM resources. If set to false, cluster\_iam\_role\_name must be specified. | `bool` | `true` | no |
| <a name="input_manage_worker_iam_resources"></a> [manage\_worker\_iam\_resources](#input\_manage\_worker\_iam\_resources) | Whether to let the module manage worker IAM resources. If set to false, iam\_instance\_profile\_name must be specified for workers. | `bool` | `true` | no |
| <a name="input_map_accounts"></a> [map\_accounts](#input\_map\_accounts) | Additional AWS account numbers to add to the aws-auth configmap. See examples/basic/variables.tf for example format. | `list(string)` | `[]` | no |
| <a name="input_map_roles"></a> [map\_roles](#input\_map\_roles) | Additional IAM roles to add to the aws-auth configmap. See examples/basic/variables.tf for example format. | <pre>list(object({<br>    rolearn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_map_users"></a> [map\_users](#input\_map\_users) | Additional IAM users to add to the aws-auth configmap. See examples/basic/variables.tf for example format. | <pre>list(object({<br>    userarn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_node_groups"></a> [node\_groups](#input\_node\_groups) | Map of map of node groups to create. See `node_groups` module's documentation for more details | `any` | `{}` | no |
| <a name="input_node_groups_defaults"></a> [node\_groups\_defaults](#input\_node\_groups\_defaults) | Map of values to be applied to all node groups. See `node_groups` module's documentation for more details | `any` | `{}` | no |
| <a name="input_permissions_boundary"></a> [permissions\_boundary](#input\_permissions\_boundary) | If provided, all IAM roles will be created with this permissions boundary attached. | `string` | `null` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | A list of subnets to place the EKS cluster and workers within. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. Tags added to launch configuration or templates override these values for ASG Tags only. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC where the cluster and workers will be deployed. | `string` | n/a | yes |
| <a name="input_wait_for_cluster_cmd"></a> [wait\_for\_cluster\_cmd](#input\_wait\_for\_cluster\_cmd) | Custom local-exec command to execute for determining if the eks cluster is healthy. Cluster endpoint will be available as an environment variable called ENDPOINT | `string` | `"for i in `seq 1 60`; do if `command -v wget > /dev/null`; then wget --no-check-certificate -O - -q $ENDPOINT/healthz >/dev/null && exit 0 || true; else curl -k -s $ENDPOINT/healthz >/dev/null && exit 0 || true;fi; sleep 5; done; echo TIMEOUT && exit 1"` | no |
| <a name="input_wait_for_cluster_interpreter"></a> [wait\_for\_cluster\_interpreter](#input\_wait\_for\_cluster\_interpreter) | Custom local-exec command line interpreter for the command to determining if the eks cluster is healthy. | `list(string)` | <pre>[<br>  "/bin/sh",<br>  "-c"<br>]</pre> | no |
| <a name="input_worker_additional_security_group_ids"></a> [worker\_additional\_security\_group\_ids](#input\_worker\_additional\_security\_group\_ids) | A list of additional security group ids to attach to worker instances | `list(string)` | `[]` | no |
| <a name="input_worker_ami_name_filter"></a> [worker\_ami\_name\_filter](#input\_worker\_ami\_name\_filter) | Name filter for AWS EKS worker AMI. If not provided, the latest official AMI for the specified 'cluster\_version' is used. | `string` | `""` | no |
| <a name="input_worker_ami_name_filter_windows"></a> [worker\_ami\_name\_filter\_windows](#input\_worker\_ami\_name\_filter\_windows) | Name filter for AWS EKS Windows worker AMI. If not provided, the latest official AMI for the specified 'cluster\_version' is used. | `string` | `""` | no |
| <a name="input_worker_ami_owner_id"></a> [worker\_ami\_owner\_id](#input\_worker\_ami\_owner\_id) | The ID of the owner for the AMI to use for the AWS EKS workers. Valid values are an AWS account ID, 'self' (the current account), or an AWS owner alias (e.g. 'amazon', 'aws-marketplace', 'microsoft'). | `string` | `"amazon"` | no |
| <a name="input_worker_ami_owner_id_windows"></a> [worker\_ami\_owner\_id\_windows](#input\_worker\_ami\_owner\_id\_windows) | The ID of the owner for the AMI to use for the AWS EKS Windows workers. Valid values are an AWS account ID, 'self' (the current account), or an AWS owner alias (e.g. 'amazon', 'aws-marketplace', 'microsoft'). | `string` | `"amazon"` | no |
| <a name="input_worker_create_cluster_primary_security_group_rules"></a> [worker\_create\_cluster\_primary\_security\_group\_rules](#input\_worker\_create\_cluster\_primary\_security\_group\_rules) | Whether to create security group rules to allow communication between pods on workers and pods using the primary cluster security group. | `bool` | `false` | no |
| <a name="input_worker_create_initial_lifecycle_hooks"></a> [worker\_create\_initial\_lifecycle\_hooks](#input\_worker\_create\_initial\_lifecycle\_hooks) | Whether to create initial lifecycle hooks provided in worker groups. | `bool` | `false` | no |
| <a name="input_worker_create_security_group"></a> [worker\_create\_security\_group](#input\_worker\_create\_security\_group) | Whether to create a security group for the workers or attach the workers to `worker_security_group_id`. | `bool` | `true` | no |
| <a name="input_worker_groups"></a> [worker\_groups](#input\_worker\_groups) | A list of maps defining worker group configurations to be defined using AWS Launch Configurations. See workers\_group\_defaults for valid keys. | `any` | `[]` | no |
| <a name="input_worker_groups_launch_template"></a> [worker\_groups\_launch\_template](#input\_worker\_groups\_launch\_template) | A list of maps defining worker group configurations to be defined using AWS Launch Templates. See workers\_group\_defaults for valid keys. | `any` | `[]` | no |
| <a name="input_worker_security_group_id"></a> [worker\_security\_group\_id](#input\_worker\_security\_group\_id) | If provided, all workers will be attached to this security group. If not given, a security group will be created with necessary ingress/egress to work with the EKS cluster. | `string` | `""` | no |
| <a name="input_worker_sg_ingress_from_port"></a> [worker\_sg\_ingress\_from\_port](#input\_worker\_sg\_ingress\_from\_port) | Minimum port number from which pods will accept communication. Must be changed to a lower value if some pods in your cluster will expose a port lower than 1025 (e.g. 22, 80, or 443). | `number` | `1025` | no |
| <a name="input_workers_additional_policies"></a> [workers\_additional\_policies](#input\_workers\_additional\_policies) | Additional policies to be added to workers | `list(string)` | `[]` | no |
| <a name="input_workers_egress_cidrs"></a> [workers\_egress\_cidrs](#input\_workers\_egress\_cidrs) | List of CIDR blocks that are permitted for workers egress traffic. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_workers_group_defaults"></a> [workers\_group\_defaults](#input\_workers\_group\_defaults) | Override default values for target groups. See workers\_group\_defaults\_defaults in local.tf for valid keys. | `any` | `{}` | no |
| <a name="input_workers_role_name"></a> [workers\_role\_name](#input\_workers\_role\_name) | User defined workers role name. | `string` | `""` | no |
| <a name="input_write_kubeconfig"></a> [write\_kubeconfig](#input\_write\_kubeconfig) | Whether to write a Kubectl config file containing the cluster configuration. Saved to `config_output_path`. | `bool` | `true` | no |

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
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | The name/id of the EKS cluster. Will block on cluster creation until the cluster is really ready |
| <a name="output_cluster_oidc_issuer_url"></a> [cluster\_oidc\_issuer\_url](#output\_cluster\_oidc\_issuer\_url) | The URL on the EKS cluster OIDC Issuer |
| <a name="output_cluster_primary_security_group_id"></a> [cluster\_primary\_security\_group\_id](#output\_cluster\_primary\_security\_group\_id) | The cluster primary security group ID created by the EKS cluster on 1.14 or later. Referred to as 'Cluster security group' in the EKS console. |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | Security group ID attached to the EKS cluster. On 1.14 or later, this is the 'Additional security groups' in the EKS console. |
| <a name="output_cluster_version"></a> [cluster\_version](#output\_cluster\_version) | The Kubernetes server version for the EKS cluster. |
| <a name="output_config_map_aws_auth"></a> [config\_map\_aws\_auth](#output\_config\_map\_aws\_auth) | A kubernetes configuration to authenticate to this EKS cluster. |
| <a name="output_fargate_iam_role_arn"></a> [fargate\_iam\_role\_arn](#output\_fargate\_iam\_role\_arn) | IAM role ARN for EKS Fargate pods |
| <a name="output_fargate_iam_role_name"></a> [fargate\_iam\_role\_name](#output\_fargate\_iam\_role\_name) | IAM role name for EKS Fargate pods |
| <a name="output_fargate_profile_arns"></a> [fargate\_profile\_arns](#output\_fargate\_profile\_arns) | Amazon Resource Name (ARN) of the EKS Fargate Profiles. |
| <a name="output_fargate_profile_ids"></a> [fargate\_profile\_ids](#output\_fargate\_profile\_ids) | EKS Cluster name and EKS Fargate Profile names separated by a colon (:). |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | kubectl config file contents for this EKS cluster. |
| <a name="output_kubeconfig_filename"></a> [kubeconfig\_filename](#output\_kubeconfig\_filename) | The filename of the generated kubectl config. |
| <a name="output_node_groups"></a> [node\_groups](#output\_node\_groups) | Outputs from EKS node groups. Map of maps, keyed by var.node\_groups keys |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | The ARN of the OIDC Provider if `enable_irsa = true`. |
| <a name="output_security_group_rule_cluster_https_worker_ingress"></a> [security\_group\_rule\_cluster\_https\_worker\_ingress](#output\_security\_group\_rule\_cluster\_https\_worker\_ingress) | Security group rule responsible for allowing pods to communicate with the EKS cluster API. |
| <a name="output_worker_iam_instance_profile_arns"></a> [worker\_iam\_instance\_profile\_arns](#output\_worker\_iam\_instance\_profile\_arns) | default IAM instance profile ARN for EKS worker groups |
| <a name="output_worker_iam_instance_profile_names"></a> [worker\_iam\_instance\_profile\_names](#output\_worker\_iam\_instance\_profile\_names) | default IAM instance profile name for EKS worker groups |
| <a name="output_worker_iam_role_arn"></a> [worker\_iam\_role\_arn](#output\_worker\_iam\_role\_arn) | default IAM role ARN for EKS worker groups |
| <a name="output_worker_iam_role_name"></a> [worker\_iam\_role\_name](#output\_worker\_iam\_role\_name) | default IAM role name for EKS worker groups |
| <a name="output_worker_security_group_id"></a> [worker\_security\_group\_id](#output\_worker\_security\_group\_id) | Security group ID attached to the EKS workers. |
| <a name="output_workers_asg_arns"></a> [workers\_asg\_arns](#output\_workers\_asg\_arns) | IDs of the autoscaling groups containing workers. |
| <a name="output_workers_asg_names"></a> [workers\_asg\_names](#output\_workers\_asg\_names) | Names of the autoscaling groups containing workers. |
| <a name="output_workers_default_ami_id"></a> [workers\_default\_ami\_id](#output\_workers\_default\_ami\_id) | ID of the default worker group AMI |
| <a name="output_workers_launch_template_arns"></a> [workers\_launch\_template\_arns](#output\_workers\_launch\_template\_arns) | ARNs of the worker launch templates. |
| <a name="output_workers_launch_template_ids"></a> [workers\_launch\_template\_ids](#output\_workers\_launch\_template\_ids) | IDs of the worker launch templates. |
| <a name="output_workers_launch_template_latest_versions"></a> [workers\_launch\_template\_latest\_versions](#output\_workers\_launch\_template\_latest\_versions) | Latest versions of the worker launch templates. |
| <a name="output_workers_user_data"></a> [workers\_user\_data](#output\_workers\_user\_data) | User data of worker groups |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
