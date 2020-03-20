# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this
project adheres to [Semantic Versioning](http://semver.org/).

## [v10.0.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v9.0.0...v10.0.0) - 2020-03-12

BREAKING CHANGES:

- Added support for EKS 1.15 (by @sc250024)

ENHANCEMENTS:

- Ensuring that ami lookup hierarchy is worker_group_launch_templates and worker_groups -> worker_group_defaults -> and finally aws ami lookup (by @ck3mp3r)
- Adding `encrypted` option to worker's root_block_device as read from the worker configurations (by @craig-rueda)
- Add support for ASG max instance lifetime (by @sidprak)
- Add `default_cooldown` and `health_check_grace_period` options to workers ASG (by @ArieLevs)
- Add support for envelope encryption of Secrets (by @babilen5)

BUG FIXES:

- Fix issue with terraform plan phase when IRSA was enabled and create_eks switches to false (by @daroga0002)
- Remove obsolete assumption from README (kubectl & aws-iam-authenticator) (by @pierresteiner)
- Fix doc about spot instances, cluster-autoscaler should be scheduled on normal instances instead of spot (by @simowaer)
- Use correct policy arns for CN regions (cn-north-1, cn-northwest-1) (by @cofyc)
- Fix support for ASG max instance lifetime for workers (by @barryib)

NOTES:

From EKS 1.15, the VPC tag `kubernetes.io/cluster/<cluster-name>: shared` is no longer required. So we droped those tags from exemples.

## [v9.0.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v8.2.0...v9.0.0) - 2020-02-27

- **Breaking:** Removal of autoscaling IAM policy and tags (by @max-rocket-internet)
- Revert #631. Add back manage security group flags. (by @ryanooi)
- Changed timeout for creating EKS (by @confiq)
- Added instructions for how to add Windows nodes (by @ivanguravel)
- [CI] Switch `Validate` github action to use env vars (by @max-rocket-internet)
- [CI] Bump pre-commit-terraform version (by @barryib)
- Added example `examples/irsa` for IAM Roles for Service Accounts (by @max-rocket-internet)
- Add `iam:{Create,Delete,Get}OpenIDConnectProvider` grants to the list of required IAM permissions in `docs/iam-permissions.md` (by @danielelisi)
- Add a `name` parameter to be able to manually name EKS Managed Node Groups (by @splieth)
- Pinned kubernetes provider version to exactly 1.10.0 across all examples and README.md's (by @andres-de-castro)
- Change variable default `wait_for_cluster_cmd` from curl to wget (by @daroga0002)

#### Important notes

Autoscaling policy and tags have been removed from this module. This reduces complexity and increases security as the policy was attached to the node group IAM role. To manage it outside of this module either follow the example in `examples/irsa` to attach an IAM role to the cluster-autoscaler `serviceAccount` or create [the policy](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v8.2.0/workers.tf#L361-L416) outside this module and pass it in using the `workers_additional_policies` variable.

## [v8.2.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v8.1.0...v8.2.0) - 2020-01-29

- Include ability to configure custom os-specific command for waiting until kube cluster is healthy (@sanjeevgiri)
- Disable creation of ingress rules if worker nodes security groups are exists (@andjelx)
- [CI] Update pre-commit and re-generate docs to work with terraform-docs >= 0.8.1 (@barryib)

## [v8.1.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v8.0.0...v8.1.0) - 2020-01-17

- Fix index reference on destroy for output `oidc_provider_arn` (@stevie-)
- Add support for restricting access to the public API endpoint (@sidprak)
- Add an `ignore_lifecycle` rule to prevent Terraform from scaling down ASG behind AWS EKS Managed Node Group (by @davidalger)

## [v8.0.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v8.0.0...v7.0.1) - 2020-01-09

- **Breaking:** Change logic of security group whitelisting. Will always whitelist worker security group on control plane security group either provide one or create new one. See Important notes below for upgrade notes (by @ryanooi)
- **Breaking:** Configure the aws-auth configmap using the terraform kubernetes providers. See Important notes below for upgrade notes (by @sdehaes)
- Wait for cluster to respond to kubectl before applying auth map_config (@shaunc)
- Added flag `create_eks` to conditionally create resources (by @syst0m / @tbeijen)
- Support for AWS EKS Managed Node Groups. (by @wmorgan6796)
- Added a if check on `aws-auth` configmap when `map_roles` is empty (by @shanmugakarna)
- Removed no longer used variable `write_aws_auth_config` (by @tbeijen)
- Exit with error code when `aws-auth` configmap is unable to be updated (by @knittingdev)
- Fix deprecated interpolation-only expression (by @angelabad)
- Updated required version of AWS Provider to >= v2.38.0 for Managed Node Groups (by @wmorgan6796)
- Updated minimum version of Terraform to avoid a bug (by @dpiddockcmp)
- Fix cluster_oidc_issuer_url output from list to string (by @chewvader)
- Fix idempotency issues for node groups with no remote_access configuration (by @jeffmhastings)
- Fix aws-auth config map for managed node groups (by @wbertelsen)
- Added support to create IAM OpenID Connect Identity Provider to enable EKS Identity Roles for Service Accounts (IRSA). (by @alaa)
- Adding node group iam role arns to outputs. (by @mukgupta)
- Added the OIDC Provider ARN to outputs. (by @eytanhanig)
- Move `eks_node_group` resources to a submodule (by @dpiddockcmp)
- Add complex output `node_groups` (by @TBeijen)

#### Important notes

The way the `aws-auth` configmap in the `kube-system` namespaces is managed has been changed. Before this was managed via kubectl using a null resources. This was changed to be managed by the terraform Kubernetes provider.

To upgrade you have to add the kubernetes provider to the place you are calling the module. You can see examples in
the [examples](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/93636625740c63fd89ad8bc60ad180761288c54d/examples) folder. Then you should import the configmap into Terraform:

```
terraform import module.cluster1.kubernetes_config_map.aws_auth[0] kube-system/aws-auth
```

You could also delete the aws-auth config map before doing an apply but this means you need to the apply with the **same user/role that created the cluster**.

For security group whitelisting change. After upgrade, have to remove `cluster_create_security_group` and `worker_create_security_group` variable. If you have whitelist worker security group before, you will have to delete it(and apply again) or import it.

```
terraform import module.eks.aws_security_group_rule.cluster_https_worker_ingress <CONTROL_PLANE_SECURITY_GROUP_ID>_ingress_tcp_443_443_<WORKER_SECURITY_GROUP_ID>
```

## [v7.0.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v7.0.1...v7.0.0) - 2019-12-11

- Test against minimum versions specified in `versions.tf` (by @dpiddockcmp)
- Updated `instance_profile_names` and `instance_profile_arns` outputs to also consider launch template as well as asg (by @ankitwal)
- Fix broken terraform plan/apply on a cluster < 1.14 (by @hodduc)
- Updated application of `aws-auth` configmap to create `kube_config.yaml` and `aws_auth_configmap.yaml` in sequence (and not parallel) to `kubectl apply` (by @knittingdev)

## [v7.0.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v6.0.2...v7.0.0) - 2019-10-30

- **Breaking:** Allow for specifying a custom AMI for the worker nodes. (by @bmcstdio)
- Added support for Windows workers AMIs (by @hodduc)
- Allow for replacing the full userdata text with a `userdata_template_file` template and `userdata_template_extra_args` in `worker_groups` (by @snstanton)
-  **Breaking:** The `kubectl` configuration file can now be fully-specified using `config_output_path`. Previously it was assumed that `config_output_path` referred to a directory and always ended with a forward slash. This is a breaking change if `config_output_path` does **not** end with a forward slash (which was advised against by the documentation). (by @joshuaspence)
- Changed logic for setting default `ebs_optimized` to only require maintaining a list of instance types that don't support it (by @jeffmhastings)
- Bumped minimum terraform version to 0.12.2 to prevent an error on yamlencode function (by @toadjaune)
- Access conditional resource using join function in combination with splat syntax (by @miguelaferreira)

#### Important notes

An AMI is now specified using the whole name, for example `amazon-eks-node-1.14-v20190927`.

## [v6.0.2](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v6.0.1...v6.0.2) - 2019-10-07

- Added `tags` to `aws_eks_cluster` introduced by terraform-provider-aws 2.31.0 (by @morganchristiansson)
- Add option to enable lifecycle hooks creation (by @barryib)
- Remove helm chart value `sslCertPath` described in `docs/autoscaling.md` (by @wi1dcard)
- Attaching of IAM policies for autoscaler and CNI to the worker nodes now optional (by @dpiddockcmp)

## [v6.0.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v6.0.0...v6.0.1) - 2019-09-25

- Added support for different workers AMI's, i.e. with GPU support (by @rvoitenko)
- Use null as default value for `target_group_arns` attribute of worker autoscaling group (by @tatusl)
- Output empty string when cluster identity is empty (by @tbarry)

## [v6.0.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v5.1.0...v6.0.0) - 2019-09-17

- Added `market_type` to `workers_launch_template.tf` allow the usage of spot nodegroups without mixed instances policy.
- Added support for log group tag in `./cluster.tf` (@lucas-giaco)
- Added support for workers iam role tag in `./workers.tf` (@lucas-giaco)
- Added `required_providers` to enforce provider minimum versions (by @dpiddockcmp)
- Updated `local.spot_allocation_strategy` docstring to indicate availability of new `capacity-optimized` option. (by @sc250024)
- Added support for initial lifecycle hooks for autosacling groups (@barryib)
- Added option to recreate ASG when LT or LC changes (by @barryib)
- Ability to specify workers role name (by @ivanich)
- Added output for OIDC Issuer URL (by @russwhelan)
- Added support for Mixed Instance ASG using `worker_groups_launch_template` variable  (by @sppwf)
- Changed ASG Tags generation using terraform 12 `for` utility  (by @sppwf)
- **Breaking:** Removed `worker_groups_launch_template_mixed` variable (by @sppwf)
- Update to EKS 1.14 (by @nauxliu)
- **Breaking:** Support map users and roles to multiple groups (by @nauxliu)
- Fixed errors sometimes happening during destroy due to usage of coalesce() in local.tf (by @petrikero)
- Removed historical mention of adding caller's IPv4 to cluster security group (by @dpiddockcmp)
- Wrapped `kubelet_extra_args` in double quotes instead of singe quotes (by @nxf5025)
- Make terraform plan more consistent and avoid unnecessary "(known after apply)" (by @barryib)
- Made sure that `market_type` was correctly passed to `workers_launch_template` (by @to266)

#### Important notes

You will need to move worker groups from `worker_groups_launch_template_mixed` to `worker_groups_launch_template`. You can rename terraform resources in the state to avoid an destructive changes.

Map roles need to rename `role_arn` to `rolearn` and `group = ""` to `groups = [""]`.

## [v5.1.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v5.1.0...v5.1.1) - 2019-07-30

- Added new tag in `worker.tf` with autoscaling_enabled = true flag (by @insider89)

## [v5.1.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v5.0.0...v5.1.0) - 2019-07-30

- Option to set a KMS key for the log group and encrypt it (by @till-krauss)
- Output the name of the cloudwatch log group (by @gbooth27)
- Added `cpu_credits` param for the workers defined in `worker_groups_launch_template` (by @a-shink)
- Added support for EBS Volumes tag in `worker_groups_launch_template` and `workers_launch_template_mixed.tf` (by @sppwf)
- Basic example now tags networks correctly, as per [ELB documentation](https://docs.aws.amazon.com/eks/latest/userguide/load-balancing.html) and [ALB documentation](https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html) (by @karolinepauls)
- Update default override instance types to work with Cluster Autoscaler (by @nauxliu on behalf of RightCapital)
- Examples now specify `enable_dns_hostnames = true`, as per [EKS documentation](https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html) (by @karolinepauls)

## [v5.0.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v4.0.2...v5.0.0) - 2019-06-19

- Added Termination Policy Option to worker ASGs (by @undeadops)
- Update EBS optimized instances type (by @gloutsch)
- Added tagging for iam role created in `./cluster.tf` (@camilosantana)
- Enable log retention for cloudwatch log groups (by @yuriipolishchuk)
- Update to EKS 1.13 (by @gloutsch)
- Finally, Terraform 0.12 support, [Upgrade Guide](https://github.com/terraform-aws-modules/terraform-aws-eks/pull/394) (by @alex-goncharov @nauxliu @timboven)
- All the xx_count variables have been removed (by @nauxliu on behalf of RightCapital)
- Use actual lists in the workers group maps instead of strings with commas (by @nauxliu on behalf of RightCapital)
- Move variable `worker_group_tags` to workers group's attribute `tags` (by @nauxliu on behalf of RightCapital)
- Change override instance_types to list (by @nauxliu on behalf of RightCapital)
- Fix toggle for IAM instance profile creation for mixed launch templates (by @jnozo)

## [v4.0.2](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v4.0.1...v4.0.2) - 2019-05-07
- Added 2 new examples, also tidy up basic example (by @max-rocket-internet)
- Updates to travis, PR template (by @max-rocket-internet)
- Fix typo in data.tf (by @max-rocket-internet)
- Add missing launch template items in `aws_auth.tf` (by @max-rocket-internet)

## [v4.0.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v4.0.0...v4.0.1) - 2019-05-07

- Fix annoying typo: worker_group_xx vs worker_groups_xx (by @max-rocket-internet)

## [v4.0.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v3.0.0...v4.0.0) - 2019-05-07

- Added support for custom service linked role for Auto Scaling group (by @voanhduy1512)
- Added support for custom IAM roles for cluster and workers (by @erks)
- Added cluster ARN to outputs (by @alexsn)
- Added outputs for `workers_user_data` and `workers_default_ami_id` (by @max-rocket-internet)
- Added doc about spot instances (by @max-rocket-internet)
- Added new worker group option with a mixed instances policy (by @max-rocket-internet)
- Set default suspended processes for ASG to `AZRebalance` (by @max-rocket-internet)
- 4 small changes to `aws_launch_template` resource (by @max-rocket-internet)
- (Breaking Change) Rewritten and de-duplicated code related to Launch Templates (by @max-rocket-internet)
- Add .prettierignore file (by @rothandrew)
- Switch to https for the pre-commit repos (by @rothandrew)
- Add instructions on how to enable the docker bridge network (by @rothandrew)

## [v3.0.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v2.3.1...v3.0.0) - 2019-04-15

- Fixed: Ability to destroy clusters due to security groups being attached to ENI's (by @whiskeyjimbo)
- Added outputs for worker IAM instance profile(s) (by @soapergem)
- Added support for cluster logging via the `cluster_enabled_log_types` variable (by @sc250024)
- Updated vpc module version and aws provider version. (by @chenrui333)
- Upgraded default kubernetes version from 1.11 to 1.12 (by @stijndehaes)

## [v2.3.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v2.3.0...v2.3.1) - 2019-03-26

- Added support for eks public and private endpoints (by @stijndehaes)
- Added minimum inbound traffic rule to the cluster worker security group as per the [EKS security group requirements](https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html) (by @sc250024)
- (Breaking Change) Replaced `enable_docker_bridge` with a generic option called `bootstrap_extra_args` to resolve [310](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/310) (by @max-rocket-internet)

## [v2.3.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v2.2.1...v2.3.0) - 2019-03-20

- Allow additional policies to be attached to worker nodes (by @rottenbytes)
- Ability to specify a placement group for each worker group (by @matheuss)
- "k8s.io/cluster-autoscaler/{cluster-name}" and "k8s.io/cluster-autoscaler/node-template/resources/ephemeral-storage" tags for autoscaling groups (by @tbarrella)
- Added "ec2:DescribeLaunchTemplateVersions" action to worker instance role (by @skang0601)
- Adding ebs encryption for workers launched using workers_launch_template (by @russki)
- Added output for generated kubeconfig filename (by @syst0m)
- Added outputs for cluster role ARN and name (by @spingel)
- Added optional name filter variable to be able to pin worker AMI to a release (by @max-rocket-internet)
- Added `--enable-docker-bridge` option for bootstrap.sh in AMI (by @michaelmccord)

## [v2.2.2](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v2.2.1...v2.2.2) - 2019-02-25

- Ability to specify a path for IAM roles (by @tekn0ir)

## [v2.2.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v2.2.0...v2.2.1) - 2019-02-18

## [v2.2.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v2.1.0...v2.2.0) - 2019-02-07

- Ability to specify a permissions_boundary for IAM roles (by @dylanhellems)
- Ability to configure force_delete for the worker group ASG (by @stefansedich)
- Ability to configure worker group ASG tags (by @stefansedich)
- Added EBS optimized mapping for the g3s.xlarge instance type (by @stefansedich)
- `enabled_metrics` input (by @zanitete)
- write_aws_auth_config to input (by @yutachaos)
- Change worker group ASG to use create_before_destroy (by @stefansedich)
- Fixed a bug where worker group defaults were being used for launch template user data (by @leonsodhi-lf)
- Managed_aws_auth option is true, the aws-auth configmap file is no longer created, and write_aws_auth_config must be set to true to generate config_map. (by @yutachaos)

## [v2.1.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v2.0.0...v2.1.0) - 2019-01-15

- Initial support for worker groups based on Launch Templates (by @skang0601)
- Updated the `update_config_map_aws_auth` resource to trigger when the EKS cluster endpoint changes. This likely means that a new cluster was spun up so our ConfigMap won't exist (fixes #234) (by @elatt)
- Removed invalid action from worker_autoscaling iam policy (by @marcelloromani)
- Fixed zsh-specific syntax in retry loop for aws auth config map (by @marcelloromani)
- Fix: fail deployment if applying the aws auth config map still fails after 10 attempts (by @marcelloromani)

## [v2.0.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v1.8.0...v2.0.0) - 2018-12-14

- (Breaking Change) New input variables `map_accounts_count`, `map_roles_count` and `map_users_count` to allow using computed values as part of `map_accounts`, `map_roles` and `map_users` configs (by @chili-man on behalf of OpenGov).
- (Breaking Change) New variables `cluster_create_security_group` and `worker_create_security_group` to stop `value of 'count' cannot be computed` error.
- Added ability to choose local-exec interpreter (by @rothandrew)
- Added `--with-aggregate-type-defaults` option to terraform-docs (by @max-rocket-internet)
- Updated AMI ID filtering to only filter AMIs from current cluster k8s version (by @max-rocket-internet)
- Added `pre-commit-terraform` git hook to automatically create documentation of inputs/outputs (by @antonbabenko)
- Travis fixes (by @RothAndrew)
- Fixed some Windows compatibility issues (by @RothAndrew)

## [v1.8.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v1.7.0...v1.8.0) - 2018-12-04

-  Support for using AWS Launch Templates to define autoscaling groups (by @skang0601)
- `suspended_processes` to `worker_groups` input (by @bkmeneguello)
- `target_group_arns` to `worker_groups` input (by @zihaoyu)
- `force_detach_policies` to `aws_iam_role` `cluster` and `workers` (by @marky-mark)
- Added sleep while trying to apply the kubernetes configurations if failed, up to 50 seconds (by @rmakram-ims)
- `cluster_create_security_group` and `worker_create_security_group`. This allows using computed cluster and worker security groups. (by @rmakram-ims)
- new variables worker_groups_launch_template and worker_group_count_launch_template (by @skang0601)
- Remove aws_iam_service_linked_role (by @max-rocket-internet)
- Adjust the order and correct/update the ec2 instance type info. (@chenrui333)
- Removed providers from `main.tf`. (by @max-rocket-internet)
- Removed `configure_kubectl_session` references in documentation [#171](https://github.com/terraform-aws-modules/terraform-aws-eks/pull/171) (by @dominik-k)

## [v1.7.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v1.6.0...v1.7.0) - 2018-10-09

- Worker groups can be created with a specified IAM profile. (from @laverya)
- exposed `aws_eks_cluster` create and destroy timeouts (by @RGPosadas)
- exposed `placement_tenancy` for autoscaling group (by @monsterxx03)
- Allow port 443 from EKS service to nodes to run `metrics-server`. (by @max-rocket-internet)
- fix default worker subnets not working (by @erks)
- fix default worker autoscaling_enabled not working (by @erks)
- Cosmetic syntax changes to improve readability. (by @max-rocket-internet)
- add `protect_from_scale_in` to solve issue #134 (by @kinghajj)

## [v1.6.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v1.5.0...v1.6.0) - 2018-09-04

- add support for [`amazon-eks-node-*` AMI with bootstrap script](https://aws.amazon.com/blogs/opensource/improvements-eks-worker-node-provisioning/) (by @erks)
- expose `kubelet_extra_args` worker group option (replacing `kubelet_node_labels`) to allow specifying arbitrary kubelet options (e.g. taints and labels) (by @erks)
- add optional input `worker_additional_security_group_ids` to allow one or more additional security groups to be added to all worker launch configurations - #47 (by @hhobbsh @mr-joshua)
- add optional input `additional_security_group_ids` to allow one or more additional security groups to be added to a specific worker launch configuration - #47 (by @mr-joshua)
- allow a custom AMI to be specified as a default (by @erks)
- bugfix for above change (by @max-rocket-internet)
- **Breaking change** Removed support for `eks-worker-*` AMI. The cluster specifying a custom AMI based off of `eks-worker-*` AMI will have to rebuild the AMI from `amazon-eks-node-*`.  (by @erks)
- **Breaking change** Removed `kubelet_node_labels` worker group option in favor of `kubelet_extra_args`. (by @erks)

## [v1.5.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v1.4.0...v1.5.0) - 2018-08-30

- add spot_price option to aws_launch_configuration
- add enable_monitoring option to aws_launch_configuration
- add t3 instance class settings
- add aws_iam_service_linked_role for elasticloadbalancing. (by @max-rocket-internet)
- Added autoscaling policies into module that are optionally attached when enabled for a worker group. (by @max-rocket-internet)
- **Breaking change** Removed `workstation_cidr` variable, http callout and unnecessary security rule. (by @dpiddockcmp)
  If you are upgrading from 1.4 you should fix state after upgrade: `terraform state rm module.eks.data.http.workstation_external_ip`
- Can now selectively override keys in `workers_group_defaults` variable rather than callers maintaining a duplicate of the whole map. (by @dpiddockcmp)

## [v1.4.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v1.3.0...v1.4.0) - 2018-08-02

- manage eks workers' root volume size and type.
- `workers_asg_names` added to outputs. (kudos to @laverya)
- New top level variable `worker_group_count` added to replace the use of `length(var.worker_groups)`. This allows using computed values as part of worker group configs. (complaints to @laverya)

## [v1.3.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v1.2.0...v1.3.0) - 2018-07-11

- New variables `map_accounts`, `map_roles` and `map_users` in order to manage additional entries in the `aws-auth` configmap. (by @max-rocket-internet)
- kubelet_node_labels worker group option allows setting --node-labels= in kubelet. (Hat-tip, @bshelton229 👒)
- `worker_iam_role_arn` added to outputs. Sweet, @hatemosphere 🔥
- Worker subnets able to be specified as a dedicated list per autoscaling group. (up top, @bshelton229 🙏)

## [v1.2.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v1.1.0...v1.2.0) - 2018-07-01

- new variable `pre_userdata` added to worker launch configuration allows to run scripts before the plugin does anything. (W00t, @jimbeck 🦉)
- kubeconfig made much more flexible. (Bang up job, @sdavids13 💥)
- ASG desired capacity is now ignored as ASG size is more effectively handed by k8s. (Thanks, @ozbillwang 💇‍♂️)
- Providing security groups didn't behave as expected. This has been fixed. (Good catch, @jimbeck 🔧)
- workstation cidr to be allowed by created security group is now more flexible. (A welcome addition, @jimbeck 🔐)

## [v1.1.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v1.0.0...v1.1.0) - 2018-06-25

- new variable `worker_sg_ingress_from_port` allows to change the minimum port number from which pods will accept communication (Thanks, @ilyasotkov 👏).
- expanded on worker example to show how multiple worker autoscaling groups can be created.
- IPv4 is used explicitly to resolve testing from IPv6 networks (thanks, @tsub 🙏).
- Configurable public IP attachment and ssh keys for worker groups. Defaults defined in `worker_group_defaults`. Nice, @hatemosphere 🌂
- `worker_iam_role_name` now an output. Sweet, @artursmet 🕶️
- IAM test role repaired by @lcharkiewicz 💅
- `kube-proxy` restart no longer needed in userdata. Good catch, @hatemosphere 🔥
- worker ASG reattachment wasn't possible when using `name`. Moved to `name_prefix` to allow recreation of resources. Kudos again, @hatemosphere 🐧

## [v1.0.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v0.2.0...v1.0.0) - 2018-06-11

- security group id can be provided for either/both of the cluster and the workers. If not provided, security groups will be created with sufficient rules to allow cluster-worker communication. - kudos to @tanmng on the idea ⭐
- outputs of security group ids and worker ASG arns added for working with these resources outside the module.
- Worker build out refactored to allow multiple autoscaling groups each having differing specs. If none are given, a single ASG is created with a set of sane defaults - big thanks to @kppullin 🥨

## [v0.2.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v0.1.1...v0.2.0) - 2018-06-08

- ability to specify extra userdata code to execute following kubelet services start.
- EBS optimization used whenever possible for the given instance type.
- When `configure_kubectl_session` is set to true the current shell will be configured to talk to the kubernetes cluster using config files output from the module.
- files rendered from dedicated templates to separate out raw code and config from `hcl`
- `workers_ami_id` is now made optional. If not specified, the module will source the latest AWS supported EKS AMI instead.

## [v0.1.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v0.1.0...v0.1.1) - 2018-06-07
- Pre-commit hooks fixed and working.
- Made progress on CI, advancing the build to the final `kitchen test` stage before failing.

## [v0.1.0] - 2018-06-07

- Everything! Initial release of the module.
- added a local variable to do a lookup against for a dynamic value in userdata which was previously static. Kudos to @tanmng for finding and fixing bug #1!
