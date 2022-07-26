# How to handle the terraform-aws-eks module upgrade

## Upgrade module to v17.0.0 for Managed Node Groups

In this release, we now decided to remove random_pet resources in Managed Node Groups (MNG). Those were used to recreate MNG if something changed. But they were causing a lot of issues. To upgrade the module without recreating your MNG, you will need to explicitly reuse their previous name and set them in your MNG `name` argument.

1. Run `terraform apply` with the module version v16.2.0
2. Get your worker group names

```shell
~ terraform state show 'module.eks.module.node_groups.aws_eks_node_group.workers["example"]' | grep node_group_name
node_group_name = "test-eks-mwIwsvui-example-sincere-squid"
```

3. Upgrade your module and configure your node groups to use existing names

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.0.0"

  cluster_name    = "test-eks-mwIwsvui"
  cluster_version = "1.20"
  # ...

  node_groups = {
    example = {
      name = "test-eks-mwIwsvui-example-sincere-squid"

      # ...
    }
  }
  # ...
}
```

4. Run `terraform plan`, you should see that only `random_pets` will be destroyed

```shell
Terraform will perform the following actions:

  # module.eks.module.node_groups.random_pet.node_groups["example"] will be destroyed
  - resource "random_pet" "node_groups" {
      - id        = "sincere-squid" -> null
      - keepers   = {
          - "ami_type"                  = "AL2_x86_64"
          - "capacity_type"             = "SPOT"
          - "disk_size"                 = "50"
          - "iam_role_arn"              = "arn:aws:iam::123456789123:role/test-eks-mwIwsvui20210527220853611600000009"
          - "instance_types"            = "t3.large"
          - "key_name"                  = ""
          - "node_group_name"           = "test-eks-mwIwsvui-example"
          - "source_security_group_ids" = ""
          - "subnet_ids"                = "subnet-xxxxxxxxxxxx|subnet-xxxxxxxxxxxx|subnet-xxxxxxxxxxxx"
        } -> null
      - length    = 2 -> null
      - separator = "-" -> null
    }

Plan: 0 to add, 0 to change, 1 to destroy.
```

5. If everything sounds good to you, run `terraform apply`

After the first apply, we recommend you to create a new node group and let the module use the `node_group_name_prefix` (by removing the `name` argument) to generate names and avoid collision during node groups re-creation if needed, because the lifecycle is `create_before_destroy = true`.
