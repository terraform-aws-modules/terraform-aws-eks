# terraform-aws-eks

A terraform module to create a managed Kubernetes cluster on AWS EKS. Available
through the [Terraform registry](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws).
Inspired by and adapted from [this doc](https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html)
and its [source code](https://github.com/terraform-providers/terraform-provider-aws/tree/master/examples/eks-getting-started).
Read the [AWS docs on EKS to get connected to the k8s dashboard](https://docs.aws.amazon.com/eks/latest/userguide/dashboard-tutorial.html).

| Branch | Build status                                                                                                                                                      |
| ------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| master | [![build Status](https://travis-ci.org/terraform-aws-modules/terraform-aws-eks.svg?branch=master)](https://travis-ci.org/terraform-aws-modules/terraform-aws-eks) |

## Assumptions

* You want to create an EKS cluster and an autoscaling group of workers for the cluster.
* You want these resources to exist within security groups that allow communication and coordination. These can be user provided or created within the module.
* You've created a Virtual Private Cloud (VPC) and subnets where you intend to put the EKS resources.
* If using the default variable value (`true`) for `configure_kubectl_session`, it's required that both [`kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl) (>=1.10) and [`aws-iam-authenticator`](https://github.com/kubernetes-sigs/aws-iam-authenticator#4-set-up-kubectl-to-use-authentication-tokens-provided-by-aws-iam-authenticator-for-kubernetes) are installed and on your shell's PATH.

## Usage example

A full example leveraging other community modules is contained in the [examples/eks_test_fixture directory](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/eks_test_fixture). Here's the gist of using it via the Terraform registry:

```hcl
module "eks" {
  source                = "terraform-aws-modules/eks/aws"
  cluster_name          = "test-eks-cluster"
  subnets               = ["subnet-abcde012", "subnet-bcde012a"]
  tags                  = {
                            "Environment" = "test"
                          }
  vpc_id                = "vpc-abcde012"
}
```

## Release schedule

Generally the maintainers will try to release the module once every 2 weeks to
keep up with PR additions. If particularly pressing changes are added or maintainers
come up with the spare time (hah!), release may happen more often on occasion.

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
future. If `configure_kubectl_session` is set `true`, once the test fixture has
converged, you can query the test cluster from that terminal session with
`kubectl get nodes --watch --kubeconfig kubeconfig`.

## Doc generation

Documentation should be modified within `main.tf` and generated using [terraform-docs](https://github.com/segmentio/terraform-docs).
Generate them like so:

```bash
go get github.com/getcloudnative/terraform-docs
terraform-docs md ./ > README.md
```

## Contributing

Report issues/questions/feature requests on in the [issues](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/new) section.

Full contributing [guidelines are covered here](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/CONTRIBUTING.md).

## IAM Permissions

Testing and using this repo requires a minimum set of IAM permissions. Test permissions
are listed in the [eks_test_fixture README](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/eks_test_fixture/README.md).

## Change log

The [changelog](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/CHANGELOG.md) captures all important release notes.

## Authors

Created and maintained by [Brandon O'Connor](https://github.com/brandoconnor) - brandon@atscale.run.
Many thanks to [the contributors listed here](https://github.com/terraform-aws-modules/terraform-aws-eks/graphs/contributors)!

## License

MIT Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/LICENSE) for full details.


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| cluster_name | Name of the EKS cluster. Also used as a prefix in names of related resources. | string | - | yes |
| cluster_security_group_id | If provided, the EKS cluster will be attached to this security group. If not given, a security group will be created with necessary ingres/egress to work with the workers and provide API access to your current IP/32. | string | `` | no |
| cluster_version | Kubernetes version to use for the EKS cluster. | string | `1.10` | no |
| config_output_path | Determines where config files are placed if using configure_kubectl_session and you want config files to land outside the current working directory. Should end in a forward slash / . | string | `./` | no |
| kubeconfig_aws_authenticator_additional_args | Any additional arguments to pass to the authenticator such as the role to assume. e.g. ["-r", "MyEksRole"]. | list | `[]` | no |
| kubeconfig_aws_authenticator_command | Command to use to to fetch AWS EKS credentials. | string | `aws-iam-authenticator` | no |
| kubeconfig_aws_authenticator_env_variables | Environment variables that should be used when executing the authenticator. e.g. { AWS_PROFILE = "eks"}. | map | `{}` | no |
| kubeconfig_name | Override the default name used for items kubeconfig. | string | `` | no |
| manage_aws_auth | Whether to write and apply the aws-auth configmap file. | string | `true` | no |
| map_accounts | Additional AWS account numbers to add to the aws-auth configmap. See examples/eks_test_fixture/variables.tf for example format. | list | `[]` | no |
| map_roles | Additional IAM roles to add to the aws-auth configmap. See examples/eks_test_fixture/variables.tf for example format. | list | `[]` | no |
| map_users | Additional IAM users to add to the aws-auth configmap. See examples/eks_test_fixture/variables.tf for example format. | list | `[]` | no |
| subnets | A list of subnets to place the EKS cluster and workers within. | list | - | yes |
| tags | A map of tags to add to all resources. | map | `{}` | no |
| vpc_id | VPC where the cluster and workers will be deployed. | string | - | yes |
| worker_group_count | The number of maps contained within the worker_groups list. | string | `1` | no |
| worker_groups | A list of maps defining worker group configurations. See workers_group_defaults for valid keys. | list | `[ { "name": "default" } ]` | no |
| worker_security_group_id | If provided, all workers will be attached to this security group. If not given, a security group will be created with necessary ingres/egress to work with the EKS cluster. | string | `` | no |
| worker_sg_ingress_from_port | Minimum port number from which pods will accept communication. Must be changed to a lower value if some pods in your cluster will expose a port lower than 1025 (e.g. 22, 80, or 443). | string | `1025` | no |
| workers_group_defaults | Default values for target groups as defined by the list of maps. | map | `{ "additional_userdata": "", "ami_id": "", "asg_desired_capacity": "1", "asg_max_size": "3", "asg_min_size": "1", "distro": "amazon", "ebs_optimized": true, "instance_type": "m4.large", "key_name": "", "kubelet_node_labels": "", "name": "count.index", "pre_userdata": "", "public_ip": false, "root_iops": "0", "root_volume_size": "100", "root_volume_type": "gp2", "spot_price": "", "subnets": "" }` | no |
| write_kubeconfig | Whether to write a kubeconfig file containing the cluster configuration. | string | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_certificate_authority_data | Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster. |
| cluster_endpoint | The endpoint for your EKS Kubernetes API. |
| cluster_id | The name/id of the EKS cluster. |
| cluster_security_group_id | Security group ID attached to the EKS cluster. |
| cluster_version | The Kubernetes server version for the EKS cluster. |
| config_map_aws_auth | A kubernetes configuration to authenticate to this EKS cluster. |
| kubeconfig | kubectl config file contents for this EKS cluster. |
| worker_iam_role_arn | IAM role ID attached to EKS workers |
| worker_iam_role_name | IAM role name attached to EKS workers |
| worker_security_group_id | Security group ID attached to the EKS workers. |
| workers_asg_arns | IDs of the autoscaling groups containing workers. |
| workers_asg_names | Names of the autoscaling groups containing workers. |

