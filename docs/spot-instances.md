# Using spot instances

Spot instances usually cost around 30-60% less than an on-demand instance. So using them for your EKS workloads can save a lot of money but requires some special considerations as they will be terminated with only 2 minutes warning.

You need to install a daemonset to catch the 2 minute warning before termination. This will ensure the node is gracefully drained before termination. You can install the [k8s-spot-termination-handler](https://github.com/kube-aws/kube-spot-termination-notice-handler) for this. There's a [Helm chart](https://github.com/helm/charts/tree/master/stable/k8s-spot-termination-handler):

```
helm install stable/k8s-spot-termination-handler --namespace kube-system
```

In the following examples at least 1 worker group that uses on-demand instances is included. This worker group has an added node label that can be used in scheduling. This could be used for any workload but is important for the [cluster-autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler) as it might be end up unscheduled when spot instances are terminated. You can add this to the values of the [cluster-autoscaler helm chart](https://github.com/helm/charts/tree/master/stable/cluster-autoscaler):

```yaml
nodeSelector:
  spot: "false"
extraArgs:
  expander: "most-pods"
```

Notes:

- The `spot_price` is set to the on-demand price so that the spot instances will run as long as they are the cheaper.
- It's best to have a broad range of instance types to ensure there's always some instances to run when prices fluctuate.
- If the instance size of the spot worker groups is larger then the cluster-autoscaler will prefer it due to its [expander](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#what-are-expanders) being set to `most-pods`
- Using an [AWS Spot Fleet](https://www.terraform.io/docs/providers/aws/r/spot_fleet_request.html) is the best option but is not supported by this module.

## Using Launch Configuration

Example Terraform worker group configuration that use an ASG with launch configuration:

```hcl
worker_group_count = 3

worker_groups = [
  {
    name                = "on-demand-1"
    instance_type       = "m4.xlarge"
    asg_max_size        = 10
    autoscaling_enabled = true
    kubelet_extra_args  = "--node-labels=spot=false"
    suspended_processes = "AZRebalance"
  },
  {
    name                = "spot-1"
    spot_price          = "0.39"
    instance_type       = "c4.2xlarge"
    asg_max_size        = 20
    autoscaling_enabled = true
    kubelet_extra_args  = "--node-labels=spot=true"
    suspended_processes = "AZRebalance"
  },
  {
    name                = "spot-2"
    spot_price          = "0.40"
    instance_type       = "m4.2xlarge"
    asg_max_size        = 20
    autoscaling_enabled = true
    kubelet_extra_args  = "--node-labels=spot=true"
    suspended_processes = "AZRebalance"
  }
]
```

## Using Launch Templates

Launch Template support is a recent addition to both AWS and this module. It might not be as tried and tested.

Example Terraform worker group configuration that use an ASG with a launch template:

```hcl

worker_group_count = 1

worker_groups = [
  {
    name                = "on-demand-1"
    instance_type       = "m4.xlarge"
    asg_max_size        = 10
    autoscaling_enabled = true
    kubelet_extra_args  = "--node-labels=spot=false"
    suspended_processes = "AZRebalance"
  }
]

worker_group_launch_template_count = 1

worker_groups_launch_template = [
  {
    name                = "lt-1"
    instance_type       = "m5.large"
    kubelet_extra_args  = "--node-labels=spot=true"
  }
]
```

## Important issues

- https://github.com/terraform-aws-modules/terraform-aws-eks/issues/360
- https://github.com/terraform-providers/terraform-provider-aws/issues/8475
- https://github.com/kubernetes/autoscaler/issues/1133
