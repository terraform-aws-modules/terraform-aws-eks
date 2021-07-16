## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 0.13.1)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (>= 3.40.0)

- <a name="requirement_http"></a> [http](#requirement\_http) (>= 2.4.1)

- <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) (>= 1.11.1)

- <a name="requirement_local"></a> [local](#requirement\_local) (>= 1.4)

## Providers

The following providers are used by this module:

- <a name="provider_aws"></a> [aws](#provider\_aws) (3.45.0)

- <a name="provider_http"></a> [http](#provider\_http) (2.4.1)

- <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) (2.3.2)

- <a name="provider_local"></a> [local](#provider\_local) (2.1.0)

## Modules

The following Modules are called:

### <a name="module_addons"></a> [addons](#module\_addons)

Source: ./modules/addons

Version:

### <a name="module_fargate"></a> [fargate](#module\_fargate)

Source: ./modules/fargate

Version:

### <a name="module_node_groups"></a> [node\_groups](#module\_node\_groups)

Source: ./modules/node_groups

Version:

## Resources

The following resources are used by this module:

- [aws_autoscaling_group.workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) (resource)
- [aws_autoscaling_group.workers_launch_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) (resource)
- [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) (resource)
- [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) (resource)
- [aws_iam_instance_profile.workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) (resource)
- [aws_iam_instance_profile.workers_launch_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) (resource)
- [aws_iam_openid_connect_provider.oidc_provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) (resource)
- [aws_iam_policy.cluster_elb_sl_role_creation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) (resource)
- [aws_iam_role.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) (resource)
- [aws_iam_role.workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) (resource)
- [aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) (resource)
- [aws_iam_role_policy_attachment.cluster_AmazonEKSServicePolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) (resource)
- [aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceControllerPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) (resource)
- [aws_iam_role_policy_attachment.cluster_elb_sl_role_creation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) (resource)
- [aws_iam_role_policy_attachment.workers_AmazonEC2ContainerRegistryReadOnly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) (resource)
- [aws_iam_role_policy_attachment.workers_AmazonEKSWorkerNodePolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) (resource)
- [aws_iam_role_policy_attachment.workers_AmazonEKS_CNI_Policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) (resource)
- [aws_iam_role_policy_attachment.workers_additional_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) (resource)
- [aws_launch_configuration.workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_configuration) (resource)
- [aws_launch_template.workers_launch_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) (resource)
- [aws_security_group.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) (resource)
- [aws_security_group.workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) (resource)
- [aws_security_group_rule.cluster_egress_internet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) (resource)
- [aws_security_group_rule.cluster_https_worker_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) (resource)
- [aws_security_group_rule.cluster_primary_ingress_workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) (resource)
- [aws_security_group_rule.cluster_private_access_cidrs_source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) (resource)
- [aws_security_group_rule.cluster_private_access_sg_source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) (resource)
- [aws_security_group_rule.workers_egress_internet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) (resource)
- [aws_security_group_rule.workers_ingress_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) (resource)
- [aws_security_group_rule.workers_ingress_cluster_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) (resource)
- [aws_security_group_rule.workers_ingress_cluster_kubelet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) (resource)
- [aws_security_group_rule.workers_ingress_cluster_primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) (resource)
- [aws_security_group_rule.workers_ingress_self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) (resource)
- [kubernetes_config_map.aws_auth](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) (resource)
- [local_file.kubeconfig](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) (resource)
- [aws_ami.eks_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) (data source)
- [aws_ami.eks_worker_windows](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) (data source)
- [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) (data source)
- [aws_iam_instance_profile.custom_worker_group_iam_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_instance_profile) (data source)
- [aws_iam_instance_profile.custom_worker_group_launch_template_iam_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_instance_profile) (data source)
- [aws_iam_policy_document.cluster_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
- [aws_iam_policy_document.cluster_elb_sl_role_creation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
- [aws_iam_policy_document.workers_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
- [aws_iam_role.custom_cluster_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role) (data source)
- [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) (data source)
- [http_http.wait_for_cluster](https://registry.terraform.io/providers/terraform-aws-modules/http/latest/docs/data-sources/http) (data source)

## Required Inputs

The following input variables are required:

### <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name)

Description: Name of the EKS cluster. Also used as a prefix in names of related resources.

Type: `string`

### <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version)

Description: Kubernetes version to use for the EKS cluster.

Type: `string`

### <a name="input_subnets"></a> [subnets](#input\_subnets)

Description: A list of subnets to place the EKS cluster and workers within.

Type: `list(string)`

### <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id)

Description: VPC where the cluster and workers will be deployed.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_addon_tags"></a> [addon\_tags](#input\_addon\_tags)

Description: A map of tags to add to addons.

Type: `map(string)`

Default: `{}`

### <a name="input_attach_worker_cni_policy"></a> [attach\_worker\_cni\_policy](#input\_attach\_worker\_cni\_policy)

Description: Whether to attach the Amazon managed `AmazonEKS_CNI_Policy` IAM policy to the default worker IAM role. WARNING: If set `false` the permissions must be assigned to the `aws-node` DaemonSet pods via another method or nodes will not be able to join the cluster. Note: Set to `false` if you enable the vpc\_cni addon with `create_vpc_cni_addon = true`

Type: `bool`

Default: `true`

### <a name="input_aws_auth_additional_labels"></a> [aws\_auth\_additional\_labels](#input\_aws\_auth\_additional\_labels)

Description: Additional kubernetes labels applied on aws-auth ConfigMap

Type: `map(string)`

Default: `{}`

### <a name="input_cluster_create_endpoint_private_access_sg_rule"></a> [cluster\_create\_endpoint\_private\_access\_sg\_rule](#input\_cluster\_create\_endpoint\_private\_access\_sg\_rule)

Description: Whether to create security group rules for the access to the Amazon EKS private API server endpoint. When is `true`, `cluster_endpoint_private_access_cidrs` must be setted.

Type: `bool`

Default: `false`

### <a name="input_cluster_create_security_group"></a> [cluster\_create\_security\_group](#input\_cluster\_create\_security\_group)

Description: Whether to create a security group for the cluster or attach the cluster to `cluster_security_group_id`.

Type: `bool`

Default: `true`

### <a name="input_cluster_create_timeout"></a> [cluster\_create\_timeout](#input\_cluster\_create\_timeout)

Description: Timeout value when creating the EKS cluster.

Type: `string`

Default: `"30m"`

### <a name="input_cluster_delete_timeout"></a> [cluster\_delete\_timeout](#input\_cluster\_delete\_timeout)

Description: Timeout value when deleting the EKS cluster.

Type: `string`

Default: `"15m"`

### <a name="input_cluster_egress_cidrs"></a> [cluster\_egress\_cidrs](#input\_cluster\_egress\_cidrs)

Description: List of CIDR blocks that are permitted for cluster egress traffic.

Type: `list(string)`

Default:

```json
[
  "0.0.0.0/0"
]
```

### <a name="input_cluster_enabled_log_types"></a> [cluster\_enabled\_log\_types](#input\_cluster\_enabled\_log\_types)

Description: A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)

Type: `list(string)`

Default: `[]`

### <a name="input_cluster_encryption_config"></a> [cluster\_encryption\_config](#input\_cluster\_encryption\_config)

Description: Configuration block with encryption configuration for the cluster. See examples/secrets\_encryption/main.tf for example format

Type:

```hcl
list(object({
    provider_key_arn = string
    resources        = list(string)
  }))
```

Default: `[]`

### <a name="input_cluster_endpoint_private_access"></a> [cluster\_endpoint\_private\_access](#input\_cluster\_endpoint\_private\_access)

Description: Indicates whether or not the Amazon EKS private API server endpoint is enabled.

Type: `bool`

Default: `false`

### <a name="input_cluster_endpoint_private_access_cidrs"></a> [cluster\_endpoint\_private\_access\_cidrs](#input\_cluster\_endpoint\_private\_access\_cidrs)

Description: List of CIDR blocks which can access the Amazon EKS private API server endpoint. To use this `cluster_endpoint_private_access` and `cluster_create_endpoint_private_access_sg_rule` must be set to `true`.

Type: `list(string)`

Default: `null`

### <a name="input_cluster_endpoint_private_access_sg"></a> [cluster\_endpoint\_private\_access\_sg](#input\_cluster\_endpoint\_private\_access\_sg)

Description: List of security group IDs which can access the Amazon EKS private API server endpoint. To use this `cluster_endpoint_private_access` and `cluster_create_endpoint_private_access_sg_rule` must be set to `true`.

Type: `list(string)`

Default: `null`

### <a name="input_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#input\_cluster\_endpoint\_public\_access)

Description: Indicates whether or not the Amazon EKS public API server endpoint is enabled. When it's set to `false` ensure to have a proper private access with `cluster_endpoint_private_access = true`.

Type: `bool`

Default: `true`

### <a name="input_cluster_endpoint_public_access_cidrs"></a> [cluster\_endpoint\_public\_access\_cidrs](#input\_cluster\_endpoint\_public\_access\_cidrs)

Description: List of CIDR blocks which can access the Amazon EKS public API server endpoint.

Type: `list(string)`

Default:

```json
[
  "0.0.0.0/0"
]
```

### <a name="input_cluster_iam_role_name"></a> [cluster\_iam\_role\_name](#input\_cluster\_iam\_role\_name)

Description: IAM role name for the cluster. If manage\_cluster\_iam\_resources is set to false, set this to reuse an existing IAM role. If manage\_cluster\_iam\_resources is set to true, set this to force the created role name.

Type: `string`

Default: `""`

### <a name="input_cluster_log_kms_key_id"></a> [cluster\_log\_kms\_key\_id](#input\_cluster\_log\_kms\_key\_id)

Description: If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html)

Type: `string`

Default: `""`

### <a name="input_cluster_log_retention_in_days"></a> [cluster\_log\_retention\_in\_days](#input\_cluster\_log\_retention\_in\_days)

Description: Number of days to retain log events. Default retention - 90 days.

Type: `number`

Default: `90`

### <a name="input_cluster_security_group_id"></a> [cluster\_security\_group\_id](#input\_cluster\_security\_group\_id)

Description: If provided, the EKS cluster will be attached to this security group. If not given, a security group will be created with necessary ingress/egress to work with the workers

Type: `string`

Default: `""`

### <a name="input_cluster_service_ipv4_cidr"></a> [cluster\_service\_ipv4\_cidr](#input\_cluster\_service\_ipv4\_cidr)

Description: service ipv4 cidr for the kubernetes cluster

Type: `string`

Default: `null`

### <a name="input_create_coredns_addon"></a> [create\_coredns\_addon](#input\_create\_coredns\_addon)

Description: Controls if coredns addon should be deployed

Type: `bool`

Default: `false`

### <a name="input_create_eks"></a> [create\_eks](#input\_create\_eks)

Description: Controls if EKS resources should be created (it affects almost all resources)

Type: `bool`

Default: `true`

### <a name="input_create_fargate_pod_execution_role"></a> [create\_fargate\_pod\_execution\_role](#input\_create\_fargate\_pod\_execution\_role)

Description: Controls if the EKS Fargate pod execution IAM role should be created.

Type: `bool`

Default: `true`

### <a name="input_create_kube_proxy_addon"></a> [create\_kube\_proxy\_addon](#input\_create\_kube\_proxy\_addon)

Description: Controls if kube proxy addon should be deployed

Type: `bool`

Default: `false`

### <a name="input_create_vpc_cni_addon"></a> [create\_vpc\_cni\_addon](#input\_create\_vpc\_cni\_addon)

Description: Controls if vpc cni addon should be deployed

Type: `bool`

Default: `false`

### <a name="input_eks_oidc_root_ca_thumbprint"></a> [eks\_oidc\_root\_ca\_thumbprint](#input\_eks\_oidc\_root\_ca\_thumbprint)

Description: Thumbprint of Root CA for EKS OIDC, Valid until 2037

Type: `string`

Default: `"9e99a48a9960b14926bb7f3b02e22da2b0ab7280"`

### <a name="input_enable_irsa"></a> [enable\_irsa](#input\_enable\_irsa)

Description: Whether to create OpenID Connect Provider for EKS to enable IRSA

Type: `bool`

Default: `false`

### <a name="input_fargate_pod_execution_role_name"></a> [fargate\_pod\_execution\_role\_name](#input\_fargate\_pod\_execution\_role\_name)

Description: The IAM Role that provides permissions for the EKS Fargate Profile.

Type: `string`

Default: `null`

### <a name="input_fargate_profiles"></a> [fargate\_profiles](#input\_fargate\_profiles)

Description: Fargate profiles to create. See `fargate_profile` keys section in fargate submodule's README.md for more details

Type: `any`

Default: `{}`

### <a name="input_iam_path"></a> [iam\_path](#input\_iam\_path)

Description: If provided, all IAM roles will be created on this path.

Type: `string`

Default: `"/"`

### <a name="input_kubeconfig_aws_authenticator_additional_args"></a> [kubeconfig\_aws\_authenticator\_additional\_args](#input\_kubeconfig\_aws\_authenticator\_additional\_args)

Description: Any additional arguments to pass to the authenticator such as the role to assume. e.g. ["-r", "MyEksRole"].

Type: `list(string)`

Default: `[]`

### <a name="input_kubeconfig_aws_authenticator_command"></a> [kubeconfig\_aws\_authenticator\_command](#input\_kubeconfig\_aws\_authenticator\_command)

Description: Command to use to fetch AWS EKS credentials.

Type: `string`

Default: `"aws-iam-authenticator"`

### <a name="input_kubeconfig_aws_authenticator_command_args"></a> [kubeconfig\_aws\_authenticator\_command\_args](#input\_kubeconfig\_aws\_authenticator\_command\_args)

Description: Default arguments passed to the authenticator command. Defaults to [token -i $cluster\_name].

Type: `list(string)`

Default: `[]`

### <a name="input_kubeconfig_aws_authenticator_env_variables"></a> [kubeconfig\_aws\_authenticator\_env\_variables](#input\_kubeconfig\_aws\_authenticator\_env\_variables)

Description: Environment variables that should be used when executing the authenticator. e.g. { AWS\_PROFILE = "eks"}.

Type: `map(string)`

Default: `{}`

### <a name="input_kubeconfig_file_permission"></a> [kubeconfig\_file\_permission](#input\_kubeconfig\_file\_permission)

Description: File permission of the Kubectl config file containing cluster configuration saved to `kubeconfig_output_path.`

Type: `string`

Default: `"0600"`

### <a name="input_kubeconfig_name"></a> [kubeconfig\_name](#input\_kubeconfig\_name)

Description: Override the default name used for items kubeconfig.

Type: `string`

Default: `""`

### <a name="input_kubeconfig_output_path"></a> [kubeconfig\_output\_path](#input\_kubeconfig\_output\_path)

Description: Where to save the Kubectl config file (if `write_kubeconfig = true`). Assumed to be a directory if the value ends with a forward slash `/`.

Type: `string`

Default: `"./"`

### <a name="input_manage_aws_auth"></a> [manage\_aws\_auth](#input\_manage\_aws\_auth)

Description: Whether to apply the aws-auth configmap file.

Type: `bool`

Default: `true`

### <a name="input_manage_cluster_iam_resources"></a> [manage\_cluster\_iam\_resources](#input\_manage\_cluster\_iam\_resources)

Description: Whether to let the module manage cluster IAM resources. If set to false, cluster\_iam\_role\_name must be specified.

Type: `bool`

Default: `true`

### <a name="input_manage_worker_iam_resources"></a> [manage\_worker\_iam\_resources](#input\_manage\_worker\_iam\_resources)

Description: Whether to let the module manage worker IAM resources. If set to false, iam\_instance\_profile\_name must be specified for workers.

Type: `bool`

Default: `true`

### <a name="input_map_accounts"></a> [map\_accounts](#input\_map\_accounts)

Description: Additional AWS account numbers to add to the aws-auth configmap. See examples/basic/variables.tf for example format.

Type: `list(string)`

Default: `[]`

### <a name="input_map_roles"></a> [map\_roles](#input\_map\_roles)

Description: Additional IAM roles to add to the aws-auth configmap. See examples/basic/variables.tf for example format.

Type:

```hcl
list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
```

Default: `[]`

### <a name="input_map_users"></a> [map\_users](#input\_map\_users)

Description: Additional IAM users to add to the aws-auth configmap. See examples/basic/variables.tf for example format.

Type:

```hcl
list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
```

Default: `[]`

### <a name="input_node_groups"></a> [node\_groups](#input\_node\_groups)

Description: Map of map of node groups to create. See `node_groups` module's documentation for more details

Type: `any`

Default: `{}`

### <a name="input_node_groups_defaults"></a> [node\_groups\_defaults](#input\_node\_groups\_defaults)

Description: Map of values to be applied to all node groups. See `node_groups` module's documentation for more details

Type: `any`

Default: `{}`

### <a name="input_permissions_boundary"></a> [permissions\_boundary](#input\_permissions\_boundary)

Description: If provided, all IAM roles will be created with this permissions boundary attached.

Type: `string`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: A map of tags to add to all resources except addons. Tags added to launch configuration or templates override these values for ASG Tags only.

Type: `map(string)`

Default: `{}`

### <a name="input_wait_for_cluster_timeout"></a> [wait\_for\_cluster\_timeout](#input\_wait\_for\_cluster\_timeout)

Description: A timeout (in seconds) to wait for cluster to be available.

Type: `number`

Default: `300`

### <a name="input_worker_additional_security_group_ids"></a> [worker\_additional\_security\_group\_ids](#input\_worker\_additional\_security\_group\_ids)

Description: A list of additional security group ids to attach to worker instances

Type: `list(string)`

Default: `[]`

### <a name="input_worker_ami_name_filter"></a> [worker\_ami\_name\_filter](#input\_worker\_ami\_name\_filter)

Description: Name filter for AWS EKS worker AMI. If not provided, the latest official AMI for the specified 'cluster\_version' is used.

Type: `string`

Default: `""`

### <a name="input_worker_ami_name_filter_windows"></a> [worker\_ami\_name\_filter\_windows](#input\_worker\_ami\_name\_filter\_windows)

Description: Name filter for AWS EKS Windows worker AMI. If not provided, the latest official AMI for the specified 'cluster\_version' is used.

Type: `string`

Default: `""`

### <a name="input_worker_ami_owner_id"></a> [worker\_ami\_owner\_id](#input\_worker\_ami\_owner\_id)

Description: The ID of the owner for the AMI to use for the AWS EKS workers. Valid values are an AWS account ID, 'self' (the current account), or an AWS owner alias (e.g. 'amazon', 'aws-marketplace', 'microsoft').

Type: `string`

Default: `"amazon"`

### <a name="input_worker_ami_owner_id_windows"></a> [worker\_ami\_owner\_id\_windows](#input\_worker\_ami\_owner\_id\_windows)

Description: The ID of the owner for the AMI to use for the AWS EKS Windows workers. Valid values are an AWS account ID, 'self' (the current account), or an AWS owner alias (e.g. 'amazon', 'aws-marketplace', 'microsoft').

Type: `string`

Default: `"amazon"`

### <a name="input_worker_create_cluster_primary_security_group_rules"></a> [worker\_create\_cluster\_primary\_security\_group\_rules](#input\_worker\_create\_cluster\_primary\_security\_group\_rules)

Description: Whether to create security group rules to allow communication between pods on workers and pods using the primary cluster security group.

Type: `bool`

Default: `false`

### <a name="input_worker_create_initial_lifecycle_hooks"></a> [worker\_create\_initial\_lifecycle\_hooks](#input\_worker\_create\_initial\_lifecycle\_hooks)

Description: Whether to create initial lifecycle hooks provided in worker groups.

Type: `bool`

Default: `false`

### <a name="input_worker_create_security_group"></a> [worker\_create\_security\_group](#input\_worker\_create\_security\_group)

Description: Whether to create a security group for the workers or attach the workers to `worker_security_group_id`.

Type: `bool`

Default: `true`

### <a name="input_worker_groups"></a> [worker\_groups](#input\_worker\_groups)

Description: A list of maps defining worker group configurations to be defined using AWS Launch Configurations. See workers\_group\_defaults for valid keys.

Type: `any`

Default: `[]`

### <a name="input_worker_groups_launch_template"></a> [worker\_groups\_launch\_template](#input\_worker\_groups\_launch\_template)

Description: A list of maps defining worker group configurations to be defined using AWS Launch Templates. See workers\_group\_defaults for valid keys.

Type: `any`

Default: `[]`

### <a name="input_worker_security_group_id"></a> [worker\_security\_group\_id](#input\_worker\_security\_group\_id)

Description: If provided, all workers will be attached to this security group. If not given, a security group will be created with necessary ingress/egress to work with the EKS cluster.

Type: `string`

Default: `""`

### <a name="input_worker_sg_ingress_from_port"></a> [worker\_sg\_ingress\_from\_port](#input\_worker\_sg\_ingress\_from\_port)

Description: Minimum port number from which pods will accept communication. Must be changed to a lower value if some pods in your cluster will expose a port lower than 1025 (e.g. 22, 80, or 443).

Type: `number`

Default: `1025`

### <a name="input_workers_additional_policies"></a> [workers\_additional\_policies](#input\_workers\_additional\_policies)

Description: Additional policies to be added to workers

Type: `list(string)`

Default: `[]`

### <a name="input_workers_egress_cidrs"></a> [workers\_egress\_cidrs](#input\_workers\_egress\_cidrs)

Description: List of CIDR blocks that are permitted for workers egress traffic.

Type: `list(string)`

Default:

```json
[
  "0.0.0.0/0"
]
```

### <a name="input_workers_group_defaults"></a> [workers\_group\_defaults](#input\_workers\_group\_defaults)

Description: Override default values for target groups. See workers\_group\_defaults\_defaults in local.tf for valid keys.

Type: `any`

Default: `{}`

### <a name="input_workers_role_name"></a> [workers\_role\_name](#input\_workers\_role\_name)

Description: User defined workers role name.

Type: `string`

Default: `""`

### <a name="input_write_kubeconfig"></a> [write\_kubeconfig](#input\_write\_kubeconfig)

Description: Whether to write a Kubectl config file containing the cluster configuration. Saved to `kubeconfig_output_path`.

Type: `bool`

Default: `true`

## Outputs

The following outputs are exported:

### <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn)

Description: Arn of cloudwatch log group created

### <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name)

Description: Name of cloudwatch log group created

### <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn)

Description: The Amazon Resource Name (ARN) of the cluster.

### <a name="output_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#output\_cluster\_certificate\_authority\_data)

Description: Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster.

### <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint)

Description: The endpoint for your EKS Kubernetes API.

### <a name="output_cluster_iam_role_arn"></a> [cluster\_iam\_role\_arn](#output\_cluster\_iam\_role\_arn)

Description: IAM role ARN of the EKS cluster.

### <a name="output_cluster_iam_role_name"></a> [cluster\_iam\_role\_name](#output\_cluster\_iam\_role\_name)

Description: IAM role name of the EKS cluster.

### <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id)

Description: The name/id of the EKS cluster. Will block on cluster creation until the cluster is really ready.

### <a name="output_cluster_oidc_issuer_url"></a> [cluster\_oidc\_issuer\_url](#output\_cluster\_oidc\_issuer\_url)

Description: The URL on the EKS cluster OIDC Issuer

### <a name="output_cluster_primary_security_group_id"></a> [cluster\_primary\_security\_group\_id](#output\_cluster\_primary\_security\_group\_id)

Description: The cluster primary security group ID created by the EKS cluster on 1.14 or later. Referred to as 'Cluster security group' in the EKS console.

### <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id)

Description: Security group ID attached to the EKS cluster. On 1.14 or later, this is the 'Additional security groups' in the EKS console.

### <a name="output_cluster_version"></a> [cluster\_version](#output\_cluster\_version)

Description: The Kubernetes server version for the EKS cluster.

### <a name="output_config_map_aws_auth"></a> [config\_map\_aws\_auth](#output\_config\_map\_aws\_auth)

Description: A kubernetes configuration to authenticate to this EKS cluster.

### <a name="output_coredns_arn"></a> [coredns\_arn](#output\_coredns\_arn)

Description: The arn of the CoreDns addon

### <a name="output_fargate_iam_role_arn"></a> [fargate\_iam\_role\_arn](#output\_fargate\_iam\_role\_arn)

Description: IAM role ARN for EKS Fargate pods

### <a name="output_fargate_iam_role_name"></a> [fargate\_iam\_role\_name](#output\_fargate\_iam\_role\_name)

Description: IAM role name for EKS Fargate pods

### <a name="output_fargate_profile_arns"></a> [fargate\_profile\_arns](#output\_fargate\_profile\_arns)

Description: Amazon Resource Name (ARN) of the EKS Fargate Profiles.

### <a name="output_fargate_profile_ids"></a> [fargate\_profile\_ids](#output\_fargate\_profile\_ids)

Description: EKS Cluster name and EKS Fargate Profile names separated by a colon (:).

### <a name="output_kube_proxy_arn"></a> [kube\_proxy\_arn](#output\_kube\_proxy\_arn)

Description: The arn of the kube-proxy addon

### <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig)

Description: kubectl config file contents for this EKS cluster. Will block on cluster creation until the cluster is really ready.

### <a name="output_kubeconfig_filename"></a> [kubeconfig\_filename](#output\_kubeconfig\_filename)

Description: The filename of the generated kubectl config. Will block on cluster creation until the cluster is really ready.

### <a name="output_node_groups"></a> [node\_groups](#output\_node\_groups)

Description: Outputs from EKS node groups. Map of maps, keyed by var.node\_groups keys

### <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn)

Description: The ARN of the OIDC Provider if `enable_irsa = true`.

### <a name="output_security_group_rule_cluster_https_worker_ingress"></a> [security\_group\_rule\_cluster\_https\_worker\_ingress](#output\_security\_group\_rule\_cluster\_https\_worker\_ingress)

Description: Security group rule responsible for allowing pods to communicate with the EKS cluster API.

### <a name="output_vpc_cni_arn"></a> [vpc\_cni\_arn](#output\_vpc\_cni\_arn)

Description: The arn of the Amazon VPC CNI addon

### <a name="output_worker_iam_instance_profile_arns"></a> [worker\_iam\_instance\_profile\_arns](#output\_worker\_iam\_instance\_profile\_arns)

Description: default IAM instance profile ARN for EKS worker groups

### <a name="output_worker_iam_instance_profile_names"></a> [worker\_iam\_instance\_profile\_names](#output\_worker\_iam\_instance\_profile\_names)

Description: default IAM instance profile name for EKS worker groups

### <a name="output_worker_iam_role_arn"></a> [worker\_iam\_role\_arn](#output\_worker\_iam\_role\_arn)

Description: default IAM role ARN for EKS worker groups

### <a name="output_worker_iam_role_name"></a> [worker\_iam\_role\_name](#output\_worker\_iam\_role\_name)

Description: default IAM role name for EKS worker groups

### <a name="output_worker_security_group_id"></a> [worker\_security\_group\_id](#output\_worker\_security\_group\_id)

Description: Security group ID attached to the EKS workers.

### <a name="output_workers_asg_arns"></a> [workers\_asg\_arns](#output\_workers\_asg\_arns)

Description: IDs of the autoscaling groups containing workers.

### <a name="output_workers_asg_names"></a> [workers\_asg\_names](#output\_workers\_asg\_names)

Description: Names of the autoscaling groups containing workers.

### <a name="output_workers_default_ami_id"></a> [workers\_default\_ami\_id](#output\_workers\_default\_ami\_id)

Description: ID of the default worker group AMI

### <a name="output_workers_default_ami_id_windows"></a> [workers\_default\_ami\_id\_windows](#output\_workers\_default\_ami\_id\_windows)

Description: ID of the default Windows worker group AMI

### <a name="output_workers_launch_template_arns"></a> [workers\_launch\_template\_arns](#output\_workers\_launch\_template\_arns)

Description: ARNs of the worker launch templates.

### <a name="output_workers_launch_template_ids"></a> [workers\_launch\_template\_ids](#output\_workers\_launch\_template\_ids)

Description: IDs of the worker launch templates.

### <a name="output_workers_launch_template_latest_versions"></a> [workers\_launch\_template\_latest\_versions](#output\_workers\_launch\_template\_latest\_versions)

Description: Latest versions of the worker launch templates.

### <a name="output_workers_user_data"></a> [workers\_user\_data](#output\_workers\_user\_data)

Description: User data of worker groups
