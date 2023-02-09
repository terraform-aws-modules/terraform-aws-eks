# Compute Resources

## Table of Contents

- [EKS Managed Node Groups](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/compute_resources.md#eks-managed-node-groups)
- [Self Managed Node Groups](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/compute_resources.md#self-managed-node-groups)
- [Fargate Profiles](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/compute_resources.md#fargate-profiles)
- [Default Configurations](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/compute_resources.md#default-configurations)

ℹ️ Only the pertinent attributes are shown below for brevity

### EKS Managed Node Groups

Refer to the [EKS Managed Node Group documentation](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html) documentation for service related details.

1. The module creates a custom launch template by default to ensure settings such as tags are propagated to instances. Please note that many of the customization options listed [here](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/modules/eks-managed-node-group#Inputs) are only available when a custom launch template is created. To use the default template provided by the AWS EKS managed node group service, disable the launch template creation by setting `use_custom_launch_template` to `false`:

```hcl
  eks_managed_node_groups = {
    default = {
      use_custom_launch_template = false
    }
  }
```

2. Native support for Bottlerocket OS is provided by providing the respective AMI type:

```hcl
  eks_managed_node_groups = {
    bottlerocket_default = {
      use_custom_launch_template = false

      ami_type = "BOTTLEROCKET_x86_64"
      platform = "bottlerocket"
    }
  }
```

3. Bottlerocket OS is supported in a similar manner. However, note that the user data for Bottlerocket OS uses the TOML format:

```hcl
  eks_managed_node_groups = {
    bottlerocket_prepend_userdata = {
      ami_type = "BOTTLEROCKET_x86_64"
      platform = "bottlerocket"

      bootstrap_extra_args = <<-EOT
        # extra args added
        [settings.kernel]
        lockdown = "integrity"
      EOT
    }
  }
```

4. When using a custom AMI, the AWS EKS Managed Node Group service will NOT inject the necessary bootstrap script into the supplied user data. Users can elect to provide their own user data to bootstrap and connect or opt in to use the module provided user data:

```hcl
  eks_managed_node_groups = {
    custom_ami = {
      ami_id = "ami-0caf35bc73450c396"

      # By default, EKS managed node groups will not append bootstrap script;
      # this adds it back in using the default template provided by the module
      # Note: this assumes the AMI provided is an EKS optimized AMI derivative
      enable_bootstrap_user_data = true

      pre_bootstrap_user_data = <<-EOT
        export FOO=bar
      EOT

      # Because we have full control over the user data supplied, we can also run additional
      # scripts/configuration changes after the bootstrap script has been run
      post_bootstrap_user_data = <<-EOT
        echo "you are free little kubelet!"
      EOT
    }
  }
```

5. There is similar support for Bottlerocket OS:

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

See the [`examples/eks_managed_node_group/` example](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/eks_managed_node_group) for a working example of various configurations.

### Self Managed Node Groups

Refer to the [Self Managed Node Group documentation](https://docs.aws.amazon.com/eks/latest/userguide/worker.html) documentation for service related details.

1. The `self-managed-node-group` uses the latest AWS EKS Optimized AMI (Linux) for the given Kubernetes version by default:

```hcl
  cluster_version = "1.24"

  # This self managed node group will use the latest AWS EKS Optimized AMI for Kubernetes 1.24
  self_managed_node_groups = {
    default = {}
  }
```

2. To use Bottlerocket, specify the `platform` as `bottlerocket` and supply a Bottlerocket OS AMI:

```hcl
  cluster_version = "1.24"

  self_managed_node_groups = {
    bottlerocket = {
      platform = "bottlerocket"
      ami_id   = data.aws_ami.bottlerocket_ami.id
    }
  }
```

See the [`examples/self_managed_node_group/` example](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/self_managed_node_group) for a working example of various configurations.

### Fargate Profiles

Fargate profiles are straightforward to use and therefore no further details are provided here. See the [`examples/fargate_profile/` example](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/fargate_profile) for a working example of various configurations.

### Default Configurations

Each type of compute resource (EKS managed node group, self managed node group, or Fargate profile) provides the option for users to specify a default configuration. These default configurations can be overridden from within the compute resource's individual definition. The order of precedence for configurations (from highest to least precedence):

- Compute resource individual configuration
  - Compute resource family default configuration (`eks_managed_node_group_defaults`, `self_managed_node_group_defaults`, `fargate_profile_defaults`)
    - Module default configuration (see `variables.tf` and `node_groups.tf`)

For example, the following creates 4 AWS EKS Managed Node Groups:

```hcl
  eks_managed_node_group_defaults = {
    ami_type               = "AL2_x86_64"
    disk_size              = 50
    instance_types         = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    # Uses module default configurations overridden by configuration above
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
