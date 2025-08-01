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
    }
  }
```

3. Bottlerocket OS is supported in a similar manner. However, note that the user data for Bottlerocket OS uses the TOML format:

```hcl
  eks_managed_node_groups = {
    bottlerocket_prepend_userdata = {
      ami_type = "BOTTLEROCKET_x86_64"

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
      ami_id   = "ami-0caf35bc73450c396"
      ami_type = "AL2023_x86_64_STANDARD"

      # By default, EKS managed node groups will not append bootstrap script;
      # this adds it back in using the default template provided by the module
      # Note: this assumes the AMI provided is an EKS optimized AMI derivative
      enable_bootstrap_user_data = true

      cloudinit_pre_nodeadm = [{
        content      = <<-EOT
          ---
          apiVersion: node.eks.aws/v1alpha1
          kind: NodeConfig
          spec:
            kubelet:
              config:
                shutdownGracePeriod: 30s
        EOT
        content_type = "application/node.eks.aws"
      }]

      # This is only possible when `ami_id` is specified, indicating a custom AMI
      cloudinit_post_nodeadm = [{
        content      = <<-EOT
          echo "All done"
        EOT
        content_type = "text/x-shellscript; charset=\"us-ascii\""
      }]
    }
  }
```

5. There is similar support for Bottlerocket OS:

```hcl
  eks_managed_node_groups = {
    bottlerocket_custom_ami = {
      ami_id   = "ami-0ff61e0bcfc81dc94"
      ami_type = "BOTTLEROCKET_x86_64"

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

See the [`examples/eks-managed-node-group/` example](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/eks-managed-node-group) for a working example of various configurations.

### Self Managed Node Groups

Refer to the [Self Managed Node Group documentation](https://docs.aws.amazon.com/eks/latest/userguide/worker.html) documentation for service related details.

1. The `self-managed-node-group` uses the latest AWS EKS Optimized AMI (Linux) for the given Kubernetes version by default:

```hcl
  kubernetes_version = "1.33"

  # This self managed node group will use the latest AWS EKS Optimized AMI for Kubernetes 1.33
  self_managed_node_groups = {
    default = {}
  }
```

2. To use Bottlerocket, specify the `ami_type` as one of the respective `"BOTTLEROCKET_*" types` and supply a Bottlerocket OS AMI:

```hcl
  kubernetes_version = "1.33"

  self_managed_node_groups = {
    bottlerocket = {
      ami_id   = data.aws_ami.bottlerocket_ami.id
      ami_type = "BOTTLEROCKET_x86_64"
    }
  }
```

See the [`examples/self-managed-node-group/` example](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/self-managed-node-group) for a working example of various configurations.

### Fargate Profiles

Fargate profiles are straightforward to use and therefore no further details are provided here. See the [`tests/fargate-profile/` tests](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/tests/fargate-profile) for a working example of various configurations.
