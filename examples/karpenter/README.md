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

# Second, scale the example deployment
kubectl scale deployment inflate --replicas 5

# You can watch Karpenter's controller logs with
kubectl logs -f -n kube-system -l app.kubernetes.io/name=karpenter -c controller
```

Validate if the Amazon EKS Addons Pods are running in the Managed Node Group and the `inflate` application Pods are running on Karpenter provisioned Nodes.

```bash
kubectl get nodes -L karpenter.sh/registered
```

```text
NAME                                        STATUS   ROLES    AGE    VERSION               REGISTERED
ip-10-0-16-155.eu-west-1.compute.internal   Ready    <none>   100s   v1.29.3-eks-ae9a62a   true
ip-10-0-3-23.eu-west-1.compute.internal     Ready    <none>   6m1s   v1.29.3-eks-ae9a62a
ip-10-0-41-2.eu-west-1.compute.internal     Ready    <none>   6m3s   v1.29.3-eks-ae9a62a
```

```sh
kubectl get pods -A -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName
```

```text
NAME                           NODE
inflate-75d744d4c6-nqwz8       ip-10-0-16-155.eu-west-1.compute.internal
inflate-75d744d4c6-nrqnn       ip-10-0-16-155.eu-west-1.compute.internal
inflate-75d744d4c6-sp4dx       ip-10-0-16-155.eu-west-1.compute.internal
inflate-75d744d4c6-xqzd9       ip-10-0-16-155.eu-west-1.compute.internal
inflate-75d744d4c6-xr6p5       ip-10-0-16-155.eu-west-1.compute.internal
aws-node-mnn7r                 ip-10-0-3-23.eu-west-1.compute.internal
aws-node-rkmvm                 ip-10-0-16-155.eu-west-1.compute.internal
aws-node-s4slh                 ip-10-0-41-2.eu-west-1.compute.internal
coredns-68bd859788-7rcfq       ip-10-0-3-23.eu-west-1.compute.internal
coredns-68bd859788-l78hw       ip-10-0-41-2.eu-west-1.compute.internal
eks-pod-identity-agent-gbx8l   ip-10-0-41-2.eu-west-1.compute.internal
eks-pod-identity-agent-s7vt7   ip-10-0-16-155.eu-west-1.compute.internal
eks-pod-identity-agent-xwgqw   ip-10-0-3-23.eu-west-1.compute.internal
karpenter-79f59bdfdc-9q5ff     ip-10-0-41-2.eu-west-1.compute.internal
karpenter-79f59bdfdc-cxvhr     ip-10-0-3-23.eu-west-1.compute.internal
kube-proxy-7crbl               ip-10-0-41-2.eu-west-1.compute.internal
kube-proxy-jtzds               ip-10-0-16-155.eu-west-1.compute.internal
kube-proxy-sm42c               ip-10-0-3-23.eu-west-1.compute.internal
```

### Tear Down & Clean-Up

Because Karpenter manages the state of node resources outside of Terraform, Karpenter created resources will need to be de-provisioned first before removing the remaining resources with Terraform.

1. Remove the example deployment created above and any nodes created by Karpenter

```bash
kubectl delete deployment inflate
kubectl delete node -l karpenter.sh/provisioner-name=default
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
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.79 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.7 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.79 |
| <a name="provider_aws.virginia"></a> [aws.virginia](#provider\_aws.virginia) | >= 5.79 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.7 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | >= 2.0 |

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
| [kubectl_manifest.karpenter_example_deployment](https://registry.terraform.io/providers/alekc/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.karpenter_node_class](https://registry.terraform.io/providers/alekc/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.karpenter_node_pool](https://registry.terraform.io/providers/alekc/kubectl/latest/docs/resources/manifest) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_ecrpublic_authorization_token.token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecrpublic_authorization_token) | data source |

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->
