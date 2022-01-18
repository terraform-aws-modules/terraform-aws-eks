# User Data Module

Configuration in this directory renders the appropriate user data for the given inputs. See [`docs/user_data.md`](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/user_data.md) for more info.

See [`examples/user_data/`](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/user_data) for various examples using this module.

### Template Variables

This module provides a number of default templates and the ability to override these with custom templates, the following variables are passed in to the `templatefile` and can be used in custom templates.

| Name | Description | Type |
|------|-------------|------|
| `cluster_name` | Name of the EKS cluster | `string` |
| `cluster_endpoint` | Endpoint of associated EKS cluster | `string` |
| `cluster_auth_base64` | Base64 encoded CA of associated EKS cluster | `string` |
| `cluster_service_ipv4_cidr` | The CIDR block to assign Kubernetes service IP addresses from, if specified | `string` |
| `platform` | Identifies if the OS platform is `bottlerocket`, `linux`, or `windows` based | `string` |
| `is_eks_managed_node_group` | Determines whether the user data is used on nodes in an EKS managed node group. | `string` |
| `merge_user_data` | Determines if the user data is being merged | `string` |
| `enable_bootstrap_user_data` | User defined flag | `bool` |
| `pre_bootstrap_user_data` | User defined content | `string` |
| `post_bootstrap_user_data` | User defined content | `string` |
| `bootstrap_extra_args` | User defined content | `string` |
| `user_data_env` | A merged map of default environment variables set by the module (see below) and user defined content | `map(string)` |

The default environment variables provided in `user_data_env` are as follows.

- `CLUSTER_NAME`
- `API_SERVER_URL`
- `B64_CLUSTER_CA`
- `SERVICE_IPV4_CIDR`
- `BOOTSTRAP_EXTRA_ARGS`

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
| [cloudinit_config.merge_user_data](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | The AMI from which to launch the instance. If not supplied, EKS will use its own default image | `string` | `""` | no |
| <a name="input_bootstrap_extra_args"></a> [bootstrap\_extra\_args](#input\_bootstrap\_extra\_args) | Additional arguments passed to the bootstrap script. When `platform` == `linux` prefer adding env variables to `user_data_env` for consistency with merged user data. When `platform` == `bottlerocket`; these are additional [settings](https://github.com/bottlerocket-os/bottlerocket#settings) in TOML that are provided to the Bottlerocket user data | `string` | `""` | no |
| <a name="input_cluster_auth_base64"></a> [cluster\_auth\_base64](#input\_cluster\_auth\_base64) | Base64 encoded CA of associated EKS cluster | `string` | `""` | no |
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | Endpoint of associated EKS cluster | `string` | `""` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `string` | `""` | no |
| <a name="input_cluster_service_ipv4_cidr"></a> [cluster\_service\_ipv4\_cidr](#input\_cluster\_service\_ipv4\_cidr) | The CIDR block to assign Kubernetes service IP addresses from. If you don't specify a block, Kubernetes assigns addresses from either the 10.100.0.0/16 or 172.20.0.0/16 CIDR blocks | `string` | `null` | no |
| <a name="input_create"></a> [create](#input\_create) | Determines whether to create user-data or not | `bool` | `true` | no |
| <a name="input_enable_bootstrap_user_data"></a> [enable\_bootstrap\_user\_data](#input\_enable\_bootstrap\_user\_data) | Determines whether the bootstrap configurations are populated within the user data template | `bool` | `false` | no |
| <a name="input_is_eks_managed_node_group"></a> [is\_eks\_managed\_node\_group](#input\_is\_eks\_managed\_node\_group) | Determines whether the user data is used on nodes in an EKS managed node group. Used with `ami_id` to determine if user data will be appended or not | `bool` | `true` | no |
| <a name="input_platform"></a> [platform](#input\_platform) | Identifies if the OS platform is `bottlerocket`, `linux`, or `windows` based | `string` | `"linux"` | no |
| <a name="input_post_bootstrap_user_data"></a> [post\_bootstrap\_user\_data](#input\_post\_bootstrap\_user\_data) | User data that is appended to the user data script after of the EKS bootstrap script. Not used in the default template when user data is being merged or `platform` == `bottlerocket` | `string` | `""` | no |
| <a name="input_pre_bootstrap_user_data"></a> [pre\_bootstrap\_user\_data](#input\_pre\_bootstrap\_user\_data) | User data that is injected into the user data script ahead of the EKS bootstrap script. Not used in the default template when `platform` == `bottlerocket` | `string` | `""` | no |
| <a name="input_user_data_env"></a> [user\_data\_env](#input\_user\_data\_env) | Map of environment variables to export as part of the user data. When user data is being merged these are also persisted and made available in the bootstrap script. Not used when `platform` == `bottlerocket` | `map(string)` | `{}` | no |
| <a name="input_user_data_template_path"></a> [user\_data\_template\_path](#input\_user\_data\_template\_path) | Path to a local, custom user data template file to use when rendering user data | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_user_data"></a> [user\_data](#output\_user\_data) | Base64 encoded user data rendered for the provided inputs |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
