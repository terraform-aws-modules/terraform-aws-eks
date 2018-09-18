# Autoscaling

Autoscaling of worker nodes can be easily enabled by setting the `autoscaling_enabled` variable to `true` for a worker group in the `worker_groups` map.
This will add the required tags to the autoscaling group for the [cluster-autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler).
One should also set `protect_from_scale_in` to `true` for such worker groups, to ensure that cluster-autoscaler is solely responsible for scaling events.

You will also need to install the cluster-autoscaler into your cluster. The easiest way to do this is with [helm](https://helm.sh/).

The [helm chart](https://github.com/helm/charts/tree/master/stable/cluster-autoscaler) for the cluster-autoscaler requires some specific settings to work in an EKS cluster. These settings are supplied via YAML values file when installing the helm chart. Here is an example values file:

```yaml
rbac:
  create: true

sslCertPath: /etc/ssl/certs/ca-bundle.crt

autoDiscovery:
  clusterName: YOUR_CLUSTER_NAME
  enabled: true
```

To install the chart, simply run helm with the `--values` option:

```
helm install stable/cluster-autoscaler --values=path/to/your/values-file.yaml
```
