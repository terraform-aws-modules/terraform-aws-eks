# Examples

Examples are created to help users understand and build EKS clusters using this module. Examples are helpful for some Proof of Concept build and are focusing on showing usage of different possibilities.

> Important
>
> Examples should not be used for production deployments. Examples try to be simple and not consistently implement best practices in areas of high availability or security.

## Example rules

- each example is independent of each other and can be created independently
- there is implemented additional random suffix so the same example should be able to be launched on the same AWS account
- each example requires some generic resources like VPC, subnets and etc., which are embedded into the standard `generic.tf` file. The file is exactly the same across all examples
- by default example is launched in `eu-west-1` region. To launch it in another region just override the region variable in terraform using `terraform apply -var=region=us-east-1`
