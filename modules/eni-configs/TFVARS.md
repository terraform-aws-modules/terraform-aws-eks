# Usage

Automated tfvars output for the eniconfig module. Use this to find all of the available input flags and created resources.

<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 1.3 |
| aws | >=4.57.0 |
| kubernetes | ~> 2.18.1 |

## Providers

| Name | Version |
|------|---------|
| aws | >=4.57.0 |
| kubernetes | ~> 2.18.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_name | name of cluster | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| eni\_config\_data | eniconfigs |

<!--- END_TF_DOCS --->
