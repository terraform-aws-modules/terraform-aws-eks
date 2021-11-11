# EKS Managed Node Group Module


# User Data Configurations

- https://github.com/aws/containers-roadmap/issues/596#issuecomment-675097667
> An important note is that user data must in MIME multi-part archive format,
> as by default, EKS will merge the bootstrapping command required for nodes to join the
> cluster with your user data. If you use a custom AMI in your launch template,
> this merging will (__NOT__) happen and you are responsible for nodes joining the cluster.
> See [docs for more details](https://docs.aws.amazon.com/eks/latest/userguide/launch-templates.html#launch-template-user-data)

- https://aws.amazon.com/blogs/containers/introducing-launch-template-and-custom-ami-support-in-amazon-eks-managed-node-groups/

a. Use EKS provided AMI which merges its user data with the user data users provide in the launch template
  i. No additional user data
  ii. Add additional user data
b. Use custom AMI which MUST bring its own user data that bootstraps the node
  i. Bring your own user data (whole shebang)
  ii. Use "default" template provided by module here and (optionally) any additional user data

TODO - need to try these out in order and verify and document what happens with user data.


## From LT
This is based on the LT that EKS would create if no custom one is specified (aws ec2 describe-launch-template-versions --launch-template-id xxx) there are several more options one could set but you probably dont need to modify them you can take the default and add your custom AMI and/or custom tags
#
Trivia: AWS transparently creates a copy of your LaunchTemplate and actually uses that copy then for the node group. If you DONT use a custom AMI,

If you use a custom AMI, you need to supply via user-data, the bootstrap script as EKS DOESNT merge its managed user-data then you can add more than the minimum code you see in the template, e.g. install SSM agent, see https://github.com/aws/containers-roadmap/issues/593#issuecomment-577181345
  #
(optionally you can use https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/cloudinit_config to render the script, example: https://github.com/terraform-aws-modules/terraform-aws-eks/pull/997#issuecomment-705286151) then the default user-data for bootstrapping a cluster is merged in the copy.

## Node Groups' IAM Role

The role ARN specified in `var.default_iam_role_arn` will be used by default. In a simple configuration this will be the worker role created by the parent module.

`iam_role_arn` must be specified in either `var.node_groups_defaults` or `var.node_groups` if the default parent IAM role is not being created for whatever reason, for example if `manage_worker_iam_resources` is set to false in the parent.

## `node_groups` and `node_groups_defaults` keys
`node_groups_defaults` is a map that can take the below keys. Values will be used if not specified in individual node groups.

`node_groups` is a map of maps. Key of first level will be used as unique value for `for_each` resources and in the `aws_eks_node_group` name. Inner map can take the below values.

| Name | Description | Type | If unset |
|------|-------------|:----:|:-----:|
| additional\_tags | Additional tags to apply to node group | map(string) | Only `var.tags` applied |
| ami\_release\_version | AMI version of workers | string | Provider default behavior |
| ami\_type | AMI Type. See Terraform or AWS docs | string | Provider default behavior |
| ami\_id | ID of custom AMI. If you use a custom AMI, you need to set `ami_is_eks_optimized` | string | Provider default behavior |
| ami\_is\_eks\_optimized | If the custom AMI is an EKS optimised image, ignored if `ami_id` is not set. If this is `true` then `bootstrap.sh` is called automatically (max pod logic needs to be manually set), if this is `false` you need to provide all the node configuration in `pre_userdata` | bool | `true` |
| capacity\_type | Type of instance capacity to provision. Options are `ON_DEMAND` and `SPOT` | string | Provider default behavior |
| create_launch_template | Create and use a default launch template | bool |  `false` |
| desired\_capacity | Desired number of workers | number | `var.workers_group_defaults[asg_desired_capacity]` |
| disk\_encrypted | Whether the root disk will be encrypyted. Requires `create_launch_template` to be `true` and `disk_kms_key_id` to be set | bool | false |
| disk\_kms\_key\_id | KMS Key used to encrypt the root disk. Requires both `create_launch_template` and `disk_encrypted` to be `true` | string | "" |
| disk\_size | Workers' disk size | number | Provider default behavior |
| disk\_type | Workers' disk type. Require `create_launch_template` to be `true`| string | Provider default behavior |
| disk\_throughput | Workers' disk throughput. Require `create_launch_template` to be `true` and `disk_type` to be `gp3`| number | Provider default behavior |
| disk\_iops | Workers' disk IOPS. Require `create_launch_template` to be `true` and `disk_type` to be `gp3`| number | Provider default behavior |
| ebs\_optimized | Enables/disables EBS optimization. Require `create_launch_template` to be `true` | bool | `true` if defined `instance\_types` are not present in `var.ebs\_optimized\_not\_supported` |
| enable_monitoring | Enables/disables detailed monitoring. Require `create_launch_template` to be `true`| bool | `true` |
| eni_delete | Delete the Elastic Network Interface (ENI) on termination (if set to false you will have to manually delete before destroying) | bool | `true` |
| force\_update\_version | Force version update if existing pods are unable to be drained due to a pod disruption budget issue. | bool | Provider default behavior |
| iam\_role\_arn | IAM role ARN for workers | string | `var.default_iam_role_arn` |
| instance\_types | Node group's instance type(s). Multiple types can be specified when `capacity_type="SPOT"`. | list | `[var.workers_group_defaults[instance_type]]` |
| k8s\_labels | Kubernetes labels | map(string) | No labels applied |
| key\_name | Key name for workers. Set to empty string to disable remote access | string | `var.workers_group_defaults[key_name]` |
| bootstrap_env | Provide environment variables to customise [bootstrap.sh](https://github.com/awslabs/amazon-eks-ami/blob/master/files/bootstrap.sh). Require `create_launch_template` to be `true` | map(string) | `{}` |
| kubelet_extra_args | Extra arguments for kubelet, this is automatically merged with `labels`. Require `create_launch_template` to be `true` | string | "" |
| launch_template_id | The id of a aws_launch_template to use | string | No LT used |
| launch\_template_version | The version of the LT to use | string | none |
| max\_capacity | Max number of workers | number | `var.workers_group_defaults[asg_max_size]` |
| min\_capacity | Min number of workers | number | `var.workers_group_defaults[asg_min_size]` |
| update_config.max\_unavailable\_percentage | Max percentage of unavailable nodes during update. (e.g. 25, 50, etc) | number | `null` if `update_config.max_unavailable` is set |
| update_config.max\_unavailable | Max number of unavailable nodes during update  | number | `null` if `update_config.max_unavailable_percentage` is set |
| name | Name of the node group. If you don't really need this, we recommend you to use `name_prefix` instead. | string | Will use the autogenerate name prefix |
| name_prefix | Name prefix of the node group | string | Auto generated |
| pre_userdata | userdata to pre-append to the default userdata. Require `create_launch_template` to be `true`| string | "" |
| public_ip | Associate a public ip address with a worker. Require `create_launch_template` to be `true`| string | `false`
| source\_security\_group\_ids | Source security groups for remote access to workers | list(string) | If key\_name is specified: THE REMOTE ACCESS WILL BE OPENED TO THE WORLD |
| subnets | Subnets to contain workers | list(string) | `var.workers_group_defaults[subnets]` |
| version | Kubernetes version | string | Provider default behavior |
| taints | Kubernetes node taints | list(map) | empty |
| timeouts | A map of timeouts for create/update/delete operations. | `map(string)` | Provider default behavior |
| update_default_version | Whether or not to set the new launch template version the Default | bool | `true` |
| metadata_http_endpoint | The state of the instance metadata service. Requires `create_launch_template` to be `true` | string | `var.workers_group_defaults[metadata_http_endpoint]` |
| metadata_http_tokens | If session tokens are required. Requires `create_launch_template` to be `true` | string | `var.workers_group_defaults[metadata_http_tokens]` |
| metadata_http_put_response_hop_limit | The desired HTTP PUT response hop limit for instance metadata requests. Requires `create_launch_template` to be `true` | number | `var.workers_group_defaults[metadata_http_put_response_hop_limit]` |

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.56.0 |
| <a name="requirement_cloudinit"></a> [cloudinit](#requirement\_cloudinit) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.56.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eks_node_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_iam_policy_document.assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | The AMI from which to launch the instance. If not supplied, EKS will use its own default image | `string` | `null` | no |
| <a name="input_ami_release_version"></a> [ami\_release\_version](#input\_ami\_release\_version) | AMI version of the EKS Node Group. Defaults to latest version for Kubernetes version | `string` | `null` | no |
| <a name="input_ami_type"></a> [ami\_type](#input\_ami\_type) | Type of Amazon Machine Image (AMI) associated with the EKS Node Group. Valid values are `AL2_x86_64`, `AL2_x86_64_GPU`, `AL2_ARM_64`, `CUSTOM`, `BOTTLEROCKET_ARM_64`, `BOTTLEROCKET_x86_64` | `string` | `null` | no |
| <a name="input_block_device_mappings"></a> [block\_device\_mappings](#input\_block\_device\_mappings) | Specify volumes to attach to the instance besides the volumes specified by the AMI | `list(any)` | `[]` | no |
| <a name="input_capacity_reservation_specification"></a> [capacity\_reservation\_specification](#input\_capacity\_reservation\_specification) | Targeting for EC2 capacity reservations | `any` | `null` | no |
| <a name="input_capacity_type"></a> [capacity\_type](#input\_capacity\_type) | Type of capacity associated with the EKS Node Group. Valid values: `ON_DEMAND`, `SPOT` | `string` | `null` | no |
| <a name="input_cluster_auth_base64"></a> [cluster\_auth\_base64](#input\_cluster\_auth\_base64) | Base64 encoded CA of associated EKS cluster | `string` | `""` | no |
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | Endpoint of associated EKS cluster | `string` | `""` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of associated EKS cluster | `string` | `null` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Kubernetes version. Defaults to EKS Cluster Kubernetes version | `string` | `null` | no |
| <a name="input_cpu_options"></a> [cpu\_options](#input\_cpu\_options) | The CPU options for the instance | `map(string)` | `null` | no |
| <a name="input_create"></a> [create](#input\_create) | Determines whether to create EKS managed node group or not | `bool` | `true` | no |
| <a name="input_create_iam_role"></a> [create\_iam\_role](#input\_create\_iam\_role) | Determines whether an IAM role is created or to use an existing IAM role | `bool` | `true` | no |
| <a name="input_create_launch_template"></a> [create\_launch\_template](#input\_create\_launch\_template) | Determines whether to create launch template or not | `bool` | `false` | no |
| <a name="input_credit_specification"></a> [credit\_specification](#input\_credit\_specification) | Customize the credit specification of the instance | `map(string)` | `null` | no |
| <a name="input_default_version"></a> [default\_version](#input\_default\_version) | Default Version of the launch template | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the launch template | `string` | `null` | no |
| <a name="input_desired_size"></a> [desired\_size](#input\_desired\_size) | Desired number of worker nodes | `number` | `1` | no |
| <a name="input_disable_api_termination"></a> [disable\_api\_termination](#input\_disable\_api\_termination) | If true, enables EC2 instance termination protection | `bool` | `null` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Disk size in GiB for worker nodes. Defaults to `20` | `number` | `null` | no |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | If true, the launched EC2 instance will be EBS-optimized | `bool` | `null` | no |
| <a name="input_elastic_gpu_specifications"></a> [elastic\_gpu\_specifications](#input\_elastic\_gpu\_specifications) | The elastic GPU to attach to the instance | `map(string)` | `null` | no |
| <a name="input_elastic_inference_accelerator"></a> [elastic\_inference\_accelerator](#input\_elastic\_inference\_accelerator) | Configuration block containing an Elastic Inference Accelerator to attach to the instance | `map(string)` | `null` | no |
| <a name="input_enable_monitoring"></a> [enable\_monitoring](#input\_enable\_monitoring) | Enables/disables detailed monitoring | `bool` | `null` | no |
| <a name="input_enclave_options"></a> [enclave\_options](#input\_enclave\_options) | Enable Nitro Enclaves on launched instances | `map(string)` | `null` | no |
| <a name="input_force_update_version"></a> [force\_update\_version](#input\_force\_update\_version) | Force version update if existing pods are unable to be drained due to a pod disruption budget issue | `bool` | `null` | no |
| <a name="input_hibernation_options"></a> [hibernation\_options](#input\_hibernation\_options) | The hibernation options for the instance | `map(string)` | `null` | no |
| <a name="input_iam_role_additional_policies"></a> [iam\_role\_additional\_policies](#input\_iam\_role\_additional\_policies) | Additional policies to be added to the IAM role | `list(string)` | `[]` | no |
| <a name="input_iam_role_arn"></a> [iam\_role\_arn](#input\_iam\_role\_arn) | Amazon Resource Name (ARN) of the IAM Role that provides permissions for the EKS Node Group | `string` | `null` | no |
| <a name="input_iam_role_attach_cni_policy"></a> [iam\_role\_attach\_cni\_policy](#input\_iam\_role\_attach\_cni\_policy) | Whether to attach the Amazon managed `AmazonEKS_CNI_Policy` IAM policy to the IAM IAM role. WARNING: If set `false` the permissions must be assigned to the `aws-node` DaemonSet pods via another method or nodes will not be able to join the cluster | `bool` | `true` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name to use on IAM role created | `string` | `null` | no |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | IAM role path | `string` | `null` | no |
| <a name="input_iam_role_permissions_boundary"></a> [iam\_role\_permissions\_boundary](#input\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM role | `string` | `null` | no |
| <a name="input_iam_role_tags"></a> [iam\_role\_tags](#input\_iam\_role\_tags) | A map of additional tags to add to the IAM role created | `map(string)` | `{}` | no |
| <a name="input_iam_role_use_name_prefix"></a> [iam\_role\_use\_name\_prefix](#input\_iam\_role\_use\_name\_prefix) | Determines whether the IAM role name (`iam_role_name`) is used as a prefix | `string` | `true` | no |
| <a name="input_instance_initiated_shutdown_behavior"></a> [instance\_initiated\_shutdown\_behavior](#input\_instance\_initiated\_shutdown\_behavior) | Shutdown behavior for the instance. Can be `stop` or `terminate`. (Default: `stop`) | `string` | `null` | no |
| <a name="input_instance_market_options"></a> [instance\_market\_options](#input\_instance\_market\_options) | The market (purchasing) option for the instance | `any` | `null` | no |
| <a name="input_instance_types"></a> [instance\_types](#input\_instance\_types) | Set of instance types associated with the EKS Node Group. Defaults to `["t3.medium"]` | `list(string)` | `null` | no |
| <a name="input_kernel_id"></a> [kernel\_id](#input\_kernel\_id) | The kernel ID | `string` | `null` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | The key name that should be used for the instance | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Key-value map of Kubernetes labels. Only labels that are applied with the EKS API are managed by this argument. Other Kubernetes labels applied to the EKS Node Group will not be managed | `map(string)` | `null` | no |
| <a name="input_launch_template_name"></a> [launch\_template\_name](#input\_launch\_template\_name) | Launch template name - either to be created (`var.create_launch_template` = `true`) or existing (`var.create_launch_template` = `false`) | `string` | `null` | no |
| <a name="input_launch_template_use_name_prefix"></a> [launch\_template\_use\_name\_prefix](#input\_launch\_template\_use\_name\_prefix) | Determines whether to use `launch_template_name` as is or create a unique name beginning with the `launch_template_name` as the prefix | `bool` | `true` | no |
| <a name="input_launch_template_version"></a> [launch\_template\_version](#input\_launch\_template\_version) | Launch template version number. The default is `$Default` | `string` | `null` | no |
| <a name="input_license_specifications"></a> [license\_specifications](#input\_license\_specifications) | A list of license specifications to associate with | `map(string)` | `null` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | Maximum number of worker nodes | `number` | `3` | no |
| <a name="input_metadata_options"></a> [metadata\_options](#input\_metadata\_options) | Customize the metadata options for the instance | `map(string)` | `null` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | Minimum number of worker nodes | `number` | `0` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the EKS Node Group | `string` | `null` | no |
| <a name="input_network_interfaces"></a> [network\_interfaces](#input\_network\_interfaces) | Customize network interfaces to be attached at instance boot time | `list(any)` | `[]` | no |
| <a name="input_placement"></a> [placement](#input\_placement) | The placement of the instance | `map(string)` | `null` | no |
| <a name="input_ram_disk_id"></a> [ram\_disk\_id](#input\_ram\_disk\_id) | The ID of the ram disk | `string` | `null` | no |
| <a name="input_remote_access"></a> [remote\_access](#input\_remote\_access) | Configuration block with remote access settings | `map(string)` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Identifiers of EC2 Subnets to associate with the EKS Node Group. These subnets must have the following resource tag: `kubernetes.io/cluster/CLUSTER_NAME` | `list(string)` | `null` | no |
| <a name="input_tag_specifications"></a> [tag\_specifications](#input\_tag\_specifications) | The tags to apply to the resources during launch | `list(any)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_taints"></a> [taints](#input\_taints) | The Kubernetes taints to be applied to the nodes in the node group. Maximum of 50 taints per node group | `map(string)` | `null` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Create, update, and delete timeout configurations for the node group | `map(string)` | `{}` | no |
| <a name="input_update_config"></a> [update\_config](#input\_update\_config) | Configuration block of settings for max unavailable resources during node group updates | `map(string)` | `null` | no |
| <a name="input_update_default_version"></a> [update\_default\_version](#input\_update\_default\_version) | Whether to update Default Version each update. Conflicts with `default_version` | `bool` | `true` | no |
| <a name="input_use_name_prefix"></a> [use\_name\_prefix](#input\_use\_name\_prefix) | Determines whether to use `name` as is or create a unique name beginning with the `name` as the prefix | `bool` | `true` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | The Base64-encoded user data to provide when launching the instance | `string` | `null` | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | A list of security group IDs to associate | `list(string)` | `null` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->