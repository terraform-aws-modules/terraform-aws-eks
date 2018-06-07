/**
# terraform-aws-eks

* A terraform module to create a managed Kubernetes cluster on AWS EKS. Available 
* through the [Terraform registry](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws).
* Inspired by and adapted from [this doc](https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html)
* and its [source code](https://github.com/terraform-providers/terraform-provider-aws/tree/master/examples/eks-getting-started).
* Instructions on [this post](https://aws.amazon.com/blogs/aws/amazon-eks-now-generally-available/)
* can help guide you through connecting to the cluster via `kubectl`.

* | Branch | Build status                                                                                                                                                      |
* | ------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
* | master | [![build Status](https://travis-ci.org/terraform-aws-modules/terraform-aws-eks.svg?branch=master)](https://travis-ci.org/terraform-aws-modules/terraform-aws-eks) |

* ## Assumptions

** You want to create a set of resources around an EKS cluster: namely an autoscaling group of workers and a security group for them.
** You've created a Virtual Private Cloud (VPC) and subnets where you intend to put this EKS.

* ## Usage example

* A full example leveraging other community modules is contained in the [examples/eks_test_fixture directory](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/eks_test_fixture). Here's the gist of using it via the Terraform registry:

* ```hcl
* module "eks" {
*   source                = "terraform-aws-modules/eks/aws"
*   version               = "0.1.0"
*   cluster_name          = "test-eks-cluster"
*   subnets               = ["subnet-abcde012", "subnet-bcde012a"]
*   tags                  = "${map("Environment", "test")}"
*   vpc_id                = "vpc-abcde012"
*   workers_ami_id        = "ami-123456"
*   cluster_ingress_cidrs = ["24.18.23.91/32"]
* }
* ```

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

* ## Doc generation

* Documentation should be modified within `main.tf` and generated using [terraform-docs](https://github.com/segmentio/terraform-docs).
* Generate them like so:

* ```bash
* go get github.com/segmentio/terraform-docs
* terraform-docs md ./ | cat -s | ghead -n -1 > README.md
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

provider "null" {}
