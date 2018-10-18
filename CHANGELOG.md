# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this
project adheres to [Semantic Versioning](http://semver.org/).

## [[v1.8.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v1.7.0...HEAD)] - 2018-10-??]

### Added

- `suspended_processes` to `worker_groups` input (by @bkmeneguello)
- `target_group_arns` to `worker_groups` input (by @zihaoyu)

### Changed

- Remove aws_iam_service_linked_role (by @max-rocket-internet)
- Adjust the order and correct/update the ec2 instance type info. (@chenrui333)
- Removed providers from `main.tf`. (by @max-rocket-internet)

## [[v1.7.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v1.6.0...v1.7.0)] - 2018-10-09]

### Added

- Worker groups can be created with a specified IAM profile. (from @laverya)
- exposed `aws_eks_cluster` create and destroy timeouts (by @RGPosadas)
- exposed `placement_tenancy` for autoscaling group (by @monsterxx03)
- Allow port 443 from EKS service to nodes to run `metrics-server`. (by @max-rocket-internet)

### Changed

- fix default worker subnets not working (by @erks)
- fix default worker autoscaling_enabled not working (by @erks)
- Cosmetic syntax changes to improve readability. (by @max-rocket-internet)
- add `protect_from_scale_in` to solve issue #134 (by @kinghajj)

## [[v1.6.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v1.5.0...v1.6.0)] - 2018-09-04]

### Added

- add support for [`amazon-eks-node-*` AMI with bootstrap script](https://aws.amazon.com/blogs/opensource/improvements-eks-worker-node-provisioning/) (by @erks)
- expose `kubelet_extra_args` worker group option (replacing `kubelet_node_labels`) to allow specifying arbitrary kubelet options (e.g. taints and labels) (by @erks)
- add optional input `worker_additional_security_group_ids` to allow one or more additional security groups to be added to all worker launch configurations - #47 (by @hhobbsh @mr-joshua)
- add optional input `additional_security_group_ids` to allow one or more additional security groups to be added to a specific worker launch configuration - #47 (by @mr-joshua)

### Changed

- allow a custom AMI to be specified as a default (by @erks)
- bugfix for above change (by @max-rocket-internet)
- **Breaking change** Removed support for `eks-worker-*` AMI. The cluster specifying a custom AMI based off of `eks-worker-*` AMI will have to rebuild the AMI from `amazon-eks-node-*`.  (by @erks)
- **Breaking change** Removed `kubelet_node_labels` worker group option in favor of `kubelet_extra_args`. (by @erks)

## [[v1.5.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v1.4.0...v1.5.0)] - 2018-08-30]

### Added

- add spot_price option to aws_launch_configuration
- add enable_monitoring option to aws_launch_configuration
- add t3 instance class settings
- add aws_iam_service_linked_role for elasticloadbalancing. (by @max-rocket-internet)
- Added autoscaling policies into module that are optionally attached when enabled for a worker group. (by @max-rocket-internet)

### Changed

- **Breaking change** Removed `workstation_cidr` variable, http callout and unnecessary security rule. (by @dpiddockcmp)
  If you are upgrading from 1.4 you should fix state after upgrade: `terraform state rm module.eks.data.http.workstation_external_ip`
- Can now selectively override keys in `workers_group_defaults` variable rather than callers maintaining a duplicate of the whole map. (by @dpiddockcmp)

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
