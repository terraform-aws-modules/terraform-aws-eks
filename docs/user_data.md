# User Data & Bootstrapping

Users can see the various methods of using and providing user data through the [user data examples](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/user_data) as well more detailed information on the design and possible configurations via the [user data module itself](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/modules/_user_data)

## Summary

- AWS EKS Managed Node Groups
  - By default, any supplied user data is pre-pended to the user data supplied by the EKS Managed Node Group service
  - If users supply an `ami_id`, the service no longers supplies user data to bootstrap nodes; users can enable `enable_bootstrap_user_data` and use the module provided user data template, or provide their own user data template
  - `bottlerocket` platform user data must be in TOML format
- Self Managed Node Groups
  - `linux` platform (default) -> the user data template (bash/shell script) provided by the module is used as the default; users are able to provide their own user data template
  - `bottlerocket` platform -> the user data template (TOML file) provided by the module is used as the default; users are able to provide their own user data template
  - `windows` platform -> the user data template (powershell/PS1 script) provided by the module is used as the default; users are able to provide their own user data template

The templates provided by the module can be found under the [templates directory](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/templates)

## EKS Managed Node Group

When using an EKS managed node group, users have 2 primary routes for interacting with the bootstrap user data:

1. If a value for `ami_id` is not provided, users can supply additional user data that is pre-pended before the EKS Managed Node Group bootstrap user data. You can read more about this process from the [AWS supplied documentation](https://docs.aws.amazon.com/eks/latest/userguide/launch-templates.html#launch-template-user-data)

   - Users can use the following variables to facilitate this process:

     ```hcl
     pre_bootstrap_user_data = "..."
     ```

2. If a custom AMI is used, then per the [AWS documentation](https://docs.aws.amazon.com/eks/latest/userguide/launch-templates.html#launch-template-custom-ami), users will need to supply the necessary user data to bootstrap and register nodes with the cluster when launched. There are two routes to facilitate this bootstrapping process:
   - If the AMI used is a derivative of the [AWS EKS Optimized AMI ](https://github.com/awslabs/amazon-eks-ami), users can opt in to using a template provided by the module that provides the minimum necessary configuration to bootstrap the node when launched:
     - Users can use the following variables to facilitate this process:
       ```hcl
       enable_bootstrap_user_data = true # to opt in to using the module supplied bootstrap user data template
       pre_bootstrap_user_data    = "..."
       bootstrap_extra_args       = "..."
       post_bootstrap_user_data   = "..."
       ```
   - If the AMI is **NOT** an AWS EKS Optimized AMI derivative, or if users wish to have more control over the user data that is supplied to the node when launched, users have the ability to supply their own user data template that will be rendered instead of the module supplied template. Note - only the variables that are supplied to the `templatefile()` for the respective platform/OS are available for use in the supplied template, otherwise users will need to pre-render/pre-populate the template before supplying the final template to the module for rendering as user data.
     - Users can use the following variables to facilitate this process:
       ```hcl
       user_data_template_path  = "./your/user_data.sh" # user supplied bootstrap user data template
       pre_bootstrap_user_data  = "..."
       bootstrap_extra_args     = "..."
       post_bootstrap_user_data = "..."
       ```

| ℹ️ When using bottlerocket as the desired platform, since the user data for bottlerocket is TOML, all configurations are merged in the one file supplied as user data. Therefore, `pre_bootstrap_user_data` and `post_bootstrap_user_data` are not valid since the bottlerocket OS handles when various settings are applied. If you wish to supply additional configuration settings when using bottlerocket, supply them via the `bootstrap_extra_args` variable. For the linux platform, `bootstrap_extra_args` are settings that will be supplied to the [AWS EKS Optimized AMI bootstrap script](https://github.com/awslabs/amazon-eks-ami/blob/master/files/bootstrap.sh#L14) such as kubelet extra args, etc. See the [bottlerocket GitHub repository documentation](https://github.com/bottlerocket-os/bottlerocket#description-of-settings) for more details on what settings can be supplied via the `bootstrap_extra_args` variable. |
| :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |

#### ⚠️ Caveat

Since the EKS Managed Node Group service provides the necessary bootstrap user data to nodes (unless an `ami_id` is provided), users do not have direct access to settings/variables provided by the EKS optimized AMI [`bootstrap.sh` script](https://github.com/awslabs/amazon-eks-ami/blob/master/files/bootstrap.sh). Currently, users must employ work-arounds to influence the `bootstrap.sh` script. For example, to enable `containerd` on EKS Managed Node Groups, users can supply the following user data. You can learn more about this issue [here](https://github.com/awslabs/amazon-eks-ami/issues/844):

```hcl
  # See issue https://github.com/awslabs/amazon-eks-ami/issues/844
  pre_bootstrap_user_data = <<-EOT
  #!/bin/bash
  set -ex
  cat <<-EOF > /etc/profile.d/bootstrap.sh
  export CONTAINER_RUNTIME="containerd"
  export USE_MAX_PODS=false
  export KUBELET_EXTRA_ARGS="--max-pods=110"
  EOF
  # Source extra environment variables in bootstrap script
  sed -i '/^set -o errexit/a\\nsource /etc/profile.d/bootstrap.sh' /etc/eks/bootstrap.sh
  EOT
```

### Self Managed Node Group

Self managed node groups require users to provide the necessary bootstrap user data. Users can elect to use the user data template provided by the module for their platform/OS or provide their own user data template for rendering by the module.

- If the AMI used is a derivative of the [AWS EKS Optimized AMI ](https://github.com/awslabs/amazon-eks-ami), users can opt in to using a template provided by the module that provides the minimum necessary configuration to bootstrap the node when launched:
  - Users can use the following variables to facilitate this process:
    ```hcl
    enable_bootstrap_user_data = true # to opt in to using the module supplied bootstrap user data template
    pre_bootstrap_user_data    = "..."
    bootstrap_extra_args       = "..."
    post_bootstrap_user_data   = "..."
    ```
  - If the AMI is **NOT** an AWS EKS Optimized AMI derivative, or if users wish to have more control over the user data that is supplied to the node when launched, users have the ability to supply their own user data template that will be rendered instead of the module supplied template. Note - only the variables that are supplied to the `templatefile()` for the respective platform/OS are available for use in the supplied template, otherwise users will need to pre-render/pre-populate the template before supplying the final template to the module for rendering as user data.
    - Users can use the following variables to facilitate this process:
      ```hcl
      user_data_template_path  = "./your/user_data.sh" # user supplied bootstrap user data template
      pre_bootstrap_user_data  = "..."
      bootstrap_extra_args     = "..."
      post_bootstrap_user_data = "..."
      ```

### Logic Diagram

The rough flow of logic that is encapsulated within the `_user_data` module can be represented by the following diagram to better highlight the various manners in which user data can be populated.

<p align="center">
  <img src="https://raw.githubusercontent.com/terraform-aws-modules/terraform-aws-eks/master/.github/images/user_data.svg" alt="User Data" width="60%">
</p>
