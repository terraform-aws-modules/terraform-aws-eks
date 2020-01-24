# IAM Roles for Service Accounts

This example shows how to create an IAM role to be used for a Kubernetes `ServiceAccount`. It will create a policy and role to be used by the [cluster-autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler) using the [public Helm chart](https://github.com/helm/charts/tree/master/stable/cluster-autoscaler).

The AWS documentation for IRSA is here: https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html

## Setup

Run Terraform:

```
terraform init
terraform apply
```

Set kubectl context to the new cluster: `export KUBECONFIG=kubeconfig_test-eks-irsa`

Check that there is a node that is `Ready`:

```
$ kubectl get nodes
NAME                                       STATUS   ROLES    AGE     VERSION
ip-10-0-2-190.us-west-2.compute.internal   Ready    <none>   6m39s   v1.14.8-eks-b8860f
```

Install Helm:

```
kubectl -n kube-system create serviceaccount tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account=tiller
```

Replace `<ACCOUNT ID>` with your AWS account ID in `cluster-autoscaler-chart-values.yaml`. There is output from terraform for this.

Install the chart using the provided values file:

```
helm install --name cluster-autoscaler --namespace kube-system stable/cluster-autoscaler --values=cluster-autoscaler-chart-values.yaml
```

## Verify

Ensure the cluster-autoscaler pod is running:

```
$ kubectl --namespace=kube-system get pods -l "app.kubernetes.io/name=aws-cluster-autoscaler"
NAME                                                        READY   STATUS    RESTARTS   AGE
cluster-autoscaler-aws-cluster-autoscaler-5545d4b97-9ztpm   1/1     Running   0          3m
```

Observe the `AWS_*` environment variables that were added to the pod automatically by EKS:

```
kubectl --namespace=kube-system get pods -l "app.kubernetes.io/name=aws-cluster-autoscaler" -o yaml | grep -A3 AWS_ROLE_ARN

- name: AWS_ROLE_ARN
  value: arn:aws:iam::xxxxxxxxx:role/cluster-autoscaler
- name: AWS_WEB_IDENTITY_TOKEN_FILE
  value: /var/run/secrets/eks.amazonaws.com/serviceaccount/token
```

Verify it is working by checking the logs, you should see that it has discovered the autoscaling group successfully:

```
kubectl --namespace=kube-system logs -l "app.kubernetes.io/name=aws-cluster-autoscaler"

I0124 11:27:12.133334       1 static_autoscaler.go:138] Starting main loop
I0124 11:27:12.256817       1 auto_scaling_groups.go:354] Regenerating instance to ASG map for ASGs: [test-eks-irsa-worker-group-120200124095239818200000013]
```
