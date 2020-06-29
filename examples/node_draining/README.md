## EKS node drainer with terraform

Changing the AMI version of worker group or changing the kubernetes version will cause recreation of the nodes.
By default the nodes won't drain themselves before they got removed. So we have some downtime.
Node groups are a good alternative but not sufficient for us as we require to [set custom security groups](https://github.com/aws/containers-roadmap/issues/609).

We are adding a termination lifecycle to run kubectl drain before we shutdown nodes.

The serverless python drain function is from https://github.com/aws-samples/amazon-k8s-node-drainer
and translated to terraform. 

**STEPS**
* build python zip https://docs.aws.amazon.com/lambda/latest/dg/python-package.html
```
# script need to be adapted to your system (python 3 version)
# you will find better solution to deploy serverless function but it serves the example purpose
./build.sh
```
* apply
```
terraform init
terraform apply
# will fail once because the subnets are not yet in the data filter
# solving subnet dependencies needs to happen on other layer but not important for this example
terraform apply
```

### Testing seamless worker upgrade

* update kubeconfig and deploy example grafana with pod disruption budget
```
aws eks update-kubeconfig --name $CLUSTER_NAME --alias drainer

# optional install latest cni plugin to ensure we can destroy cluster clean
# https://github.com/terraform-aws-modules/terraform-aws-eks/issues/285
# https://docs.aws.amazon.com/eks/latest/userguide/cni-upgrades.html
kubectl apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/release-1.6/config/v1.6/aws-k8s-cni.yaml

# install metrics server to watch node resource allocation
helm upgrade --install grafana stable/grafana --set podDisruptionBudget.minAvailable=1 --set replicas=2 --set persistence.enabled=true --set persistence.type=statefulset

# check that volumes are allocated in different regions
kubectl get pv -o custom-columns=PVC-NAME:.spec.claimRef.name,REGION:.metadata.labels

kubectl get pods
```
* change version number of the ami version of nodes to see node drainer in action
* you can also verify the output in cloudwatch of the lambda function
```
terraform apply -var ami_version=v20200609
```
* now the nodes will not get deleted before they have been drained completely
* the drainer will respect pod disruption budget in our example that's one running grafana replica

### Drawbacks
* terminating instances will just continue after the lifecycle timeout is reaching regardless of failure during draining 

### Info
* this example shows an example for a single AZ workergroup which is necessary if you are using EBS volumes with Statefulsets.
    * not really necessary for node draining remove if you want
* the drainer works also in combination with cluster-autoscaler
    * how to use cluster-autoscaler is already well documented in [examples/irsa](../irsa)
    * a full example with no guarantees can we found at [eks-node-drainer](https://github.com/karlderkaefer/eks-node-drainer)
