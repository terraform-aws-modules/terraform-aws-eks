# AWS EKS Terraform module

Terraform module which creates AWS EKS (Kubernetes) resources

[![SWUbanner](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/banner2-direct.svg)](https://github.com/vshymanskyy/StandWithUkraine/blob/main/docs/README.md)

## Available Features

- AWS EKS Cluster
- AWS EKS Cluster Addons
- AWS EKS Identity Provider Configuration
- All [node types](https://docs.aws.amazon.com/eks/latest/userguide/eks-compute.html) are supported:
  - [EKS Managed Node Group](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html)
  - [Self Managed Node Group](https://docs.aws.amazon.com/eks/latest/userguide/worker.html)
  - [Fargate Profile](https://docs.aws.amazon.com/eks/latest/userguide/fargate.html)
- Support for custom AMI, custom launch template, and custom user data
- Support for Amazon Linux 2 EKS Optimized AMI and Bottlerocket nodes
  - Windows based node support is limited to a default user data template that is provided due to the lack of Windows support and manual steps required to provision Windows based EKS nodes
- Support for module created security group, bring your own security groups, as well as adding additional security group rules to the module created security group(s)
- Support for providing maps of node groups/Fargate profiles to the cluster module definition or use separate node group/Fargate profile sub-modules
- Provisions to provide node group/Fargate profile "default" settings - useful for when creating multiple node groups/Fargate profiles where you want to set a common set of configurations once, and then individual control only select features

## Documentation

- [Frequently Asked Questions](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/faq.md)
- [Module Design](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/module_design.md)
- [Node Groups](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/node_groups.md)
- [User Data](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/user_data.md)
- [Network Connectivity](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/network_connectivity.md)
- Upgrade Guides
  - [Upgrade to v17.x](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/UPGRADE-17.0.md)
  - [Upgrade to v18.x](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/UPGRADE-18.0.md)

## Usage

```hcl
module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name                    = "my-cluster"
  cluster_version                 = "1.21"
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
    provider_key_arn = "ac01234b-00d9-40f6-ac95-e42345f78b00"
    resources        = ["secrets"]
  }]

  vpc_id     = "vpc-1234556abcdef"
  subnet_ids = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]

  # Self Managed Node Group(s)
  self_managed_node_group_defaults = {
    instance_type                          = "m6i.large"
    update_launch_template_default_version = true
    iam_role_additional_policies           = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  }

  self_managed_node_groups = {
    one = {
      name = "spot-1"

      public_ip    = true
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

      pre_bootstrap_user_data = <<-EOT
      echo "foo"
      export FOO=bar
      EOT

      bootstrap_extra_args = "--kubelet-extra-args '--node-labels=node.kubernetes.io/lifecycle=spot'"

      post_bootstrap_user_data = <<-EOT
      cd /tmp
      sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
      sudo systemctl enable amazon-ssm-agent
      sudo systemctl start amazon-ssm-agent
      EOT
    }
  }

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type               = "AL2_x86_64"
    disk_size              = 50
    instance_types         = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
    vpc_security_group_ids = [aws_security_group.additional.id]
  }

  eks_managed_node_groups = {
    blue = {}
    green = {
      min_size     = 1
      max_size     = 10
      desired_size = 1

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"
      labels = {
        Environment = "test"
        GithubRepo  = "terraform-aws-eks"
        GithubOrg   = "terraform-aws-modules"
      }
      taints = {
        dedicated = {
          key    = "dedicated"
          value  = "gpuGroup"
          effect = "NO_SCHEDULE"
        }
      }
      tags = {
        ExtraTag = "example"
      }
    }
  }

  # Fargate Profile(s)
  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "kube-system"
          labels = {
            k8s-app = "kube-dns"
          }
        },
        {
          namespace = "default"
        }
      ]

      tags = {
        Owner = "test"
      }

      timeouts = {
        create = "20m"
        delete = "20m"
      }
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

## Examples

- [Complete](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/complete): EKS Cluster using all available node group types in various combinations demonstrating many of the supported features and configurations
- [EKS Managed Node Group](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/eks_managed_node_group): EKS Cluster using EKS managed node groups
- [Fargate Profile](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/fargate_profile): EKS cluster using [Fargate Profiles](https://docs.aws.amazon.com/eks/latest/userguide/fargate.html)
- [IRSA, Node Autoscaler, Instance Refresh](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/irsa_autoscale_refresh): EKS Cluster using self-managed node group demonstrating how to enable/utilize instance refresh configuration along with node termination handler
- [Self Managed Node Group](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/self_managed_node_group): EKS Cluster using self-managed node groups
- [User Data](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/user_data): Various supported methods of providing necessary bootstrap scripts and configuration settings via user data

## Contributing

Report issues/questions/feature requests via [issues](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/new)
Full contributing [guidelines are covered here](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/.github/CONTRIBUTING.md)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 2.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.72 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | >= 2.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks_managed_node_group"></a> [eks\_managed\_node\_group](#module\_eks\_managed\_node\_group) | ./modules/eks-managed-node-group | n/a |
| <a name="module_fargate_profile"></a> [fargate\_profile](#module\_fargate\_profile) | ./modules/fargate-profile | n/a |
| <a name="module_self_managed_node_group"></a> [self\_managed\_node\_group](#module\_self\_managed\_node\_group) | ./modules/self-managed-node-group | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ec2_tag.cluster_primary_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_tag) | resource |
| [aws_eks_addon.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [aws_eks_identity_provider_config.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_identity_provider_config) | resource |
| [aws_iam_openid_connect_provider.oidc_provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_policy.cluster_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.cni_ipv6_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cluster_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_iam_policy_document.assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cni_ipv6_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [tls_certificate.this](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attach_cluster_encryption_policy"></a> [attach\_cluster\_encryption\_policy](#input\_attach\_cluster\_encryption\_policy) | Indicates whether or not to attach an additional policy for the cluster IAM role to utilize the encryption key provided | `bool` | `true` | no |
| <a name="input_cloudwatch_log_group_kms_key_id"></a> [cloudwatch\_log\_group\_kms\_key\_id](#input\_cloudwatch\_log\_group\_kms\_key\_id) | If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html) | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_retention_in_days"></a> [cloudwatch\_log\_group\_retention\_in\_days](#input\_cloudwatch\_log\_group\_retention\_in\_days) | Number of days to retain log events. Default retention - 90 days | `number` | `90` | no |
| <a name="input_cluster_additional_security_group_ids"></a> [cluster\_additional\_security\_group\_ids](#input\_cluster\_additional\_security\_group\_ids) | List of additional, externally created security group IDs to attach to the cluster control plane | `list(string)` | `[]` | no |
| <a name="input_cluster_addons"></a> [cluster\_addons](#input\_cluster\_addons) | Map of cluster addon configurations to enable for the cluster. Addon name can be the map keys or set with `name` | `any` | `{}` | no |
| <a name="input_cluster_enabled_log_types"></a> [cluster\_enabled\_log\_types](#input\_cluster\_enabled\_log\_types) | A list of the desired control plane logs to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html) | `list(string)` | <pre>[<br>  "audit",<br>  "api",<br>  "authenticator"<br>]</pre> | no |
| <a name="input_cluster_encryption_config"></a> [cluster\_encryption\_config](#input\_cluster\_encryption\_config) | Configuration block with encryption configuration for the cluster | <pre>list(object({<br>    provider_key_arn = string<br>    resources        = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_cluster_encryption_policy_description"></a> [cluster\_encryption\_policy\_description](#input\_cluster\_encryption\_policy\_description) | Description of the cluster encryption policy created | `string` | `"Cluster encryption policy to allow cluster role to utilize CMK provided"` | no |
| <a name="input_cluster_encryption_policy_name"></a> [cluster\_encryption\_policy\_name](#input\_cluster\_encryption\_policy\_name) | Name to use on cluster encryption policy created | `string` | `null` | no |
| <a name="input_cluster_encryption_policy_path"></a> [cluster\_encryption\_policy\_path](#input\_cluster\_encryption\_policy\_path) | Cluster encryption policy path | `string` | `null` | no |
| <a name="input_cluster_encryption_policy_tags"></a> [cluster\_encryption\_policy\_tags](#input\_cluster\_encryption\_policy\_tags) | A map of additional tags to add to the cluster encryption policy created | `map(string)` | `{}` | no |
| <a name="input_cluster_encryption_policy_use_name_prefix"></a> [cluster\_encryption\_policy\_use\_name\_prefix](#input\_cluster\_encryption\_policy\_use\_name\_prefix) | Determines whether cluster encryption policy name (`cluster_encryption_policy_name`) is used as a prefix | `string` | `true` | no |
| <a name="input_cluster_endpoint_private_access"></a> [cluster\_endpoint\_private\_access](#input\_cluster\_endpoint\_private\_access) | Indicates whether or not the Amazon EKS private API server endpoint is enabled | `bool` | `false` | no |
| <a name="input_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#input\_cluster\_endpoint\_public\_access) | Indicates whether or not the Amazon EKS public API server endpoint is enabled | `bool` | `true` | no |
| <a name="input_cluster_endpoint_public_access_cidrs"></a> [cluster\_endpoint\_public\_access\_cidrs](#input\_cluster\_endpoint\_public\_access\_cidrs) | List of CIDR blocks which can access the Amazon EKS public API server endpoint | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_cluster_iam_role_dns_suffix"></a> [cluster\_iam\_role\_dns\_suffix](#input\_cluster\_iam\_role\_dns\_suffix) | Base DNS domain name for the current partition (e.g., amazonaws.com in AWS Commercial, amazonaws.com.cn in AWS China) | `string` | `null` | no |
| <a name="input_cluster_identity_providers"></a> [cluster\_identity\_providers](#input\_cluster\_identity\_providers) | Map of cluster identity provider configurations to enable for the cluster. Note - this is different/separate from IRSA | `any` | `{}` | no |
| <a name="input_cluster_ip_family"></a> [cluster\_ip\_family](#input\_cluster\_ip\_family) | The IP family used to assign Kubernetes pod and service addresses. Valid values are `ipv4` (default) and `ipv6`. You can only specify an IP family when you create a cluster, changing this value will force a new cluster to be created | `string` | `null` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `string` | `""` | no |
| <a name="input_cluster_security_group_additional_rules"></a> [cluster\_security\_group\_additional\_rules](#input\_cluster\_security\_group\_additional\_rules) | List of additional security group rules to add to the cluster security group created. Set `source_node_security_group = true` inside rules to set the `node_security_group` as source | `any` | `{}` | no |
| <a name="input_cluster_security_group_description"></a> [cluster\_security\_group\_description](#input\_cluster\_security\_group\_description) | Description of the cluster security group created | `string` | `"EKS cluster security group"` | no |
| <a name="input_cluster_security_group_id"></a> [cluster\_security\_group\_id](#input\_cluster\_security\_group\_id) | Existing security group ID to be attached to the cluster. Required if `create_cluster_security_group` = `false` | `string` | `""` | no |
| <a name="input_cluster_security_group_name"></a> [cluster\_security\_group\_name](#input\_cluster\_security\_group\_name) | Name to use on cluster security group created | `string` | `null` | no |
| <a name="input_cluster_security_group_tags"></a> [cluster\_security\_group\_tags](#input\_cluster\_security\_group\_tags) | A map of additional tags to add to the cluster security group created | `map(string)` | `{}` | no |
| <a name="input_cluster_security_group_use_name_prefix"></a> [cluster\_security\_group\_use\_name\_prefix](#input\_cluster\_security\_group\_use\_name\_prefix) | Determines whether cluster security group name (`cluster_security_group_name`) is used as a prefix | `string` | `true` | no |
| <a name="input_cluster_service_ipv4_cidr"></a> [cluster\_service\_ipv4\_cidr](#input\_cluster\_service\_ipv4\_cidr) | The CIDR block to assign Kubernetes service IP addresses from. If you don't specify a block, Kubernetes assigns addresses from either the 10.100.0.0/16 or 172.20.0.0/16 CIDR blocks | `string` | `null` | no |
| <a name="input_cluster_tags"></a> [cluster\_tags](#input\_cluster\_tags) | A map of additional tags to add to the cluster | `map(string)` | `{}` | no |
| <a name="input_cluster_timeouts"></a> [cluster\_timeouts](#input\_cluster\_timeouts) | Create, update, and delete timeout configurations for the cluster | `map(string)` | `{}` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.21`) | `string` | `null` | no |
| <a name="input_create"></a> [create](#input\_create) | Controls if EKS resources should be created (affects nearly all resources) | `bool` | `true` | no |
| <a name="input_create_cloudwatch_log_group"></a> [create\_cloudwatch\_log\_group](#input\_create\_cloudwatch\_log\_group) | Determines whether a log group is created by this module for the cluster logs. If not, AWS will automatically create one if logging is enabled | `bool` | `true` | no |
| <a name="input_create_cluster_security_group"></a> [create\_cluster\_security\_group](#input\_create\_cluster\_security\_group) | Determines if a security group is created for the cluster or use the existing `cluster_security_group_id` | `bool` | `true` | no |
| <a name="input_create_cni_ipv6_iam_policy"></a> [create\_cni\_ipv6\_iam\_policy](#input\_create\_cni\_ipv6\_iam\_policy) | Determines whether to create an [`AmazonEKS_CNI_IPv6_Policy`](https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html#cni-iam-role-create-ipv6-policy) | `bool` | `false` | no |
| <a name="input_create_iam_role"></a> [create\_iam\_role](#input\_create\_iam\_role) | Determines whether a an IAM role is created or to use an existing IAM role | `bool` | `true` | no |
| <a name="input_create_node_security_group"></a> [create\_node\_security\_group](#input\_create\_node\_security\_group) | Determines whether to create a security group for the node groups or use the existing `node_security_group_id` | `bool` | `true` | no |
| <a name="input_custom_oidc_thumbprints"></a> [custom\_oidc\_thumbprints](#input\_custom\_oidc\_thumbprints) | Additional list of server certificate thumbprints for the OpenID Connect (OIDC) identity provider's server certificate(s) | `list(string)` | `[]` | no |
| <a name="input_eks_managed_node_group_defaults"></a> [eks\_managed\_node\_group\_defaults](#input\_eks\_managed\_node\_group\_defaults) | Map of EKS managed node group default configurations | `any` | `{}` | no |
| <a name="input_eks_managed_node_groups"></a> [eks\_managed\_node\_groups](#input\_eks\_managed\_node\_groups) | Map of EKS managed node group definitions to create | `any` | `{}` | no |
| <a name="input_enable_irsa"></a> [enable\_irsa](#input\_enable\_irsa) | Determines whether to create an OpenID Connect Provider for EKS to enable IRSA | `bool` | `true` | no |
| <a name="input_fargate_profile_defaults"></a> [fargate\_profile\_defaults](#input\_fargate\_profile\_defaults) | Map of Fargate Profile default configurations | `any` | `{}` | no |
| <a name="input_fargate_profiles"></a> [fargate\_profiles](#input\_fargate\_profiles) | Map of Fargate Profile definitions to create | `any` | `{}` | no |
| <a name="input_iam_role_additional_policies"></a> [iam\_role\_additional\_policies](#input\_iam\_role\_additional\_policies) | Additional policies to be added to the IAM role | `list(string)` | `[]` | no |
| <a name="input_iam_role_arn"></a> [iam\_role\_arn](#input\_iam\_role\_arn) | Existing IAM role ARN for the cluster. Required if `create_iam_role` is set to `false` | `string` | `null` | no |
| <a name="input_iam_role_description"></a> [iam\_role\_description](#input\_iam\_role\_description) | Description of the role | `string` | `null` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name to use on IAM role created | `string` | `null` | no |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | Cluster IAM role path | `string` | `null` | no |
| <a name="input_iam_role_permissions_boundary"></a> [iam\_role\_permissions\_boundary](#input\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM role | `string` | `null` | no |
| <a name="input_iam_role_tags"></a> [iam\_role\_tags](#input\_iam\_role\_tags) | A map of additional tags to add to the IAM role created | `map(string)` | `{}` | no |
| <a name="input_iam_role_use_name_prefix"></a> [iam\_role\_use\_name\_prefix](#input\_iam\_role\_use\_name\_prefix) | Determines whether the IAM role name (`iam_role_name`) is used as a prefix | `string` | `true` | no |
| <a name="input_node_security_group_additional_rules"></a> [node\_security\_group\_additional\_rules](#input\_node\_security\_group\_additional\_rules) | List of additional security group rules to add to the node security group created. Set `source_cluster_security_group = true` inside rules to set the `cluster_security_group` as source | `any` | `{}` | no |
| <a name="input_node_security_group_description"></a> [node\_security\_group\_description](#input\_node\_security\_group\_description) | Description of the node security group created | `string` | `"EKS node shared security group"` | no |
| <a name="input_node_security_group_id"></a> [node\_security\_group\_id](#input\_node\_security\_group\_id) | ID of an existing security group to attach to the node groups created | `string` | `""` | no |
| <a name="input_node_security_group_name"></a> [node\_security\_group\_name](#input\_node\_security\_group\_name) | Name to use on node security group created | `string` | `null` | no |
| <a name="input_node_security_group_tags"></a> [node\_security\_group\_tags](#input\_node\_security\_group\_tags) | A map of additional tags to add to the node security group created | `map(string)` | `{}` | no |
| <a name="input_node_security_group_use_name_prefix"></a> [node\_security\_group\_use\_name\_prefix](#input\_node\_security\_group\_use\_name\_prefix) | Determines whether node security group name (`node_security_group_name`) is used as a prefix | `string` | `true` | no |
| <a name="input_openid_connect_audiences"></a> [openid\_connect\_audiences](#input\_openid\_connect\_audiences) | List of OpenID Connect audience client IDs to add to the IRSA provider | `list(string)` | `[]` | no |
| <a name="input_prefix_separator"></a> [prefix\_separator](#input\_prefix\_separator) | The separator to use between the prefix and the generated timestamp for resource names | `string` | `"-"` | no |
| <a name="input_putin_khuylo"></a> [putin\_khuylo](#input\_putin\_khuylo) | Do you agree that Putin doesn't respect Ukrainian sovereignty and territorial integrity? More info: https://en.wikipedia.org/wiki/Putin_khuylo! | `bool` | `true` | no |
| <a name="input_self_managed_node_group_defaults"></a> [self\_managed\_node\_group\_defaults](#input\_self\_managed\_node\_group\_defaults) | Map of self-managed node group default configurations | `any` | `{}` | no |
| <a name="input_self_managed_node_groups"></a> [self\_managed\_node\_groups](#input\_self\_managed\_node\_groups) | Map of self-managed node group definitions to create | `any` | `{}` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of subnet IDs where the EKS cluster (ENIs) will be provisioned along with the nodes/node groups. Node groups can be deployed within a different set of subnet IDs from within the node group configuration | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where the cluster and its nodes will be provisioned | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_auth_configmap_yaml"></a> [aws\_auth\_configmap\_yaml](#output\_aws\_auth\_configmap\_yaml) | Formatted yaml output for base aws-auth configmap containing roles used in cluster node groups/fargate profiles |
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | Arn of cloudwatch log group created |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | Name of cloudwatch log group created |
| <a name="output_cluster_addons"></a> [cluster\_addons](#output\_cluster\_addons) | Map of attribute maps for all EKS cluster addons enabled |
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | The Amazon Resource Name (ARN) of the cluster |
| <a name="output_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#output\_cluster\_certificate\_authority\_data) | Base64 encoded certificate data required to communicate with the cluster |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint for your Kubernetes API server |
| <a name="output_cluster_iam_role_arn"></a> [cluster\_iam\_role\_arn](#output\_cluster\_iam\_role\_arn) | IAM role ARN of the EKS cluster |
| <a name="output_cluster_iam_role_name"></a> [cluster\_iam\_role\_name](#output\_cluster\_iam\_role\_name) | IAM role name of the EKS cluster |
| <a name="output_cluster_iam_role_unique_id"></a> [cluster\_iam\_role\_unique\_id](#output\_cluster\_iam\_role\_unique\_id) | Stable and unique string identifying the IAM role |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | The name/id of the EKS cluster. Will block on cluster creation until the cluster is really ready |
| <a name="output_cluster_identity_providers"></a> [cluster\_identity\_providers](#output\_cluster\_identity\_providers) | Map of attribute maps for all EKS identity providers enabled |
| <a name="output_cluster_oidc_issuer_url"></a> [cluster\_oidc\_issuer\_url](#output\_cluster\_oidc\_issuer\_url) | The URL on the EKS cluster for the OpenID Connect identity provider |
| <a name="output_cluster_platform_version"></a> [cluster\_platform\_version](#output\_cluster\_platform\_version) | Platform version for the cluster |
| <a name="output_cluster_primary_security_group_id"></a> [cluster\_primary\_security\_group\_id](#output\_cluster\_primary\_security\_group\_id) | Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console |
| <a name="output_cluster_security_group_arn"></a> [cluster\_security\_group\_arn](#output\_cluster\_security\_group\_arn) | Amazon Resource Name (ARN) of the cluster security group |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | ID of the cluster security group |
| <a name="output_cluster_status"></a> [cluster\_status](#output\_cluster\_status) | Status of the EKS cluster. One of `CREATING`, `ACTIVE`, `DELETING`, `FAILED` |
| <a name="output_cluster_version"></a> [cluster\_version](#output\_cluster\_version) | The Kubernetes version for the cluster |
| <a name="output_eks_managed_node_groups"></a> [eks\_managed\_node\_groups](#output\_eks\_managed\_node\_groups) | Map of attribute maps for all EKS managed node groups created |
| <a name="output_eks_managed_node_groups_autoscaling_group_names"></a> [eks\_managed\_node\_groups\_autoscaling\_group\_names](#output\_eks\_managed\_node\_groups\_autoscaling\_group\_names) | List of the autoscaling group names created by EKS managed node groups |
| <a name="output_fargate_profiles"></a> [fargate\_profiles](#output\_fargate\_profiles) | Map of attribute maps for all EKS Fargate Profiles created |
| <a name="output_node_security_group_arn"></a> [node\_security\_group\_arn](#output\_node\_security\_group\_arn) | Amazon Resource Name (ARN) of the node shared security group |
| <a name="output_node_security_group_id"></a> [node\_security\_group\_id](#output\_node\_security\_group\_id) | ID of the node shared security group |
| <a name="output_oidc_provider"></a> [oidc\_provider](#output\_oidc\_provider) | The OpenID Connect identity provider (issuer URL without leading `https://`) |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | The ARN of the OIDC Provider if `enable_irsa = true` |
| <a name="output_self_managed_node_groups"></a> [self\_managed\_node\_groups](#output\_self\_managed\_node\_groups) | Map of attribute maps for all self managed node groups created |
| <a name="output_self_managed_node_groups_autoscaling_group_names"></a> [self\_managed\_node\_groups\_autoscaling\_group\_names](#output\_self\_managed\_node\_groups\_autoscaling\_group\_names) | List of the autoscaling group names created by self-managed node groups |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## License

Apache 2 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-rds-aurora/tree/master/LICENSE) for full details.

## Additional information for users from Russia and Belarus

* Russia has [illegally annexed Crimea in 2014](https://en.wikipedia.org/wiki/Annexation_of_Crimea_by_the_Russian_Federation) and [brought the war in Donbas](https://en.wikipedia.org/wiki/War_in_Donbas) followed by [full-scale invasion of Ukraine in 2022](https://en.wikipedia.org/wiki/2022_Russian_invasion_of_Ukraine).
* Russia has brought sorrow and devastations to millions of Ukrainians, killed hundreds of innocent people, damaged thousands of buildings, and forced several million people to flee.
* [Putin khuylo!](https://en.wikipedia.org/wiki/Putin_khuylo!)
