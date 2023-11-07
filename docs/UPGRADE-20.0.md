# Upgrade from v19.x to v20.x

Please consult the `examples` directory for reference example configurations. If you find a bug, please open an issue with supporting configuration to reproduce.

## List of backwards incompatible changes

- Minium supported AWS provider version increased to `v5.0`
- The `resolve_conflicts` argument within the `cluster_addons` configuration has been replaced with `resolve_conflicts_on_create` and `resolve_conflicts_on_delete` now that `resolve_conflicts` is deprecated
- The `cluster_addons` `preserve` argument default/fallback value is now set to `true`. This has shown to be useful for users deprovisioning clusters while avoiding the situation where the CNI is deleted too early and causes resources to be left orphaned which results in conflicts.

## Additional changes

### Added

   -

### Modified

   - For `sts:AssumeRole` permissions by services, the use of dynamically looking up the DNS suffix has been replaced with the static value of `amazonaws.com`. This does not appear to change by partition and instead requires users to set this manually for non-commercial regions.

### Removed

   -

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

### Diff of Before (v18.x) vs After (v19.x)

```diff
 module "eks" {
   source  = "terraform-aws-modules/eks/aws"
-  version = "~> 19.17.1"
+  version = "~> 20.0"

}
```

## Terraform State Moves
