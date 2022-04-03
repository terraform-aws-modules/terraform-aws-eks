# Node Group Configuration

⚠️ The configurations shown below are referenced from within the root EKS module; there will be slight differences in the default values provided when compared to the underlying sub-modules (`eks-managed-node-group`, `self-managed-node-group`, and `fargate-profile`).

### EKS Managed Node Groups

ℹ️ Only the pertinent attributes are shown for brevity

1. AWS EKS Managed Node Group can provide its own launch template and utilize the latest AWS EKS Optimized AMI (Linux) for the given Kubernetes version. By default, the module creates a launch template to ensure tags are propagated to instances, etc., so we need to disable it to use the default template provided by the AWS EKS managed node group service:

```hcl
  eks_managed_node_groups = {
    default = {
      create_launch_template = false
      launch_template_name   = ""
    }
  }
```

2. AWS EKS Managed Node Group also offers native, default support for Bottlerocket OS by simply specifying the AMI type:

```hcl
  eks_managed_node_groups = {
    bottlerocket_default = {
      create_launch_template = false
      launch_template_name   = ""

      ami_type = "BOTTLEROCKET_x86_64"
      platform = "bottlerocket"
    }
  }
```

3. AWS EKS Managed Node Groups allow you to extend configurations by providing your own launch template and user data that is merged with what the service provides. For example, to provide additional user data before the nodes are bootstrapped as well as supply additional arguments to the bootstrap script:

```hcl
  eks_managed_node_groups = {
    extend_config = {
      # This is supplied to the AWS EKS Optimized AMI
      # bootstrap script https://github.com/awslabs/amazon-eks-ami/blob/master/files/bootstrap.sh
      bootstrap_extra_args = "--container-runtime containerd --kubelet-extra-args '--max-pods=20'"

      # This user data will be injected prior to the user data provided by the
      # AWS EKS Managed Node Group service (contains the actually bootstrap configuration)
      pre_bootstrap_user_data = <<-EOT
        export CONTAINER_RUNTIME="containerd"
        export USE_MAX_PODS=false
      EOT
    }
  }
```

4. The same configurations extension is offered when utilizing Bottlerocket OS AMIs, but the user data is slightly different. Bottlerocket OS uses a TOML user data file and you can provide additional configuration settings via the `bootstrap_extra_args` variable which gets merged into what is provided by the AWS EKS Managed Node Service:

```hcl
  eks_managed_node_groups = {
    bottlerocket_extend_config = {
      ami_type = "BOTTLEROCKET_x86_64"
      platform = "bottlerocket"

      # this will get added to what AWS provides
      bootstrap_extra_args = <<-EOT
      # extra args added
      [settings.kernel]
      lockdown = "integrity"
      EOT
    }
  }
```

5. Users can also utilize a custom AMI, but doing so means that AWS EKS Managed Node Group will NOT inject the necessary bootstrap script and configurations into the user data supplied to the launch template. When using a custom AMI, users must also opt in to bootstrapping the nodes via user data and either use the module default user data template or provide your own user data template file:

```hcl
  eks_managed_node_groups = {
    custom_ami = {
      ami_id = "ami-0caf35bc73450c396"

      # By default, EKS managed node groups will not append bootstrap script;
      # this adds it back in using the default template provided by the module
      # Note: this assumes the AMI provided is an EKS optimized AMI derivative
      enable_bootstrap_user_data = true

      bootstrap_extra_args = "--container-runtime containerd --kubelet-extra-args '--max-pods=20'"

      pre_bootstrap_user_data = <<-EOT
        export CONTAINER_RUNTIME="containerd"
        export USE_MAX_PODS=false
      EOT

      # Because we have full control over the user data supplied, we can also run additional
      # scripts/configuration changes after the bootstrap script has been run
      post_bootstrap_user_data = <<-EOT
        echo "you are free little kubelet!"
      EOT
    }
  }
```

6. Similarly, for Bottlerocket there is similar support:

```hcl
  eks_managed_node_groups = {
    bottlerocket_custom_ami = {
      ami_id   = "ami-0ff61e0bcfc81dc94"
      platform = "bottlerocket"

      # use module user data template to bootstrap
      enable_bootstrap_user_data = true
      # this will get added to the template
      bootstrap_extra_args = <<-EOT
      # extra args added
      [settings.kernel]
      lockdown = "integrity"

      [settings.kubernetes.node-labels]
      "label1" = "foo"
      "label2" = "bar"

      [settings.kubernetes.node-taints]
      "dedicated" = "experimental:PreferNoSchedule"
      "special" = "true:NoSchedule"
      EOT
    }
  }
```

See the [`examples/eks_managed_node_group/` example](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/eks_managed_node_group) for a working example of these configurations.

### Self Managed Node Groups

ℹ️ Only the pertinent attributes are shown for brevity

1. By default, the `self-managed-node-group` sub-module will use the latest AWS EKS Optimized AMI (Linux) for the given Kubernetes version:

