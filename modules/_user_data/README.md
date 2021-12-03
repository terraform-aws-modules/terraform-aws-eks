# Internal User Data Module

Configuration in this directory renderes the appropriate user data for the given inputs. There are a number of different ways that user data can be utilized and this internal module is designed to aid in making that flexibility possible without over complicating and duplicating code.

## Combinations

At a high level, we have two methods for launching nodes within the EKS module:

1. EKS managed node group
2. Self managed node group

### EKS Managed Node Group

Within the EKS managed node group, users have 2 methods of user data populating

ℹ️ Note: When using bottlerocket as the desired platform, since the user data for bottlerocket is TOML, all configurations are merged in the one file supplied as user data. Therefore, `pre_bootstra_user_data` and `post_bootstrap_user_data` are not valid since the bottlerocket OS handles when various settings are applied. If you wish to supply additional configuration settings when using bottlerocket, supply them via the `bootstrap_extra_args` variable. For the linux platform, `bootstrap_extra_args` are settings that will be supplied to the [AWS EKS Optimized AMI boostrap script](https://github.com/awslabs/amazon-eks-ami/blob/master/files/bootstrap.sh#L14) such as kubelet extra args, etc.

1. If the EKS managed node group does not use a custom AMI, the EKS managed node group is responsible for the AMI used, then users can elect to supply additional user data that is pre-pended before the EKS managed node group bootstrap user data. You can read more about this process from the [AWS supplied documentation](https://docs.aws.amazon.com/eks/latest/userguide/launch-templates.html#launch-template-user-data)

    - Users can use the following two variables to supplement this process:

      ```hcl
      pre_bootstrap_user_data = "..."
      bootstrap_extra_args    = "..."
      ```

2. If the EKS managed node group utilizes a custom AMI, then per the [AWS documentation](https://docs.aws.amazon.com/eks/latest/userguide/launch-templates.html#launch-template-custom-ami), users will need to supply the necessary bootstrap configuration via user data to ensure that the node is configured to register with the cluster upon launch. There are two routes that users can utilize to facilitate this bootstrapping process:
    - If the AMI used is a derivative of the [AWS EKS Optimized AMI ](https://github.com/awslabs/amazon-eks-ami), users can opt in to using a template provided by the module that provides the minimum necessary configuration to bootstrap the node when launched, with the option to add additional pre and post boostrap user data as well as bootstrap additional args that are supplied to the [AWS EKS boostrap.sh script](https://github.com/awslabs/amazon-eks-ami/blob/master/files/bootstrap.sh)
      - Users can use the following variables to facilitate this process:
        ```hcl
        enable_bootstrap_user_data = true # to opt in to using the module supplied bootstrap user data template
        pre_bootstrap_user_data    = "..."
        bootstrap_extra_args       = "..."
        post_bootstrap_user_data   = "..."
        ```
    - If the AMI is not an AWS EKS Optmized AMI derivative, or if users wish to have more control over the user data that is supplied to the node upon launch, users have the ability to supply their own user data template that will be rendered instead of the module supplied template. Note - only the variables that are supplied to the `templatefile()` for the respective platform/OS are available for use in the supplied template, otherwise users will need to pre-render/pre-populate the template before supplying the final template to the module for rendering as user data.
      - Users can use the following variables to faciliate this process:
        ```hcl
        user_data_template_path  = "./your/user_data.sh" # user supplied bootstrap user data template
        pre_bootstrap_user_data  = "..."
        bootstrap_extra_args     = "..."
        post_bootstrap_user_data = "..."
        ```

### Self Managed Node Group

Within the self managed node group, the options presented to users is very similar to the 2nd option listed above for EKS managed node groups. Because self managed node groups require users to provide the bootstrap user data, there is no concept of appending to user data that AWS provides, users can either elect to use the user data template provided for their platform/OS by the module or provide their own user data template for rendering by the module.

- If the AMI used is a derivative of the [AWS EKS Optimized AMI ](https://github.com/awslabs/amazon-eks-ami), users can opt in to using a template provided by the module that provides the minimum necessary configuration to bootstrap the node when launched, with the option to add additional pre and post boostrap user data as well as bootstrap additional args that are supplied to the [AWS EKS boostrap.sh script](https://github.com/awslabs/amazon-eks-ami/blob/master/files/bootstrap.sh)
  - Users can use the following variables to facilitate this process:
    ```hcl
    enable_bootstrap_user_data = true # to opt in to using the module supplied bootstrap user data template
    pre_bootstrap_user_data    = "..."
    bootstrap_extra_args       = "..."
    post_bootstrap_user_data   = "..."
    ```
- If the AMI is not an AWS EKS Optmized AMI derivative, or if users wish to have more control over the user data that is supplied to the node upon launch, users have the ability to supply their own user data template that will be rendered instead of the module supplied template. Note - only the variables that are supplied to the `templatefile()` for the respective platform/OS are available for use in the supplied template, otherwise users will need to pre-render/pre-populate the template before supplying the final template to the module for rendering as user data.
  - Users can use the following variables to faciliate this process:
    ```hcl
    user_data_template_path  = "./your/user_data.sh" # user supplied bootstrap user data template
    pre_bootstrap_user_data  = "..."
    bootstrap_extra_args     = "..."
    post_bootstrap_user_data = "..."
    ```

### Logic Diagram

The rough flow of logic that is encapsulated within the `_user_data` internal module can be represented by the following diagram to better highlight the various manners in which user data can be populated.

<p align="center">
  <img src="https://raw.githubusercontent.com/terraform-aws-modules/terraform-aws-eks/master/.github/images/user_data.svg" alt="User Data" width="100%">
  <!-- TODO - Delete this line below before merging -->
  <img src="../../.github/images/user_data.svg" alt="User Data" width="100%">
</p>

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
````

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_cloudinit"></a> [cloudinit](#requirement\_cloudinit) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | >= 2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [cloudinit_config.linux_eks_managed_node_group](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bootstrap_extra_args"></a> [bootstrap\_extra\_args](#input\_bootstrap\_extra\_args) | Additional arguments passed to the bootstrap script | `string` | `""` | no |
| <a name="input_cluster_auth_base64"></a> [cluster\_auth\_base64](#input\_cluster\_auth\_base64) | Base64 encoded CA of associated EKS cluster | `string` | `""` | no |
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | Endpoint of associated EKS cluster | `string` | `""` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster and default name (prefix) used throughout the resources created | `string` | `""` | no |
| <a name="input_create"></a> [create](#input\_create) | Determines whether to create EKS managed node group or not | `bool` | `true` | no |
| <a name="input_enable_bootstrap_user_data"></a> [enable\_bootstrap\_user\_data](#input\_enable\_bootstrap\_user\_data) | Determines whether the bootstrap configurations are populated within the user data template | `bool` | `false` | no |
| <a name="input_is_eks_managed_node_group"></a> [is\_eks\_managed\_node\_group](#input\_is\_eks\_managed\_node\_group) | Determines whether the user data is used on nodes in an EKS managed node group | `bool` | `true` | no |
| <a name="input_platform"></a> [platform](#input\_platform) | Identifies if the OS platform is `bottlerocket`, `linux`, or `windows` based | `string` | `"linux"` | no |
| <a name="input_post_bootstrap_user_data"></a> [post\_bootstrap\_user\_data](#input\_post\_bootstrap\_user\_data) | User data that is appended to the user data script after of the EKS bootstrap script. Only valid when using a custom EKS optimized AMI derivative | `string` | `""` | no |
| <a name="input_pre_bootstrap_user_data"></a> [pre\_bootstrap\_user\_data](#input\_pre\_bootstrap\_user\_data) | User data that is injected into the user data script ahead of the EKS bootstrap script | `string` | `""` | no |
| <a name="input_user_data_template_path"></a> [user\_data\_template\_path](#input\_user\_data\_template\_path) | Path to a local, custom user data template file to use when rendering user data | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_user_data"></a> [user\_data](#output\_user\_data) | Base64 encoded user data rendered for the provided inputs |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->