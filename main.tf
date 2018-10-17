/**
# terraform-aws-eks

* A terraform module to create a managed Kubernetes cluster on AWS EKS. Available
* through the [Terraform registry](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws).
* Inspired by and adapted from [this doc](https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html)
* and its [source code](https://github.com/terraform-providers/terraform-provider-aws/tree/master/examples/eks-getting-started).
* Read the [AWS docs on EKS to get connected to the k8s dashboard](https://docs.aws.amazon.com/eks/latest/userguide/dashboard-tutorial.html).

* | Branch | Build status                                                                                                                                                      |
* | ------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
* | master | [![build Status](https://travis-ci.org/terraform-aws-modules/terraform-aws-eks.svg?branch=master)](https://travis-ci.org/terraform-aws-modules/terraform-aws-eks) |

* ## Assumptions

** You want to create an EKS cluster and an autoscaling group of workers for the cluster.
** You want these resources to exist within security groups that allow communication and coordination. These can be user provided or created within the module.
** You've created a Virtual Private Cloud (VPC) and subnets where you intend to put the EKS resources.
** If using the default variable value (`true`) for `configure_kubectl_session`, it's required that both [`kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl) (>=1.10) and [`aws-iam-authenticator`](https://github.com/kubernetes-sigs/aws-iam-authenticator#4-set-up-kubectl-to-use-authentication-tokens-provided-by-aws-iam-authenticator-for-kubernetes) are installed and on your shell's PATH.

* ## Usage example

* A full example leveraging other community modules is contained in the [examples/eks_test_fixture directory](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/eks_test_fixture). Here's the gist of using it via the Terraform registry:

* ```hcl
* module "eks" {
*   source                = "terraform-aws-modules/eks/aws"
*   cluster_name          = "test-eks-cluster"
*   subnets               = ["subnet-abcde012", "subnet-bcde012a"]
*   tags                  = {Environment = "test"}
*   vpc_id                = "vpc-abcde012"
* }
* ```

* ## Other documentation
*
* - [Autoscaling](docs/autoscaling.md): How to enabled worker node autoscaling.

* ## Release schedule

* Generally the maintainers will try to release the module once every 2 weeks to
* keep up with PR additions. If particularly pressing changes are added or maintainers
* come up with the spare time (hah!), release may happen more often on occasion.

* ## Testing

* This module has been packaged with [awspec](https://github.com/k1LoW/awspec) tests through [kitchen](https://kitchen.ci/) and [kitchen-terraform](https://newcontext-oss.github.io/kitchen-terraform/). To run them:

* 1. Install [rvm](https://rvm.io/rvm/install) and the ruby version specified in the [Gemfile](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/Gemfile).
* 2. Install bundler and the gems from our Gemfile:
*
*     ```bash
*     gem install bundler && bundle install
*     ```
*
* 3. Ensure your AWS environment is configured (i.e. credentials and region) for test.
* 4. Test using `bundle exec kitchen test` from the root of the repo.

* For now, connectivity to the kubernetes cluster is not tested but will be in the
* future. If `configure_kubectl_session` is set `true`, once the test fixture has
* converged, you can query the test cluster from that terminal session with
* `kubectl get nodes --watch --kubeconfig kubeconfig`.

* ## Doc generation

* Documentation should be modified within `main.tf` and generated using [terraform-docs](https://github.com/segmentio/terraform-docs).
* Generate them like so:

* ```bash
* go get github.com/segmentio/terraform-docs
* terraform-docs md ./ | cat -s | tail -r | tail -n +2 | tail -r > README.md
* ```

* ## Contributing

* Report issues/questions/feature requests on in the [issues](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/new) section.

* Full contributing [guidelines are covered here](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/CONTRIBUTING.md).

* ## IAM Permissions

* Testing and using this repo requires a minimum set of IAM permissions. Test permissions
* are listed in the [eks_test_fixture README](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/eks_test_fixture/README.md).

* ## Change log

* The [changelog](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/CHANGELOG.md) captures all important release notes.

* ## Authors

* Created and maintained by [Brandon O'Connor](https://github.com/brandoconnor) - brandon@atscale.run.
* Many thanks to [the contributors listed here](https://github.com/terraform-aws-modules/terraform-aws-eks/graphs/contributors)!

* ## License

* MIT Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/LICENSE) for full details.
*/

