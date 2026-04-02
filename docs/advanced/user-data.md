# User Data & Bootstrapping

User data controls how nodes bootstrap and register with the EKS cluster. The behavior varies by node group type and AMI type. Reference the [user data submodule](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/modules/_user_data) for the underlying implementation and the [templates directory](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/templates) for bootstrap templates.

## Overview

The behavior of user data differs depending on the node group type:

- EKS Managed Node Groups: By default, any user data you supply is pre-pended to the user data provided by the EKS Managed Node Group service. If `ami_id` is set, EKS no longer injects bootstrap user data — you must supply it yourself (see [Custom AMIs](#custom-amis) below).
- Self-Managed Node Groups: The module provides bootstrap templates for each AMI type. Users can provide their own template via `user_data_template_path` if needed.

The templates provided by the module can be found in the [templates directory](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/templates).

## EKS Managed Node Groups

When no `ami_id` is specified, the EKS Managed Node Group service injects bootstrap user data automatically. Any user data you supply through the module is pre-pended before the EKS-injected bootstrap script runs. This allows you to perform pre-configuration steps before the node joins the cluster.

For more details on this behavior, refer to the [AWS launch template user data documentation](https://docs.aws.amazon.com/eks/latest/userguide/launch-templates.html#launch-template-user-data).

The variable used to supply pre-bootstrap user data depends on the AMI type:

For `AL2023_*`, use `cloudinit_pre_nodeadm` with a YAML content block:

```hcl
cloudinit_pre_nodeadm = [{
  content      = <<-EOT
    ---
    apiVersion: node.eks.aws/v1alpha1
    kind: NodeConfig
    spec:
      ...
  EOT
  content_type = "application/node.eks.aws"
}]
```

> When using Bottlerocket, the supplied user data (TOML format) is merged with the values provided by EKS. As a result, `pre_bootstrap_user_data` and `post_bootstrap_user_data` are not applicable. Supply additional Bottlerocket configuration settings via `bootstrap_extra_args` instead. See the [Bottlerocket documentation](https://github.com/bottlerocket-os/bottlerocket#description-of-settings) for supported settings.

## Self-Managed Node Groups

Self-managed node groups always require bootstrap user data since there is no EKS-managed injection. The module provides a default bootstrap template for each AMI type:

| AMI type | Template format |
|----------|----------------|
| `AL2023_*` | MIME multipart (nodeadm) |
| `BOTTLEROCKET_*` | TOML |
| `WINDOWS_*` | PowerShell script |

Users can provide their own template using the `user_data_template_path` variable:

```hcl
user_data_template_path = "./your/user_data.sh"
```

Note that only the variables supplied to `templatefile()` for the respective AMI type are available within a custom template. If additional variables are needed, pre-render the template before passing it to the module.

## AL2 end of life

Amazon Linux 2 (AL2) reached end of life on June 30, 2025. All examples in this documentation use AL2023. If you are still running AL2 nodes, migrate to AL2023. See the [upgrade guides](../upgrade/UPGRADE-21.0.md) for details on migrating node groups to AL2023.

## Custom AMIs

When using a custom AMI (via `ami_id`), the bootstrapping behavior changes. For managed node groups, AWS no longer injects bootstrap user data — you must provide it yourself. Refer to the [AWS documentation](https://docs.aws.amazon.com/eks/latest/userguide/launch-templates.html#launch-template-custom-ami) for details on this behavior.

When `ami_id` is set on an EKS managed node group, you must also specify `ami_type`. The `ami_type` tells the module which bootstrap template format to use — AL2023 uses nodeadm (MIME multipart), Bottlerocket uses TOML, and Windows uses PowerShell. Without `ami_type`, the module cannot generate the correct user data for your AMI.

### Module-provided bootstrap

Set `enable_bootstrap_user_data = true` to use the module's built-in bootstrap template. This approach assumes the AMI is a derivative of the [AWS EKS Optimized AMI](https://github.com/awslabs/amazon-eks-ami).

For `AL2023_*` AMI types, use `cloudinit_pre_nodeadm` and `cloudinit_post_nodeadm`:

```hcl
eks_managed_node_groups = {
  custom_ami = {
    ami_id   = "ami-0caf35bc73450c396"
    ami_type = "AL2023_x86_64_STANDARD"

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

    cloudinit_post_nodeadm = [{
      content      = <<-EOT
        echo "All done"
      EOT
      content_type = "text/x-shellscript; charset=\"us-ascii\""
    }]
  }
}
```

For `BOTTLEROCKET_*` AMI types, supply additional settings via `bootstrap_extra_args` in TOML format:

```hcl
eks_managed_node_groups = {
  bottlerocket_custom_ami = {
    ami_id   = "ami-0ff61e0bcfc81dc94"
    ami_type = "BOTTLEROCKET_x86_64"

    enable_bootstrap_user_data = true
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

### Custom template

If the AMI is not an EKS Optimized AMI derivative, or if you need full control over the bootstrap process, provide your own template using `user_data_template_path`:

```hcl
user_data_template_path  = "./your/user_data.sh"
pre_bootstrap_user_data  = "..."
bootstrap_extra_args     = "..."
post_bootstrap_user_data = "..."
```

Only the variables supplied to `templatefile()` for the respective AMI type are available within the custom template. If additional variables are needed, pre-render the template before passing it to the module.

### Self-managed node groups with custom AMIs

Self-managed node groups always require bootstrap user data regardless of whether a custom AMI is used, since there is no EKS-managed injection. The same two approaches apply: use `enable_bootstrap_user_data = true` with the module's built-in template (assumes an EKS Optimized AMI derivative), or supply a fully custom template via `user_data_template_path`. The [template files](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/templates) can serve as a reference for writing your own.

## Examples

User data customization is demonstrated in the [EKS Managed Node Group](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/eks-managed-node-group) and [Self-Managed Node Group](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/self-managed-node-group) examples on GitHub.
