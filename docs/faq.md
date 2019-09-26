# Frequently Asked Questions

## How do I customize X on the worker group's settings?

All the options that can be customized for worker groups are listed in [local.tf](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/local.tf) under `workers_group_defaults_defaults`.

Please open Issues or PRs if you think something is missing.

## Why are nodes not being registered?

### Networking

Often caused by a networking or endpoint configuration issue.

At least one of the cluster public or private endpoints must be enabled in order for access to the cluster to work.

Your nodes need to be able to contact the EKS cluster endpoint. By default the module only creates a public endpoint. You should also enable the private endpoint by setting `cluster_endpoint_private_access = true` on this module.

If you have the private endpoint enabled ensure that you also have VPC DNS enabled. Set `enable_dns_hostnames = true` on your `aws_vpc` resource or the `terraform-aws-module/vpc/aws` community module.

Nodes need to be able to connect to AWS services plus pull down container images from repos. You can either:
- enable endpoints to the relevant services, if only using ECR repos and for some reason cannot enable public outbound: EC2 API, ECR API, ECR DKR and S3
- enable outbound public internet access:
  - Private subnets: via a NAT gateway or instance
  - Public subnets: assign public IPs to nodes

### `aws-auth` ConfigMap not present

The module configures the `aws-auth` ConfigMap. This is used by the cluster to grant IAM users RBAC permissions in the cluster. Sometimes the map fails to apply correctly, especially if terraform could not access the cluster endpoint during cluster creation.

Confirm that the ConfigMap matches the contents of the generated `config-map-aws-auth_${cluster_name}.yaml` file. You can retrieve the live config by running the following in your terraform folder:
`kubectl --kubeconfig=kubeconfig_* -n kube-system get cm aws-auth -o yaml`

Apply the config with:
`kubectl --kubeconfig=kubeconfig_* apply -f config-map-aws-auth_*.yaml`

## How can I work with the cluster if I disable the public endpoint?

You have to interact with the cluster from within the VPC that it's associated with, from an instance that's allowed access via the cluster's security group.

Creating a new cluster with the public endpoint disabled is harder to achieve. You will either want to pass in a pre-configured cluster security group or apply the `aws-auth` configmap in a separate action.

## How can I stop Terraform from removing the EKS tags from my VPC and subnets?

You need to add the tags to the VPC and subnets yourself. See the [basic example](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/basic).

## How do I safely remove old worker groups?

You've added new worker groups. Deleting worker groups from earlier in the list causes Terraform to want to recreate all worker groups. This is a limitation with how Terraform works and the module using `count` to create the ASGs and other resources.

The safest and easiest option is to set `asg_min_size` and `asg_max_size` to 0 on the worker groups to "remove".

## Why does changing the worker group's desired count not do anything?

The module is configured to ignore this value. Unfortunately Terraform does not support variables within the `lifecycle` block.

The setting is ignored to allow the cluster autoscaler to work correctly and so that terraform applys do not accidentally remove running workers.

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