```hcl
  cluster_version = "1.21"

  # This self managed node group will use the latest AWS EKS Optimized AMI for Kubernetes 1.21
  self_managed_node_groups = {
    default = {}
  }
```

2. To use Bottlerocket, specify the `platform` as `bottlerocket` and supply the Bottlerocket AMI. The module provided user data for Bottlerocket will be used to bootstrap the nodes created:

```hcl
  cluster_version = "1.21"

  self_managed_node_groups = {
    bottlerocket = {
      platform = "bottlerocket"
      ami_id   = data.aws_ami.bottlerocket_ami.id
    }
  }
```

### Fargate Profiles

Fargate profiles are rather straightforward. Simply supply the necessary information for the desired profile(s). See the [`examples/fargate_profile/` example](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/fargate_profile) for a working example of the various configurations.

### Mixed Node Groups

ℹ️ Only the pertinent attributes are shown for brevity

Users are free to mix and match the different node group types that meet their needs. For example, the following are just an example of the different possibilities:

- AWS EKS Cluster with one or more AWS EKS Managed Node Groups
- AWS EKS Cluster with one or more Self Managed Node Groups
- AWS EKS Cluster with one or more Fargate profiles
- AWS EKS Cluster with one or more AWS EKS Managed Node Groups, one or more Self Managed Node Groups, one or more Fargate profiles

It is also possible to configure the various node groups of each family differently. Node groups may also be defined outside of the root `eks` module definition by using the provided sub-modules. There are no restrictions on the the various different possibilities provided by the module.

```hcl
  self_managed_node_group_defaults = {
    vpc_security_group_ids       = [aws_security_group.additional.id]
    iam_role_additional_policies = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
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

      update_config = {
        max_unavailable_percentage = 50 # or set `max_unavailable`
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
```

See the [`examples/complete/` example](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/complete) for a working example of these configurations.

### Default configurations

Each node group type (EKS managed node group, self managed node group, or Fargate profile) provides a default configuration setting that allows users to provide their own default configuration instead of the module's default configuration. This allows users to set a common set of defaults for their node groups and still maintain the ability to override these settings within the specific node group definition. The order of precedence for each node group type roughly follows (from highest to least precedence):

- Node group individual configuration
  - Node group family default configuration
    - Module default configuration

These are provided via the following variables for the respective node group family:

- `eks_managed_node_group_defaults`
- `self_managed_node_group_defaults`
- `fargate_profile_defaults`

For example, the following creates 4 AWS EKS Managed Node Groups:

```hcl
  eks_managed_node_group_defaults = {
    ami_type               = "AL2_x86_64"
    disk_size              = 50
    instance_types         = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    # Uses defaults provided by module with the default settings above overriding the module defaults
    default = {}

    # This further overrides the instance types used
    compute = {
      instance_types = ["c5.large", "c6i.large", "c6d.large"]
    }

    # This further overrides the instance types and disk size used
    persistent = {
      disk_size = 1024
      instance_types = ["r5.xlarge", "r6i.xlarge", "r5b.xlarge"]
    }

    # This overrides the OS used
    bottlerocket = {
      ami_type = "BOTTLEROCKET_x86_64"
      platform = "bottlerocket"
    }
  }
```

### IRSA Integration

An [IAM role for service accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) module has been created to work in conjunction with the EKS module. The [`iam-role-for-service-accounts`](https://github.com/terraform-aws-modules/terraform-aws-iam/tree/master/modules/iam-role-for-service-accounts-eks) module has a set of pre-defined IAM policies for common addons/controllers/custom resources to allow users to quickly enable common integrations. Check [`policy.tf`](https://github.com/terraform-aws-modules/terraform-aws-iam/blob/master/modules/iam-role-for-service-accounts-eks/policies.tf) for a list of the policies currently supported. A example of this integration is shown below, and more can be found in the [`iam-role-for-service-accounts`](https://github.com/terraform-aws-modules/terraform-aws-iam/blob/master/examples/iam-role-for-service-accounts-eks/main.tf) example directory:

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"

  cluster_name    = "example"
  cluster_version = "1.21"

  cluster_addons = {
    vpc-cni = {
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
    }
  }

  vpc_id     = "vpc-1234556abcdef"
  subnet_ids = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]

  eks_managed_node_group_defaults = {
    # We are using the IRSA created below for permissions
    # This is a better practice as well so that the nodes do not have the permission,
    # only the VPC CNI addon will have the permission
    iam_role_attach_cni_policy = false
  }

  eks_managed_node_groups = {
    default = {}
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "vpc_cni"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

module "karpenter_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                          = "karpenter_controller"
  attach_karpenter_controller_policy = true

  karpenter_controller_cluster_id         = module.eks.cluster_id
  karpenter_controller_node_iam_role_arns = [
    module.eks.eks_managed_node_groups["default"].iam_role_arn
  ]

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["karpenter:karpenter"]
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```
