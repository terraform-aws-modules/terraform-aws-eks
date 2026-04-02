# Cluster Add-ons

EKS add-ons are operational software that provides key cluster functionality like networking, DNS resolution, and identity management. They are installed and managed through the EKS API rather than manually via Helm or kubectl. The module supports configuring add-ons declaratively via the `addons` variable.

!!! warning

    If you are using [EKS Auto Mode](auto-mode.md), many common add-ons (CoreDNS, VPC CNI, kube-proxy, EBS CSI driver, AWS Load Balancer Controller, Karpenter) are automatically managed as built-in components. Do not install these as separate add-ons on Auto Mode clusters — doing so will cause conflicts. The add-on configuration on this page applies to standard EKS clusters.

## Common add-ons

The most commonly used add-ons are:

- CoreDNS — cluster DNS resolution
- kube-proxy — network proxy running on each node
- VPC CNI — pod networking using native VPC IP addresses
- EKS Pod Identity Agent — enables IAM roles for pods

```hcl
addons = {
  coredns                = {}
  eks-pod-identity-agent = {
    before_compute = true
  }
  kube-proxy = {}
  vpc-cni    = {
    before_compute = true
  }
}
```

## Before compute

Setting `before_compute = true` on an add-on instructs the module to install that add-on before any compute resources (node groups) are created. Add-ons like `vpc-cni` and `eks-pod-identity-agent` should be installed before compute resources to ensure nodes can register with the cluster properly. Without `vpc-cni` in place, pods scheduled on new nodes may fail networking setup.

## Discovering available add-ons

To list all available add-ons for a given Kubernetes version:

```bash
aws eks describe-addon-versions --kubernetes-version 1.35
```

To retrieve the configuration schema for a specific add-on version:

```bash
aws eks describe-addon-configuration \
  --addon-name <addon-name> \
  --addon-version <addon-version>
```

The available configuration values vary between add-on versions. Typically more configuration options are added in later versions as EKS enables additional functionality.

## Custom add-on configuration

Add-ons accept custom configuration via the `configuration_values` field as a JSON-encoded string. This is how you tune add-on behavior beyond the defaults.

VPC CNI — enable prefix delegation (assigns /28 prefixes instead of individual IPs, increasing pods-per-node):

```hcl
addons = {
  vpc-cni = {
    before_compute    = true
    configuration_values = jsonencode({
      enableNetworkPolicy = "true"
      env = {
        ENABLE_PREFIX_DELEGATION = "true"
        WARM_PREFIX_TARGET       = "1"
      }
    })
  }
}
```

CoreDNS — adjust replica count and resource limits:

```hcl
addons = {
  coredns = {
    configuration_values = jsonencode({
      replicaCount = 3
      resources = {
        limits = {
          cpu    = "100m"
          memory = "150Mi"
        }
      }
    })
  }
}
```

To discover the full configuration schema for any add-on, use the CLI commands in the [Discovering available add-ons](#discovering-available-add-ons) section above.

## Gotchas

- Add-on versions are tied to Kubernetes versions — each add-on version is compatible with a specific range of Kubernetes versions. Check compatibility before upgrading your cluster, as an incompatible add-on version can cause cluster instability or failed upgrades.

!!! warning "Pod Identity and VPC CNI ordering"

    If your VPC CNI add-on uses Pod Identity for its IAM permissions, the `eks-pod-identity-agent` must be running before `vpc-cni` can authenticate. Both may need `before_compute = true`, but `before_compute` does not control ordering between add-ons — Terraform may create them in parallel. Workarounds:

    1. Two-stage apply — first apply with only `eks-pod-identity-agent`, then add `vpc-cni` in a second apply
    2. Use IRSA instead of Pod Identity for VPC CNI — IRSA uses the OIDC provider and does not have this ordering dependency

    Note: the VPC CNI inherits permissions from the node IAM role by default. This ordering issue only applies if you explicitly configure VPC CNI to use Pod Identity for its IAM permissions.

!!! info "Removing VPC networking permissions from the node IAM role"

    If you want the VPC CNI to use IRSA or Pod Identity instead of the node IAM role for its permissions, the node IAM role must still include the VPC networking managed policy (`AmazonEKS_CNI_Policy`) on initial cluster creation. This is a chicken-and-egg problem: the VPC CNI needs EC2 networking permissions to set up pod networking, but pod networking must be functional before VPC CNI pods can be deployed and assume their IRSA/Pod Identity role.

    Provision the cluster with the VPC networking policy on the node IAM role first. Once the cluster is running and the VPC CNI pods are healthy with IRSA or Pod Identity configured, you can remove the policy from the node IAM role in a subsequent apply.

- `before_compute` is Terraform dependency ordering, not a readiness check — it ensures the add-on API call is made before compute resources are created, but does not wait for the add-on to reach `ACTIVE` status. If nodes launch before an add-on is fully healthy, you may see `NetworkPluginNotReady` errors. Verify add-on status with:

  ```bash
  aws eks describe-addon \
    --cluster-name <cluster> \
    --addon-name vpc-cni \
    --query 'addon.status'
  ```

See the [EKS Cluster Upgrade Best Practices](https://docs.aws.amazon.com/eks/latest/best-practices/cluster-upgrades.html) for guidance on managing add-on versions during upgrades.

## Examples

Add-on configuration is demonstrated in the [EKS Managed Node Group](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/eks-managed-node-group) and [Karpenter](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/karpenter) examples on GitHub.
