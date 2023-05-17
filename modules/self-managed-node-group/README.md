# Self Managed Node Group Module

Configuration in this directory creates a Self Managed Node Group (AutoScaling Group) along with an IAM role, security group, and launch template

## Usage

```hcl
module "self_managed_node_group" {
  source = "terraform-aws-modules/eks/aws//modules/self-managed-node-group"

  name                = "separate-self-mng"
  cluster_name        = "my-cluster"
  cluster_version     = "1.24"
  cluster_endpoint    = "https://012345678903AB2BAE5D1E0BFE0E2B50.gr7.us-east-1.eks.amazonaws.com"
  cluster_auth_base64 = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUM1ekNDQWMrZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKbXFqQ1VqNGdGR2w3ZW5PeWthWnZ2RjROOTVOUEZCM2o0cGhVZUsrWGFtN2ZSQnZya0d6OGxKZmZEZWF2b2plTwpQK2xOZFlqdHZncmxCUEpYdHZIZmFzTzYxVzdIZmdWQ2EvamdRM2w3RmkvL1dpQmxFOG9oWUZkdWpjc0s1SXM2CnNkbk5KTTNYUWN2TysrSitkV09NT2ZlNzlsSWdncmdQLzgvRU9CYkw3eUY1aU1hS3lsb1RHL1V3TlhPUWt3ZUcKblBNcjdiUmdkQ1NCZTlXYXowOGdGRmlxV2FOditsTDhsODBTdFZLcWVNVlUxbjQyejVwOVpQRTd4T2l6L0xTNQpYV2lXWkVkT3pMN0xBWGVCS2gzdkhnczFxMkI2d1BKZnZnS1NzWllQRGFpZTloT1NNOUJkNFNPY3JrZTRYSVBOCkVvcXVhMlYrUDRlTWJEQzhMUkVWRDdCdVZDdWdMTldWOTBoL3VJUy9WU2VOcEdUOGVScE5DakszSjc2aFlsWm8KWjNGRG5QWUY0MWpWTHhiOXF0U1ROdEp6amYwWXBEYnFWci9xZzNmQWlxbVorMzd3YWM1eHlqMDZ4cmlaRUgzZgpUM002d2lCUEVHYVlGeWN5TmNYTk5aYW9DWDJVL0N1d2JsUHAKLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQ=="

  subnet_ids = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]

  // The following variables are necessary if you decide to use the module outside of the parent EKS module context.
  // Without it, the security groups of the nodes are empty and thus won't join the cluster.
  vpc_security_group_ids = [
    module.eks.cluster_primary_security_group_id,
    module.eks.cluster_security_group_id,
  ]

  min_size     = 1
  max_size     = 10
  desired_size = 1

  launch_template_name   = "separate-self-mng"
  instance_type          = "m5.large"

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.57 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.57 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_user_data"></a> [user\_data](#module\_user\_data) | ../_user_data | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_autoscaling_schedule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_schedule) | resource |
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_ami.eks_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | The AMI from which to launch the instance | `string` | `""` | no |
| <a name="input_autoscaling_group_tags"></a> [autoscaling\_group\_tags](#input\_autoscaling\_group\_tags) | A map of additional tags to add to the autoscaling group created. Tags are applied to the autoscaling group only and are NOT propagated to instances | `map(string)` | `{}` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | A list of one or more availability zones for the group. Used for EC2-Classic and default subnets when not specified with `subnet_ids` argument. Conflicts with `subnet_ids` | `list(string)` | `null` | no |
| <a name="input_block_device_mappings"></a> [block\_device\_mappings](#input\_block\_device\_mappings) | Specify volumes to attach to the instance besides the volumes specified by the AMI | `any` | `{}` | no |
| <a name="input_bootstrap_extra_args"></a> [bootstrap\_extra\_args](#input\_bootstrap\_extra\_args) | Additional arguments passed to the bootstrap script. When `platform` = `bottlerocket`; these are additional [settings](https://github.com/bottlerocket-os/bottlerocket#settings) that are provided to the Bottlerocket user data | `string` | `""` | no |
| <a name="input_capacity_rebalance"></a> [capacity\_rebalance](#input\_capacity\_rebalance) | Indicates whether capacity rebalance is enabled | `bool` | `null` | no |
| <a name="input_capacity_reservation_specification"></a> [capacity\_reservation\_specification](#input\_capacity\_reservation\_specification) | Targeting for EC2 capacity reservations | `any` | `{}` | no |
| <a name="input_cluster_auth_base64"></a> [cluster\_auth\_base64](#input\_cluster\_auth\_base64) | Base64 encoded CA of associated EKS cluster | `string` | `""` | no |
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | Endpoint of associated EKS cluster | `string` | `""` | no |
| <a name="input_cluster_ip_family"></a> [cluster\_ip\_family](#input\_cluster\_ip\_family) | The IP family used to assign Kubernetes pod and service addresses. Valid values are `ipv4` (default) and `ipv6` | `string` | `null` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of associated EKS cluster | `string` | `""` | no |
| <a name="input_cluster_primary_security_group_id"></a> [cluster\_primary\_security\_group\_id](#input\_cluster\_primary\_security\_group\_id) | The ID of the EKS cluster primary security group to associate with the instance(s). This is the security group that is automatically created by the EKS service | `string` | `null` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Kubernetes cluster version - used to lookup default AMI ID if one is not provided | `string` | `null` | no |
| <a name="input_context"></a> [context](#input\_context) | Reserved | `string` | `null` | no |
| <a name="input_cpu_options"></a> [cpu\_options](#input\_cpu\_options) | The CPU options for the instance | `map(string)` | `{}` | no |
| <a name="input_create"></a> [create](#input\_create) | Determines whether to create self managed node group or not | `bool` | `true` | no |
| <a name="input_create_autoscaling_group"></a> [create\_autoscaling\_group](#input\_create\_autoscaling\_group) | Determines whether to create autoscaling group or not | `bool` | `true` | no |
| <a name="input_create_iam_instance_profile"></a> [create\_iam\_instance\_profile](#input\_create\_iam\_instance\_profile) | Determines whether an IAM instance profile is created or to use an existing IAM instance profile | `bool` | `true` | no |
| <a name="input_create_launch_template"></a> [create\_launch\_template](#input\_create\_launch\_template) | Determines whether to create launch template or not | `bool` | `true` | no |
| <a name="input_create_schedule"></a> [create\_schedule](#input\_create\_schedule) | Determines whether to create autoscaling group schedule or not | `bool` | `true` | no |
| <a name="input_credit_specification"></a> [credit\_specification](#input\_credit\_specification) | Customize the credit specification of the instance | `map(string)` | `{}` | no |
| <a name="input_default_cooldown"></a> [default\_cooldown](#input\_default\_cooldown) | The amount of time, in seconds, after a scaling activity completes before another scaling activity can start | `number` | `null` | no |
| <a name="input_default_instance_warmup"></a> [default\_instance\_warmup](#input\_default\_instance\_warmup) | Amount of time, in seconds, until a newly launched instance can contribute to the Amazon CloudWatch metrics. This delay lets an instance finish initializing before Amazon EC2 Auto Scaling aggregates instance metrics, resulting in more reliable usage data | `number` | `null` | no |
| <a name="input_delete_timeout"></a> [delete\_timeout](#input\_delete\_timeout) | Delete timeout to wait for destroying autoscaling group | `string` | `null` | no |
| <a name="input_desired_size"></a> [desired\_size](#input\_desired\_size) | The number of Amazon EC2 instances that should be running in the autoscaling group | `number` | `1` | no |
| <a name="input_disable_api_termination"></a> [disable\_api\_termination](#input\_disable\_api\_termination) | If true, enables EC2 instance termination protection | `bool` | `null` | no |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | If true, the launched EC2 instance will be EBS-optimized | `bool` | `null` | no |
| <a name="input_elastic_gpu_specifications"></a> [elastic\_gpu\_specifications](#input\_elastic\_gpu\_specifications) | The elastic GPU to attach to the instance | `any` | `{}` | no |
| <a name="input_elastic_inference_accelerator"></a> [elastic\_inference\_accelerator](#input\_elastic\_inference\_accelerator) | Configuration block containing an Elastic Inference Accelerator to attach to the instance | `map(string)` | `{}` | no |
| <a name="input_enable_monitoring"></a> [enable\_monitoring](#input\_enable\_monitoring) | Enables/disables detailed monitoring | `bool` | `true` | no |
| <a name="input_enabled_metrics"></a> [enabled\_metrics](#input\_enabled\_metrics) | A list of metrics to collect. The allowed values are `GroupDesiredCapacity`, `GroupInServiceCapacity`, `GroupPendingCapacity`, `GroupMinSize`, `GroupMaxSize`, `GroupInServiceInstances`, `GroupPendingInstances`, `GroupStandbyInstances`, `GroupStandbyCapacity`, `GroupTerminatingCapacity`, `GroupTerminatingInstances`, `GroupTotalCapacity`, `GroupTotalInstances` | `list(string)` | `[]` | no |
| <a name="input_enclave_options"></a> [enclave\_options](#input\_enclave\_options) | Enable Nitro Enclaves on launched instances | `map(string)` | `{}` | no |
| <a name="input_force_delete"></a> [force\_delete](#input\_force\_delete) | Allows deleting the Auto Scaling Group without waiting for all instances in the pool to terminate. You can force an Auto Scaling Group to delete even if it's in the process of scaling a resource. Normally, Terraform drains all the instances before deleting the group. This bypasses that behavior and potentially leaves resources dangling | `bool` | `null` | no |
| <a name="input_force_delete_warm_pool"></a> [force\_delete\_warm\_pool](#input\_force\_delete\_warm\_pool) | Allows deleting the Auto Scaling Group without waiting for all instances in the warm pool to terminate | `bool` | `null` | no |
| <a name="input_health_check_grace_period"></a> [health\_check\_grace\_period](#input\_health\_check\_grace\_period) | Time (in seconds) after instance comes into service before checking health | `number` | `null` | no |
| <a name="input_health_check_type"></a> [health\_check\_type](#input\_health\_check\_type) | `EC2` or `ELB`. Controls how health checking is done | `string` | `null` | no |
| <a name="input_hibernation_options"></a> [hibernation\_options](#input\_hibernation\_options) | The hibernation options for the instance | `map(string)` | `{}` | no |
| <a name="input_iam_instance_profile_arn"></a> [iam\_instance\_profile\_arn](#input\_iam\_instance\_profile\_arn) | Amazon Resource Name (ARN) of an existing IAM instance profile that provides permissions for the node group. Required if `create_iam_instance_profile` = `false` | `string` | `null` | no |
| <a name="input_iam_role_additional_policies"></a> [iam\_role\_additional\_policies](#input\_iam\_role\_additional\_policies) | Additional policies to be added to the IAM role | `map(string)` | `{}` | no |
| <a name="input_iam_role_attach_cni_policy"></a> [iam\_role\_attach\_cni\_policy](#input\_iam\_role\_attach\_cni\_policy) | Whether to attach the `AmazonEKS_CNI_Policy`/`AmazonEKS_CNI_IPv6_Policy` IAM policy to the IAM IAM role. WARNING: If set `false` the permissions must be assigned to the `aws-node` DaemonSet pods via another method or nodes will not be able to join the cluster | `bool` | `true` | no |
| <a name="input_iam_role_description"></a> [iam\_role\_description](#input\_iam\_role\_description) | Description of the role | `string` | `null` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name to use on IAM role created | `string` | `null` | no |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | IAM role path | `string` | `null` | no |
| <a name="input_iam_role_permissions_boundary"></a> [iam\_role\_permissions\_boundary](#input\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM role | `string` | `null` | no |
| <a name="input_iam_role_tags"></a> [iam\_role\_tags](#input\_iam\_role\_tags) | A map of additional tags to add to the IAM role created | `map(string)` | `{}` | no |
| <a name="input_iam_role_use_name_prefix"></a> [iam\_role\_use\_name\_prefix](#input\_iam\_role\_use\_name\_prefix) | Determines whether cluster IAM role name (`iam_role_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_initial_lifecycle_hooks"></a> [initial\_lifecycle\_hooks](#input\_initial\_lifecycle\_hooks) | One or more Lifecycle Hooks to attach to the Auto Scaling Group before instances are launched. The syntax is exactly the same as the separate `aws_autoscaling_lifecycle_hook` resource, without the `autoscaling_group_name` attribute. Please note that this will only work when creating a new Auto Scaling Group. For all other use-cases, please use `aws_autoscaling_lifecycle_hook` resource | `list(map(string))` | `[]` | no |
| <a name="input_instance_initiated_shutdown_behavior"></a> [instance\_initiated\_shutdown\_behavior](#input\_instance\_initiated\_shutdown\_behavior) | Shutdown behavior for the instance. Can be `stop` or `terminate`. (Default: `stop`) | `string` | `null` | no |
| <a name="input_instance_market_options"></a> [instance\_market\_options](#input\_instance\_market\_options) | The market (purchasing) option for the instance | `any` | `{}` | no |
| <a name="input_instance_refresh"></a> [instance\_refresh](#input\_instance\_refresh) | If this block is configured, start an Instance Refresh when this Auto Scaling Group is updated | `any` | <pre>{<br>  "preferences": {<br>    "min_healthy_percentage": 66<br>  },<br>  "strategy": "Rolling"<br>}</pre> | no |
| <a name="input_instance_requirements"></a> [instance\_requirements](#input\_instance\_requirements) | The attribute requirements for the type of instance. If present then `instance_type` cannot be present | `any` | `{}` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The type of the instance to launch | `string` | `""` | no |
| <a name="input_kernel_id"></a> [kernel\_id](#input\_kernel\_id) | The kernel ID | `string` | `null` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | The key name that should be used for the instance | `string` | `null` | no |
| <a name="input_launch_template_default_version"></a> [launch\_template\_default\_version](#input\_launch\_template\_default\_version) | Default Version of the launch template | `string` | `null` | no |
| <a name="input_launch_template_description"></a> [launch\_template\_description](#input\_launch\_template\_description) | Description of the launch template | `string` | `null` | no |
| <a name="input_launch_template_id"></a> [launch\_template\_id](#input\_launch\_template\_id) | The ID of an existing launch template to use. Required when `create_launch_template` = `false` | `string` | `""` | no |
| <a name="input_launch_template_name"></a> [launch\_template\_name](#input\_launch\_template\_name) | Name of launch template to be created | `string` | `null` | no |
| <a name="input_launch_template_tags"></a> [launch\_template\_tags](#input\_launch\_template\_tags) | A map of additional tags to add to the tag\_specifications of launch template created | `map(string)` | `{}` | no |
| <a name="input_launch_template_use_name_prefix"></a> [launch\_template\_use\_name\_prefix](#input\_launch\_template\_use\_name\_prefix) | Determines whether to use `launch_template_name` as is or create a unique name beginning with the `launch_template_name` as the prefix | `bool` | `true` | no |
| <a name="input_launch_template_version"></a> [launch\_template\_version](#input\_launch\_template\_version) | Launch template version. Can be version number, `$Latest`, or `$Default` | `string` | `null` | no |
| <a name="input_license_specifications"></a> [license\_specifications](#input\_license\_specifications) | A map of license specifications to associate with | `any` | `{}` | no |
| <a name="input_maintenance_options"></a> [maintenance\_options](#input\_maintenance\_options) | The maintenance options for the instance | `any` | `{}` | no |
| <a name="input_max_instance_lifetime"></a> [max\_instance\_lifetime](#input\_max\_instance\_lifetime) | The maximum amount of time, in seconds, that an instance can be in service, values must be either equal to 0 or between 604800 and 31536000 seconds | `number` | `null` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | The maximum size of the autoscaling group | `number` | `3` | no |
| <a name="input_metadata_options"></a> [metadata\_options](#input\_metadata\_options) | Customize the metadata options for the instance | `map(string)` | <pre>{<br>  "http_endpoint": "enabled",<br>  "http_put_response_hop_limit": 2,<br>  "http_tokens": "required"<br>}</pre> | no |
| <a name="input_metrics_granularity"></a> [metrics\_granularity](#input\_metrics\_granularity) | The granularity to associate with the metrics to collect. The only valid value is `1Minute` | `string` | `null` | no |
| <a name="input_min_elb_capacity"></a> [min\_elb\_capacity](#input\_min\_elb\_capacity) | Setting this causes Terraform to wait for this number of instances to show up healthy in the ELB only on creation. Updates will not wait on ELB instance number changes | `number` | `null` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | The minimum size of the autoscaling group | `number` | `0` | no |
| <a name="input_mixed_instances_policy"></a> [mixed\_instances\_policy](#input\_mixed\_instances\_policy) | Configuration block containing settings to define launch targets for Auto Scaling groups | `any` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the Self managed Node Group | `string` | `""` | no |
| <a name="input_network_interfaces"></a> [network\_interfaces](#input\_network\_interfaces) | Customize network interfaces to be attached at instance boot time | `list(any)` | `[]` | no |
| <a name="input_placement"></a> [placement](#input\_placement) | The placement of the instance | `map(string)` | `{}` | no |
| <a name="input_placement_group"></a> [placement\_group](#input\_placement\_group) | The name of the placement group into which you'll launch your instances, if any | `string` | `null` | no |
| <a name="input_platform"></a> [platform](#input\_platform) | Identifies if the OS platform is `bottlerocket`, `linux`, or `windows` based | `string` | `"linux"` | no |
| <a name="input_post_bootstrap_user_data"></a> [post\_bootstrap\_user\_data](#input\_post\_bootstrap\_user\_data) | User data that is appended to the user data script after of the EKS bootstrap script. Not used when `platform` = `bottlerocket` | `string` | `""` | no |
| <a name="input_pre_bootstrap_user_data"></a> [pre\_bootstrap\_user\_data](#input\_pre\_bootstrap\_user\_data) | User data that is injected into the user data script ahead of the EKS bootstrap script. Not used when `platform` = `bottlerocket` | `string` | `""` | no |
| <a name="input_private_dns_name_options"></a> [private\_dns\_name\_options](#input\_private\_dns\_name\_options) | The options for the instance hostname. The default values are inherited from the subnet | `map(string)` | `{}` | no |
| <a name="input_protect_from_scale_in"></a> [protect\_from\_scale\_in](#input\_protect\_from\_scale\_in) | Allows setting instance protection. The autoscaling group will not select instances with this setting for termination during scale in events. | `bool` | `false` | no |
| <a name="input_ram_disk_id"></a> [ram\_disk\_id](#input\_ram\_disk\_id) | The ID of the ram disk | `string` | `null` | no |
| <a name="input_schedules"></a> [schedules](#input\_schedules) | Map of autoscaling group schedule to create | `map(any)` | `{}` | no |
| <a name="input_service_linked_role_arn"></a> [service\_linked\_role\_arn](#input\_service\_linked\_role\_arn) | The ARN of the service-linked role that the ASG will use to call other AWS services | `string` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of subnet IDs to launch resources in. Subnets automatically determine which availability zones the group will reside. Conflicts with `availability_zones` | `list(string)` | `null` | no |
| <a name="input_suspended_processes"></a> [suspended\_processes](#input\_suspended\_processes) | A list of processes to suspend for the Auto Scaling Group. The allowed values are `Launch`, `Terminate`, `HealthCheck`, `ReplaceUnhealthy`, `AZRebalance`, `AlarmNotification`, `ScheduledActions`, `AddToLoadBalancer`. Note that if you suspend either the `Launch` or `Terminate` process types, it can prevent your Auto Scaling Group from functioning properly | `list(string)` | `[]` | no |
| <a name="input_tag_specifications"></a> [tag\_specifications](#input\_tag\_specifications) | The tags to apply to the resources during launch | `list(string)` | <pre>[<br>  "instance",<br>  "volume",<br>  "network-interface"<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_target_group_arns"></a> [target\_group\_arns](#input\_target\_group\_arns) | A set of `aws_alb_target_group` ARNs, for use with Application or Network Load Balancing | `list(string)` | `[]` | no |
| <a name="input_termination_policies"></a> [termination\_policies](#input\_termination\_policies) | A list of policies to decide how the instances in the Auto Scaling Group should be terminated. The allowed values are `OldestInstance`, `NewestInstance`, `OldestLaunchConfiguration`, `ClosestToNextInstanceHour`, `OldestLaunchTemplate`, `AllocationStrategy`, `Default` | `list(string)` | `[]` | no |
| <a name="input_update_launch_template_default_version"></a> [update\_launch\_template\_default\_version](#input\_update\_launch\_template\_default\_version) | Whether to update Default Version each update. Conflicts with `launch_template_default_version` | `bool` | `true` | no |
| <a name="input_use_mixed_instances_policy"></a> [use\_mixed\_instances\_policy](#input\_use\_mixed\_instances\_policy) | Determines whether to use a mixed instances policy in the autoscaling group or not | `bool` | `false` | no |
| <a name="input_use_name_prefix"></a> [use\_name\_prefix](#input\_use\_name\_prefix) | Determines whether to use `name` as is or create a unique name beginning with the `name` as the prefix | `bool` | `true` | no |
| <a name="input_user_data_template_path"></a> [user\_data\_template\_path](#input\_user\_data\_template\_path) | Path to a local, custom user data template file to use when rendering user data | `string` | `""` | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | A list of security group IDs to associate | `list(string)` | `[]` | no |
| <a name="input_wait_for_capacity_timeout"></a> [wait\_for\_capacity\_timeout](#input\_wait\_for\_capacity\_timeout) | A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. (See also Waiting for Capacity below.) Setting this to '0' causes Terraform to skip all Capacity Waiting behavior. | `string` | `null` | no |
| <a name="input_wait_for_elb_capacity"></a> [wait\_for\_elb\_capacity](#input\_wait\_for\_elb\_capacity) | Setting this will cause Terraform to wait for exactly this number of healthy instances in all attached load balancers on both create and update operations. Takes precedence over `min_elb_capacity` behavior. | `number` | `null` | no |
| <a name="input_warm_pool"></a> [warm\_pool](#input\_warm\_pool) | If this block is configured, add a Warm Pool to the specified Auto Scaling group | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_autoscaling_group_arn"></a> [autoscaling\_group\_arn](#output\_autoscaling\_group\_arn) | The ARN for this autoscaling group |
| <a name="output_autoscaling_group_availability_zones"></a> [autoscaling\_group\_availability\_zones](#output\_autoscaling\_group\_availability\_zones) | The availability zones of the autoscaling group |
| <a name="output_autoscaling_group_default_cooldown"></a> [autoscaling\_group\_default\_cooldown](#output\_autoscaling\_group\_default\_cooldown) | Time between a scaling activity and the succeeding scaling activity |
| <a name="output_autoscaling_group_desired_capacity"></a> [autoscaling\_group\_desired\_capacity](#output\_autoscaling\_group\_desired\_capacity) | The number of Amazon EC2 instances that should be running in the group |
| <a name="output_autoscaling_group_health_check_grace_period"></a> [autoscaling\_group\_health\_check\_grace\_period](#output\_autoscaling\_group\_health\_check\_grace\_period) | Time after instance comes into service before checking health |
| <a name="output_autoscaling_group_health_check_type"></a> [autoscaling\_group\_health\_check\_type](#output\_autoscaling\_group\_health\_check\_type) | EC2 or ELB. Controls how health checking is done |
| <a name="output_autoscaling_group_id"></a> [autoscaling\_group\_id](#output\_autoscaling\_group\_id) | The autoscaling group id |
| <a name="output_autoscaling_group_max_size"></a> [autoscaling\_group\_max\_size](#output\_autoscaling\_group\_max\_size) | The maximum size of the autoscaling group |
| <a name="output_autoscaling_group_min_size"></a> [autoscaling\_group\_min\_size](#output\_autoscaling\_group\_min\_size) | The minimum size of the autoscaling group |
| <a name="output_autoscaling_group_name"></a> [autoscaling\_group\_name](#output\_autoscaling\_group\_name) | The autoscaling group name |
| <a name="output_autoscaling_group_schedule_arns"></a> [autoscaling\_group\_schedule\_arns](#output\_autoscaling\_group\_schedule\_arns) | ARNs of autoscaling group schedules |
| <a name="output_autoscaling_group_vpc_zone_identifier"></a> [autoscaling\_group\_vpc\_zone\_identifier](#output\_autoscaling\_group\_vpc\_zone\_identifier) | The VPC zone identifier |
| <a name="output_iam_instance_profile_arn"></a> [iam\_instance\_profile\_arn](#output\_iam\_instance\_profile\_arn) | ARN assigned by AWS to the instance profile |
| <a name="output_iam_instance_profile_id"></a> [iam\_instance\_profile\_id](#output\_iam\_instance\_profile\_id) | Instance profile's ID |
| <a name="output_iam_instance_profile_unique"></a> [iam\_instance\_profile\_unique](#output\_iam\_instance\_profile\_unique) | Stable and unique string identifying the IAM instance profile |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | The Amazon Resource Name (ARN) specifying the IAM role |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | The name of the IAM role |
| <a name="output_iam_role_unique_id"></a> [iam\_role\_unique\_id](#output\_iam\_role\_unique\_id) | Stable and unique string identifying the IAM role |
| <a name="output_image_id"></a> [image\_id](#output\_image\_id) | ID of the image |
| <a name="output_launch_template_arn"></a> [launch\_template\_arn](#output\_launch\_template\_arn) | The ARN of the launch template |
| <a name="output_launch_template_id"></a> [launch\_template\_id](#output\_launch\_template\_id) | The ID of the launch template |
| <a name="output_launch_template_latest_version"></a> [launch\_template\_latest\_version](#output\_launch\_template\_latest\_version) | The latest version of the launch template |
| <a name="output_launch_template_name"></a> [launch\_template\_name](#output\_launch\_template\_name) | The name of the launch template |
| <a name="output_platform"></a> [platform](#output\_platform) | Identifies if the OS platform is `bottlerocket`, `linux`, or `windows` based |
| <a name="output_user_data"></a> [user\_data](#output\_user\_data) | Base64 encoded user data |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
