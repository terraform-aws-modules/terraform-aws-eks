# Internal User Data Module

Configuration in this directory render various user data outputs used for testing and validating the internal `_user-data` sub-module.

## Usage

To provision the provided configurations you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply --auto-approve
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.2 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | >= 2.4 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks_mng_al2023_additional"></a> [eks\_mng\_al2023\_additional](#module\_eks\_mng\_al2023\_additional) | ../../modules/_user_data | n/a |
| <a name="module_eks_mng_al2023_custom_ami"></a> [eks\_mng\_al2023\_custom\_ami](#module\_eks\_mng\_al2023\_custom\_ami) | ../../modules/_user_data | n/a |
| <a name="module_eks_mng_al2023_custom_template"></a> [eks\_mng\_al2023\_custom\_template](#module\_eks\_mng\_al2023\_custom\_template) | ../../modules/_user_data | n/a |
| <a name="module_eks_mng_al2023_no_op"></a> [eks\_mng\_al2023\_no\_op](#module\_eks\_mng\_al2023\_no\_op) | ../../modules/_user_data | n/a |
| <a name="module_eks_mng_al2_additional"></a> [eks\_mng\_al2\_additional](#module\_eks\_mng\_al2\_additional) | ../../modules/_user_data | n/a |
| <a name="module_eks_mng_al2_custom_ami"></a> [eks\_mng\_al2\_custom\_ami](#module\_eks\_mng\_al2\_custom\_ami) | ../../modules/_user_data | n/a |
| <a name="module_eks_mng_al2_custom_ami_ipv6"></a> [eks\_mng\_al2\_custom\_ami\_ipv6](#module\_eks\_mng\_al2\_custom\_ami\_ipv6) | ../../modules/_user_data | n/a |
| <a name="module_eks_mng_al2_custom_template"></a> [eks\_mng\_al2\_custom\_template](#module\_eks\_mng\_al2\_custom\_template) | ../../modules/_user_data | n/a |
| <a name="module_eks_mng_al2_disabled"></a> [eks\_mng\_al2\_disabled](#module\_eks\_mng\_al2\_disabled) | ../../modules/_user_data | n/a |
| <a name="module_eks_mng_al2_no_op"></a> [eks\_mng\_al2\_no\_op](#module\_eks\_mng\_al2\_no\_op) | ../../modules/_user_data | n/a |
| <a name="module_eks_mng_bottlerocket_additional"></a> [eks\_mng\_bottlerocket\_additional](#module\_eks\_mng\_bottlerocket\_additional) | ../../modules/_user_data | n/a |
| <a name="module_eks_mng_bottlerocket_custom_ami"></a> [eks\_mng\_bottlerocket\_custom\_ami](#module\_eks\_mng\_bottlerocket\_custom\_ami) | ../../modules/_user_data | n/a |
| <a name="module_eks_mng_bottlerocket_custom_template"></a> [eks\_mng\_bottlerocket\_custom\_template](#module\_eks\_mng\_bottlerocket\_custom\_template) | ../../modules/_user_data | n/a |
| <a name="module_eks_mng_bottlerocket_no_op"></a> [eks\_mng\_bottlerocket\_no\_op](#module\_eks\_mng\_bottlerocket\_no\_op) | ../../modules/_user_data | n/a |
| <a name="module_eks_mng_windows_additional"></a> [eks\_mng\_windows\_additional](#module\_eks\_mng\_windows\_additional) | ../../modules/_user_data | n/a |
| <a name="module_eks_mng_windows_custom_ami"></a> [eks\_mng\_windows\_custom\_ami](#module\_eks\_mng\_windows\_custom\_ami) | ../../modules/_user_data | n/a |
| <a name="module_eks_mng_windows_custom_template"></a> [eks\_mng\_windows\_custom\_template](#module\_eks\_mng\_windows\_custom\_template) | ../../modules/_user_data | n/a |
| <a name="module_eks_mng_windows_no_op"></a> [eks\_mng\_windows\_no\_op](#module\_eks\_mng\_windows\_no\_op) | ../../modules/_user_data | n/a |
| <a name="module_self_mng_al2023_bootstrap"></a> [self\_mng\_al2023\_bootstrap](#module\_self\_mng\_al2023\_bootstrap) | ../../modules/_user_data | n/a |
| <a name="module_self_mng_al2023_custom_template"></a> [self\_mng\_al2023\_custom\_template](#module\_self\_mng\_al2023\_custom\_template) | ../../modules/_user_data | n/a |
| <a name="module_self_mng_al2023_no_op"></a> [self\_mng\_al2023\_no\_op](#module\_self\_mng\_al2023\_no\_op) | ../../modules/_user_data | n/a |
| <a name="module_self_mng_al2_bootstrap"></a> [self\_mng\_al2\_bootstrap](#module\_self\_mng\_al2\_bootstrap) | ../../modules/_user_data | n/a |
| <a name="module_self_mng_al2_bootstrap_ipv6"></a> [self\_mng\_al2\_bootstrap\_ipv6](#module\_self\_mng\_al2\_bootstrap\_ipv6) | ../../modules/_user_data | n/a |
| <a name="module_self_mng_al2_custom_template"></a> [self\_mng\_al2\_custom\_template](#module\_self\_mng\_al2\_custom\_template) | ../../modules/_user_data | n/a |
| <a name="module_self_mng_al2_no_op"></a> [self\_mng\_al2\_no\_op](#module\_self\_mng\_al2\_no\_op) | ../../modules/_user_data | n/a |
| <a name="module_self_mng_bottlerocket_bootstrap"></a> [self\_mng\_bottlerocket\_bootstrap](#module\_self\_mng\_bottlerocket\_bootstrap) | ../../modules/_user_data | n/a |
| <a name="module_self_mng_bottlerocket_custom_template"></a> [self\_mng\_bottlerocket\_custom\_template](#module\_self\_mng\_bottlerocket\_custom\_template) | ../../modules/_user_data | n/a |
| <a name="module_self_mng_bottlerocket_no_op"></a> [self\_mng\_bottlerocket\_no\_op](#module\_self\_mng\_bottlerocket\_no\_op) | ../../modules/_user_data | n/a |
| <a name="module_self_mng_windows_bootstrap"></a> [self\_mng\_windows\_bootstrap](#module\_self\_mng\_windows\_bootstrap) | ../../modules/_user_data | n/a |
| <a name="module_self_mng_windows_custom_template"></a> [self\_mng\_windows\_custom\_template](#module\_self\_mng\_windows\_custom\_template) | ../../modules/_user_data | n/a |
| <a name="module_self_mng_windows_no_op"></a> [self\_mng\_windows\_no\_op](#module\_self\_mng\_windows\_no\_op) | ../../modules/_user_data | n/a |

## Resources

| Name | Type |
|------|------|
| [local_file.eks_mng_al2023_additional](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.eks_mng_al2023_custom_ami](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.eks_mng_al2023_custom_template](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.eks_mng_al2023_no_op](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.eks_mng_al2_additional](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.eks_mng_al2_custom_ami](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.eks_mng_al2_custom_ami_ipv6](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.eks_mng_al2_custom_template](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.eks_mng_al2_no_op](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.eks_mng_bottlerocket_additional](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.eks_mng_bottlerocket_custom_ami](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.eks_mng_bottlerocket_custom_template](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.eks_mng_bottlerocket_no_op](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.eks_mng_windows_additional](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.eks_mng_windows_custom_ami](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.eks_mng_windows_custom_template](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.eks_mng_windows_no_op](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.self_mng_al2023_bootstrap](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.self_mng_al2023_custom_template](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.self_mng_al2023_no_op](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.self_mng_al2_bootstrap](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.self_mng_al2_bootstrap_ipv6](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.self_mng_al2_custom_template](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.self_mng_al2_no_op](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.self_mng_bottlerocket_bootstrap](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.self_mng_bottlerocket_custom_template](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.self_mng_bottlerocket_no_op](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.self_mng_windows_bootstrap](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.self_mng_windows_custom_template](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.self_mng_windows_no_op](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
