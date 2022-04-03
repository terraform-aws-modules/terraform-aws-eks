# User Data & Bootstrapping

Users can see the various methods of using and providing user data through the [user data examples](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/user_data) as well more detailed information on the design and possible configurations via the [user data module itself](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/modules/_user_data)

In general:

- AWS EKS Managed Node Groups
  - By default, any supplied user data is pre-pended to the user data supplied by the EKS Managed Node Group service
  - If users supply an `ami_id`, the service no longers supplies user data to bootstrap nodes; users can enable `enable_bootstrap_user_data` and use the module provided user data template, or provide their own user data template
  - `bottlerocket` platform user data must be in TOML format
- Self Managed Node Groups
  - `linux` platform (default) -> the user data template (bash/shell script) provided by the module is used as the default; users are able to provide their own user data template
  - `bottlerocket` platform -> the user data template (TOML file) provided by the module is used as the default; users are able to provide their own user data template
  - `windows` platform -> the user data template (powershell/PS1 script) provided by the module is used as the default; users are able to provide their own user data template

The templates provided by the module can be found under the [templates directory](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/templates)
