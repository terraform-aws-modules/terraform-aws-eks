# Upgrade from v20.x to v21.x

If you have any questions regarding this upgrade process, please consult the [`examples`](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples) directory:
If you find a bug, please open an issue with supporting configuration to reproduce.

## List of backwards incompatible changes

- Terraform `v1.5.7` is now minimum supported version
- AWS provider `v6.0.0` is now minimum supported version

## Additional changes

### Added

- Support for `region` parameter to specify the AWS region for the resources created if different from the provider region.

### Modified

- Variable definitions now contain detailed `object` types in place of the previously used any type.

### Variable and output changes

1. Removed variables:

    -

2. Renamed variables:

    -

3. Added variables:

    -

4. Removed outputs:

    -

5. Renamed outputs:

    -

6. Added outputs:

    -

## Upgrade Migrations

### Before 20.x Example

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  # Truncated for brevity ...

}
```

### After 21.x Example

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  # Truncated for brevity ...

}
```

### State Changes
