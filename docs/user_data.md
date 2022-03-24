### User Data & Bootstrapping

There are a multitude of different possible configurations for how module users require their user data to be configured. In order to better support the various combinations from simple, out of the box support provided by the module to full customization of the user data using a template provided by users - the user data has been abstracted out to its own module. Users can see the various methods of using and providing user data through the [user data examples](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/user_data) as well more detailed information on the design and possible configurations via the [user data module itself](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/modules/_user_data)

In general (tl;dr):
- AWS EKS Managed Node Groups
  - `linux` platform (default) -> user data is pre-pended to the AWS provided bootstrap user data (bash/shell script) when using the AWS EKS provided AMI, otherwise users need to opt in via `enable_bootstrap_user_data` and use the module provided user data template or provide their own user data template to bootstrap nodes to join the cluster
  - `bottlerocket` platform -> user data is merged with the AWS provided bootstrap user data (TOML file) when using the AWS EKS provided AMI, otherwise users need to opt in via `enable_bootstrap_user_data` and use the module provided user data template or provide their own user data template to bootstrap nodes to join the cluster
- Self Managed Node Groups
  - `linux` platform (default) -> the user data template (bash/shell script) provided by the module is used as the default; users are able to provide their own user data template
  - `bottlerocket` platform -> the user data template (TOML file) provided by the module is used as the default; users are able to provide their own user data template
  - `windows` platform -> the user data template (powershell/PS1 script) provided by the module is used as the default; users are able to provide their own user data template

Module provided default templates can be found under the [templates directory](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/templates)
