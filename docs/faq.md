# Frequently Asked Questions

## How do I customize X on the worker group's settings?

All the options that can be customized for worker groups are listed in [local.tf](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/local.tf) under `workers_group_defaults_defaults`.

Please open Issues or PRs if you think something is missing.

## Why are nodes not being registered?

### Networking

Often caused by a networking or endpoint configuration issue.

At least one of the cluster public or private endpoints must be enabled to access the cluster to work. If you require a public endpoint, setting up both (public and private) and restricting the public endpoint via setting `cluster_endpoint_public_access_cidrs` is recommended. More about communication with an endpoint is available [here](https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html).

Nodes need to be able to contact the EKS cluster endpoint. By default, the module only creates a public endpoint. To access endpoint, the nodes need outgoing internet access:

- Nodes in private subnets: via a NAT gateway or instance. It will need adding along with appropriate routing rules.
- Nodes in public subnets: assign public IPs to nodes. Set `public_ip = true` in the `worker_groups` list on this module.

> Important:
> If you apply only the public endpoint and setup `cluster_endpoint_public_access_cidrs` to restrict access, remember that EKS nodes also use the public endpoint, so you must allow access to the endpoint. If not, then your nodes will not be working correctly.

Cluster private endpoint can also be enabled by setting `cluster_endpoint_private_access = true` on this module. Node calls to the endpoint stay within the VPC.

When the private endpoint is enabled ensure that VPC DNS resolution and hostnames are also enabled:

- If managing the VPC with Terraform: set `enable_dns_hostnames = true` and `enable_dns_support = true` on the `aws_vpc` resource. The [`terraform-aws-module/vpc/aws`](https://github.com/terraform-aws-modules/terraform-aws-vpc/) community module also has these variables.
- Otherwise refer to the [AWS VPC docs](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-dns.html#vpc-dns-updating) and [AWS EKS Cluster Endpoint Access docs](https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html) for more information.

Nodes need to be able to connect to other AWS services plus pull down container images from repos. If for some reason you cannot enable public internet access for nodes you can add VPC endpoints to the relevant services: EC2 API, ECR API, ECR DKR and S3.

## How can I work with the cluster if I disable the public endpoint?

You have to interact with the cluster from within the VPC that it's associated with, from an instance that's allowed access via the cluster's security group.

Creating a new cluster with the public endpoint disabled is harder to achieve. You will either want to pass in a pre-configured cluster security group or apply the `aws-auth` configmap in a separate action.

## How can I stop Terraform from removing the EKS tags from my VPC and subnets?

You need to add the tags to the VPC and subnets yourself. See the [basic example](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/basic).

An alternative is to use the aws provider's [`ignore_tags` variable](https://www.terraform.io/docs/providers/aws/#ignore_tags-configuration-block). However this can also cause terraform to display a perpetual difference.

## Why does changing the node or worker group's desired count not do anything?

The module is configured to ignore this value. Unfortunately, Terraform does not support variables within the `lifecycle` block.

The setting is ignored to allow the cluster autoscaler to work correctly so that `terraform apply` does not accidentally remove running workers.

You can change the desired count via the CLI or console if you're not using the cluster autoscaler.

If you are not using autoscaling and want to control the number of nodes via terraform, set the `min_capacity` and `max_capacity` for node groups or `asg_min_size` and `asg_max_size` for worker groups. Before changing those values, you must satisfy AWS `desired` capacity constraints (which must be between new min/max values).

When you scale down AWS will remove a random instance, so you will have to weigh the risks here.

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

You can also use a 3rd party tool like Gruntwork's kubergrunt. See the [`eks deploy`](https://github.com/gruntwork-io/kubergrunt#deploy) subcommand.

## How can I use Windows workers?

To enable Windows support for your EKS cluster, you should apply some configs manually. See the [Enabling Windows Support (Windows/MacOS/Linux)](https://docs.aws.amazon.com/eks/latest/userguide/windows-support.html#enable-windows-support).

Windows worker nodes requires additional cluster role (eks:kube-proxy-windows). If you are adding windows workers to existing cluster, you should apply config-map-aws-auth again.

#### Example configuration

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

## Worker nodes with labels do not join a 1.16+ cluster

Kubelet restricts the allowed list of labels in the `kubernetes.io` namespace that can be applied to nodes starting in 1.16.

Older configurations used labels like `kubernetes.io/lifecycle=spot` and this is no longer allowed. Use `node.kubernetes.io/lifecycle=spot` instead.

Reference the `--node-labels` argument for your version of Kubenetes for the allowed prefixes. [Documentation for 1.16](https://v1-16.docs.kubernetes.io/docs/reference/command-line-tools-reference/kubelet/)

## I'm using both AWS-Managed node groups and Self-Managed worker groups and pods scheduled on a AWS Managed node groups are unable resolve DNS (even communication between pods)

This happen because Core DNS can be scheduled on Self-Managed worker groups and by default, the terraform module doesn't create security group rules to ensure communication between pods schedulled on Self-Managed worker group and AWS-Managed node groups.

You can set `var.worker_create_cluster_primary_security_group_rules` to `true` to create required rules.

## Dedicated control plane subnets

[AWS recommends](https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html) to create dedicated subnets for EKS created network interfaces (control plane). The module fully supports this approach. To set up this, you must configure the module by adding additional `subnets` into workers default specification `workers_group_defaults` map or directly `subnets` definition in worker definition.

```hcl
module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_version = "1.21"
  cluster_name    = "my-cluster"
  vpc_id          = "vpc-1234556abcdef"
  subnet_ids      = ["subnet-abcde123", "subnet-abcde456", "subnet-abcde789"]

  workers_group_defaults = {
    subnet_ids = ["subnet-xyz123", "subnet-xyz456", "subnet-xyz789"]
  }

  worker_groups = {
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
}
```
