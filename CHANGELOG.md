# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this
project adheres to [Semantic Versioning](http://semver.org/).

## Next release

## [[v2.3.0?](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v2.2.0...HEAD)] - 2019-03-??]

### Added

- Ability to specify a placement group for each worker group (by @matheuss)
- Added "ec2:DescribeLaunchTemplateVersions" action to worker instance role (by @skang0601)
- Adding ebs encryption for workers launched using workers_launch_template (by @russki)
- Added output for generated kubeconfig filename (by @syst0m)
- Added outputs for cluster role ARN and name (by @spingel)
- Added optional name filter variable to be able to pin worker AMI to a release (by @max-rocket-internet)

### Changed

 - Write your awesome change here (by @you)

# History

## [[v2.2.2](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v2.2.1...v2.2.2)] - 2019-02-25]

### Added

- Ability to specify a path for IAM roles (by @tekn0ir)

## [[v2.2.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v2.2.0...v2.2.1)] - 2019-02-18]

## [[v2.2.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v2.1.0...v2.2.0)] - 2019-02-07]

### Added

- Ability to specify a permissions_boundary for IAM roles (by @dylanhellems)
- Ability to configure force_delete for the worker group ASG (by @stefansedich)
- Ability to configure worker group ASG tags (by @stefansedich)
- Added EBS optimized mapping for the g3s.xlarge instance type (by @stefansedich)
- `enabled_metrics` input (by @zanitete)
- write_aws_auth_config to input (by @yutachaos)

### Changed

- Change worker group ASG to use create_before_destroy (by @stefansedich)
- Fixed a bug where worker group defaults were being used for launch template user data (by @leonsodhi-lf)
- Managed_aws_auth option is true, the aws-auth configmap file is no longer created, and write_aws_auth_config must be set to true to generate config_map. (by @yutachaos)

## [[v2.1.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v2.0.0...v2.1.0)] - 2019-01-15]

### Added

- Initial support for worker groups based on Launch Templates (by @skang0601)

### Changed

- Updated the `update_config_map_aws_auth` resource to trigger when the EKS cluster endpoint changes. This likely means that a new cluster was spun up so our ConfigMap won't exist (fixes #234) (by @elatt)
- Removed invalid action from worker_autoscaling iam policy (by @marcelloromani)
- Fixed zsh-specific syntax in retry loop for aws auth config map (by @marcelloromani)
- Fix: fail deployment if applying the aws auth config map still fails after 10 attempts (by @marcelloromani)

## [[v2.0.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v1.8.0...v2.0.0)] - 2018-12-14]

### Added

- (Breaking Change) New input variables `map_accounts_count`, `map_roles_count` and `map_users_count` to allow using computed values as part of `map_accounts`, `map_roles` and `map_users` configs (by @chili-man on behalf of OpenGov).
- (Breaking Change) New variables `cluster_create_security_group` and `worker_create_security_group` to stop `value of 'count' cannot be computed` error.
- Added ability to choose local-exec interpreter (by @rothandrew)

### Changed

- Added `--with-aggregate-type-defaults` option to terraform-docs (by @max-rocket-internet)
- Updated AMI ID filtering to only filter AMIs from current cluster k8s version (by @max-rocket-internet)
- Added `pre-commit-terraform` git hook to automatically create documentation of inputs/outputs (by @antonbabenko)
- Travis fixes (by @RothAndrew)
- Fixed some Windows compatibility issues (by @RothAndrew)

## [[v1.8.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v1.7.0...v1.8.0)] - 2018-12-04]

### Added

-  Support for using AWS Launch Templates to define autoscaling groups (by @skang0601)
- `suspended_processes` to `worker_groups` input (by @bkmeneguello)
- `target_group_arns` to `worker_groups` input (by @zihaoyu)
- `force_detach_policies` to `aws_iam_role` `cluster` and `workers` (by @marky-mark)
- Added sleep while trying to apply the kubernetes configurations if failed, up to 50 seconds (by @rmakram-ims)
- `cluster_create_security_group` and `worker_create_security_group`. This allows using computed cluster and worker security groups. (by @rmakram-ims)

### Changed

- new variables worker_groups_launch_template and worker_group_count_launch_template (by @skang0601)
- Remove aws_iam_service_linked_role (by @max-rocket-internet)
- Adjust the order and correct/update the ec2 instance type info. (@chenrui333)
- Removed providers from `main.tf`. (by @max-rocket-internet)
- Removed `configure_kubectl_session` references in documentation [#171](https://github.com/terraform-aws-modules/terraform-aws-eks/pull/171) (by @dominik-k)

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
