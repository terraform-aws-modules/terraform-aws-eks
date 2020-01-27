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
* If `manage_aws_auth = true`, it's required that both [`kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl) (>=1.10) and [`aws-iam-authenticator`](https://github.com/kubernetes-sigs/aws-iam-authenticator#4-set-up-kubectl-to-use-authentication-tokens-provided-by-aws-iam-authenticator-for-kubernetes) are installed and on your shell's PATH.

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
  cluster_version = "1.14"
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
  host                   = element(concat(data.aws_eks_cluster.cluster[*].endpoint, list("")), 0)
  cluster_ca_certificate = base64decode(element(concat(data.aws_eks_cluster.cluster[*].certificate_authority.0.data, list("")), 0))
  token                  = element(concat(data.aws_eks_cluster_auth.cluster[*].token, list("")), 0)
  load_config_file       = false
  version                = "~> 1.10"
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

## Testing

This module has been packaged with [awspec](https://github.com/k1LoW/awspec) tests through [kitchen](https://kitchen.ci/) and [kitchen-terraform](https://newcontext-oss.github.io/kitchen-terraform/). To run them:

1. Install [rvm](https://rvm.io/rvm/install) and the ruby version specified in the [Gemfile](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/Gemfile).
2. Install bundler and the gems from our Gemfile:

    ```bash
    gem install bundler && bundle install
    ```

3. Ensure your AWS environment is configured (i.e. credentials and region) for test.
4. Test using `bundle exec kitchen test` from the root of the repo.

For now, connectivity to the kubernetes cluster is not tested but will be in the
future. Once the test fixture has converged, you can query the test cluster from
that terminal session with
```bash
kubectl get nodes --watch --kubeconfig kubeconfig
```
(using default settings `config_output_path = "./"` & `write_kubeconfig = true`)

## Doc generation

Code formatting and documentation for variables and outputs is generated using [pre-commit-terraform hooks](https://github.com/antonbabenko/pre-commit-terraform) which uses [terraform-docs](https://github.com/segmentio/terraform-docs).

Follow [these instructions](https://github.com/antonbabenko/pre-commit-terraform#how-to-install) to install pre-commit locally.

And install `terraform-docs` with `go get github.com/segmentio/terraform-docs` or `brew install terraform-docs`.

## Contributing

Report issues/questions/feature requests on in the [issues](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/new) section.

Full contributing [guidelines are covered here](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/CONTRIBUTING.md).

## Change log

The [changelog](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/CHANGELOG.md) captures all important release notes.

## Authors

Created by [Brandon O'Connor](https://github.com/brandoconnor) - brandon@atscale.run.
Maintained by [Max Williams](https://github.com/max-rocket-internet) and [Thierno IB. BARRY](https://github.com/barryib).
Many thanks to [the contributors listed here](https://github.com/terraform-aws-modules/terraform-aws-eks/graphs/contributors)!

## License

MIT Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/LICENSE) for full details.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Providers

| Name | Version |
|------|---------|
| aws | >= 2.44.0 |
| kubernetes | >= 1.6.2 |
| local | >= 1.2 |
| null | >= 2.1 |
| random | >= 2.1 |
| template | >= 2.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| attach_worker_autoscaling_policy | Whether to attach the module managed cluster autoscaling iam policy to the default worker IAM role. This requires `manage_worker_autoscaling_policy = true` | bool | `"true"` | no |
| attach_worker_cni_policy | Whether to attach the Amazon managed `AmazonEKS_CNI_Policy` IAM policy to the default worker IAM role. WARNING: If set `false` the permissions must be assigned to the `aws-node` DaemonSet pods via another method or nodes will not be able to join the cluster. | bool | `"true"` | no |
| cluster_create_timeout | Timeout value when creating the EKS cluster. | string | `"15m"` | no |
| cluster_delete_timeout | Timeout value when deleting the EKS cluster. | string | `"15m"` | no |
| cluster_enabled_log_types | A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html) | list(string) | `[]` | no |
| cluster_endpoint_private_access | Indicates whether or not the Amazon EKS private API server endpoint is enabled. | bool | `"false"` | no |
| cluster_endpoint_public_access | Indicates whether or not the Amazon EKS public API server endpoint is enabled. | bool | `"true"` | no |
| cluster_endpoint_public_access_cidrs | List of CIDR blocks which can access the Amazon EKS public API server endpoint. | list(string) | `[ "0.0.0.0/0" ]` | no |
| cluster_iam_role_name | IAM role name for the cluster. Only applicable if manage_cluster_iam_resources is set to false. | string | `""` | no |
| cluster_log_kms_key_id | If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html) | string | `""` | no |
| cluster_log_retention_in_days | Number of days to retain log events. Default retention - 90 days. | number | `"90"` | no |
| cluster_name | Name of the EKS cluster. Also used as a prefix in names of related resources. | string | n/a | yes |
| cluster_security_group_id | If provided, the EKS cluster will be attached to this security group. If not given, a security group will be created with necessary ingress/egress to work with the workers | string | `""` | no |
| cluster_version | Kubernetes version to use for the EKS cluster. | string | `"1.14"` | no |
| config_output_path | Where to save the Kubectl config file (if `write_kubeconfig = true`). Assumed to be a directory if the value ends with a forward slash `/`. | string | `"./"` | no |
| create_eks | Controls if EKS resources should be created (it affects almost all resources) | bool | `"true"` | no |
| eks_oidc_root_ca_thumbprint | Thumbprint of Root CA for EKS OIDC, Valid until 2037 | string | `"9e99a48a9960b14926bb7f3b02e22da2b0ab7280"` | no |
| enable_irsa | Whether to create OpenID Connect Provider for EKS to enable IRSA | bool | `"false"` | no |
| iam_path | If provided, all IAM roles will be created on this path. | string | `"/"` | no |
| kubeconfig_aws_authenticator_additional_args | Any additional arguments to pass to the authenticator such as the role to assume. e.g. ["-r", "MyEksRole"]. | list(string) | `[]` | no |
| kubeconfig_aws_authenticator_command | Command to use to fetch AWS EKS credentials. | string | `"aws-iam-authenticator"` | no |
| kubeconfig_aws_authenticator_command_args | Default arguments passed to the authenticator command. Defaults to [token -i $cluster_name]. | list(string) | `[]` | no |
| kubeconfig_aws_authenticator_env_variables | Environment variables that should be used when executing the authenticator. e.g. { AWS_PROFILE = "eks"}. | map(string) | `{}` | no |
| kubeconfig_name | Override the default name used for items kubeconfig. | string | `""` | no |
| manage_aws_auth | Whether to apply the aws-auth configmap file. | string | `"true"` | no |
| manage_cluster_iam_resources | Whether to let the module manage cluster IAM resources. If set to false, cluster_iam_role_name must be specified. | bool | `"true"` | no |
| manage_worker_autoscaling_policy | Whether to let the module manage the cluster autoscaling iam policy. | bool | `"true"` | no |
| manage_worker_iam_resources | Whether to let the module manage worker IAM resources. If set to false, iam_instance_profile_name must be specified for workers. | bool | `"true"` | no |
| map_accounts | Additional AWS account numbers to add to the aws-auth configmap. See examples/basic/variables.tf for example format. | list(string) | `[]` | no |
| map_roles | Additional IAM roles to add to the aws-auth configmap. See examples/basic/variables.tf for example format. | object | `[]` | no |
| map_users | Additional IAM users to add to the aws-auth configmap. See examples/basic/variables.tf for example format. | object | `[]` | no |
| node_groups | Map of map of node groups to create. See `node_groups` module's documentation for more details | any | `{}` | no |
| node_groups_defaults | Map of values to be applied to all node groups. See `node_groups` module's documentaton for more details | any | `{}` | no |
| permissions_boundary | If provided, all IAM roles will be created with this permissions boundary attached. | string | `"null"` | no |
| subnets | A list of subnets to place the EKS cluster and workers within. | list(string) | n/a | yes |
| tags | A map of tags to add to all resources. | map(string) | `{}` | no |
| vpc_id | VPC where the cluster and workers will be deployed. | string | n/a | yes |
| wait_for_cluster_cmd | Custom local-exec command to execute for determining if the eks cluster is healthy. Cluster endpoint will be available as an environment variable called ENDPOINT | string | `"until curl -k -s $ENDPOINT/healthz \u003e/dev/null; do sleep 4; done"` | no |
| worker_additional_security_group_ids | A list of additional security group ids to attach to worker instances | list(string) | `[]` | no |
| worker_ami_name_filter | Name filter for AWS EKS worker AMI. If not provided, the latest official AMI for the specified 'cluster_version' is used. | string | `""` | no |
| worker_ami_name_filter_windows | Name filter for AWS EKS Windows worker AMI. If not provided, the latest official AMI for the specified 'cluster_version' is used. | string | `""` | no |
| worker_ami_owner_id | The ID of the owner for the AMI to use for the AWS EKS workers. Valid values are an AWS account ID, 'self' (the current account), or an AWS owner alias (e.g. 'amazon', 'aws-marketplace', 'microsoft'). | string | `"602401143452"` | no |
| worker_ami_owner_id_windows | The ID of the owner for the AMI to use for the AWS EKS Windows workers. Valid values are an AWS account ID, 'self' (the current account), or an AWS owner alias (e.g. 'amazon', 'aws-marketplace', 'microsoft'). | string | `"801119661308"` | no |
| worker_create_initial_lifecycle_hooks | Whether to create initial lifecycle hooks provided in worker groups. | bool | `"false"` | no |
| worker_groups | A list of maps defining worker group configurations to be defined using AWS Launch Configurations. See workers_group_defaults for valid keys. | any | `[]` | no |
| worker_groups_launch_template | A list of maps defining worker group configurations to be defined using AWS Launch Templates. See workers_group_defaults for valid keys. | any | `[]` | no |
| worker_security_group_id | If provided, all workers will be attached to this security group. If not given, a security group will be created with necessary ingress/egress to work with the EKS cluster. | string | `""` | no |
| worker_sg_ingress_from_port | Minimum port number from which pods will accept communication. Must be changed to a lower value if some pods in your cluster will expose a port lower than 1025 (e.g. 22, 80, or 443). | number | `"1025"` | no |
| workers_additional_policies | Additional policies to be added to workers | list(string) | `[]` | no |
| workers_group_defaults | Override default values for target groups. See workers_group_defaults_defaults in local.tf for valid keys. | any | `{}` | no |
| workers_role_name | User defined workers role name. | string | `""` | no |
| write_kubeconfig | Whether to write a Kubectl config file containing the cluster configuration. Saved to `config_output_path`. | bool | `"true"` | no |


## Outputs

| Name | Description |
|------|-------------|
| cloudwatch\_log\_group\_name | Name of cloudwatch log group created |
| cluster\_arn | The Amazon Resource Name (ARN) of the cluster. |
| cluster\_certificate\_authority\_data | Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster. |
| cluster\_endpoint | The endpoint for your EKS Kubernetes API. |
| cluster\_iam\_role\_arn | IAM role ARN of the EKS cluster. |
| cluster\_iam\_role\_name | IAM role name of the EKS cluster. |
| cluster\_id | The name/id of the EKS cluster. |
| cluster\_oidc\_issuer\_url | The URL on the EKS cluster OIDC Issuer |
| cluster\_security\_group\_id | Security group ID attached to the EKS cluster. |
| cluster\_version | The Kubernetes server version for the EKS cluster. |
| config\_map\_aws\_auth | A kubernetes configuration to authenticate to this EKS cluster. |
| kubeconfig | kubectl config file contents for this EKS cluster. |
| kubeconfig\_filename | The filename of the generated kubectl config. |
| node\_groups | Outputs from EKS node groups. Map of maps, keyed by var.node\_groups keys |
| oidc\_provider\_arn | The ARN of the OIDC Provider if `enable_irsa = true`. |
| worker\_autoscaling\_policy\_arn | ARN of the worker autoscaling IAM policy if `manage_worker_autoscaling_policy = true` |
| worker\_autoscaling\_policy\_name | Name of the worker autoscaling IAM policy if `manage_worker_autoscaling_policy = true` |
| worker\_iam\_instance\_profile\_arns | default IAM instance profile ARN for EKS worker groups |
| worker\_iam\_instance\_profile\_names | default IAM instance profile name for EKS worker groups |
| worker\_iam\_role\_arn | default IAM role ARN for EKS worker groups |
| worker\_iam\_role\_name | default IAM role name for EKS worker groups |
| worker\_security\_group\_id | Security group ID attached to the EKS workers. |
| workers\_asg\_arns | IDs of the autoscaling groups containing workers. |
| workers\_asg\_names | Names of the autoscaling groups containing workers. |
| workers\_default\_ami\_id | ID of the default worker group AMI |
| workers\_launch\_template\_arns | ARNs of the worker launch templates. |
| workers\_launch\_template\_ids | IDs of the worker launch templates. |
| workers\_launch\_template\_latest\_versions | Latest versions of the worker launch templates. |
| workers\_user\_data | User data of worker groups |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
