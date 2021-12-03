# Complete AWS EKS Cluster

Configuration in this directory creates EKS cluster with different features shown all-in-one cluster (e.g. Managed Node Groups, Worker Groups, Fargate, Spot instances, AWS Auth enabled).

This example can be used to do smoke test.

See configurations in other `examples` directories for more specific cases.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
<<<<<<< HEAD
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.64 |
<<<<<<< HEAD
| <a name="requirement_http"></a> [http](#requirement\_http) | >= 2.4.1 |
=======
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.56 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 1.11.1 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 1.4 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 2.1 |
>>>>>>> b876ff9 (fix: update CI/CD process to enable auto-release workflow (#1698))
=======
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.0 |
>>>>>>> e831206 (feat: add additional resources, outputs for aws-auth configmap)

## Providers

| Name | Version |
|------|---------|
<<<<<<< HEAD
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.64 |
<<<<<<< HEAD
=======
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.56 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 2.1 |
>>>>>>> b876ff9 (fix: update CI/CD process to enable auto-release workflow (#1698))
=======
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.0 |
>>>>>>> e831206 (feat: add additional resources, outputs for aws-auth configmap)

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_disabled_eks"></a> [disabled\_eks](#module\_disabled\_eks) | ../.. | n/a |
<<<<<<< HEAD
| <a name="module_disabled_eks_managed_node_group"></a> [disabled\_eks\_managed\_node\_group](#module\_disabled\_eks\_managed\_node\_group) | ../../modules/eks-managed-node-group | n/a |
| <a name="module_disabled_fargate_profile"></a> [disabled\_fargate\_profile](#module\_disabled\_fargate\_profile) | ../../modules/fargate-profile | n/a |
| <a name="module_disabled_self_managed_node_group"></a> [disabled\_self\_managed\_node\_group](#module\_disabled\_self\_managed\_node\_group) | ../../modules/self-managed-node-group | n/a |
=======
| <a name="module_disabled_fargate"></a> [disabled\_fargate](#module\_disabled\_fargate) | ../../modules/fargate | n/a |
| <a name="module_disabled_node_groups"></a> [disabled\_node\_groups](#module\_disabled\_node\_groups) | ../../modules/node_groups | n/a |
>>>>>>> b876ff9 (fix: update CI/CD process to enable auto-release workflow (#1698))
| <a name="module_eks"></a> [eks](#module\_eks) | ../.. | n/a |
| <a name="module_eks_managed_node_group"></a> [eks\_managed\_node\_group](#module\_eks\_managed\_node\_group) | ../../modules/eks-managed-node-group | n/a |
| <a name="module_fargate_profile"></a> [fargate\_profile](#module\_fargate\_profile) | ../../modules/fargate-profile | n/a |
| <a name="module_self_managed_node_group"></a> [self\_managed\_node\_group](#module\_self\_managed\_node\_group) | ../../modules/self-managed-node-group | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_kms_key.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_security_group.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [null_resource.patch](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_eks_cluster_auth.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_auth_configmap_yaml"></a> [aws\_auth\_configmap\_yaml](#output\_aws\_auth\_configmap\_yaml) | Formatted yaml output for base aws-auth configmap containing roles used in cluster node groups/fargate profiles |
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | Arn of cloudwatch log group created |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | Name of cloudwatch log group created |
| <a name="output_cluster_addons"></a> [cluster\_addons](#output\_cluster\_addons) | Map of attribute maps for all EKS cluster addons enabled |
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | The Amazon Resource Name (ARN) of the cluster |
| <a name="output_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#output\_cluster\_certificate\_authority\_data) | Base64 encoded certificate data required to communicate with the cluster |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint for your Kubernetes API server |
| <a name="output_cluster_iam_role_arn"></a> [cluster\_iam\_role\_arn](#output\_cluster\_iam\_role\_arn) | IAM role ARN of the EKS cluster |
| <a name="output_cluster_iam_role_name"></a> [cluster\_iam\_role\_name](#output\_cluster\_iam\_role\_name) | IAM role name of the EKS cluster |
| <a name="output_cluster_iam_role_unique_id"></a> [cluster\_iam\_role\_unique\_id](#output\_cluster\_iam\_role\_unique\_id) | Stable and unique string identifying the IAM role |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | The name/id of the EKS cluster. Will block on cluster creation until the cluster is really ready |
| <a name="output_cluster_identity_providers"></a> [cluster\_identity\_providers](#output\_cluster\_identity\_providers) | Map of attribute maps for all EKS identity providers enabled |
| <a name="output_cluster_oidc_issuer_url"></a> [cluster\_oidc\_issuer\_url](#output\_cluster\_oidc\_issuer\_url) | The URL on the EKS cluster for the OpenID Connect identity provider |
| <a name="output_cluster_platform_version"></a> [cluster\_platform\_version](#output\_cluster\_platform\_version) | Platform version for the cluster |
| <a name="output_cluster_security_group_arn"></a> [cluster\_security\_group\_arn](#output\_cluster\_security\_group\_arn) | Amazon Resource Name (ARN) of the cluster security group |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console |
| <a name="output_cluster_status"></a> [cluster\_status](#output\_cluster\_status) | Status of the EKS cluster. One of `CREATING`, `ACTIVE`, `DELETING`, `FAILED` |
| <a name="output_eks_managed_node_groups"></a> [eks\_managed\_node\_groups](#output\_eks\_managed\_node\_groups) | Map of attribute maps for all EKS managed node groups created |
| <a name="output_fargate_profiles"></a> [fargate\_profiles](#output\_fargate\_profiles) | Map of attribute maps for all EKS Fargate Profiles created |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | The ARN of the OIDC Provider if `enable_irsa = true` |
| <a name="output_self_managed_node_groups"></a> [self\_managed\_node\_groups](#output\_self\_managed\_node\_groups) | Map of attribute maps for all self managed node groups created |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
