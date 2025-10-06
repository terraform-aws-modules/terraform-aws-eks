# AWS EKS Terraform module

Terraform module which creates Amazon EKS (Kubernetes) resources

[![SWUbanner](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/banner2-direct.svg)](https://github.com/vshymanskyy/StandWithUkraine/blob/main/docs/README.md)

## [Documentation](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs)

- [Frequently Asked Questions](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/faq.md)
- [Compute Resources](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/compute_resources.md)
- [User Data](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/user_data.md)
- [Network Connectivity](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/network_connectivity.md)
- Upgrade Guides
  - [Upgrade to v17.x](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/UPGRADE-17.0.md)
  - [Upgrade to v18.x](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/UPGRADE-18.0.md)
  - [Upgrade to v19.x](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/UPGRADE-19.0.md)
  - [Upgrade to v20.x](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/UPGRADE-20.0.md)
  - [Upgrade to v21.x](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/UPGRADE-21.0.md)

### External Documentation

Please note that we strive to provide a comprehensive suite of documentation for __*configuring and utilizing the module(s)*__ defined here, and that documentation regarding EKS (including EKS managed node group, self managed node group, and Fargate profile) and/or Kubernetes features, usage, etc. are better left up to their respective sources:

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)

## Usage

### EKS Auto Mode

> [!CAUTION]
> Due to the current EKS Auto Mode API, to disable EKS Auto Mode you will have to explicity set:
>
>```hcl
>compute_config = {
>  enabled = false
> }
>```
>
> If you try to disable by simply removing the `compute_config` block, this will fail to disble EKS Auto Mode. Only after applying with `enabled = false` can you then remove the `compute_config` block from your configurations.

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "example"
  kubernetes_version = "1.33"

  # Optional
  endpoint_public_access = true

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

  vpc_id     = "vpc-1234556abcdef"
  subnet_ids = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

### EKS Auto Mode - Custom Node Pools Only

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "example"
  kubernetes_version = "1.33"

  # Optional
  endpoint_public_access = true

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  # Create just the IAM resources for EKS Auto Mode for use with custom node pools
  create_auto_mode_iam_resources = true
  compute_config = {
    enabled = true
  }

  vpc_id     = "vpc-1234556abcdef"
  subnet_ids = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

### EKS Managed Node Group

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "my-cluster"
  kubernetes_version = "1.33"

  addons = {
    coredns                = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy             = {}
    vpc-cni                = {
      before_compute = true
    }
  }

  # Optional
  endpoint_public_access = true

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = "vpc-1234556abcdef"
  subnet_ids               = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]
  control_plane_subnet_ids = ["subnet-xyzde987", "subnet-slkjf456", "subnet-qeiru789"]

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    example = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["m5.xlarge"]

      min_size     = 2
      max_size     = 10
      desired_size = 2
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

### Cluster Access Entry

When enabling `authentication_mode = "API_AND_CONFIG_MAP"`, EKS will automatically create an access entry for the IAM role(s) used by managed node group(s) and Fargate profile(s). There are no additional actions required by users. For self-managed node groups and the Karpenter sub-module, this project automatically adds the access entry on behalf of users so there are no additional actions required by users.

On clusters that were created prior to cluster access management (CAM) support, there will be an existing access entry for the cluster creator. This was previously not visible when using `aws-auth` ConfigMap, but will become visible when access entry is enabled.

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  # Truncated for brevity ...

  access_entries = {
    # One access entry with a policy associated
    example = {
      principal_arn = "arn:aws:iam::123456789012:role/something"

      policy_associations = {
        example = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            namespaces = ["default"]
            type       = "namespace"
          }
        }
      }
    }
  }
}
```

### EKS Hybrid Nodes

```hcl
locals {
  # RFC 1918 IP ranges supported
  remote_network_cidr = "172.16.0.0/16"
  remote_node_cidr    = cidrsubnet(local.remote_network_cidr, 2, 0)
  remote_pod_cidr     = cidrsubnet(local.remote_network_cidr, 2, 1)
}

# SSM and IAM Roles Anywhere supported - SSM is default
module "eks_hybrid_node_role" {
  source  = "terraform-aws-modules/eks/aws//modules/hybrid-node-role"
  version = "~> 21.0"

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "example"
  kubernetes_version = "1.33"

  addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
  }

  # Optional
  endpoint_public_access = true

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  create_node_security_group = false
  security_group_additional_rules = {
    hybrid-all = {
      cidr_blocks = [local.remote_network_cidr]
      description = "Allow all traffic from remote node/pod network"
      from_port   = 0
      to_port     = 0
      protocol    = "all"
      type        = "ingress"
    }
  }

  # Optional
  compute_config = {
    enabled    = true
    node_pools = ["system"]
  }

  access_entries = {
    hybrid-node-role = {
      principal_arn = module.eks_hybrid_node_role.arn
      type          = "HYBRID_LINUX"
    }
  }

  vpc_id     = "vpc-1234556abcdef"
  subnet_ids = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]

  remote_network_config = {
    remote_node_networks = {
      cidrs = [local.remote_node_cidr]
    }
    # Required if running webhooks on Hybrid nodes
    remote_pod_networks = {
      cidrs = [local.remote_pod_cidr]
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

### Bootstrap Cluster Creator Admin Permissions

Setting the `bootstrap_cluster_creator_admin_permissions` is a one time operation when the cluster is created; it cannot be modified later through the EKS API. In this project we are hardcoding this to `false`. If users wish to achieve the same functionality, we will do that through an access entry which can be enabled or disabled at any time of their choosing using the variable `enable_cluster_creator_admin_permissions`

### Enabling EFA Support

When enabling EFA support via `enable_efa_support = true`, there are two locations this can be specified - one at the cluster level, and one at the node group level. Enabling at the cluster level will add the EFA required ingress/egress rules to the shared security group created for the node group(s). Enabling at the node group level will do the following (per node group where enabled):

1. All EFA interfaces supported by the instance will be exposed on the launch template used by the node group
2. A placement group with `strategy = "clustered"` per EFA requirements is created and passed to the launch template used by the node group
3. Data sources will reverse lookup the availability zones that support the instance type selected based on the subnets provided, ensuring that only the associated subnets are passed to the launch template and therefore used by the placement group. This avoids the placement group being created in an availability zone that does not support the instance type selected.

> [!TIP]
> Use the [aws-efa-k8s-device-plugin](https://github.com/aws/eks-charts/tree/master/stable/aws-efa-k8s-device-plugin) Helm chart to expose the EFA interfaces on the nodes as an extended resource, and allow pods to request the interfaces be mounted to their containers.
>
> The EKS AL2 GPU AMI comes with the necessary EFA components pre-installed - you just need to expose the EFA devices on the nodes via their launch templates, ensure the required EFA security group rules are in place, and deploy the `aws-efa-k8s-device-plugin` in order to start utilizing EFA within your cluster. Your application container will need to have the necessary libraries and runtime in order to utilize communication over the EFA interfaces (NCCL, aws-ofi-nccl, hwloc, libfabric, aws-neuornx-collectives, CUDA, etc.).

If you disable the creation and use of the managed node group custom launch template (`create_launch_template = false` and/or `use_custom_launch_template = false`), this will interfere with the EFA functionality provided. In addition, if you do not supply an `instance_type` for self-managed node group(s), or `instance_types` for the managed node group(s), this will also interfere with the functionality. In order to support the EFA functionality provided by `enable_efa_support = true`, you must utilize the custom launch template created/provided by this module, and supply an `instance_type`/`instance_types` for the respective node group.

The logic behind supporting EFA uses a data source to lookup the instance type to retrieve the number of interfaces that the instance supports in order to enumerate and expose those interfaces on the launch template created. For managed node groups where a list of instance types are supported, the first instance type in the list is used to calculate the number of EFA interfaces supported. Mixing instance types with varying number of interfaces is not recommended for EFA (or in some cases, mixing instance types is not supported - i.e. - p5.48xlarge and p4d.24xlarge). In addition to exposing the EFA interfaces and updating the security group rules, a placement group is created per the EFA requirements and only the availability zones that support the instance type selected are used in the subnets provided to the node group.

In order to enable EFA support, you will have to specify `enable_efa_support = true` on both the cluster and each node group that you wish to enable EFA support for:

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  # Truncated for brevity ...

  # Adds the EFA required security group rules to the shared
  # security group created for the node group(s)
  enable_efa_support = true

  eks_managed_node_groups = {
    example = {
      # The EKS AL2023 NVIDIA AMI provides all of the necessary components
      # for accelerated workloads w/ EFA
      ami_type       = "AL2023_x86_64_NVIDIA"
      instance_types = ["p5.48xlarge"]

      # Exposes all EFA interfaces on the launch template created by the node group(s)
      # This would expose all 32 EFA interfaces for the p5.48xlarge instance type
      enable_efa_support = true

      # Mount instance store volumes in RAID-0 for kubelet and containerd
      # https://github.com/awslabs/amazon-eks-ami/blob/master/doc/USER_GUIDE.md#raid-0-for-kubelet-and-containerd-raid0
      cloudinit_pre_nodeadm = [
        {
          content_type = "application/node.eks.aws"
          content      = <<-EOT
            ---
            apiVersion: node.eks.aws/v1alpha1
            kind: NodeConfig
            spec:
              instance:
                localStorage:
                  strategy: RAID0
          EOT
        }
      ]

      # EFA should only be enabled when connecting 2 or more nodes
      # Do not use EFA on a single node workload
      min_size     = 2
      max_size     = 10
      desired_size = 2
    }
  }
}
```

## Examples

- [EKS Auto Mode](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/eks-auto-mode): EKS Cluster with EKS Auto Mode
- [EKS Hybrid Nodes](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/eks-hybrid-nodes): EKS Cluster with EKS Hybrid nodes
- [EKS Managed Node Group](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/eks-managed-node-group): EKS Cluster with EKS managed node group(s)
- [Karpenter](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/karpenter): EKS Cluster with [Karpenter](https://karpenter.sh/) provisioned for intelligent data plane management
- [Self Managed Node Group](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/self-managed-node-group): EKS Cluster with self-managed node group(s)

## Contributing

We are grateful to the community for contributing bugfixes and improvements! Please see below to learn how you can take part.

- [Code of Conduct](https://github.com/terraform-aws-modules/.github/blob/master/CODE_OF_CONDUCT.md)
- [Contributing Guide](https://github.com/terraform-aws-modules/.github/blob/master/CONTRIBUTING.md)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.15 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.15 |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.9 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | >= 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks_managed_node_group"></a> [eks\_managed\_node\_group](#module\_eks\_managed\_node\_group) | ./modules/eks-managed-node-group | n/a |
| <a name="module_fargate_profile"></a> [fargate\_profile](#module\_fargate\_profile) | ./modules/fargate-profile | n/a |
| <a name="module_kms"></a> [kms](#module\_kms) | terraform-aws-modules/kms/aws | 4.0.0 |
| <a name="module_self_managed_node_group"></a> [self\_managed\_node\_group](#module\_self\_managed\_node\_group) | ./modules/self-managed-node-group | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ec2_tag.cluster_primary_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_tag) | resource |
| [aws_eks_access_entry.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_entry) | resource |
| [aws_eks_access_policy_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_policy_association) | resource |
| [aws_eks_addon.before_compute](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_addon.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [aws_eks_identity_provider_config.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_identity_provider_config) | resource |
| [aws_iam_openid_connect_provider.oidc_provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_policy.cluster_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.cni_ipv6_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.eks_auto](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cluster_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks_auto](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks_auto_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [time_sleep.this](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_addon_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_addon_version) | data source |
| [aws_iam_policy_document.assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cni_ipv6_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.node_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_session_context.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_session_context) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [tls_certificate.this](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_entries"></a> [access\_entries](#input\_access\_entries) | Map of access entries to add to the cluster | <pre>map(object({<br/>    # Access entry<br/>    kubernetes_groups = optional(list(string))<br/>    principal_arn     = string<br/>    type              = optional(string, "STANDARD")<br/>    user_name         = optional(string)<br/>    tags              = optional(map(string), {})<br/>    # Access policy association<br/>    policy_associations = optional(map(object({<br/>      policy_arn = string<br/>      access_scope = object({<br/>        namespaces = optional(list(string))<br/>        type       = string<br/>      })<br/>    })), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_additional_security_group_ids"></a> [additional\_security\_group\_ids](#input\_additional\_security\_group\_ids) | List of additional, externally created security group IDs to attach to the cluster control plane | `list(string)` | `[]` | no |
| <a name="input_addons"></a> [addons](#input\_addons) | Map of cluster addon configurations to enable for the cluster. Addon name can be the map keys or set with `name` | <pre>map(object({<br/>    name                 = optional(string) # will fall back to map key<br/>    before_compute       = optional(bool, false)<br/>    most_recent          = optional(bool, true)<br/>    addon_version        = optional(string)<br/>    configuration_values = optional(string)<br/>    pod_identity_association = optional(list(object({<br/>      role_arn        = string<br/>      service_account = string<br/>    })))<br/>    preserve                    = optional(bool, true)<br/>    resolve_conflicts_on_create = optional(string, "NONE")<br/>    resolve_conflicts_on_update = optional(string, "OVERWRITE")<br/>    service_account_role_arn    = optional(string)<br/>    timeouts = optional(object({<br/>      create = optional(string)<br/>      update = optional(string)<br/>      delete = optional(string)<br/>    }), {})<br/>    tags = optional(map(string), {})<br/>  }))</pre> | `null` | no |
| <a name="input_addons_timeouts"></a> [addons\_timeouts](#input\_addons\_timeouts) | Create, update, and delete timeout configurations for the cluster addons | <pre>object({<br/>    create = optional(string)<br/>    update = optional(string)<br/>    delete = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_attach_encryption_policy"></a> [attach\_encryption\_policy](#input\_attach\_encryption\_policy) | Indicates whether or not to attach an additional policy for the cluster IAM role to utilize the encryption key provided | `bool` | `true` | no |
| <a name="input_authentication_mode"></a> [authentication\_mode](#input\_authentication\_mode) | The authentication mode for the cluster. Valid values are `CONFIG_MAP`, `API` or `API_AND_CONFIG_MAP` | `string` | `"API_AND_CONFIG_MAP"` | no |
| <a name="input_cloudwatch_log_group_class"></a> [cloudwatch\_log\_group\_class](#input\_cloudwatch\_log\_group\_class) | Specified the log class of the log group. Possible values are: `STANDARD` or `INFREQUENT_ACCESS` | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_kms_key_id"></a> [cloudwatch\_log\_group\_kms\_key\_id](#input\_cloudwatch\_log\_group\_kms\_key\_id) | If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html) | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_retention_in_days"></a> [cloudwatch\_log\_group\_retention\_in\_days](#input\_cloudwatch\_log\_group\_retention\_in\_days) | Number of days to retain log events. Default retention - 90 days | `number` | `90` | no |
| <a name="input_cloudwatch_log_group_tags"></a> [cloudwatch\_log\_group\_tags](#input\_cloudwatch\_log\_group\_tags) | A map of additional tags to add to the cloudwatch log group created | `map(string)` | `{}` | no |
| <a name="input_cluster_tags"></a> [cluster\_tags](#input\_cluster\_tags) | A map of additional tags to add to the cluster | `map(string)` | `{}` | no |
| <a name="input_compute_config"></a> [compute\_config](#input\_compute\_config) | Configuration block for the cluster compute configuration | <pre>object({<br/>    enabled       = optional(bool, false)<br/>    node_pools    = optional(list(string))<br/>    node_role_arn = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_control_plane_subnet_ids"></a> [control\_plane\_subnet\_ids](#input\_control\_plane\_subnet\_ids) | A list of subnet IDs where the EKS cluster control plane (ENIs) will be provisioned. Used for expanding the pool of subnets used by nodes/node groups without replacing the EKS control plane | `list(string)` | `[]` | no |
| <a name="input_create"></a> [create](#input\_create) | Controls if resources should be created (affects nearly all resources) | `bool` | `true` | no |
| <a name="input_create_auto_mode_iam_resources"></a> [create\_auto\_mode\_iam\_resources](#input\_create\_auto\_mode\_iam\_resources) | Determines whether to create/attach IAM resources for EKS Auto Mode. Useful for when using only custom node pools and not built-in EKS Auto Mode node pools | `bool` | `false` | no |
| <a name="input_create_cloudwatch_log_group"></a> [create\_cloudwatch\_log\_group](#input\_create\_cloudwatch\_log\_group) | Determines whether a log group is created by this module for the cluster logs. If not, AWS will automatically create one if logging is enabled | `bool` | `true` | no |
| <a name="input_create_cni_ipv6_iam_policy"></a> [create\_cni\_ipv6\_iam\_policy](#input\_create\_cni\_ipv6\_iam\_policy) | Determines whether to create an [`AmazonEKS_CNI_IPv6_Policy`](https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html#cni-iam-role-create-ipv6-policy) | `bool` | `false` | no |
| <a name="input_create_iam_role"></a> [create\_iam\_role](#input\_create\_iam\_role) | Determines whether an IAM role is created for the cluster | `bool` | `true` | no |
| <a name="input_create_kms_key"></a> [create\_kms\_key](#input\_create\_kms\_key) | Controls if a KMS key for cluster encryption should be created | `bool` | `true` | no |
| <a name="input_create_node_iam_role"></a> [create\_node\_iam\_role](#input\_create\_node\_iam\_role) | Determines whether an EKS Auto node IAM role is created | `bool` | `true` | no |
| <a name="input_create_node_security_group"></a> [create\_node\_security\_group](#input\_create\_node\_security\_group) | Determines whether to create a security group for the node groups or use the existing `node_security_group_id` | `bool` | `true` | no |
| <a name="input_create_primary_security_group_tags"></a> [create\_primary\_security\_group\_tags](#input\_create\_primary\_security\_group\_tags) | Indicates whether or not to tag the cluster's primary security group. This security group is created by the EKS service, not the module, and therefore tagging is handled after cluster creation | `bool` | `true` | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | Determines if a security group is created for the cluster. Note: the EKS service creates a primary security group for the cluster by default | `bool` | `true` | no |
| <a name="input_custom_oidc_thumbprints"></a> [custom\_oidc\_thumbprints](#input\_custom\_oidc\_thumbprints) | Additional list of server certificate thumbprints for the OpenID Connect (OIDC) identity provider's server certificate(s) | `list(string)` | `[]` | no |
| <a name="input_dataplane_wait_duration"></a> [dataplane\_wait\_duration](#input\_dataplane\_wait\_duration) | Duration to wait after the EKS cluster has become active before creating the dataplane components (EKS managed node group(s), self-managed node group(s), Fargate profile(s)) | `string` | `"30s"` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Whether to enable deletion protection for the cluster. When enabled, the cluster cannot be deleted unless deletion protection is first disabled | `bool` | `null` | no |
| <a name="input_eks_managed_node_groups"></a> [eks\_managed\_node\_groups](#input\_eks\_managed\_node\_groups) | Map of EKS managed node group definitions to create | <pre>map(object({<br/>    create             = optional(bool)<br/>    kubernetes_version = optional(string)<br/><br/>    # EKS Managed Node Group<br/>    name                           = optional(string) # Will fall back to map key<br/>    use_name_prefix                = optional(bool)<br/>    subnet_ids                     = optional(list(string))<br/>    min_size                       = optional(number)<br/>    max_size                       = optional(number)<br/>    desired_size                   = optional(number)<br/>    ami_id                         = optional(string)<br/>    ami_type                       = optional(string)<br/>    ami_release_version            = optional(string)<br/>    use_latest_ami_release_version = optional(bool)<br/>    capacity_type                  = optional(string)<br/>    disk_size                      = optional(number)<br/>    force_update_version           = optional(bool)<br/>    instance_types                 = optional(list(string))<br/>    labels                         = optional(map(string))<br/>    node_repair_config = optional(object({<br/>      enabled = optional(bool)<br/>    }))<br/>    remote_access = optional(object({<br/>      ec2_ssh_key               = optional(string)<br/>      source_security_group_ids = optional(list(string))<br/>    }))<br/>    taints = optional(map(object({<br/>      key    = string<br/>      value  = optional(string)<br/>      effect = string<br/>    })))<br/>    update_config = optional(object({<br/>      max_unavailable            = optional(number)<br/>      max_unavailable_percentage = optional(number)<br/>    }))<br/>    timeouts = optional(object({<br/>      create = optional(string)<br/>      update = optional(string)<br/>      delete = optional(string)<br/>    }))<br/>    # User data<br/>    enable_bootstrap_user_data = optional(bool)<br/>    pre_bootstrap_user_data    = optional(string)<br/>    post_bootstrap_user_data   = optional(string)<br/>    bootstrap_extra_args       = optional(string)<br/>    user_data_template_path    = optional(string)<br/>    cloudinit_pre_nodeadm = optional(list(object({<br/>      content      = string<br/>      content_type = optional(string)<br/>      filename     = optional(string)<br/>      merge_type   = optional(string)<br/>    })))<br/>    cloudinit_post_nodeadm = optional(list(object({<br/>      content      = string<br/>      content_type = optional(string)<br/>      filename     = optional(string)<br/>      merge_type   = optional(string)<br/>    })))<br/>    # Launch Template<br/>    create_launch_template                 = optional(bool)<br/>    use_custom_launch_template             = optional(bool)<br/>    launch_template_id                     = optional(string)<br/>    launch_template_name                   = optional(string) # Will fall back to map key<br/>    launch_template_use_name_prefix        = optional(bool)<br/>    launch_template_version                = optional(string)<br/>    launch_template_default_version        = optional(string)<br/>    update_launch_template_default_version = optional(bool)<br/>    launch_template_description            = optional(string)<br/>    launch_template_tags                   = optional(map(string))<br/>    tag_specifications                     = optional(list(string))<br/>    ebs_optimized                          = optional(bool)<br/>    key_name                               = optional(string)<br/>    disable_api_termination                = optional(bool)<br/>    kernel_id                              = optional(string)<br/>    ram_disk_id                            = optional(string)<br/>    block_device_mappings = optional(map(object({<br/>      device_name = optional(string)<br/>      ebs = optional(object({<br/>        delete_on_termination      = optional(bool)<br/>        encrypted                  = optional(bool)<br/>        iops                       = optional(number)<br/>        kms_key_id                 = optional(string)<br/>        snapshot_id                = optional(string)<br/>        throughput                 = optional(number)<br/>        volume_initialization_rate = optional(number)<br/>        volume_size                = optional(number)<br/>        volume_type                = optional(string)<br/>      }))<br/>      no_device    = optional(string)<br/>      virtual_name = optional(string)<br/>    })))<br/>    capacity_reservation_specification = optional(object({<br/>      capacity_reservation_preference = optional(string)<br/>      capacity_reservation_target = optional(object({<br/>        capacity_reservation_id                 = optional(string)<br/>        capacity_reservation_resource_group_arn = optional(string)<br/>      }))<br/>    }))<br/>    cpu_options = optional(object({<br/>      amd_sev_snp      = optional(string)<br/>      core_count       = optional(number)<br/>      threads_per_core = optional(number)<br/>    }))<br/>    credit_specification = optional(object({<br/>      cpu_credits = optional(string)<br/>    }))<br/>    enclave_options = optional(object({<br/>      enabled = optional(bool)<br/>    }))<br/>    instance_market_options = optional(object({<br/>      market_type = optional(string)<br/>      spot_options = optional(object({<br/>        block_duration_minutes         = optional(number)<br/>        instance_interruption_behavior = optional(string)<br/>        max_price                      = optional(string)<br/>        spot_instance_type             = optional(string)<br/>        valid_until                    = optional(string)<br/>      }))<br/>    }))<br/>    license_specifications = optional(list(object({<br/>      license_configuration_arn = string<br/>    })))<br/>    metadata_options = optional(object({<br/>      http_endpoint               = optional(string)<br/>      http_protocol_ipv6          = optional(string)<br/>      http_put_response_hop_limit = optional(number)<br/>      http_tokens                 = optional(string)<br/>      instance_metadata_tags      = optional(string)<br/>    }))<br/>    enable_monitoring      = optional(bool)<br/>    enable_efa_support     = optional(bool)<br/>    enable_efa_only        = optional(bool)<br/>    efa_indices            = optional(list(string))<br/>    create_placement_group = optional(bool)<br/>    placement = optional(object({<br/>      affinity                = optional(string)<br/>      availability_zone       = optional(string)<br/>      group_name              = optional(string)<br/>      host_id                 = optional(string)<br/>      host_resource_group_arn = optional(string)<br/>      partition_number        = optional(number)<br/>      spread_domain           = optional(string)<br/>      tenancy                 = optional(string)<br/>    }))<br/>    network_interfaces = optional(list(object({<br/>      associate_carrier_ip_address = optional(bool)<br/>      associate_public_ip_address  = optional(bool)<br/>      connection_tracking_specification = optional(object({<br/>        tcp_established_timeout = optional(number)<br/>        udp_stream_timeout      = optional(number)<br/>        udp_timeout             = optional(number)<br/>      }))<br/>      delete_on_termination = optional(bool)<br/>      description           = optional(string)<br/>      device_index          = optional(number)<br/>      ena_srd_specification = optional(object({<br/>        ena_srd_enabled = optional(bool)<br/>        ena_srd_udp_specification = optional(object({<br/>          ena_srd_udp_enabled = optional(bool)<br/>        }))<br/>      }))<br/>      interface_type       = optional(string)<br/>      ipv4_address_count   = optional(number)<br/>      ipv4_addresses       = optional(list(string))<br/>      ipv4_prefix_count    = optional(number)<br/>      ipv4_prefixes        = optional(list(string))<br/>      ipv6_address_count   = optional(number)<br/>      ipv6_addresses       = optional(list(string))<br/>      ipv6_prefix_count    = optional(number)<br/>      ipv6_prefixes        = optional(list(string))<br/>      network_card_index   = optional(number)<br/>      network_interface_id = optional(string)<br/>      primary_ipv6         = optional(bool)<br/>      private_ip_address   = optional(string)<br/>      security_groups      = optional(list(string), [])<br/>      subnet_id            = optional(string)<br/>    })))<br/>    maintenance_options = optional(object({<br/>      auto_recovery = optional(string)<br/>    }))<br/>    private_dns_name_options = optional(object({<br/>      enable_resource_name_dns_aaaa_record = optional(bool)<br/>      enable_resource_name_dns_a_record    = optional(bool)<br/>      hostname_type                        = optional(string)<br/>    }))<br/>    # IAM role<br/>    create_iam_role               = optional(bool)<br/>    iam_role_arn                  = optional(string)<br/>    iam_role_name                 = optional(string)<br/>    iam_role_use_name_prefix      = optional(bool)<br/>    iam_role_path                 = optional(string)<br/>    iam_role_description          = optional(string)<br/>    iam_role_permissions_boundary = optional(string)<br/>    iam_role_tags                 = optional(map(string))<br/>    iam_role_attach_cni_policy    = optional(bool)<br/>    iam_role_additional_policies  = optional(map(string))<br/>    create_iam_role_policy        = optional(bool)<br/>    iam_role_policy_statements = optional(list(object({<br/>      sid           = optional(string)<br/>      actions       = optional(list(string))<br/>      not_actions   = optional(list(string))<br/>      effect        = optional(string)<br/>      resources     = optional(list(string))<br/>      not_resources = optional(list(string))<br/>      principals = optional(list(object({<br/>        type        = string<br/>        identifiers = list(string)<br/>      })))<br/>      not_principals = optional(list(object({<br/>        type        = string<br/>        identifiers = list(string)<br/>      })))<br/>      condition = optional(list(object({<br/>        test     = string<br/>        values   = list(string)<br/>        variable = string<br/>      })))<br/>    })))<br/>    # Security group<br/>    vpc_security_group_ids                = optional(list(string), [])<br/>    attach_cluster_primary_security_group = optional(bool, false)<br/>    cluster_primary_security_group_id     = optional(string)<br/>    create_security_group                 = optional(bool)<br/>    security_group_name                   = optional(string)<br/>    security_group_use_name_prefix        = optional(bool)<br/>    security_group_description            = optional(string)<br/>    security_group_ingress_rules = optional(map(object({<br/>      name                         = optional(string)<br/>      cidr_ipv4                    = optional(string)<br/>      cidr_ipv6                    = optional(string)<br/>      description                  = optional(string)<br/>      from_port                    = optional(string)<br/>      ip_protocol                  = optional(string)<br/>      prefix_list_id               = optional(string)<br/>      referenced_security_group_id = optional(string)<br/>      self                         = optional(bool)<br/>      tags                         = optional(map(string))<br/>      to_port                      = optional(string)<br/>    })))<br/>    security_group_egress_rules = optional(map(object({<br/>      name                         = optional(string)<br/>      cidr_ipv4                    = optional(string)<br/>      cidr_ipv6                    = optional(string)<br/>      description                  = optional(string)<br/>      from_port                    = optional(string)<br/>      ip_protocol                  = optional(string)<br/>      prefix_list_id               = optional(string)<br/>      referenced_security_group_id = optional(string)<br/>      self                         = optional(bool)<br/>      tags                         = optional(map(string))<br/>      to_port                      = optional(string)<br/>    })), {})<br/>    security_group_tags = optional(map(string))<br/><br/>    tags = optional(map(string))<br/>  }))</pre> | `null` | no |
| <a name="input_enable_auto_mode_custom_tags"></a> [enable\_auto\_mode\_custom\_tags](#input\_enable\_auto\_mode\_custom\_tags) | Determines whether to enable permissions for custom tags resources created by EKS Auto Mode | `bool` | `true` | no |
| <a name="input_enable_cluster_creator_admin_permissions"></a> [enable\_cluster\_creator\_admin\_permissions](#input\_enable\_cluster\_creator\_admin\_permissions) | Indicates whether or not to add the cluster creator (the identity used by Terraform) as an administrator via access entry | `bool` | `false` | no |
| <a name="input_enable_irsa"></a> [enable\_irsa](#input\_enable\_irsa) | Determines whether to create an OpenID Connect Provider for EKS to enable IRSA | `bool` | `true` | no |
| <a name="input_enable_kms_key_rotation"></a> [enable\_kms\_key\_rotation](#input\_enable\_kms\_key\_rotation) | Specifies whether key rotation is enabled | `bool` | `true` | no |
| <a name="input_enabled_log_types"></a> [enabled\_log\_types](#input\_enabled\_log\_types) | A list of the desired control plane logs to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html) | `list(string)` | <pre>[<br/>  "audit",<br/>  "api",<br/>  "authenticator"<br/>]</pre> | no |
| <a name="input_encryption_config"></a> [encryption\_config](#input\_encryption\_config) | Configuration block with encryption configuration for the cluster | <pre>object({<br/>    provider_key_arn = optional(string)<br/>    resources        = optional(list(string), ["secrets"])<br/>  })</pre> | `{}` | no |
| <a name="input_encryption_policy_description"></a> [encryption\_policy\_description](#input\_encryption\_policy\_description) | Description of the cluster encryption policy created | `string` | `"Cluster encryption policy to allow cluster role to utilize CMK provided"` | no |
| <a name="input_encryption_policy_name"></a> [encryption\_policy\_name](#input\_encryption\_policy\_name) | Name to use on cluster encryption policy created | `string` | `null` | no |
| <a name="input_encryption_policy_path"></a> [encryption\_policy\_path](#input\_encryption\_policy\_path) | Cluster encryption policy path | `string` | `null` | no |
| <a name="input_encryption_policy_tags"></a> [encryption\_policy\_tags](#input\_encryption\_policy\_tags) | A map of additional tags to add to the cluster encryption policy created | `map(string)` | `{}` | no |
| <a name="input_encryption_policy_use_name_prefix"></a> [encryption\_policy\_use\_name\_prefix](#input\_encryption\_policy\_use\_name\_prefix) | Determines whether cluster encryption policy name (`cluster_encryption_policy_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_endpoint_private_access"></a> [endpoint\_private\_access](#input\_endpoint\_private\_access) | Indicates whether or not the Amazon EKS private API server endpoint is enabled | `bool` | `true` | no |
| <a name="input_endpoint_public_access"></a> [endpoint\_public\_access](#input\_endpoint\_public\_access) | Indicates whether or not the Amazon EKS public API server endpoint is enabled | `bool` | `false` | no |
| <a name="input_endpoint_public_access_cidrs"></a> [endpoint\_public\_access\_cidrs](#input\_endpoint\_public\_access\_cidrs) | List of CIDR blocks which can access the Amazon EKS public API server endpoint | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_fargate_profiles"></a> [fargate\_profiles](#input\_fargate\_profiles) | Map of Fargate Profile definitions to create | <pre>map(object({<br/>    create = optional(bool)<br/><br/>    # Fargate profile<br/>    name       = optional(string) # Will fall back to map key<br/>    subnet_ids = optional(list(string))<br/>    selectors = optional(list(object({<br/>      labels    = optional(map(string))<br/>      namespace = string<br/>    })))<br/>    timeouts = optional(object({<br/>      create = optional(string)<br/>      delete = optional(string)<br/>    }))<br/><br/>    # IAM role<br/>    create_iam_role               = optional(bool)<br/>    iam_role_arn                  = optional(string)<br/>    iam_role_name                 = optional(string)<br/>    iam_role_use_name_prefix      = optional(bool)<br/>    iam_role_path                 = optional(string)<br/>    iam_role_description          = optional(string)<br/>    iam_role_permissions_boundary = optional(string)<br/>    iam_role_tags                 = optional(map(string))<br/>    iam_role_attach_cni_policy    = optional(bool)<br/>    iam_role_additional_policies  = optional(map(string))<br/>    create_iam_role_policy        = optional(bool)<br/>    iam_role_policy_statements = optional(list(object({<br/>      sid           = optional(string)<br/>      actions       = optional(list(string))<br/>      not_actions   = optional(list(string))<br/>      effect        = optional(string)<br/>      resources     = optional(list(string))<br/>      not_resources = optional(list(string))<br/>      principals = optional(list(object({<br/>        type        = string<br/>        identifiers = list(string)<br/>      })))<br/>      not_principals = optional(list(object({<br/>        type        = string<br/>        identifiers = list(string)<br/>      })))<br/>      condition = optional(list(object({<br/>        test     = string<br/>        values   = list(string)<br/>        variable = string<br/>      })))<br/>    })))<br/>    tags = optional(map(string))<br/>  }))</pre> | `null` | no |
| <a name="input_force_update_version"></a> [force\_update\_version](#input\_force\_update\_version) | Force version update by overriding upgrade-blocking readiness checks when updating a cluster | `bool` | `null` | no |
| <a name="input_iam_role_additional_policies"></a> [iam\_role\_additional\_policies](#input\_iam\_role\_additional\_policies) | Additional policies to be added to the IAM role | `map(string)` | `{}` | no |
| <a name="input_iam_role_arn"></a> [iam\_role\_arn](#input\_iam\_role\_arn) | Existing IAM role ARN for the cluster. Required if `create_iam_role` is set to `false` | `string` | `null` | no |
| <a name="input_iam_role_description"></a> [iam\_role\_description](#input\_iam\_role\_description) | Description of the role | `string` | `null` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name to use on IAM role created | `string` | `null` | no |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | The IAM role path | `string` | `null` | no |
| <a name="input_iam_role_permissions_boundary"></a> [iam\_role\_permissions\_boundary](#input\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM role | `string` | `null` | no |
| <a name="input_iam_role_tags"></a> [iam\_role\_tags](#input\_iam\_role\_tags) | A map of additional tags to add to the IAM role created | `map(string)` | `{}` | no |
| <a name="input_iam_role_use_name_prefix"></a> [iam\_role\_use\_name\_prefix](#input\_iam\_role\_use\_name\_prefix) | Determines whether the IAM role name (`iam_role_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_identity_providers"></a> [identity\_providers](#input\_identity\_providers) | Map of cluster identity provider configurations to enable for the cluster. Note - this is different/separate from IRSA | <pre>map(object({<br/>    client_id                     = string<br/>    groups_claim                  = optional(string)<br/>    groups_prefix                 = optional(string)<br/>    identity_provider_config_name = optional(string) # will fall back to map key<br/>    issuer_url                    = string<br/>    required_claims               = optional(map(string))<br/>    username_claim                = optional(string)<br/>    username_prefix               = optional(string)<br/>    tags                          = optional(map(string), {})<br/>  }))</pre> | `null` | no |
| <a name="input_include_oidc_root_ca_thumbprint"></a> [include\_oidc\_root\_ca\_thumbprint](#input\_include\_oidc\_root\_ca\_thumbprint) | Determines whether to include the root CA thumbprint in the OpenID Connect (OIDC) identity provider's server certificate(s) | `bool` | `true` | no |
| <a name="input_ip_family"></a> [ip\_family](#input\_ip\_family) | The IP family used to assign Kubernetes pod and service addresses. Valid values are `ipv4` (default) and `ipv6`. You can only specify an IP family when you create a cluster, changing this value will force a new cluster to be created | `string` | `"ipv4"` | no |
| <a name="input_kms_key_administrators"></a> [kms\_key\_administrators](#input\_kms\_key\_administrators) | A list of IAM ARNs for [key administrators](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-administrators). If no value is provided, the current caller identity is used to ensure at least one key admin is available | `list(string)` | `[]` | no |
| <a name="input_kms_key_aliases"></a> [kms\_key\_aliases](#input\_kms\_key\_aliases) | A list of aliases to create. Note - due to the use of `toset()`, values must be static strings and not computed values | `list(string)` | `[]` | no |
| <a name="input_kms_key_deletion_window_in_days"></a> [kms\_key\_deletion\_window\_in\_days](#input\_kms\_key\_deletion\_window\_in\_days) | The waiting period, specified in number of days. After the waiting period ends, AWS KMS deletes the KMS key. If you specify a value, it must be between `7` and `30`, inclusive. If you do not specify a value, it defaults to `30` | `number` | `null` | no |
| <a name="input_kms_key_description"></a> [kms\_key\_description](#input\_kms\_key\_description) | The description of the key as viewed in AWS console | `string` | `null` | no |
| <a name="input_kms_key_enable_default_policy"></a> [kms\_key\_enable\_default\_policy](#input\_kms\_key\_enable\_default\_policy) | Specifies whether to enable the default key policy | `bool` | `true` | no |
| <a name="input_kms_key_override_policy_documents"></a> [kms\_key\_override\_policy\_documents](#input\_kms\_key\_override\_policy\_documents) | List of IAM policy documents that are merged together into the exported document. In merging, statements with non-blank `sid`s will override statements with the same `sid` | `list(string)` | `[]` | no |
| <a name="input_kms_key_owners"></a> [kms\_key\_owners](#input\_kms\_key\_owners) | A list of IAM ARNs for those who will have full key permissions (`kms:*`) | `list(string)` | `[]` | no |
| <a name="input_kms_key_service_users"></a> [kms\_key\_service\_users](#input\_kms\_key\_service\_users) | A list of IAM ARNs for [key service users](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-service-integration) | `list(string)` | `[]` | no |
| <a name="input_kms_key_source_policy_documents"></a> [kms\_key\_source\_policy\_documents](#input\_kms\_key\_source\_policy\_documents) | List of IAM policy documents that are merged together into the exported document. Statements must have unique `sid`s | `list(string)` | `[]` | no |
| <a name="input_kms_key_users"></a> [kms\_key\_users](#input\_kms\_key\_users) | A list of IAM ARNs for [key users](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-users) | `list(string)` | `[]` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.33`) | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the EKS cluster | `string` | `""` | no |
| <a name="input_node_iam_role_additional_policies"></a> [node\_iam\_role\_additional\_policies](#input\_node\_iam\_role\_additional\_policies) | Additional policies to be added to the EKS Auto node IAM role | `map(string)` | `{}` | no |
| <a name="input_node_iam_role_description"></a> [node\_iam\_role\_description](#input\_node\_iam\_role\_description) | Description of the EKS Auto node IAM role | `string` | `null` | no |
| <a name="input_node_iam_role_name"></a> [node\_iam\_role\_name](#input\_node\_iam\_role\_name) | Name to use on the EKS Auto node IAM role created | `string` | `null` | no |
| <a name="input_node_iam_role_path"></a> [node\_iam\_role\_path](#input\_node\_iam\_role\_path) | The EKS Auto node IAM role path | `string` | `null` | no |
| <a name="input_node_iam_role_permissions_boundary"></a> [node\_iam\_role\_permissions\_boundary](#input\_node\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the EKS Auto node IAM role | `string` | `null` | no |
| <a name="input_node_iam_role_tags"></a> [node\_iam\_role\_tags](#input\_node\_iam\_role\_tags) | A map of additional tags to add to the EKS Auto node IAM role created | `map(string)` | `{}` | no |
| <a name="input_node_iam_role_use_name_prefix"></a> [node\_iam\_role\_use\_name\_prefix](#input\_node\_iam\_role\_use\_name\_prefix) | Determines whether the EKS Auto node IAM role name (`node_iam_role_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_node_security_group_additional_rules"></a> [node\_security\_group\_additional\_rules](#input\_node\_security\_group\_additional\_rules) | List of additional security group rules to add to the node security group created. Set `source_cluster_security_group = true` inside rules to set the `cluster_security_group` as source | <pre>map(object({<br/>    protocol                      = optional(string, "tcp")<br/>    from_port                     = number<br/>    to_port                       = number<br/>    type                          = optional(string, "ingress")<br/>    description                   = optional(string)<br/>    cidr_blocks                   = optional(list(string))<br/>    ipv6_cidr_blocks              = optional(list(string))<br/>    prefix_list_ids               = optional(list(string))<br/>    self                          = optional(bool)<br/>    source_cluster_security_group = optional(bool, false)<br/>    source_security_group_id      = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_node_security_group_description"></a> [node\_security\_group\_description](#input\_node\_security\_group\_description) | Description of the node security group created | `string` | `"EKS node shared security group"` | no |
| <a name="input_node_security_group_enable_recommended_rules"></a> [node\_security\_group\_enable\_recommended\_rules](#input\_node\_security\_group\_enable\_recommended\_rules) | Determines whether to enable recommended security group rules for the node security group created. This includes node-to-node TCP ingress on ephemeral ports and allows all egress traffic | `bool` | `true` | no |
| <a name="input_node_security_group_id"></a> [node\_security\_group\_id](#input\_node\_security\_group\_id) | ID of an existing security group to attach to the node groups created | `string` | `""` | no |
| <a name="input_node_security_group_name"></a> [node\_security\_group\_name](#input\_node\_security\_group\_name) | Name to use on node security group created | `string` | `null` | no |
| <a name="input_node_security_group_tags"></a> [node\_security\_group\_tags](#input\_node\_security\_group\_tags) | A map of additional tags to add to the node security group created | `map(string)` | `{}` | no |
| <a name="input_node_security_group_use_name_prefix"></a> [node\_security\_group\_use\_name\_prefix](#input\_node\_security\_group\_use\_name\_prefix) | Determines whether node security group name (`node_security_group_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_openid_connect_audiences"></a> [openid\_connect\_audiences](#input\_openid\_connect\_audiences) | List of OpenID Connect audience client IDs to add to the IRSA provider | `list(string)` | `[]` | no |
| <a name="input_outpost_config"></a> [outpost\_config](#input\_outpost\_config) | Configuration for the AWS Outpost to provision the cluster on | <pre>object({<br/>    control_plane_instance_type = optional(string)<br/>    control_plane_placement = optional(object({<br/>      group_name = string<br/>    }))<br/>    outpost_arns = list(string)<br/>  })</pre> | `null` | no |
| <a name="input_prefix_separator"></a> [prefix\_separator](#input\_prefix\_separator) | The separator to use between the prefix and the generated timestamp for resource names | `string` | `"-"` | no |
| <a name="input_putin_khuylo"></a> [putin\_khuylo](#input\_putin\_khuylo) | Do you agree that Putin doesn't respect Ukrainian sovereignty and territorial integrity? More info: https://en.wikipedia.org/wiki/Putin_khuylo! | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration | `string` | `null` | no |
| <a name="input_remote_network_config"></a> [remote\_network\_config](#input\_remote\_network\_config) | Configuration block for the cluster remote network configuration | <pre>object({<br/>    remote_node_networks = object({<br/>      cidrs = optional(list(string))<br/>    })<br/>    remote_pod_networks = optional(object({<br/>      cidrs = optional(list(string))<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_security_group_additional_rules"></a> [security\_group\_additional\_rules](#input\_security\_group\_additional\_rules) | List of additional security group rules to add to the cluster security group created. Set `source_node_security_group = true` inside rules to set the `node_security_group` as source | <pre>map(object({<br/>    protocol                   = optional(string, "tcp")<br/>    from_port                  = number<br/>    to_port                    = number<br/>    type                       = optional(string, "ingress")<br/>    description                = optional(string)<br/>    cidr_blocks                = optional(list(string))<br/>    ipv6_cidr_blocks           = optional(list(string))<br/>    prefix_list_ids            = optional(list(string))<br/>    self                       = optional(bool)<br/>    source_node_security_group = optional(bool, false)<br/>    source_security_group_id   = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_security_group_description"></a> [security\_group\_description](#input\_security\_group\_description) | Description of the cluster security group created | `string` | `"EKS cluster security group"` | no |
| <a name="input_security_group_id"></a> [security\_group\_id](#input\_security\_group\_id) | Existing security group ID to be attached to the cluster | `string` | `""` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | Name to use on cluster security group created | `string` | `null` | no |
| <a name="input_security_group_tags"></a> [security\_group\_tags](#input\_security\_group\_tags) | A map of additional tags to add to the cluster security group created | `map(string)` | `{}` | no |
| <a name="input_security_group_use_name_prefix"></a> [security\_group\_use\_name\_prefix](#input\_security\_group\_use\_name\_prefix) | Determines whether cluster security group name (`cluster_security_group_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_self_managed_node_groups"></a> [self\_managed\_node\_groups](#input\_self\_managed\_node\_groups) | Map of self-managed node group definitions to create | <pre>map(object({<br/>    create             = optional(bool)<br/>    kubernetes_version = optional(string)<br/><br/>    # Autoscaling Group<br/>    create_autoscaling_group         = optional(bool)<br/>    name                             = optional(string) # Will fall back to map key<br/>    use_name_prefix                  = optional(bool)<br/>    availability_zones               = optional(list(string))<br/>    subnet_ids                       = optional(list(string))<br/>    min_size                         = optional(number)<br/>    max_size                         = optional(number)<br/>    desired_size                     = optional(number)<br/>    desired_size_type                = optional(string)<br/>    capacity_rebalance               = optional(bool)<br/>    default_instance_warmup          = optional(number)<br/>    protect_from_scale_in            = optional(bool)<br/>    context                          = optional(string)<br/>    create_placement_group           = optional(bool)<br/>    placement_group                  = optional(string)<br/>    health_check_type                = optional(string)<br/>    health_check_grace_period        = optional(number)<br/>    ignore_failed_scaling_activities = optional(bool)<br/>    force_delete                     = optional(bool)<br/>    termination_policies             = optional(list(string))<br/>    suspended_processes              = optional(list(string))<br/>    max_instance_lifetime            = optional(number)<br/>    enabled_metrics                  = optional(list(string))<br/>    metrics_granularity              = optional(string)<br/>    initial_lifecycle_hooks = optional(list(object({<br/>      default_result          = optional(string)<br/>      heartbeat_timeout       = optional(number)<br/>      lifecycle_transition    = string<br/>      name                    = string<br/>      notification_metadata   = optional(string)<br/>      notification_target_arn = optional(string)<br/>      role_arn                = optional(string)<br/>    })))<br/>    instance_maintenance_policy = optional(object({<br/>      max_healthy_percentage = number<br/>      min_healthy_percentage = number<br/>    }))<br/>    instance_refresh = optional(object({<br/>      preferences = optional(object({<br/>        alarm_specification = optional(object({<br/>          alarms = optional(list(string))<br/>        }))<br/>        auto_rollback                = optional(bool)<br/>        checkpoint_delay             = optional(number)<br/>        checkpoint_percentages       = optional(list(number))<br/>        instance_warmup              = optional(number)<br/>        max_healthy_percentage       = optional(number)<br/>        min_healthy_percentage       = optional(number)<br/>        scale_in_protected_instances = optional(string)<br/>        skip_matching                = optional(bool)<br/>        standby_instances            = optional(string)<br/>      }))<br/>      strategy = optional(string)<br/>      triggers = optional(list(string))<br/>      })<br/>    )<br/>    use_mixed_instances_policy = optional(bool)<br/>    mixed_instances_policy = optional(object({<br/>      instances_distribution = optional(object({<br/>        on_demand_allocation_strategy            = optional(string)<br/>        on_demand_base_capacity                  = optional(number)<br/>        on_demand_percentage_above_base_capacity = optional(number)<br/>        spot_allocation_strategy                 = optional(string)<br/>        spot_instance_pools                      = optional(number)<br/>        spot_max_price                           = optional(string)<br/>      }))<br/>      launch_template = object({<br/>        override = optional(list(object({<br/>          instance_requirements = optional(object({<br/>            accelerator_count = optional(object({<br/>              max = optional(number)<br/>              min = optional(number)<br/>            }))<br/>            accelerator_manufacturers = optional(list(string))<br/>            accelerator_names         = optional(list(string))<br/>            accelerator_total_memory_mib = optional(object({<br/>              max = optional(number)<br/>              min = optional(number)<br/>            }))<br/>            accelerator_types      = optional(list(string))<br/>            allowed_instance_types = optional(list(string))<br/>            bare_metal             = optional(string)<br/>            baseline_ebs_bandwidth_mbps = optional(object({<br/>              max = optional(number)<br/>              min = optional(number)<br/>            }))<br/>            burstable_performance                                   = optional(string)<br/>            cpu_manufacturers                                       = optional(list(string))<br/>            excluded_instance_types                                 = optional(list(string))<br/>            instance_generations                                    = optional(list(string))<br/>            local_storage                                           = optional(string)<br/>            local_storage_types                                     = optional(list(string))<br/>            max_spot_price_as_percentage_of_optimal_on_demand_price = optional(number)<br/>            memory_gib_per_vcpu = optional(object({<br/>              max = optional(number)<br/>              min = optional(number)<br/>            }))<br/>            memory_mib = optional(object({<br/>              max = optional(number)<br/>              min = optional(number)<br/>            }))<br/>            network_bandwidth_gbps = optional(object({<br/>              max = optional(number)<br/>              min = optional(number)<br/>            }))<br/>            network_interface_count = optional(object({<br/>              max = optional(number)<br/>              min = optional(number)<br/>            }))<br/>            on_demand_max_price_percentage_over_lowest_price = optional(number)<br/>            require_hibernate_support                        = optional(bool)<br/>            spot_max_price_percentage_over_lowest_price      = optional(number)<br/>            total_local_storage_gb = optional(object({<br/>              max = optional(number)<br/>              min = optional(number)<br/>            }))<br/>            vcpu_count = optional(object({<br/>              max = optional(number)<br/>              min = optional(number)<br/>            }))<br/>          }))<br/>          instance_type = optional(string)<br/>          launch_template_specification = optional(object({<br/>            launch_template_id   = optional(string)<br/>            launch_template_name = optional(string)<br/>            version              = optional(string)<br/>          }))<br/>          weighted_capacity = optional(string)<br/>        })))<br/>      })<br/>    }))<br/>    timeouts = optional(object({<br/>      delete = optional(string)<br/>    }))<br/>    autoscaling_group_tags = optional(map(string))<br/>    # User data<br/>    ami_type                   = optional(string)<br/>    additional_cluster_dns_ips = optional(list(string))<br/>    pre_bootstrap_user_data    = optional(string)<br/>    post_bootstrap_user_data   = optional(string)<br/>    bootstrap_extra_args       = optional(string)<br/>    user_data_template_path    = optional(string)<br/>    cloudinit_pre_nodeadm = optional(list(object({<br/>      content      = string<br/>      content_type = optional(string)<br/>      filename     = optional(string)<br/>      merge_type   = optional(string)<br/>    })))<br/>    cloudinit_post_nodeadm = optional(list(object({<br/>      content      = string<br/>      content_type = optional(string)<br/>      filename     = optional(string)<br/>      merge_type   = optional(string)<br/>    })))<br/>    # Launch Template<br/>    create_launch_template                 = optional(bool)<br/>    use_custom_launch_template             = optional(bool)<br/>    launch_template_id                     = optional(string)<br/>    launch_template_name                   = optional(string) # Will fall back to map key<br/>    launch_template_use_name_prefix        = optional(bool)<br/>    launch_template_version                = optional(string)<br/>    launch_template_default_version        = optional(string)<br/>    update_launch_template_default_version = optional(bool)<br/>    launch_template_description            = optional(string)<br/>    launch_template_tags                   = optional(map(string))<br/>    tag_specifications                     = optional(list(string))<br/>    ebs_optimized                          = optional(bool)<br/>    ami_id                                 = optional(string)<br/>    instance_type                          = optional(string)<br/>    key_name                               = optional(string)<br/>    disable_api_termination                = optional(bool)<br/>    instance_initiated_shutdown_behavior   = optional(string)<br/>    kernel_id                              = optional(string)<br/>    ram_disk_id                            = optional(string)<br/>    block_device_mappings = optional(map(object({<br/>      device_name = optional(string)<br/>      ebs = optional(object({<br/>        delete_on_termination      = optional(bool)<br/>        encrypted                  = optional(bool)<br/>        iops                       = optional(number)<br/>        kms_key_id                 = optional(string)<br/>        snapshot_id                = optional(string)<br/>        throughput                 = optional(number)<br/>        volume_initialization_rate = optional(number)<br/>        volume_size                = optional(number)<br/>        volume_type                = optional(string)<br/>      }))<br/>      no_device    = optional(string)<br/>      virtual_name = optional(string)<br/>    })))<br/>    capacity_reservation_specification = optional(object({<br/>      capacity_reservation_preference = optional(string)<br/>      capacity_reservation_target = optional(object({<br/>        capacity_reservation_id                 = optional(string)<br/>        capacity_reservation_resource_group_arn = optional(string)<br/>      }))<br/>    }))<br/>    cpu_options = optional(object({<br/>      amd_sev_snp      = optional(string)<br/>      core_count       = optional(number)<br/>      threads_per_core = optional(number)<br/>    }))<br/>    credit_specification = optional(object({<br/>      cpu_credits = optional(string)<br/>    }))<br/>    enclave_options = optional(object({<br/>      enabled = optional(bool)<br/>    }))<br/>    instance_requirements = optional(object({<br/>      accelerator_count = optional(object({<br/>        max = optional(number)<br/>        min = optional(number)<br/>      }))<br/>      accelerator_manufacturers = optional(list(string))<br/>      accelerator_names         = optional(list(string))<br/>      accelerator_total_memory_mib = optional(object({<br/>        max = optional(number)<br/>        min = optional(number)<br/>      }))<br/>      accelerator_types      = optional(list(string))<br/>      allowed_instance_types = optional(list(string))<br/>      bare_metal             = optional(string)<br/>      baseline_ebs_bandwidth_mbps = optional(object({<br/>        max = optional(number)<br/>        min = optional(number)<br/>      }))<br/>      burstable_performance                                   = optional(string)<br/>      cpu_manufacturers                                       = optional(list(string))<br/>      excluded_instance_types                                 = optional(list(string))<br/>      instance_generations                                    = optional(list(string))<br/>      local_storage                                           = optional(string)<br/>      local_storage_types                                     = optional(list(string))<br/>      max_spot_price_as_percentage_of_optimal_on_demand_price = optional(number)<br/>      memory_gib_per_vcpu = optional(object({<br/>        max = optional(number)<br/>        min = optional(number)<br/>      }))<br/>      memory_mib = optional(object({<br/>        max = optional(number)<br/>        min = optional(number)<br/>      }))<br/>      network_bandwidth_gbps = optional(object({<br/>        max = optional(number)<br/>        min = optional(number)<br/>      }))<br/>      network_interface_count = optional(object({<br/>        max = optional(number)<br/>        min = optional(number)<br/>      }))<br/>      on_demand_max_price_percentage_over_lowest_price = optional(number)<br/>      require_hibernate_support                        = optional(bool)<br/>      spot_max_price_percentage_over_lowest_price      = optional(number)<br/>      total_local_storage_gb = optional(object({<br/>        max = optional(number)<br/>        min = optional(number)<br/>      }))<br/>      vcpu_count = optional(object({<br/>        max = optional(number)<br/>        min = string<br/>      }))<br/>    }))<br/>    instance_market_options = optional(object({<br/>      market_type = optional(string)<br/>      spot_options = optional(object({<br/>        block_duration_minutes         = optional(number)<br/>        instance_interruption_behavior = optional(string)<br/>        max_price                      = optional(string)<br/>        spot_instance_type             = optional(string)<br/>        valid_until                    = optional(string)<br/>      }))<br/>    }))<br/>    license_specifications = optional(list(object({<br/>      license_configuration_arn = string<br/>    })))<br/>    metadata_options = optional(object({<br/>      http_endpoint               = optional(string)<br/>      http_protocol_ipv6          = optional(string)<br/>      http_put_response_hop_limit = optional(number)<br/>      http_tokens                 = optional(string)<br/>      instance_metadata_tags      = optional(string)<br/>    }))<br/>    enable_monitoring  = optional(bool)<br/>    enable_efa_support = optional(bool)<br/>    enable_efa_only    = optional(bool)<br/>    efa_indices        = optional(list(string))<br/>    network_interfaces = optional(list(object({<br/>      associate_carrier_ip_address = optional(bool)<br/>      associate_public_ip_address  = optional(bool)<br/>      connection_tracking_specification = optional(object({<br/>        tcp_established_timeout = optional(number)<br/>        udp_stream_timeout      = optional(number)<br/>        udp_timeout             = optional(number)<br/>      }))<br/>      delete_on_termination = optional(bool)<br/>      description           = optional(string)<br/>      device_index          = optional(number)<br/>      ena_srd_specification = optional(object({<br/>        ena_srd_enabled = optional(bool)<br/>        ena_srd_udp_specification = optional(object({<br/>          ena_srd_udp_enabled = optional(bool)<br/>        }))<br/>      }))<br/>      interface_type       = optional(string)<br/>      ipv4_address_count   = optional(number)<br/>      ipv4_addresses       = optional(list(string))<br/>      ipv4_prefix_count    = optional(number)<br/>      ipv4_prefixes        = optional(list(string))<br/>      ipv6_address_count   = optional(number)<br/>      ipv6_addresses       = optional(list(string))<br/>      ipv6_prefix_count    = optional(number)<br/>      ipv6_prefixes        = optional(list(string))<br/>      network_card_index   = optional(number)<br/>      network_interface_id = optional(string)<br/>      primary_ipv6         = optional(bool)<br/>      private_ip_address   = optional(string)<br/>      security_groups      = optional(list(string))<br/>      subnet_id            = optional(string)<br/>    })))<br/>    placement = optional(object({<br/>      affinity                = optional(string)<br/>      availability_zone       = optional(string)<br/>      group_name              = optional(string)<br/>      host_id                 = optional(string)<br/>      host_resource_group_arn = optional(string)<br/>      partition_number        = optional(number)<br/>      spread_domain           = optional(string)<br/>      tenancy                 = optional(string)<br/>    }))<br/>    maintenance_options = optional(object({<br/>      auto_recovery = optional(string)<br/>    }))<br/>    private_dns_name_options = optional(object({<br/>      enable_resource_name_dns_aaaa_record = optional(bool)<br/>      enable_resource_name_dns_a_record    = optional(bool)<br/>      hostname_type                        = optional(string)<br/>    }))<br/>    # IAM role<br/>    create_iam_instance_profile   = optional(bool)<br/>    iam_instance_profile_arn      = optional(string)<br/>    iam_role_name                 = optional(string)<br/>    iam_role_use_name_prefix      = optional(bool)<br/>    iam_role_path                 = optional(string)<br/>    iam_role_description          = optional(string)<br/>    iam_role_permissions_boundary = optional(string)<br/>    iam_role_tags                 = optional(map(string))<br/>    iam_role_attach_cni_policy    = optional(bool)<br/>    iam_role_additional_policies  = optional(map(string))<br/>    create_iam_role_policy        = optional(bool)<br/>    iam_role_policy_statements = optional(list(object({<br/>      sid           = optional(string)<br/>      actions       = optional(list(string))<br/>      not_actions   = optional(list(string))<br/>      effect        = optional(string)<br/>      resources     = optional(list(string))<br/>      not_resources = optional(list(string))<br/>      principals = optional(list(object({<br/>        type        = string<br/>        identifiers = list(string)<br/>      })))<br/>      not_principals = optional(list(object({<br/>        type        = string<br/>        identifiers = list(string)<br/>      })))<br/>      condition = optional(list(object({<br/>        test     = string<br/>        values   = list(string)<br/>        variable = string<br/>      })))<br/>    })))<br/>    # Access entry<br/>    create_access_entry = optional(bool)<br/>    iam_role_arn        = optional(string)<br/>    # Security group<br/>    vpc_security_group_ids                = optional(list(string), [])<br/>    attach_cluster_primary_security_group = optional(bool, false)<br/>    create_security_group                 = optional(bool)<br/>    security_group_name                   = optional(string)<br/>    security_group_use_name_prefix        = optional(bool)<br/>    security_group_description            = optional(string)<br/>    security_group_ingress_rules = optional(map(object({<br/>      name                         = optional(string)<br/>      cidr_ipv4                    = optional(string)<br/>      cidr_ipv6                    = optional(string)<br/>      description                  = optional(string)<br/>      from_port                    = optional(string)<br/>      ip_protocol                  = optional(string)<br/>      prefix_list_id               = optional(string)<br/>      referenced_security_group_id = optional(string)<br/>      self                         = optional(bool)<br/>      tags                         = optional(map(string))<br/>      to_port                      = optional(string)<br/>    })))<br/>    security_group_egress_rules = optional(map(object({<br/>      name                         = optional(string)<br/>      cidr_ipv4                    = optional(string)<br/>      cidr_ipv6                    = optional(string)<br/>      description                  = optional(string)<br/>      from_port                    = optional(string)<br/>      ip_protocol                  = optional(string)<br/>      prefix_list_id               = optional(string)<br/>      referenced_security_group_id = optional(string)<br/>      self                         = optional(bool)<br/>      tags                         = optional(map(string))<br/>      to_port                      = optional(string)<br/>    })))<br/>    security_group_tags = optional(map(string))<br/><br/>    tags = optional(map(string))<br/>  }))</pre> | `null` | no |
| <a name="input_service_ipv4_cidr"></a> [service\_ipv4\_cidr](#input\_service\_ipv4\_cidr) | The CIDR block to assign Kubernetes service IP addresses from. If you don't specify a block, Kubernetes assigns addresses from either the 10.100.0.0/16 or 172.20.0.0/16 CIDR blocks | `string` | `null` | no |
| <a name="input_service_ipv6_cidr"></a> [service\_ipv6\_cidr](#input\_service\_ipv6\_cidr) | The CIDR block to assign Kubernetes pod and service IP addresses from if `ipv6` was specified when the cluster was created. Kubernetes assigns service addresses from the unique local address range (fc00::/7) because you can't specify a custom IPv6 CIDR block when you create the cluster | `string` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of subnet IDs where the nodes/node groups will be provisioned. If `control_plane_subnet_ids` is not provided, the EKS cluster control plane (ENIs) will be provisioned in these subnets | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Create, update, and delete timeout configurations for the cluster | <pre>object({<br/>    create = optional(string)<br/>    update = optional(string)<br/>    delete = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_upgrade_policy"></a> [upgrade\_policy](#input\_upgrade\_policy) | Configuration block for the cluster upgrade policy | <pre>object({<br/>    support_type = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where the cluster security group will be provisioned | `string` | `null` | no |
| <a name="input_zonal_shift_config"></a> [zonal\_shift\_config](#input\_zonal\_shift\_config) | Configuration block for the cluster zonal shift | <pre>object({<br/>    enabled = optional(bool)<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_entries"></a> [access\_entries](#output\_access\_entries) | Map of access entries created and their attributes |
| <a name="output_access_policy_associations"></a> [access\_policy\_associations](#output\_access\_policy\_associations) | Map of eks cluster access policy associations created and their attributes |
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | Arn of cloudwatch log group created |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | Name of cloudwatch log group created |
| <a name="output_cluster_addons"></a> [cluster\_addons](#output\_cluster\_addons) | Map of attribute maps for all EKS cluster addons enabled |
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | The Amazon Resource Name (ARN) of the cluster |
| <a name="output_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#output\_cluster\_certificate\_authority\_data) | Base64 encoded certificate data required to communicate with the cluster |
| <a name="output_cluster_dualstack_oidc_issuer_url"></a> [cluster\_dualstack\_oidc\_issuer\_url](#output\_cluster\_dualstack\_oidc\_issuer\_url) | Dual-stack compatible URL on the EKS cluster for the OpenID Connect identity provider |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint for your Kubernetes API server |
| <a name="output_cluster_iam_role_arn"></a> [cluster\_iam\_role\_arn](#output\_cluster\_iam\_role\_arn) | Cluster IAM role ARN |
| <a name="output_cluster_iam_role_name"></a> [cluster\_iam\_role\_name](#output\_cluster\_iam\_role\_name) | Cluster IAM role name |
| <a name="output_cluster_iam_role_unique_id"></a> [cluster\_iam\_role\_unique\_id](#output\_cluster\_iam\_role\_unique\_id) | Stable and unique string identifying the IAM role |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | The ID of the EKS cluster. Note: currently a value is returned only for local EKS clusters created on Outposts |
| <a name="output_cluster_identity_providers"></a> [cluster\_identity\_providers](#output\_cluster\_identity\_providers) | Map of attribute maps for all EKS identity providers enabled |
| <a name="output_cluster_ip_family"></a> [cluster\_ip\_family](#output\_cluster\_ip\_family) | The IP family used by the cluster (e.g. `ipv4` or `ipv6`) |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | The name of the EKS cluster |
| <a name="output_cluster_oidc_issuer_url"></a> [cluster\_oidc\_issuer\_url](#output\_cluster\_oidc\_issuer\_url) | The URL on the EKS cluster for the OpenID Connect identity provider |
| <a name="output_cluster_platform_version"></a> [cluster\_platform\_version](#output\_cluster\_platform\_version) | Platform version for the cluster |
| <a name="output_cluster_primary_security_group_id"></a> [cluster\_primary\_security\_group\_id](#output\_cluster\_primary\_security\_group\_id) | Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console |
| <a name="output_cluster_security_group_arn"></a> [cluster\_security\_group\_arn](#output\_cluster\_security\_group\_arn) | Amazon Resource Name (ARN) of the cluster security group |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | ID of the cluster security group |
| <a name="output_cluster_service_cidr"></a> [cluster\_service\_cidr](#output\_cluster\_service\_cidr) | The CIDR block where Kubernetes pod and service IP addresses are assigned from |
| <a name="output_cluster_status"></a> [cluster\_status](#output\_cluster\_status) | Status of the EKS cluster. One of `CREATING`, `ACTIVE`, `DELETING`, `FAILED` |
| <a name="output_cluster_tls_certificate_sha1_fingerprint"></a> [cluster\_tls\_certificate\_sha1\_fingerprint](#output\_cluster\_tls\_certificate\_sha1\_fingerprint) | The SHA1 fingerprint of the public key of the cluster's certificate |
| <a name="output_cluster_version"></a> [cluster\_version](#output\_cluster\_version) | The Kubernetes version for the cluster |
| <a name="output_eks_managed_node_groups"></a> [eks\_managed\_node\_groups](#output\_eks\_managed\_node\_groups) | Map of attribute maps for all EKS managed node groups created |
| <a name="output_eks_managed_node_groups_autoscaling_group_names"></a> [eks\_managed\_node\_groups\_autoscaling\_group\_names](#output\_eks\_managed\_node\_groups\_autoscaling\_group\_names) | List of the autoscaling group names created by EKS managed node groups |
| <a name="output_fargate_profiles"></a> [fargate\_profiles](#output\_fargate\_profiles) | Map of attribute maps for all EKS Fargate Profiles created |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | The Amazon Resource Name (ARN) of the key |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | The globally unique identifier for the key |
| <a name="output_kms_key_policy"></a> [kms\_key\_policy](#output\_kms\_key\_policy) | The IAM resource policy set on the key |
| <a name="output_node_iam_role_arn"></a> [node\_iam\_role\_arn](#output\_node\_iam\_role\_arn) | EKS Auto node IAM role ARN |
| <a name="output_node_iam_role_name"></a> [node\_iam\_role\_name](#output\_node\_iam\_role\_name) | EKS Auto node IAM role name |
| <a name="output_node_iam_role_unique_id"></a> [node\_iam\_role\_unique\_id](#output\_node\_iam\_role\_unique\_id) | Stable and unique string identifying the IAM role |
| <a name="output_node_security_group_arn"></a> [node\_security\_group\_arn](#output\_node\_security\_group\_arn) | Amazon Resource Name (ARN) of the node shared security group |
| <a name="output_node_security_group_id"></a> [node\_security\_group\_id](#output\_node\_security\_group\_id) | ID of the node shared security group |
| <a name="output_oidc_provider"></a> [oidc\_provider](#output\_oidc\_provider) | The OpenID Connect identity provider (issuer URL without leading `https://`) |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | The ARN of the OIDC Provider if `enable_irsa = true` |
| <a name="output_self_managed_node_groups"></a> [self\_managed\_node\_groups](#output\_self\_managed\_node\_groups) | Map of attribute maps for all self managed node groups created |
| <a name="output_self_managed_node_groups_autoscaling_group_names"></a> [self\_managed\_node\_groups\_autoscaling\_group\_names](#output\_self\_managed\_node\_groups\_autoscaling\_group\_names) | List of the autoscaling group names created by self-managed node groups |
<!-- END_TF_DOCS -->

## License

Apache 2 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/LICENSE) for full details.

## Additional information for users from Russia and Belarus

* Russia has [illegally annexed Crimea in 2014](https://en.wikipedia.org/wiki/Annexation_of_Crimea_by_the_Russian_Federation) and [brought the war in Donbas](https://en.wikipedia.org/wiki/War_in_Donbas) followed by [full-scale invasion of Ukraine in 2022](https://en.wikipedia.org/wiki/2022_Russian_invasion_of_Ukraine).
* Russia has brought sorrow and devastations to millions of Ukrainians, killed hundreds of innocent people, damaged thousands of buildings, and forced several million people to flee.
* [Putin khuylo!](https://en.wikipedia.org/wiki/Putin_khuylo!)
