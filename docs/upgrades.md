# How to handle the terraform-aws-eks module upgrade

## Upgrade module to v17.0.0 for Managed Node Groups

In this release, we now decided to remove random_pet resources in Managed Node Groups (MNG). Those were used to recreate MNG if something changed. But they were causing a lot of issues. To upgrade the module without recreating your MNG, you will need to explicitly reuse their previous name and set them in your MNG `name` argument.

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "16.0.1"

  cluster_name    = "your-cluster-name"
  cluster_version = "1.20"
  # ...

  node_groups = {
    example = {
      name             = "your-pre-v17.0.0-managed-node-group-name"
      desired_capacity = 1
      max_capacity     = 10
      min_capacity     = 1

      # ...
    }
  }
  # ...
}
```

After the first apply, we recommand you to create a new node group and let the module use the `node_group_name_prefix` (by removing the `name` argument) to generate names and collision during node groups re-creation if needed, because the lifce cycle is `create_before_destroy = true`.
