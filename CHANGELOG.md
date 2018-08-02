# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this
project adheres to [Semantic Versioning](http://semver.org/).

## [[v1.5.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v1.4.0...HEAD)] - 2018-08-??]

### Added

- A useful addition (slam dunk, @self 🔥)

### Changed

- A subtle but thoughtful change. (Boomshakalaka, @self 🏀)

## [[v1.4.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v1.3.0...v1.4.0)] - 2018-08-02]

### Added

- manage eks workers' root volume size and type.
- `workers_asg_names` added to outputs. (kudos to @laverya)
- New top level variable `worker_group_count` added to replace the use of `length(var.worker_groups)`. This allows using computed values as part of worker group configs. (complaints to @laverya)

## [[v1.3.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v1.2.0...v1.3.0)] - 2018-07-11]

### Added

- New variables `map_accounts`, `map_roles` and `map_users` in order to manage additional entries in the `aws-auth` configmap. (by @max-rocket-internet)
- kubelet_node_labels worker group option allows setting --node-labels= in kubelet. (Hat-tip, @bshelton229 👒)
- `worker_iam_role_arn` added to outputs. Sweet, @hatemosphere 🔥

### Changed

- Worker subnets able to be specified as a dedicated list per autoscaling group. (up top, @bshelton229 🙏)

## [[v1.2.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v1.1.0...v1.2.0)] - 2018-07-01]

### Added

- new variable `pre_userdata` added to worker launch configuration allows to run scripts before the plugin does anything. (W00t, @jimbeck 🦉)

### Changed

- kubeconfig made much more flexible. (Bang up job, @sdavids13 💥)
- ASG desired capacity is now ignored as ASG size is more effectively handed by k8s. (Thanks, @ozbillwang 💇‍♂️)
- Providing security groups didn't behave as expected. This has been fixed. (Good catch, @jimbeck 🔧)
- workstation cidr to be allowed by created security group is now more flexible. (A welcome addition, @jimbeck 🔐)

## [[v1.1.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v1.0.0...v1.1.0)] - 2018-06-25]

### Added

- new variable `worker_sg_ingress_from_port` allows to change the minimum port number from which pods will accept communication (Thanks, @ilyasotkov 👏).
- expanded on worker example to show how multiple worker autoscaling groups can be created.
- IPv4 is used explicitly to resolve testing from IPv6 networks (thanks, @tsub 🙏).
- Configurable public IP attachment and ssh keys for worker groups. Defaults defined in `worker_group_defaults`. Nice, @hatemosphere 🌂
- `worker_iam_role_name` now an output. Sweet, @artursmet 🕶️

### Changed

- IAM test role repaired by @lcharkiewicz 💅
- `kube-proxy` restart no longer needed in userdata. Good catch, @hatemosphere 🔥
- worker ASG reattachment wasn't possible when using `name`. Moved to `name_prefix` to allow recreation of resources. Kudos again, @hatemosphere 🐧

## [[v1.0.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v0.2.0...v1.0.0)] - 2018-06-11]

### Added

- security group id can be provided for either/both of the cluster and the workers. If not provided, security groups will be created with sufficient rules to allow cluster-worker communication. - kudos to @tanmng on the idea ⭐
- outputs of security group ids and worker ASG arns added for working with these resources outside the module.

### Changed

- Worker build out refactored to allow multiple autoscaling groups each having differing specs. If none are given, a single ASG is created with a set of sane defaults - big thanks to @kppullin 🥨

## [[v0.2.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v0.1.1...v0.2.0)] - 2018-06-08]

### Added

- ability to specify extra userdata code to execute following kubelet services start.
- EBS optimization used whenever possible for the given instance type.
- When `configure_kubectl_session` is set to true the current shell will be configured to talk to the kubernetes cluster using config files output from the module.

### Changed

- files rendered from dedicated templates to separate out raw code and config from `hcl`
- `workers_ami_id` is now made optional. If not specified, the module will source the latest AWS supported EKS AMI instead.

## [[v0.1.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v0.1.0...v0.1.1)] - 2018-06-07]

### Changed

- Pre-commit hooks fixed and working.
- Made progress on CI, advancing the build to the final `kitchen test` stage before failing.

## [v0.1.0] - 2018-06-07

### Added

- Everything! Initial release of the module.
- added a local variable to do a lookup against for a dynamic value in userdata which was previously static. Kudos to @tanmng for finding and fixing bug #1!
