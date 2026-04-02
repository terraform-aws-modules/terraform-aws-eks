# Access Entries

Cluster access entries provide IAM-based authentication and authorization for your EKS cluster. They are the successor to the `aws-auth` ConfigMap, offering a more manageable API-driven model.

## How it works

EKS automatically creates access entries for managed node group and Fargate profile IAM roles. The module automatically creates entries for self-managed node groups and Karpenter. The module uses `authentication_mode = "API_AND_CONFIG_MAP"` by default for backward compatibility — this allows both access entries and existing `aws-auth` ConfigMap entries to work simultaneously. Once you have migrated all access to entries, you can switch to `authentication_mode = "API"` to disable the ConfigMap entirely. See the [v20.x migration guide](../upgrade/UPGRADE-20.0.md) for details on migrating from `aws-auth`.

## Cluster creator admin

The `enable_cluster_creator_admin_permissions = true` variable adds the current caller identity as a cluster administrator via an access entry.

This is distinct from the `bootstrap_cluster_creator_admin_permissions` setting that EKS accepts at cluster creation time. The bootstrap setting is a one-time operation that cannot be modified after the cluster is created. This module hardcodes it to `false` and achieves the same result through an access entry instead, which can be enabled or disabled at any time without recreating the cluster.

## Configuring access entries

Use the `access_entries` variable to grant IAM principals access to your cluster:

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  # Truncated for brevity ...

  access_entries = {
    # One access entry with a policy associated
    example = {
      principal_arn = "arn:aws:iam::<ACCOUNT_ID>:role/something"

      policy_associations = {
        example = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            namespaces = ["default"]
            type       = "namespace"
          }
        }
      }
    }
  }
}
```

## Pre-existing clusters

On clusters that were created prior to cluster access management (CAM) support, there will be an existing access entry for the cluster creator. This entry was previously not visible when using the `aws-auth` ConfigMap, but will become visible once access entry mode is enabled. No action is required — this is expected behavior.

## Example

Access entries are configured in all of the [examples](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples) on GitHub via `enable_cluster_creator_admin_permissions`.
