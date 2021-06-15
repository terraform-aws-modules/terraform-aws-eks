## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 0.13.0)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (>= 3.43.0)

## Providers

The following providers are used by this module:

- <a name="provider_aws"></a> [aws](#provider\_aws) (3.45.0)

## Modules

The following Modules are called:

### <a name="module_iam_assumable_role_with_oidc"></a> [iam\_assumable\_role\_with\_oidc](#module\_iam\_assumable\_role\_with\_oidc)

Source: terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc

Version: v4.1.0

## Resources

The following resources are used by this module:

- [aws_eks_addon.coredns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) (resource)
- [aws_eks_addon.kube_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) (resource)
- [aws_eks_addon.vpc_cni](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name)

Description: Name of parent cluster

Type: `string`

### <a name="input_cluster_oidc_issuer_url"></a> [cluster\_oidc\_issuer\_url](#input\_cluster\_oidc\_issuer\_url)

Description: The cluster oidc issuer url

Type: `string`

### <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version)

Description: Kubernetes version to use for the EKS cluster.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_coredns_versions"></a> [coredns\_versions](#input\_coredns\_versions)

Description: The CoreDns plugin version for the corresponding version

Type: `map(any)`

Default:

```json
{
  "1.18": "v1.8.3-eksbuild.1",
  "1.19": "v1.8.3-eksbuild.1",
  "1.20": "v1.8.3-eksbuild.1"
}
```

### <a name="input_create_coredns_addon"></a> [create\_coredns\_addon](#input\_create\_coredns\_addon)

Description: Controls if coredns addon should be deployed

Type: `bool`

Default: `true`

### <a name="input_create_kube_proxy_addon"></a> [create\_kube\_proxy\_addon](#input\_create\_kube\_proxy\_addon)

Description: Controls if kube proxy addon should be deployed

Type: `bool`

Default: `true`

### <a name="input_create_vpc_cni_addon"></a> [create\_vpc\_cni\_addon](#input\_create\_vpc\_cni\_addon)

Description: Controls if vpc cni addon should be deployed

Type: `bool`

Default: `true`

### <a name="input_eks_depends_on"></a> [eks\_depends\_on](#input\_eks\_depends\_on)

Description: List of references to other resources this submodule depends on.

Type: `any`

Default: `null`

### <a name="input_enable_irsa"></a> [enable\_irsa](#input\_enable\_irsa)

Description: Whether to create iam role for vpc cni and attach it to the service account, if irsa=false vpc cni plugin will not be deployed

Type: `bool`

Default: `true`

### <a name="input_kube_proxy_versions"></a> [kube\_proxy\_versions](#input\_kube\_proxy\_versions)

Description: The Kube proxy plugin version for the corresponding eks version

Type: `map(any)`

Default:

```json
{
  "1.18": "v1.18.8-eksbuild.1",
  "1.19": "v1.19.6-eksbuild.2",
  "1.20": "v1.20.4-eksbuild.2"
}
```

### <a name="input_vpc_cni_versions"></a> [vpc\_cni\_versions](#input\_vpc\_cni\_versions)

Description: The VPC CNI plugin version for the corresponding eks version

Type: `map(any)`

Default:

```json
{
  "1.18": "v1.7.10-eksbuild.1",
  "1.19": "v1.7.10-eksbuild.1",
  "1.20": "v1.7.10-eksbuild.1"
}
```

## Outputs

The following outputs are exported:

### <a name="output_coredns_id"></a> [coredns\_id](#output\_coredns\_id)

Description: The id of the CoreDns addon

### <a name="output_kube_proxy_id"></a> [kube\_proxy\_id](#output\_kube\_proxy\_id)

Description: The id of the kube-proxy addon

### <a name="output_vpc_cni_id"></a> [vpc\_cni\_id](#output\_vpc\_cni\_id)

Description: The id of the Amazon VPC CNI addon
