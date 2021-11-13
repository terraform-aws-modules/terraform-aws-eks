# AWS EKS Terraform module

Terraform module which creates AWS EKS (Kubernetes) resources

## Available Features

- EKS cluster
- All [node types](https://docs.aws.amazon.com/eks/latest/userguide/eks-compute.html) are supported:
  - [EKS Managed Node Group](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html)
  - [Self Managed Node Group](https://docs.aws.amazon.com/eks/latest/userguide/worker.html)
  - [Fargate Profile](https://docs.aws.amazon.com/eks/latest/userguide/fargate.html)
- Support for custom AMI, custom launch template, and custom user data
- Create or manage security groups that allow communication and coordination

## Usage

```hcl
module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_version = "1.22"
  cluster_name    = "my-cluster"

  vpc_id                          = "vpc-1234556abcdef"
  subnet_ids                      = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  eks_managed_node_groups = {
    default = {}
  }

  self_managed_node_groups = {
    one = {
      instance_type    = "m5.large"
      desired_capacity = 1
      max_size         = 5
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

## Notes

- Kubernetes is constantly evolving, and each version brings new features, fixes, and changes. Always check [Kubernetes Release Notes](https://kubernetes.io/docs/setup/release/notes/) before updating the major version, and [CHANGELOG.md](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/CHANGELOG.md) for all changes related to this EKS module. Applications and add-ons will most likely require updates or workloads could fail after an upgrade. Check [the documentation](https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html) for any necessary steps you may need to perform.

- Setting `instance_refresh_enabled = true` will recreate your worker nodes without draining them first. It is recommended to install [aws-node-termination-handler](https://github.com/aws/aws-node-termination-handler) for proper node draining. See the [instance_refresh](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/instance_refresh) example provided.

<details><summary><b>Frequently Asked Questions</b></summary><br>

<h4>Why are nodes not being registered?</h4>

Often an issue caused by a networking or endpoint mis-configuration. At least one of the cluster public or private endpoints must be enabled to access the cluster to work. If you require a public endpoint, setting up both (public and private) and restricting the public endpoint via setting `cluster_endpoint_public_access_cidrs` is recommended. More about communication with an endpoint is available [here](https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html).

Nodes need to be able to contact the EKS cluster endpoint. By default, the module only creates a public endpoint. To access endpoint, the nodes need outgoing internet access:

- Nodes in private subnets: via a NAT gateway or instance. It will need adding along with appropriate routing rules.
- Nodes in public subnets: assign public IPs to nodes. Set `public_ip = true` in the `worker_groups` list on this module.

<strong>Important: If you apply only the public endpoint and setup `cluster_endpoint_public_access_cidrs` to restrict access. Remember, EKS nodes also use the public endpoint, so you must allow access to the endpoint. If not, then your nodes will fail to work correctly.</strong>

Cluster private endpoint can also be enabled by setting `cluster_endpoint_private_access = true` on this module. Node communication to the endpoint stay within the VPC. When the private endpoint is enabled ensure that VPC DNS resolution and hostnames are also enabled:

- If managing the VPC with Terraform: set `enable_dns_hostnames = true` and `enable_dns_support = true` on the `aws_vpc` resource. The [`terraform-aws-module/vpc/aws`](https://github.com/terraform-aws-modules/terraform-aws-vpc/) community module also has these variables.
- Otherwise refer to the [AWS VPC docs](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-dns.html#vpc-dns-updating) and [AWS EKS Cluster Endpoint Access docs](https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html) for more information.

Nodes need to be able to connect to other AWS services plus pull down container images from container registries (ECR). If for some reason you cannot enable public internet access for nodes you can add VPC endpoints to the relevant services: EC2 API, ECR API, ECR DKR and S3.

<h4>How can I work with the cluster if I disable the public endpoint?</h4>

You have to interact with the cluster from within the VPC that it is associated with; either through a VPN connection, a bastion EC2 instance, etc.

<h4>How can I stop Terraform from removing the EKS tags from my VPC and subnets?</h4>

You need to add the tags to the VPC and subnets yourself. See the [basic example](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/basic).

An alternative is to use the aws provider's [`ignore_tags` variable](https://www.terraform.io/docs/providers/aws/#ignore_tags-configuration-block). However this can also cause terraform to display a perpetual difference.

<h4>Why are there no changes when a node group's desired count is modified?</h4>

The module is configured to ignore this value. Unfortunately, Terraform does not support variables within the `lifecycle` block. The setting is ignored to allow the cluster autoscaler to work correctly so that `terraform apply` does not accidentally remove running workers. You can change the desired count via the CLI or console if you're not using the cluster autoscaler.

If you are not using autoscaling and want to control the number of nodes via terraform, set the `min_capacity` and `max_capacity` for node groups. Before changing those values, you must satisfy AWS `desired_capacity` constraints (which must be between new min/max values).

<h4>Why are nodes not recreated when the `launch_template` is recreated?</h4>

By default the ASG is not configured to be recreated when the launch configuration or template changes; you will need to use a process to drain and cycle the nodes.

If you are NOT using the cluster autoscaler:

- Add a new instance
- Drain an old node `kubectl drain --force --ignore-daemonsets --delete-local-data ip-xxxxxxx.eu-west-1.compute.internal`
- Wait for pods to be Running
- Terminate the old node instance. ASG will start a new instance
- Repeat the drain and delete process until all old nodes are replaced

If you are using the cluster autoscaler:

- Drain an old node `kubectl drain --force --ignore-daemonsets --delete-local-data ip-xxxxxxx.eu-west-1.compute.internal`
- Wait for pods to be Running
- Cluster autoscaler will create new nodes when required
- Repeat until all old nodes are drained
- Cluster autoscaler will terminate the old nodes after 10-60 minutes automatically

You can also use a 3rd party tool like Gruntwork's kubergrunt. See the [`eks deploy`](https://github.com/gruntwork-io/kubergrunt#deploy) subcommand.

<h4>How can I use Windows workers?</h4>

To enable Windows support for your EKS cluster, you should apply some configs manually. See the [Enabling Windows Support (Windows/MacOS/Linux)](https://docs.aws.amazon.com/eks/latest/userguide/windows-support.html#enable-windows-support).

Windows nodes requires additional cluster role (`eks:kube-proxy-windows`).

<h5>Example configuration</h5>

Amazon EKS clusters must contain one or more Linux worker nodes to run core system pods that only run on Linux, such as coredns and the VPC resource controller.

1. Build AWS EKS cluster with the next workers configuration (default Linux):

```hcl
  worker_groups = {
    one = {
      name                          = "worker-group-linux"
      instance_type                 = "m5.large"
      platform                      = "linux"
      asg_desired_capacity          = 2
    },
  }
```

2. Apply commands from https://docs.aws.amazon.com/eks/latest/userguide/windows-support.html#enable-windows-support (use tab with name `Windows`)
3. Add one more worker group for Windows with required field `platform = "windows"` and update your cluster. Worker group example:

```hcl
  worker_groups = {
    linux = {
      name                          = "worker-group-linux"
      instance_type                 = "m5.large"
      platform                      = "linux"
      asg_desired_capacity          = 2
    },
    windows = {
      name                          = "worker-group-windows"
      instance_type                 = "m5.large"
      platform                      = "windows"
      asg_desired_capacity          = 1
    },
  }
```

4. With `kubectl get nodes` you can see cluster with mixed (Linux/Windows) nodes support.

<h4>Worker nodes with labels do not join a 1.16+ cluster</h4>

Kubelet restricts the allowed list of labels in the `kubernetes.io` namespace that can be applied to nodes starting in 1.16. Older configurations used labels such as `kubernetes.io/lifecycle=spot` which is no longer allowed; instead, use `node.kubernetes.io/lifecycle=spot`

Reference the `--node-labels` argument for your version of Kubenetes for the allowed prefixes. [Documentation for 1.16](https://v1-16.docs.kubernetes.io/docs/reference/command-line-tools-reference/kubelet/)

<h4>I am using both EKS Managed node groups and Self Managed node groups and pods scheduled on an EKS Managed node group are unable resolve DNS (even communication between pods)</h4>

This happen because CoreDNS can be scheduled on Self Managed nodes and by default this module does not create security group rules to allow communication between pods scheduled on Self Managed node groups and EKS Managed node groups.

You can set `var.worker_create_cluster_primary_security_group_rules` to `true` to create required rules.

<h4>Dedicated control plane subnets</h4>

[AWS recommends](https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html) to create dedicated subnets for EKS created network interfaces (control plane) which this module supports. To enable this:
1. Set the `subnet_ids` to the subnets for the control plane
2. Within the `eks_managed_node_groups`, `self_managed_node_groups`, or `fargate_profiles`, set the `subnet_ids` for the nodes (different from the control plane).

```hcl
module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_version = "1.21"
  cluster_name    = "my-cluster"

  vpc_id     = "vpc-1234556abcdef"
  subnet_ids = ["subnet-abcde123", "subnet-abcde456", "subnet-abcde789"]

  self_managed_node_group_defaults = {
    subnet_ids = ["subnet-xyz123", "subnet-xyz456", "subnet-xyz789"]
  }

  self_managed_node_groups = {
    one = {
      instance_type = "m4.large"
      asg_max_size  = 5
    },
    two = {
      name                 = "worker-group-2"
      subnet_ids           = ["subnet-qwer123"]
      instance_type        = "t3.medium"
      asg_desired_capacity = 1
      public_ip            = true
      ebs_optimized        = true
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```
</details>

<details><summary><b>Autoscaling</b></summary><br>

To enable worker node autoscaling you will need to do a few things:

- Add the [required tags](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler/cloudprovider/aws#auto-discovery-setup) to the worker group
- Install the cluster-autoscaler
- Give the cluster-autoscaler access via an IAM policy

It's probably easiest to follow the example in [examples/irsa](examples/irsa), this will install the cluster-autoscaler using [Helm](https://helm.sh/) and use IRSA to attach a policy.

If you don't want to use IRSA then you will need to attach the IAM policy to the worker node IAM role or add AWS credentials to the cluster-autoscaler environment variables. Here is some example terraform code for the policy:

```hcl
resource "aws_iam_role_policy_attachment" "workers_autoscaling" {
  policy_arn = aws_iam_policy.worker_autoscaling.arn
  role       = module.my_cluster.worker_iam_role_name
}

resource "aws_iam_policy" "worker_autoscaling" {
  name_prefix = "eks-worker-autoscaling-${module.my_cluster.cluster_id}"
  description = "EKS worker node autoscaling policy for cluster ${module.my_cluster.cluster_id}"
  policy      = data.aws_iam_policy_document.worker_autoscaling.json
  path        = var.iam_path
  tags        = var.tags
}

data "aws_iam_policy_document" "worker_autoscaling" {
  statement {
    sid    = "eksWorkerAutoscalingAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "eksWorkerAutoscalingOwn"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${module.my_cluster.cluster_id}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}
```

And example values for the [helm chart](https://github.com/helm/charts/tree/master/stable/cluster-autoscaler):

```yaml
rbac:
  create: true

cloudProvider: aws
awsRegion: YOUR_AWS_REGION

autoDiscovery:
  clusterName: YOUR_CLUSTER_NAME
  enabled: true

image:
  repository: us.gcr.io/k8s-artifacts-prod/autoscaling/cluster-autoscaler
  tag: v1.16.5
```

To install the chart, simply run helm with the `--values` option:

```bash
helm install stable/cluster-autoscaler --values=path/to/your/values-file.yaml
```

</details>

<details><summary><b>Spot Instances</b></summary><br>

# TODO - move to an example

You will need to install a daemonset to catch the 2 minute warning before termination. This will ensure the node is gracefully drained before termination. You can install the [k8s-spot-termination-handler](https://github.com/kube-aws/kube-spot-termination-notice-handler) for this. There's a [Helm chart](https://github.com/helm/charts/tree/master/stable/k8s-spot-termination-handler):

In the following examples at least 1 worker group that uses on-demand instances is included. This worker group has an added node label that can be used in scheduling. This could be used to schedule any workload not suitable for spot instances but is important for the [cluster-autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler) as it might be end up unscheduled when spot instances are terminated. You can add this to the values of the [cluster-autoscaler helm chart](https://github.com/kubernetes/autoscaler/tree/master/charts/cluster-autoscaler-chart):

```yaml
nodeSelector:
  kubernetes.io/lifecycle: normal
```

Notes:

- The `spot_price` is set to the on-demand price so that the spot instances will run as long as they are the cheaper.
- It's best to have a broad range of instance types to ensure there's always some instances to run when prices fluctuate.
- There is an AWS blog article about this [here](https://aws.amazon.com/blogs/compute/run-your-kubernetes-workloads-on-amazon-ec2-spot-instances-with-amazon-eks/).
- Consider using [k8s-spot-rescheduler](https://github.com/pusher/k8s-spot-rescheduler) to move pods from on-demand to spot instances.

## Using Launch Templates

```hcl
  self_managed_node_groups = {
    one = {
      name                 = "spot-1"
      instance_types       = ["m5.large", "m5a.large", "m5d.large", "m5ad.large"]
      spot_instance_pools  = 4
      max_size             = 5
      desired_capacity     = 5
      bootstrap_extra_args = "--kubelet-extra-args '--node-labels=node.kubernetes.io/lifecycle=spot'"
      public_ip            = true
    },
  }
```

## Using Launch Templates With Both Spot and On Demand

Example launch template to launch 2 on demand instances of type m5.large, and have the ability to scale up using spot instances and on demand instances. The `node.kubernetes.io/lifecycle` node label will be set to the value queried from the EC2 meta-data service: either "on-demand" or "spot".

`on_demand_percentage_above_base_capacity` is set to 25 so 1 in 4 new nodes, when auto-scaling, will be on-demand instances. If not set, all new nodes will be spot instances. The on-demand instances will be the primary instance type (first in the array if they are not weighted).

```hcl
  self_managed_node_groups = {
    one = {
      name                    = "mixed-demand-spot"
      override_instance_types = ["m5.large", "m5a.large", "m4.large"]
      root_encrypted          = true
      root_volume_size        = 50

      min_size                                 = 2
      desired_capacity                         = 2
      on_demand_base_capacity                  = 3
      on_demand_percentage_above_base_capacity = 25
      asg_max_size                             = 20
      spot_instance_pools                      = 3

      bootstrap_extra_args = "--kubelet-extra-args '--node-labels=node.kubernetes.io/lifecycle=`curl -s http://169.254.169.254/latest/meta-data/instance-life-cycle`'"
    }
  }
```

<strong>Note: An issue with the cluster-autoscaler: https://github.com/kubernetes/autoscaler/issues/1133 - AWS have released their own termination handler now: https://github.com/aws/aws-node-termination-handler</strong>

</details>

## Examples

- [Bottlerocket](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/bottlerocket): EKS cluster using [Bottlerocket AMI](https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami-bottlerocket.html)
- [Complete](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/complete): EKS Cluster using all available node group types in various combinations demonstrating many of the supported features and configurations
- [EKS Managed Node Group](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/eks_managed_node_group): EKS Cluster using EKS managed node groups
- [Fargate](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/fargate): EKS cluster using [Fargate Profiles](https://docs.aws.amazon.com/eks/latest/userguide/fargate.html)
- [Instance Refresh](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/instance_refresh): EKS Cluster using self-managed node group demonstrating how to enable/utilize instance refresh configuration along with node termination handler
- [IRSA](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/irsa): EKS Cluster demonstrating how to enable IRSA
- [Secrets Encryption](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/secrets_encryption): EKS Cluster demonstrating how to encrypt cluster secrets
- [Self Managed Node Group](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/self_managed_node_group): EKS Cluster using self-managed node groups

## Contributing

Report issues/questions/feature requests on in the [issues](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/new) section.
Full contributing [guidelines are covered here](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/.github/CONTRIBUTING.md).

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.64 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 2.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.64 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | >= 2.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks_managed_node_group"></a> [eks\_managed\_node\_group](#module\_eks\_managed\_node\_group) | ./modules/eks-managed-node-group | n/a |
| <a name="module_fargate_profile"></a> [fargate\_profile](#module\_fargate\_profile) | ./modules/fargate-profile | n/a |
| <a name="module_self_managed_node_group"></a> [self\_managed\_node\_group](#module\_self\_managed\_node\_group) | ./modules/self-managed-node-group | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [aws_iam_openid_connect_provider.oidc_provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_policy.cluster_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.cluster_egress_internet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.cluster_private_access_cidrs_source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.cluster_private_access_sg_source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_iam_policy_document.cluster_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cluster_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [tls_certificate.this](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_create_endpoint_private_access_sg_rule"></a> [cluster\_create\_endpoint\_private\_access\_sg\_rule](#input\_cluster\_create\_endpoint\_private\_access\_sg\_rule) | Whether to create security group rules for the access to the Amazon EKS private API server endpoint. If `true`, `cluster_endpoint_private_access_cidrs` and/or 'cluster\_endpoint\_private\_access\_sg' should be provided | `bool` | `false` | no |
| <a name="input_cluster_egress_cidrs"></a> [cluster\_egress\_cidrs](#input\_cluster\_egress\_cidrs) | List of CIDR blocks that are permitted for cluster egress traffic | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_cluster_enabled_log_types"></a> [cluster\_enabled\_log\_types](#input\_cluster\_enabled\_log\_types) | A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html) | `list(string)` | `[]` | no |
| <a name="input_cluster_encryption_config"></a> [cluster\_encryption\_config](#input\_cluster\_encryption\_config) | Configuration block with encryption configuration for the cluster. See examples/secrets\_encryption/main.tf for example format | <pre>list(object({<br>    provider_key_arn = string<br>    resources        = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_cluster_endpoint_private_access"></a> [cluster\_endpoint\_private\_access](#input\_cluster\_endpoint\_private\_access) | Indicates whether or not the Amazon EKS private API server endpoint is enabled | `bool` | `false` | no |
| <a name="input_cluster_endpoint_private_access_cidrs"></a> [cluster\_endpoint\_private\_access\_cidrs](#input\_cluster\_endpoint\_private\_access\_cidrs) | List of CIDR blocks which can access the Amazon EKS private API server endpoint. `cluster_endpoint_private_access` and `cluster_create_endpoint_private_access_sg_rule` must be set to `true` | `list(string)` | `[]` | no |
| <a name="input_cluster_endpoint_private_access_sg"></a> [cluster\_endpoint\_private\_access\_sg](#input\_cluster\_endpoint\_private\_access\_sg) | List of security group IDs which can access the Amazon EKS private API server endpoint. `cluster_endpoint_private_access` and `cluster_create_endpoint_private_access_sg_rule` must be set to `true` | `list(string)` | `[]` | no |
| <a name="input_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#input\_cluster\_endpoint\_public\_access) | Indicates whether or not the Amazon EKS public API server endpoint is enabled. When it's set to `false` ensure to have a proper private access with `cluster_endpoint_private_access = true` | `bool` | `true` | no |
| <a name="input_cluster_endpoint_public_access_cidrs"></a> [cluster\_endpoint\_public\_access\_cidrs](#input\_cluster\_endpoint\_public\_access\_cidrs) | List of CIDR blocks which can access the Amazon EKS public API server endpoint | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_cluster_iam_role_arn"></a> [cluster\_iam\_role\_arn](#input\_cluster\_iam\_role\_arn) | Existing IAM role ARN for the cluster. Required if `create_cluster_iam_role` is set to `false` | `string` | `null` | no |
| <a name="input_cluster_iam_role_name"></a> [cluster\_iam\_role\_name](#input\_cluster\_iam\_role\_name) | Name to use on cluster role created | `string` | `null` | no |
| <a name="input_cluster_iam_role_path"></a> [cluster\_iam\_role\_path](#input\_cluster\_iam\_role\_path) | Cluster IAM role path | `string` | `null` | no |
| <a name="input_cluster_iam_role_permissions_boundary"></a> [cluster\_iam\_role\_permissions\_boundary](#input\_cluster\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the cluster role | `string` | `null` | no |
| <a name="input_cluster_iam_role_tags"></a> [cluster\_iam\_role\_tags](#input\_cluster\_iam\_role\_tags) | A map of additional tags to add to the cluster IAM role created | `map(string)` | `{}` | no |
| <a name="input_cluster_iam_role_use_name_prefix"></a> [cluster\_iam\_role\_use\_name\_prefix](#input\_cluster\_iam\_role\_use\_name\_prefix) | Determines whether cluster IAM role name (`cluster_iam_role_name`) is used as a prefix | `string` | `true` | no |
| <a name="input_cluster_log_kms_key_id"></a> [cluster\_log\_kms\_key\_id](#input\_cluster\_log\_kms\_key\_id) | If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html) | `string` | `""` | no |
| <a name="input_cluster_log_retention_in_days"></a> [cluster\_log\_retention\_in\_days](#input\_cluster\_log\_retention\_in\_days) | Number of days to retain log events. Default retention - 90 days | `number` | `90` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster and default name (prefix) used throughout the resources created | `string` | `""` | no |
| <a name="input_cluster_security_group_id"></a> [cluster\_security\_group\_id](#input\_cluster\_security\_group\_id) | If provided, the EKS cluster will be attached to this security group. If not given, a security group will be created with necessary ingress/egress to work with the workers | `string` | `""` | no |
| <a name="input_cluster_security_group_name"></a> [cluster\_security\_group\_name](#input\_cluster\_security\_group\_name) | Name to use on cluster role created | `string` | `null` | no |
| <a name="input_cluster_security_group_tags"></a> [cluster\_security\_group\_tags](#input\_cluster\_security\_group\_tags) | A map of additional tags to add to the cluster security group created | `map(string)` | `{}` | no |
| <a name="input_cluster_security_group_use_name_prefix"></a> [cluster\_security\_group\_use\_name\_prefix](#input\_cluster\_security\_group\_use\_name\_prefix) | Determines whether cluster IAM role name (`cluster_iam_role_name`) is used as a prefix | `string` | `true` | no |
| <a name="input_cluster_service_ipv4_cidr"></a> [cluster\_service\_ipv4\_cidr](#input\_cluster\_service\_ipv4\_cidr) | service ipv4 cidr for the kubernetes cluster | `string` | `null` | no |
| <a name="input_cluster_tags"></a> [cluster\_tags](#input\_cluster\_tags) | A map of additional tags to add to the cluster | `map(string)` | `{}` | no |
| <a name="input_cluster_timeouts"></a> [cluster\_timeouts](#input\_cluster\_timeouts) | Create, update, and delete timeout configurations for the cluster | `map(string)` | `{}` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Kubernetes minor version to use for the EKS cluster (for example 1.21) | `string` | `null` | no |
| <a name="input_create"></a> [create](#input\_create) | Controls if EKS resources should be created (it affects almost all resources) | `bool` | `true` | no |
| <a name="input_create_cluster_iam_role"></a> [create\_cluster\_iam\_role](#input\_create\_cluster\_iam\_role) | Determines whether a cluster IAM role is created or to use an existing IAM role | `bool` | `true` | no |
| <a name="input_create_cluster_security_group"></a> [create\_cluster\_security\_group](#input\_create\_cluster\_security\_group) | Whether to create a security group for the cluster or attach the cluster to `cluster_security_group_id` | `bool` | `true` | no |
| <a name="input_eks_managed_node_group_defaults"></a> [eks\_managed\_node\_group\_defaults](#input\_eks\_managed\_node\_group\_defaults) | Map of EKS managed node group default configurations | `any` | `{}` | no |
| <a name="input_eks_managed_node_groups"></a> [eks\_managed\_node\_groups](#input\_eks\_managed\_node\_groups) | Map of EKS managed node group definitions to create | `any` | `{}` | no |
| <a name="input_enable_irsa"></a> [enable\_irsa](#input\_enable\_irsa) | Whether to create OpenID Connect Provider for EKS to enable IRSA | `bool` | `false` | no |
| <a name="input_fargate_profile_defaults"></a> [fargate\_profile\_defaults](#input\_fargate\_profile\_defaults) | Map of Fargate Profile default configurations | `any` | `{}` | no |
| <a name="input_fargate_profiles"></a> [fargate\_profiles](#input\_fargate\_profiles) | Map of Fargate Profile definitions to create | `any` | `{}` | no |
| <a name="input_openid_connect_audiences"></a> [openid\_connect\_audiences](#input\_openid\_connect\_audiences) | List of OpenID Connect audience client IDs to add to the IRSA provider | `list(string)` | `[]` | no |
| <a name="input_self_managed_node_group_defaults"></a> [self\_managed\_node\_group\_defaults](#input\_self\_managed\_node\_group\_defaults) | Map of self-managed node group default configurations | `any` | `{}` | no |
| <a name="input_self_managed_node_groups"></a> [self\_managed\_node\_groups](#input\_self\_managed\_node\_groups) | Map of self-managed node group definitions to create | `any` | `{}` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of subnet IDs to place the EKS cluster and workers within | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. Tags added to launch configuration or templates override these values for ASG Tags only | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where the cluster and workers will be provisioned | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | Arn of cloudwatch log group created |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | Name of cloudwatch log group created |
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | The Amazon Resource Name (ARN) of the cluster |
| <a name="output_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#output\_cluster\_certificate\_authority\_data) | Base64 encoded certificate data required to communicate with the cluster |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint for your Kubernetes API server |
| <a name="output_cluster_iam_role_arn"></a> [cluster\_iam\_role\_arn](#output\_cluster\_iam\_role\_arn) | IAM role ARN of the EKS cluster |
| <a name="output_cluster_iam_role_name"></a> [cluster\_iam\_role\_name](#output\_cluster\_iam\_role\_name) | IAM role name of the EKS cluster |
| <a name="output_cluster_iam_role_unique_id"></a> [cluster\_iam\_role\_unique\_id](#output\_cluster\_iam\_role\_unique\_id) | Stable and unique string identifying the IAM role |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | The name/id of the EKS cluster. Will block on cluster creation until the cluster is really ready |
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

## License

Apache 2 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-rds-aurora/tree/master/LICENSE) for full details.
