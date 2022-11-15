# AWS EKS Terraform module

Terraform module which creates AWS EKS (Kubernetes) resources
[![Lint Status](https://github.com/tothenew/terraform-aws-eks/workflows/Lint/badge.svg)](https://github.com/tothenew/terraform-aws-eks/actions)
[![LICENSE](https://img.shields.io/github/license/tothenew/terraform-aws-eks)](https://github.com/tothenew/terraform-aws-template/blob/master/LICENSE)

## [Documentation](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs)

- [Frequently Asked Questions](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/faq.md)
- [Compute Resources](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/compute_resources.md)
- [IRSA Integration](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/irsa_integration.md)
- [User Data](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/user_data.md)
- [Network Connectivity](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/network_connectivity.md)
- Upgrade Guides
  - [Upgrade to v17.x](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/UPGRADE-17.0.md)
  - [Upgrade to v18.x](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/UPGRADE-18.0.md)

### External Documentation

Please note that we strive to provide a comprehensive suite of documentation for __*configuring and utilizing the module(s)*__ defined here, and that documentation regarding EKS (including EKS managed node group, self managed node group, and Fargate profile) and/or Kubernetes features, usage, etc. are better left up to their respective sources:
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)

## Available Features

- AWS EKS Cluster Addons
- AWS EKS Identity Provider Configuration
- All [node types](https://docs.aws.amazon.com/eks/latest/userguide/eks-compute.html) are supported:
  - [EKS Managed Node Group](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html)
  - [Self Managed Node Group](https://docs.aws.amazon.com/eks/latest/userguide/worker.html)
  - [Fargate Profile](https://docs.aws.amazon.com/eks/latest/userguide/fargate.html)
- Support for custom AMI, custom launch template, and custom user data including custom user data template
- Support for Amazon Linux 2 EKS Optimized AMI and Bottlerocket nodes
  - Windows based node support is limited to a default user data template that is provided due to the lack of Windows support and manual steps required to provision Windows based EKS nodes
- Support for module created security group, bring your own security groups, as well as adding additional security group rules to the module created security group(s)
- Support for creating node groups/profiles separate from the cluster through the use of sub-modules (same as what is used by root module)
- Support for node group/profile "default" settings - useful for when creating multiple node groups/Fargate profiles where you want to set a common set of configurations once, and then individually control only select features on certain node groups/profiles

### [IRSA Terraform Module](https://github.com/terraform-aws-modules/terraform-aws-iam/tree/master/modules/iam-role-for-service-accounts-eks)

An IAM role for service accounts (IRSA) sub-module has been created to make deploying common addons/controllers easier. Instead of users having to create a custom IAM role with the necessary federated role assumption required for IRSA plus find and craft the associated policy required for the addon/controller, users can create the IRSA role and policy with a few lines of code. See the [`terraform-aws-iam/examples/iam-role-for-service-accounts`](https://github.com/terraform-aws-modules/terraform-aws-iam/blob/master/examples/iam-role-for-service-accounts-eks/main.tf) directory for examples on how to use the IRSA sub-module in conjunction with this (`terraform-aws-eks`) module.

Some of the addon/controller policies that are currently supported include:

- [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md)
- [External DNS](https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md#iam-policy)
- [EBS CSI Driver](https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/docs/example-iam-policy.json)
- [VPC CNI](https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html)
- [Node Termination Handler](https://github.com/aws/aws-node-termination-handler#5-create-an-iam-role-for-the-pods)
- [Karpenter](https://karpenter.sh/preview/getting-started/getting-started-with-terraform/#create-the-karpentercontroller-iam-role)
- [Load Balancer Controller](https://github.com/kubernetes-sigs/aws-load-balancer-controller/blob/main/docs/install/iam_policy.json)

See [terraform-aws-iam/modules/iam-role-for-service-accounts](https://github.com/terraform-aws-modules/terraform-aws-iam/tree/master/modules/iam-role-for-service-accounts-eks) for current list of supported addon/controller policies as more are added to the project.

## Usage

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name    = "my-cluster"
  cluster_version = "1.22"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  cluster_encryption_config = [{
    provider_key_arn = "arn:aws:kms:eu-west-1:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"
    resources        = ["secrets"]
  }]

  vpc_id     = "vpc-1234556abcdef"
  subnet_ids = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]

  # Self Managed Node Group(s)
  self_managed_node_group_defaults = {
    instance_type                          = "m6i.large"
    update_launch_template_default_version = true
    iam_role_additional_policies = [
      "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    ]
  }

  self_managed_node_groups = {
    one = {
      name         = "mixed-1"
      max_size     = 5
      desired_size = 2

      use_mixed_instances_policy = true
      mixed_instances_policy = {
        instances_distribution = {
          on_demand_base_capacity                  = 0
          on_demand_percentage_above_base_capacity = 10
          spot_allocation_strategy                 = "capacity-optimized"
        }

        override = [
          {
            instance_type     = "m5.large"
            weighted_capacity = "1"
          },
          {
            instance_type     = "m6i.large"
            weighted_capacity = "2"
          },
        ]
      }
    }
  }

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    disk_size      = 50
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    blue = {}
    green = {
      min_size     = 1
      max_size     = 10
      desired_size = 1

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"
    }
  }

  # Fargate Profile(s)
  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "default"
        }
      ]
    }
  }

  # aws-auth configmap
  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::66666666666:role/role1"
      username = "role1"
      groups   = ["system:masters"]
    },
  ]

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::66666666666:user/user1"
      username = "user1"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::66666666666:user/user2"
      username = "user2"
      groups   = ["system:masters"]
    },
  ]

  aws_auth_accounts = [
    "777777777777",
    "888888888888",
  ]

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```
<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
## Examples

- [Complete](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/complete): EKS Cluster using all available node group types in various combinations demonstrating many of the supported features and configurations
- [EKS Managed Node Group](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/eks_managed_node_group): EKS Cluster using EKS managed node groups
- [Fargate Profile](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/fargate_profile): EKS cluster using [Fargate Profiles](https://docs.aws.amazon.com/eks/latest/userguide/fargate.html)
- [Karpenter](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/karpenter): EKS Cluster with [Karpenter](https://karpenter.sh/) provisioned for managing compute resource scaling
- [Self Managed Node Group](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/self_managed_node_group): EKS Cluster using self-managed node groups
- [User Data](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/user_data): Various supported methods of providing necessary bootstrap scripts and configuration settings via user data

## Contributing

We are grateful to the community for contributing bugfixes and improvements! Please see below to learn how you can take part.

- [Code of Conduct](https://github.com/terraform-aws-modules/.github/blob/master/CODE_OF_CONDUCT.md)
- [Contributing Guide](https://github.com/terraform-aws-modules/.github/blob/master/CONTRIBUTING.md)


## License

Apache 2 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-rds-aurora/tree/master/LICENSE) for full details.

## Additional information for users from Russia and Belarus
