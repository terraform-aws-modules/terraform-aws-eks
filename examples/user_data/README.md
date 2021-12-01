# Internal User Data Module

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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.64 |

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
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
