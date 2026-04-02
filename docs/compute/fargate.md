# Fargate Profiles

AWS Fargate lets you run Kubernetes pods without managing EC2 instances. You define Fargate profiles with namespace and label selectors, and AWS automatically runs matching pods on serverless compute.

The [submodule source](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/modules/fargate-profile) is available on GitHub.

## Basic usage

A Fargate profile with a single namespace selector:

```hcl
fargate_profiles = {
  example = {
    selectors = [
      { namespace = "default" }
    ]
  }
}
```

## Multiple selectors

A single profile can match pods across multiple namespaces or using label filters:

```hcl
fargate_profiles = {
  multi = {
    selectors = [
      { namespace = "default" },
      {
        namespace = "app"
        labels = {
          workload = "fargate"
        }
      }
    ]
  }
}
```

## Considerations

Fargate has limitations compared to EC2-based node groups:

- Fargate profiles only run pods in private subnets — public subnets are not supported. The private subnets must have outbound internet access (via NAT gateway) so that Fargate can pull container images and communicate with the EKS API
- Fargate pods cannot use host networking (`hostNetwork: true`)
- DaemonSets are not supported on Fargate
- GPU workloads are not available on Fargate
- Not all EKS add-ons support running on Fargate — check add-on documentation before relying on Fargate for system components

## Example

Fargate profiles are configured as part of the root module. See the [examples gallery](../examples.md) for working configurations that can be extended with Fargate selectors.
