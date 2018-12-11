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
* If `manage_aws_auth = true`, it's required that both [`kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl) (>=1.10) and [`aws-iam-authenticator`](https://github.com/kubernetes-sigs/aws-iam-authenticator#4-set-up-kubectl-to-use-authentication-tokens-provided-by-aws-iam-authenticator-for-kubernetes) are installed and on your shell's PATH.

## Usage example

A full example leveraging other community modules is contained in the [examples/eks_test_fixture directory](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/eks_test_fixture). Here's the gist of using it via the Terraform registry:

```hcl
module "eks" {
  source                = "terraform-aws-modules/eks/aws"
  cluster_name          = "test-eks-cluster"
  subnets               = ["subnet-abcde012", "subnet-bcde012a"]
  tags                  = {Environment = "test"}
  vpc_id                = "vpc-abcde012"
}
```

## Other documentation

- [Autoscaling](docs/autoscaling.md): How to enabled worker node autoscaling.

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
future. Once the test fixture has converged, you can query the test cluster from
that terminal session with
```bash
kubectl get nodes --watch --kubeconfig kubeconfig
```
(using default settings `config_output_path = "./"` & `write_kubeconfig = true`)

## Doc generation

Documentation should be modified within `main.tf` and generated using [terraform-docs](https://github.com/segmentio/terraform-docs).
Generate them like so:

```bash
go get github.com/segmentio/terraform-docs
terraform-docs md ./ | cat -s | tail -r | tail -n +2 | tail -r > README.md
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
| cluster\_create\_timeout | Timeout value when creating the EKS cluster. | string | `15m` | no |
| cluster\_delete\_timeout | Timeout value when deleting the EKS cluster. | string | `15m` | no |
| cluster\_name | Name of the EKS cluster. Also used as a prefix in names of related resources. | string | - | yes |
| cluster\_security\_group\_id | If provided, the EKS cluster will be attached to this security group. If not given, a security group will be created with necessary ingres/egress to work with the workers and provide API access to your current IP/32. | string | `` | no |
| cluster\_version | Kubernetes version to use for the EKS cluster. | string | `1.10` | no |
| config\_output\_path | Where to save the Kubectl config file (if `write_kubeconfig = true`). Should end in a forward slash `/` . | string | `./` | no |
| kubeconfig\_aws\_authenticator\_additional\_args | Any additional arguments to pass to the authenticator such as the role to assume. e.g. ["-r", "MyEksRole"]. | list | `<list>` | no |
| kubeconfig\_aws\_authenticator\_command | Command to use to to fetch AWS EKS credentials. | string | `aws-iam-authenticator` | no |
| kubeconfig\_aws\_authenticator\_command\_args | Default arguments passed to the authenticator command. Defaults to [token -i $cluster_name]. | list | `<list>` | no |
| kubeconfig\_aws\_authenticator\_env\_variables | Environment variables that should be used when executing the authenticator. e.g. { AWS_PROFILE = "eks"}. | map | `<map>` | no |
| kubeconfig\_name | Override the default name used for items kubeconfig. | string | `` | no |
| local\_exec\_interpreter | Command to run for local-exec resources. Must be a shell-style interpreter. If you are on Windows Git Bash is a good choice. Defaults to ["/bin/sh", "-c"] | list | `<list>` | no |
| manage\_aws\_auth | Whether to write and apply the aws-auth configmap file. | string | `true` | no |
| map\_accounts | Additional AWS account numbers to add to the aws-auth configmap. See examples/eks_test_fixture/variables.tf for example format. | list | `<list>` | no |
| map\_roles | Additional IAM roles to add to the aws-auth configmap. See examples/eks_test_fixture/variables.tf for example format. | list | `<list>` | no |
| map\_users | Additional IAM users to add to the aws-auth configmap. See examples/eks_test_fixture/variables.tf for example format. | list | `<list>` | no |
| subnets | A list of subnets to place the EKS cluster and workers within. | list | - | yes |
| tags | A map of tags to add to all resources. | map | `<map>` | no |
| vpc\_id | VPC where the cluster and workers will be deployed. | string | - | yes |
| worker\_additional\_security\_group\_ids | A list of additional security group ids to attach to worker instances | list | `<list>` | no |
| worker\_group\_count | The number of maps contained within the worker_groups list. | string | `1` | no |
| worker\_groups | A list of maps defining worker group configurations. See workers_group_defaults for valid keys. | list | `<list>` | no |
| worker\_security\_group\_id | If provided, all workers will be attached to this security group. If not given, a security group will be created with necessary ingres/egress to work with the EKS cluster. | string | `` | no |
| worker\_sg\_ingress\_from\_port | Minimum port number from which pods will accept communication. Must be changed to a lower value if some pods in your cluster will expose a port lower than 1025 (e.g. 22, 80, or 443). | string | `1025` | no |
| workers\_group\_defaults | Override default values for target groups. See workers_group_defaults_defaults in locals.tf for valid keys. | map | `<map>` | no |
| write\_kubeconfig | Whether to write a Kubectl config file containing the cluster configuration. Saved to `config_output_path`. | string | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster\_certificate\_authority\_data | Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster. |
| cluster\_endpoint | The endpoint for your EKS Kubernetes API. |
| cluster\_id | The name/id of the EKS cluster. |
| cluster\_security\_group\_id | Security group ID attached to the EKS cluster. |
| cluster\_version | The Kubernetes server version for the EKS cluster. |
| config\_map\_aws\_auth | A kubernetes configuration to authenticate to this EKS cluster. |
| kubeconfig | kubectl config file contents for this EKS cluster. |
| worker\_iam\_role\_arn | default IAM role ARN for EKS worker groups |
| worker\_iam\_role\_name | default IAM role name for EKS worker groups |
| worker\_security\_group\_id | Security group ID attached to the EKS workers. |
| workers\_asg\_arns | IDs of the autoscaling groups containing workers. |
| workers\_asg\_names | Names of the autoscaling groups containing workers. |
