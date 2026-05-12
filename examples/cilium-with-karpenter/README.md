# Cilium + Karpenter Example

Configuration in this directory creates an AWS EKS cluster with [Cilium](https://cilium.io/) as the CNI and [Karpenter](https://karpenter.sh/) for node provisioning.

## Solving the CNI Bootstrap (Chicken-and-Egg) Problem

EKS nodes will not reach `Ready` state until a CNI plugin is present on the node. Normally, `vpc-cni` handles this automatically. When replacing it with Cilium, a bootstrap ordering problem arises:

- Cilium must be installed **before** nodes join, so nodes have a CNI binary on startup
- But Helm requires a reachable API server with schedulable nodes to deploy

This example solves it with three mechanisms working together:

1. **Cilium is installed before any nodes join** — `helm_release.cilium` depends only on the EKS control plane (`module.eks`), not on any node group. With `wait = false`, Terraform does not block waiting for Cilium pods to be Running (there are no nodes yet to schedule them on).

2. **Nodes are tainted at join time** — the managed node group applies the `node.cilium.io/agent-not-ready:NoExecute` taint via the launch template. This prevents any workload pods from being scheduled on a node until the Cilium agent DaemonSet pod is Running and removes the taint itself.

3. **`nodeInit` writes the bootstrap marker** — Cilium's `nodeInit` component runs as an init container and writes `/tmp/cilium-bootstrap-time` to the node filesystem before the kubelet fully initializes, ensuring the CNI binary and config are in place before the node announces itself to the API server.

The result: nodes join, find Cilium already registered in the cluster, become `Ready`, and Cilium removes the taint — all without manual intervention.

## Cilium Configuration

Cilium is configured in **ENI native routing mode** (`ipam.mode: eni`), which gives each pod a real AWS ENI IP address — no overlay, no tunneling. This mode requires the Cilium IAM policy attached to node instance roles.

Additional features enabled in this example:
- `kubeProxyReplacement: true` — Cilium replaces kube-proxy entirely using eBPF
- Hubble observability with UI, relay, and metrics
- Maglev load balancing
- AWS prefix delegation for higher pod density

## Usage

```bash
terraform init
terraform plan
terraform apply --auto-approve
```

Once the cluster is up:

```bash
# Update kubeconfig
aws eks --region us-east-1 update-kubeconfig --name ex-karpenter-cilium

# Verify Cilium is healthy
kubectl -n kube-system exec ds/cilium -- cilium status

# Deploy Karpenter NodeClass and NodePool
kubectl apply -f karpenter.yaml

# Deploy a test workload for Karpenter to provision nodes for
kubectl apply -f inflate.yaml

# Watch Karpenter logs
kubectl logs -f -n kube-system -l app.kubernetes.io/name=karpenter -c controller
```

Verify Cilium is the active CNI and nodes are healthy:

```bash
kubectl get nodes -L karpenter.sh/registered
kubectl get pods -n kube-system -l k8s-app=cilium
```

Expected output — Cilium agent Running on every node, no `aws-node` pods:

```text
NAME                                       READY   STATUS    NODE
cilium-xxxxx                               1/1     Running   ip-10-0-x-x...
cilium-xxxxx                               1/1     Running   ip-10-0-x-x...
cilium-operator-xxxxx                      1/1     Running   ip-10-0-x-x...
hubble-relay-xxxxx                         1/1     Running   ip-10-0-x-x...
```

### Tear Down & Clean-Up

Remove Karpenter-provisioned nodes before destroying with Terraform:

```bash
kubectl delete deployment inflate
# Wait for Karpenter to deprovision nodes
kubectl get nodes --watch

terraform destroy --auto-approve
```

Note that this example may create resources which cost money. Run `terraform destroy` when you no longer need them.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->