# Internal User Data Module

Configuration in this directory render various user data outputs used for testing and validating the internal `_user-data` sub-module.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks_mng_bottlerocket_additional"></a> [eks\_mng\_bottlerocket\_additional](#module\_eks\_mng\_bottlerocket\_additional) | ../../modules/_user_data | n/a |
| <a name="module_eks_mng_bottlerocket_custom_ami"></a> [eks\_mng\_bottlerocket\_custom\_ami](#module\_eks\_mng\_bottlerocket\_custom\_ami) | ../../modules/_user_data | n/a |
| <a name="module_eks_mng_bottlerocket_custom_template"></a> [eks\_mng\_bottlerocket\_custom\_template](#module\_eks\_mng\_bottlerocket\_custom\_template) | ../../modules/_user_data | n/a |
| <a name="module_eks_mng_bottlerocket_no_op"></a> [eks\_mng\_bottlerocket\_no\_op](#module\_eks\_mng\_bottlerocket\_no\_op) | ../../modules/_user_data | n/a |
| <a name="module_eks_mng_linux_additional"></a> [eks\_mng\_linux\_additional](#module\_eks\_mng\_linux\_additional) | ../../modules/_user_data | n/a |
| <a name="module_eks_mng_linux_custom_ami"></a> [eks\_mng\_linux\_custom\_ami](#module\_eks\_mng\_linux\_custom\_ami) | ../../modules/_user_data | n/a |
| <a name="module_eks_mng_linux_custom_template"></a> [eks\_mng\_linux\_custom\_template](#module\_eks\_mng\_linux\_custom\_template) | ../../modules/_user_data | n/a |
| <a name="module_eks_mng_linux_no_op"></a> [eks\_mng\_linux\_no\_op](#module\_eks\_mng\_linux\_no\_op) | ../../modules/_user_data | n/a |
| <a name="module_self_mng_bottlerocket_bootstrap"></a> [self\_mng\_bottlerocket\_bootstrap](#module\_self\_mng\_bottlerocket\_bootstrap) | ../../modules/_user_data | n/a |
| <a name="module_self_mng_bottlerocket_custom_template"></a> [self\_mng\_bottlerocket\_custom\_template](#module\_self\_mng\_bottlerocket\_custom\_template) | ../../modules/_user_data | n/a |
| <a name="module_self_mng_bottlerocket_no_op"></a> [self\_mng\_bottlerocket\_no\_op](#module\_self\_mng\_bottlerocket\_no\_op) | ../../modules/_user_data | n/a |
| <a name="module_self_mng_linux_bootstrap"></a> [self\_mng\_linux\_bootstrap](#module\_self\_mng\_linux\_bootstrap) | ../../modules/_user_data | n/a |
| <a name="module_self_mng_linux_custom_template"></a> [self\_mng\_linux\_custom\_template](#module\_self\_mng\_linux\_custom\_template) | ../../modules/_user_data | n/a |
| <a name="module_self_mng_linux_no_op"></a> [self\_mng\_linux\_no\_op](#module\_self\_mng\_linux\_no\_op) | ../../modules/_user_data | n/a |
| <a name="module_self_mng_windows_bootstrap"></a> [self\_mng\_windows\_bootstrap](#module\_self\_mng\_windows\_bootstrap) | ../../modules/_user_data | n/a |
| <a name="module_self_mng_windows_custom_template"></a> [self\_mng\_windows\_custom\_template](#module\_self\_mng\_windows\_custom\_template) | ../../modules/_user_data | n/a |
| <a name="module_self_mng_windows_no_op"></a> [self\_mng\_windows\_no\_op](#module\_self\_mng\_windows\_no\_op) | ../../modules/_user_data | n/a |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eks_mng_bottlerocket_additional"></a> [eks\_mng\_bottlerocket\_additional](#output\_eks\_mng\_bottlerocket\_additional) | Base64 decoded user data rendered for the provided inputs |
| <a name="output_eks_mng_bottlerocket_custom_ami"></a> [eks\_mng\_bottlerocket\_custom\_ami](#output\_eks\_mng\_bottlerocket\_custom\_ami) | Base64 decoded user data rendered for the provided inputs |
| <a name="output_eks_mng_bottlerocket_custom_template"></a> [eks\_mng\_bottlerocket\_custom\_template](#output\_eks\_mng\_bottlerocket\_custom\_template) | Base64 decoded user data rendered for the provided inputs |
| <a name="output_eks_mng_bottlerocket_no_op"></a> [eks\_mng\_bottlerocket\_no\_op](#output\_eks\_mng\_bottlerocket\_no\_op) | Base64 decoded user data rendered for the provided inputs |
| <a name="output_eks_mng_linux_additional"></a> [eks\_mng\_linux\_additional](#output\_eks\_mng\_linux\_additional) | Base64 decoded user data rendered for the provided inputs |
| <a name="output_eks_mng_linux_custom_ami"></a> [eks\_mng\_linux\_custom\_ami](#output\_eks\_mng\_linux\_custom\_ami) | Base64 decoded user data rendered for the provided inputs |
| <a name="output_eks_mng_linux_custom_template"></a> [eks\_mng\_linux\_custom\_template](#output\_eks\_mng\_linux\_custom\_template) | Base64 decoded user data rendered for the provided inputs |
| <a name="output_eks_mng_linux_no_op"></a> [eks\_mng\_linux\_no\_op](#output\_eks\_mng\_linux\_no\_op) | Base64 decoded user data rendered for the provided inputs |
| <a name="output_self_mng_bottlerocket_bootstrap"></a> [self\_mng\_bottlerocket\_bootstrap](#output\_self\_mng\_bottlerocket\_bootstrap) | Base64 decoded user data rendered for the provided inputs |
| <a name="output_self_mng_bottlerocket_custom_template"></a> [self\_mng\_bottlerocket\_custom\_template](#output\_self\_mng\_bottlerocket\_custom\_template) | Base64 decoded user data rendered for the provided inputs |
| <a name="output_self_mng_bottlerocket_no_op"></a> [self\_mng\_bottlerocket\_no\_op](#output\_self\_mng\_bottlerocket\_no\_op) | Base64 decoded user data rendered for the provided inputs |
| <a name="output_self_mng_linux_bootstrap"></a> [self\_mng\_linux\_bootstrap](#output\_self\_mng\_linux\_bootstrap) | Base64 decoded user data rendered for the provided inputs |
| <a name="output_self_mng_linux_custom_template"></a> [self\_mng\_linux\_custom\_template](#output\_self\_mng\_linux\_custom\_template) | Base64 decoded user data rendered for the provided inputs |
| <a name="output_self_mng_linux_no_op"></a> [self\_mng\_linux\_no\_op](#output\_self\_mng\_linux\_no\_op) | Base64 decoded user data rendered for the provided inputs |
| <a name="output_self_mng_windows_bootstrap"></a> [self\_mng\_windows\_bootstrap](#output\_self\_mng\_windows\_bootstrap) | Base64 decoded user data rendered for the provided inputs |
| <a name="output_self_mng_windows_custom_template"></a> [self\_mng\_windows\_custom\_template](#output\_self\_mng\_windows\_custom\_template) | Base64 decoded user data rendered for the provided inputs |
| <a name="output_self_mng_windows_no_op"></a> [self\_mng\_windows\_no\_op](#output\_self\_mng\_windows\_no\_op) | Base64 decoded user data rendered for the provided inputs |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
