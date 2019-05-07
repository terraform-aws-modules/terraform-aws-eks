# Using spot instances

Spot instances usually cost around 30-70% less than an on-demand instance. So using them for your EKS workloads can save a lot of money but requires some special considerations as they could be terminated with only 2 minutes warning.

You need to install a daemonset to catch the 2 minute warning before termination. This will ensure the node is gracefully drained before termination. You can install the [k8s-spot-termination-handler](https://github.com/kube-aws/kube-spot-termination-notice-handler) for this. There's a [Helm chart](https://github.com/helm/charts/tree/master/stable/k8s-spot-termination-handler):

```
helm install stable/k8s-spot-termination-handler --namespace kube-system
```

In the following examples at least 1 worker group that uses on-demand instances is included. This worker group has an added node label that can be used in scheduling. This could be used to schedule any workload not suitable for spot instances but is important for the [cluster-autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler) as it might be end up unscheduled when spot instances are terminated. You can add this to the values of the [cluster-autoscaler helm chart](https://github.com/helm/charts/tree/master/stable/cluster-autoscaler):

```yaml
nodeSelector:
  kubernetes.io/lifecycle: spot
```

Notes:

- The `spot_price` is set to the on-demand price so that the spot instances will run as long as they are the cheaper.
- It's best to have a broad range of instance types to ensure there's always some instances to run when prices fluctuate.
- There is an AWS blog article about this [here](https://aws.amazon.com/blogs/compute/run-your-kubernetes-workloads-on-amazon-ec2-spot-instances-with-amazon-eks/).
- Consider using [k8s-spot-rescheduler](https://github.com/pusher/k8s-spot-rescheduler) to move pods from on-demand to spot instances.

## Using Launch Configuration

Example worker group configuration that uses an ASG with launch configuration for each worker group:

```hcl
  worker_group_count = 3

  worker_groups = [
    {
      name                = "on-demand-1"
      instance_type       = "m4.xlarge"
      asg_max_size        = 1
      autoscaling_enabled = true
      kubelet_extra_args  = "--node-labels=kubernetes.io/lifecycle=normal"
      suspended_processes = "AZRebalance"
    },
    {
      name                = "spot-1"
      spot_price          = "0.199"
      instance_type       = "c4.xlarge"
      asg_max_size        = 20
      autoscaling_enabled = true
      kubelet_extra_args  = "--node-labels=kubernetes.io/lifecycle=spot"
      suspended_processes = "AZRebalance"
    },
    {
      name                = "spot-2"
      spot_price          = "0.20"
      instance_type       = "m4.xlarge"
      asg_max_size        = 20
      autoscaling_enabled = true
      kubelet_extra_args  = "--node-labels=kubernetes.io/lifecycle=spot"
      suspended_processes = "AZRebalance"
    }
  ]
```

## Using Launch Templates

Launch Template support is a recent addition to both AWS and this module. It might not be as tried and tested but it's more suitable for spot instances as it allowed multiple instance types in the same worker group:

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

  worker_group_launch_template_mixed_count = 1

  worker_group_launch_template_mixed = [
    {
      name                     = "spot-1"
      override_instance_type_1 = "m5.large"
      override_instance_type_2 = "c5.large"
      override_instance_type_3 = "t3.large"
      override_instance_type_4 = "r5.large"
      spot_instance_pools      = 3
      asg_max_size             = 5
      asg_desired_size         = 5
      autoscaling_enabled      = true
      kubelet_extra_args       = "--node-labels=kubernetes.io/lifecycle=spot"
    }
  ]
```

## Important issues

- https://github.com/terraform-aws-modules/terraform-aws-eks/issues/360
- https://github.com/terraform-providers/terraform-provider-aws/issues/8475
- https://github.com/kubernetes/autoscaler/issues/1133
