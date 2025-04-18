# Karpenter Example

Configuration in this directory creates an AWS EKS cluster with [Karpenter](https://karpenter.sh/) provisioned for managing compute resource scaling. In the example provided, Karpenter is provisioned on top of an EKS Managed Node Group.

## Usage

To provision the provided configurations you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply --auto-approve
```

Once the cluster is up and running, you can check that Karpenter is functioning as intended with the following command:

```bash
# First, make sure you have updated your local kubeconfig
aws eks --region eu-west-1 update-kubeconfig --name ex-karpenter

# Second, deploy the Karpenter NodeClass/NodePool
kubectl apply -f karpenter.yaml

# Second, deploy the example deployment
kubectl apply -f inflate.yaml

# You can watch Karpenter's controller logs with
kubectl logs -f -n kube-system -l app.kubernetes.io/name=karpenter -c controller
```

Validate if the Amazon EKS Addons Pods are running in the Managed Node Group and the `inflate` application Pods are running on Karpenter provisioned Nodes.

```bash
kubectl get nodes -L karpenter.sh/registered
```

```text
NAME                                        STATUS   ROLES    AGE   VERSION               REGISTERED
ip-10-0-13-51.eu-west-1.compute.internal    Ready    <none>   29s   v1.31.1-eks-1b3e656   true
ip-10-0-41-242.eu-west-1.compute.internal   Ready    <none>   35m   v1.31.1-eks-1b3e656
ip-10-0-8-151.eu-west-1.compute.internal    Ready    <none>   35m   v1.31.1-eks-1b3e656
```

```sh
kubectl get pods -A -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName
```

```text
NAME                           NODE
inflate-67cd5bb766-hvqfn       ip-10-0-13-51.eu-west-1.compute.internal
inflate-67cd5bb766-jnsdp       ip-10-0-13-51.eu-west-1.compute.internal
inflate-67cd5bb766-k4gwf       ip-10-0-41-242.eu-west-1.compute.internal
inflate-67cd5bb766-m49f6       ip-10-0-13-51.eu-west-1.compute.internal
inflate-67cd5bb766-pgzx9       ip-10-0-8-151.eu-west-1.compute.internal
aws-node-58m4v                 ip-10-0-3-57.eu-west-1.compute.internal
aws-node-pj2gc                 ip-10-0-8-151.eu-west-1.compute.internal
aws-node-thffj                 ip-10-0-41-242.eu-west-1.compute.internal
aws-node-vh66d                 ip-10-0-13-51.eu-west-1.compute.internal
coredns-844dbb9f6f-9g9lg       ip-10-0-41-242.eu-west-1.compute.internal
coredns-844dbb9f6f-fmzfq       ip-10-0-41-242.eu-west-1.compute.internal
eks-pod-identity-agent-jr2ns   ip-10-0-8-151.eu-west-1.compute.internal
eks-pod-identity-agent-mpjkq   ip-10-0-13-51.eu-west-1.compute.internal
eks-pod-identity-agent-q4tjc   ip-10-0-3-57.eu-west-1.compute.internal
eks-pod-identity-agent-zzfdj   ip-10-0-41-242.eu-west-1.compute.internal
karpenter-5b8965dc9b-rx9bx     ip-10-0-8-151.eu-west-1.compute.internal
karpenter-5b8965dc9b-xrfnx     ip-10-0-41-242.eu-west-1.compute.internal
kube-proxy-2xf42               ip-10-0-41-242.eu-west-1.compute.internal
kube-proxy-kbfc8               ip-10-0-8-151.eu-west-1.compute.internal
kube-proxy-kt8zn               ip-10-0-13-51.eu-west-1.compute.internal
kube-proxy-sl6bz               ip-10-0-3-57.eu-west-1.compute.internal
```

### Tear Down & Clean-Up

Because Karpenter manages the state of node resources outside of Terraform, Karpenter created resources will need to be de-provisioned first before removing the remaining resources with Terraform.

1. Remove the example deployment created above and any nodes created by Karpenter

```bash
kubectl delete deployment inflate
```

2. Remove the resources created by Terraform

```bash
terraform destroy --auto-approve
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.95 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.95 |
| <a name="provider_aws.virginia"></a> [aws.virginia](#provider\_aws.virginia) | >= 5.95 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.7 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | ../.. | n/a |
| <a name="module_karpenter"></a> [karpenter](#module\_karpenter) | ../../modules/karpenter | n/a |
| <a name="module_karpenter_disabled"></a> [karpenter\_disabled](#module\_karpenter\_disabled) | ../../modules/karpenter | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 5.0 |

## Resources

| Name | Type |
|------|------|
| [helm_release.karpenter](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_ecrpublic_authorization_token.token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecrpublic_authorization_token) | data source |

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->
