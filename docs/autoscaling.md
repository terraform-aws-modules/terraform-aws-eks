# Autoscaling

To enable worker node autoscaling you will need to do a few things:

- Add the [required tags](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler/cloudprovider/aws#auto-discovery-setup) to the worker group
- Install the cluster-autoscaler
- Give the cluster-autoscaler access via an IAM policy

It's probably easiest to follow the example in [examples/irsa](../examples/irsa), this will install the cluster-autoscaler using [Helm](https://helm.sh/) and use IRSA to attach a policy.

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

```
helm install stable/cluster-autoscaler --values=path/to/your/values-file.yaml
```

## Notes

There is a variable `asg_desired_capacity` given in the `local.tf` file, currently it can be used to change the desired worker(s) capacity in the autoscaling group but currently it is being ignored in terraform to reduce the [complexities](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/510#issuecomment-531700442) and the feature of scaling up and down the cluster nodes is being handled by the cluster autoscaler.

The cluster autoscaler major and minor versions must match your cluster. For example if you are running a 1.16 EKS cluster set `image.tag=v1.16.5`. Search through their [releases page](https://github.com/kubernetes/autoscaler/releases) for valid version numbers.
