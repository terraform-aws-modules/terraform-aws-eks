# Frequently Asked Questions

## How do I customize X on the worker group's settings?

All the options that can be customized for worker groups are listed in [local.tf](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/local.tf) under `workers_group_defaults_defaults`.

Please open Issues or PRs if you think something is missing.

## Why are nodes not being registered?

### Networking

Often caused by a networking or endpoint configuration issue.

At least one of the cluster public or private endpoints must be enabled in order for access to the cluster to work.

Nodes need to be able to contact the EKS cluster endpoint. By default the module only creates a public endpoint. To access this endpoint the nodes need outgoing internet access:
- Nodes in private subnets: via a NAT gateway or instance. This will need adding along with appropriate routing rules.
- Nodes in public subnets: assign public IPs to nodes. Set `public_ip = true` in the `worker_groups` list on this module.

Cluster private endpoint can also be enabled by setting `cluster_endpoint_private_access = true` on this module. Node calls to the endpoint stay within the VPC.

When the private endpoint is enabled ensure that VPC DNS resolution and hostnames are also enabled:
- If managing the VPC with Terraform: set `enable_dns_hostnames = true` and `enable_dns_support = true` on the `aws_vpc` resource. The [`terraform-aws-module/vpc/aws`](https://github.com/terraform-aws-modules/terraform-aws-vpc/) community module also has these variables.
- Otherwise refer to the [AWS VPC docs](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-dns.html#vpc-dns-updating) and [AWS EKS Cluster Endpoint Access docs](https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html) for more information.

Nodes need to be able to connect to other AWS services plus pull down container images from repos. If for some reason you cannot enable public internet access for nodes you can add VPC endpoints to the relevant services: EC2 API, ECR API, ECR DKR and S3.

### `aws-auth` ConfigMap not present

The module configures the `aws-auth` ConfigMap. This is used by the cluster to grant IAM users and roles RBAC permissions in the cluster, like the IAM role assigned to the worker nodes.

Confirm that the ConfigMap matches the contents of the `config_map_aws_auth` module output. You can retrieve the live config by running the following in your terraform folder:
`kubectl --kubeconfig=kubeconfig_* -n kube-system get cm aws-auth -o yaml`

If the ConfigMap is missing or the contents are incorrect then ensure that you have properly configured the kubernetes provider block by referring to [README.md](https://github.com/terraform-aws-modules/terraform-aws-eks/#usage-example) and run `terraform apply` again.

Users with `manage_aws_auth = false` will need to apply the ConfigMap themselves.

## How can I work with the cluster if I disable the public endpoint?

You have to interact with the cluster from within the VPC that it's associated with, from an instance that's allowed access via the cluster's security group.

Creating a new cluster with the public endpoint disabled is harder to achieve. You will either want to pass in a pre-configured cluster security group or apply the `aws-auth` configmap in a separate action.

## ConfigMap "aws-auth" already exists

This can happen if the kubernetes provider has not been configured for use with the cluster. The kubernetes provider will be accessing your default kubernetes cluster which already has the map defined. Read [README.md](https://github.com/terraform-aws-modules/terraform-aws-eks/#usage-example) for more details on how to configure the kubernetes provider correctly.

Users upgrading from modules before 8.0.0 will need to import their existing aws-auth ConfigMap in to the terraform state. See 8.0.0's [CHANGELOG](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v8.0.0/CHANGELOG.md#v800---2019-12-11) for more details.

## `Error: Get http://localhost/api/v1/namespaces/kube-system/configmaps/aws-auth: dial tcp 127.0.0.1:80: connect: connection refused`

Usually this means that the kubernetes provider has not been configured, there is no default `~/.kube/config` and so the kubernetes provider is attempting to talk to localhost.

You need to configure the kubernetes provider correctly. See [README.md](https://github.com/terraform-aws-modules/terraform-aws-eks/#usage-example) for more details.

## How can I stop Terraform from removing the EKS tags from my VPC and subnets?

You need to add the tags to the VPC and subnets yourself. See the [basic example](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/basic).

An alternative is to use the aws provider's [`ignore_tags` variable](https://www.terraform.io/docs/providers/aws/#ignore\_tags-configuration-block). However this can also cause terraform to display a perpetual difference.

## How do I safely remove old worker groups?

You've added new worker groups. Deleting worker groups from earlier in the list causes Terraform to want to recreate all worker groups. This is a limitation with how Terraform works and the module using `count` to create the ASGs and other resources.

The safest and easiest option is to set `asg_min_size` and `asg_max_size` to 0 on the worker groups to "remove".

## Why does changing the worker group's desired count not do anything?

The module is configured to ignore this value. Unfortunately Terraform does not support variables within the `lifecycle` block.

The setting is ignored to allow the cluster autoscaler to work correctly and so that terraform apply does not accidentally remove running workers.

You can change the desired count via the CLI or console if you're not using the cluster autoscaler.

If you are not using autoscaling and really want to control the number of nodes via terraform then set the `asg_min_size` and `asg_max_size` instead. AWS will remove a random instance when you scale down. You will have to weigh the risks here.

## Why are nodes not recreated when the `launch_configuration`/`launch_template` is recreated?

By default the ASG is not configured to be recreated when the launch configuration or template changes. Terraform spins up new instances and then deletes all the old instances in one go as the AWS provider team have refused to implement rolling updates of autoscaling groups. This is not good for kubernetes stability.

You need to use a process to drain and cycle the workers.

You are not using the cluster autoscaler:
- Add a new instance
- Drain an old node `kubectl drain --force --ignore-daemonsets --delete-local-data ip-xxxxxxx.eu-west-1.compute.internal`
- Wait for pods to be Running
- Terminate the old node instance. ASG will start a new instance
- Repeat the drain and delete process until all old nodes are replaced

You are using the cluster autoscaler:
- Drain an old node `kubectl drain --force --ignore-daemonsets --delete-local-data ip-xxxxxxx.eu-west-1.compute.internal`
- Wait for pods to be Running
- Cluster autoscaler will create new nodes when required
- Repeat until all old nodes are drained
- Cluster autoscaler will terminate the old nodes after 10-60 minutes automatically

Alternatively you can set the `asg_recreate_on_change = true` worker group option to get the ASG recreated after changes to the launch configuration or template. But be aware of the risks to cluster stability mentioned above.

You can also use a 3rd party tool like Gruntwork's kubergrunt. See the [`eks deploy`](https://github.com/gruntwork-io/kubergrunt#deploy) subcommand.

## How do I create kubernetes resources when creating the cluster?

You do not need to do anything extra since v12.1.0 of the module as long as the following conditions are met:
- `manage_aws_auth = true` on the module (default)
- the kubernetes provider is correctly configured like in the [Usage Example](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/README.md#usage-example). Primarily the module's `cluster_id` output is used as input to the `aws_eks_cluster*` data sources.

The `cluster_id` depends on a `data.http.wait_for_cluster` that polls the EKS cluster's endpoint until it is alive. This blocks initialisation of the kubernetes provider.

## `aws_auth.tf: At 2:14: Unknown token: 2:14 IDENT`

You are attempting to use a Terraform 0.12 module with Terraform 0.11.

We highly recommend that you upgrade your EKS Terraform config to 0.12 to take advantage of new features in the module.

Alternatively you can lock your module to a compatible version if you must stay with terraform 0.11:
```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 4.0"
  # ...
}
```

## How can I use Windows workers?

To enable Windows support for your EKS cluster, you should apply some configs manually. See the [Enabling Windows Support (Windows/MacOS/Linux)](https://docs.aws.amazon.com/eks/latest/userguide/windows-support.html#enable-windows-support).

Windows worker nodes requires additional cluster role (eks:kube-proxy-windows). If you are adding windows workers to existing cluster, you should apply config-map-aws-auth again.

#### Example configuration

Amazon EKS clusters must contain one or more Linux worker nodes to run core system pods that only run on Linux, such as coredns and the VPC resource controller.

1. Build AWS EKS cluster with the next workers configuration (default Linux):

```
worker_groups = [
    {
      name                          = "worker-group-linux"
      instance_type                 = "m5.large"
      platform                      = "linux"
      asg_desired_capacity          = 2
    },
  ]
```

2. Apply commands from https://docs.aws.amazon.com/eks/latest/userguide/windows-support.html#enable-windows-support (use tab with name `Windows`)

3. Add one more worker group for Windows with required field `platform = "windows"` and update your cluster. Worker group example:

```
worker_groups = [
    {
      name                          = "worker-group-linux"
      instance_type                 = "m5.large"
      platform                      = "linux"
      asg_desired_capacity          = 2
    },
    {
      name                          = "worker-group-windows"
      instance_type                 = "m5.large"
      platform                      = "windows"
      asg_desired_capacity          = 1
    },
  ]
```

4. With `kubectl get nodes` you can see cluster with mixed (Linux/Windows) nodes support.

## Worker nodes with labels do not join a 1.16+ cluster

Kubelet restricts the allowed list of labels in the `kubernetes.io` namespace that can be applied to nodes starting in 1.16.

Older configurations used labels like `kubernetes.io/lifecycle=spot` and this is no longer allowed. Use `node.kubernetes.io/lifecycle=spot` instead.

Reference the `--node-labels` argument for your version of Kubenetes for the allowed prefixes. [Documentation for 1.16](https://v1-16.docs.kubernetes.io/docs/reference/command-line-tools-reference/kubelet/)

## What is the difference between `node_groups` and `worker_groups`?

`node_groups` are [AWS-managed node groups](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html) (configures "Node Groups" that you can find on the EKS dashboard). This system is supposed to ease some of the lifecycle around upgrading nodes. Although they do not do this automatically and you still need to manually trigger the updates.

`worker_groups` are [self-managed nodes](https://docs.aws.amazon.com/eks/latest/userguide/worker.html) (provisions a typical "Autoscaling group" on EC2). It gives you full control over nodes in the cluster like using custom AMI for the nodes. As AWS says, "with worker groups the customer controls the data plane & AWS controls the control plane".

Both can be used together in the same cluster.

## I'm using both AWS-Managed node groups and Self-Managed worker groups and pods scheduled on a AWS Managed node groups are unable resolve DNS (even communication between pods)

This happen because Core DNS can be scheduled on Self-Managed worker groups and by default, the terraform module doesn't create security group rules to ensure communication between pods schedulled on Self-Managed worker group and AWS-Managed node groups.

You can set `var.worker_create_cluster_primary_security_group_rules` to `true` to create required rules.
