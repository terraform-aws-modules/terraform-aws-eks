# Upgrade from v17.x to v18.x

If you have any questions regarding this upgrade process, please consult the `examples` directory:

- TODO

If you find a bug, please open an issue with supporting configuration to reproduce.

## Changes

- Launch configuration support has been removed and only launch template is supported going forward. AWS is no longer adding new features back into launch configuration and their docs state [`We strongly recommend that you do not use launch configurations. They do not provide full functionality for Amazon EC2 Auto Scaling or Amazon EC2. We provide information about launch configurations for customers who have not yet migrated from launch configurations to launch templates.`](https://docs.aws.amazon.com/autoscaling/ec2/userguide/LaunchConfiguration.html)
- One IAM role/profile is created as a "default" role (if users opt in to create the role/profile). Otherwise users need to supply the instance profile name/arn to use for the various groups
- Maps, maps, maps, maps...

## List of backwards incompatible changes

- TODO

### Variable and output changes

1. Removed variables:

   - `var.cluster_create_timeout`, `var.cluster_update_timeout`, and `var.cluster_delete_timeout` have been replaced with `var.cluster_timeouts`

2. Renamed variables:

   - `create_eks` -> `create`
   - `subnets` -> `subnet_ids`
   - `cluster_create_security_group` -> `create_cluster_security_group`

3. Added variables:

   - TODO

4. Removed outputs:

   - TODO

5. Renamed outputs:

   - TODO

6. Added outputs:

   - TODO

## Upgrade Migrations

### Before 17.x Example

```hcl
module "cluster_before" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 17.0"

  # TODO

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

### After 18.x Example

```hcl
module "cluster_after" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  # TODO

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

### State Changes

To migrate from the `v17.x` version to `v18.x` version example shown above, the following state move commands can be performed to maintain the current resources without modification:

```bash
terraform state mv 'from' 'to'
```

### Configuration Changes

TODO
