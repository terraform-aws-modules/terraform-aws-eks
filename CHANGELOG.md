# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this
project adheres to [Semantic Versioning](http://semver.org/).

<a name="unreleased"></a>
## [Unreleased]



<a name="v17.20.0"></a>
## [v17.20.0] - 2021-09-17
FEATURES:
- Ability to specify cluster update timeout ([#1588](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1588))


<a name="v17.19.0"></a>
## [v17.19.0] - 2021-09-16
REFACTORS:
- Refactoring to match the rest of terraform-aws-modules ([#1583](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1583))


<a name="v17.18.0"></a>
## [v17.18.0] - 2021-09-08
FEATURES:
- Add metadata_options for node_groups ([#1485](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1485))


<a name="v17.17.0"></a>
## [v17.17.0] - 2021-09-08
FEATURES:
- Added custom AMI support for managed node groups ([#1473](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1473))


<a name="v17.16.0"></a>
## [v17.16.0] - 2021-09-08
BUG FIXES:
- Fixed coalescelist() with subnets in fargate module ([#1576](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1576))


<a name="v17.15.0"></a>
## [v17.15.0] - 2021-09-06
FEATURES:
- Added ability to pass different subnets for fargate and the cluster ([#1527](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1527))


<a name="v17.14.0"></a>
## [v17.14.0] - 2021-09-06
FEATURES:
- Create SG rule for each new cluster_endpoint_private_access_cidr block ([#1549](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1549))


<a name="v17.13.0"></a>
## [v17.13.0] - 2021-09-06
BUG FIXES:
- Worker security group handling when worker_create_security_group=false ([#1461](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1461))


<a name="v17.12.0"></a>
## [v17.12.0] - 2021-09-06
FEATURES:
- Add ability to tag network-interface using Launch Template ([#1563](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1563))


<a name="v17.11.0"></a>
## [v17.11.0] - 2021-09-04
BUG FIXES:
- Updated required version of AWS provider to 3.56.0 ([#1571](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1571))


<a name="v17.10.0"></a>
## [v17.10.0] - 2021-09-03
FEATURES:
- Added support for update_config in EKS managed node groups ([#1560](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1560))


<a name="v17.9.0"></a>
## [v17.9.0] - 2021-09-03
FEATURES:
- Allow override of timeouts in node_groups ([#1552](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1552))
- Ability to tag just EKS cluster ([#1569](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1569))


<a name="v17.8.0"></a>
## [v17.8.0] - 2021-09-03
BUG FIXES:
- Put KubeletExtraArgs in double quotes for Windows ([#1082](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1082))


<a name="v17.7.0"></a>
## [v17.7.0] - 2021-09-02
FEATURES:
- Added throughput support for root and EBS disks ([#1445](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1445))


<a name="v17.6.0"></a>
## [v17.6.0] - 2021-08-31
FEATURES:
- Tags passed into worker_groups_launch_template extend var.tags for the volumes ([#1397](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1397))


<a name="v17.5.0"></a>
## [v17.5.0] - 2021-08-31
FEATURES:
- Allow users to add more Audiences to OpenID Connect ([#1451](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1451))


<a name="v17.4.0"></a>
## [v17.4.0] - 2021-08-27
BUG FIXES:
- Discourage usage of iam_policy_attachment in example ([#1529](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1529))
- Allow instance `Name` tag to be overwritten ([#1538](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1538))

DOCS:
- Fix cluster-autoscaler tags in irsa example ([#1436](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1436))
- Add missing comma to docs/iam-permissions.md ([#1437](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1437))
- Updated autoscaling.md ([#1515](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1515))


<a name="v17.3.0"></a>
## [v17.3.0] - 2021-08-25
BUG FIXES:
- Fixed launch template version infinite plan issue and improved rolling updates ([#1447](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1447))


<a name="v17.2.0"></a>
## [v17.2.0] - 2021-08-25
FEATURES:
- Support for encrypted root disk in node_groups ([#1428](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1428))
- Enable ebs_optimized setting for node_groups ([#1459](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1459))


<a name="v17.1.0"></a>
## [v17.1.0] - 2021-06-09
FEATURES:
- Add support for Managed Node Groups (`node_groups`) taints ([#1424](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1424))
- Allow to choose launch template version for Managed Node Groups when `create_launch_template` is set to `true` ([#1419](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1419))
- Add `capacity_rebalance` support for self-managed worker groups ([#1326](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1326))
- Add `var.wait_for_cluster_timeout` to allow configuring the wait for cluster timeout ([#1420](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1420))


<a name="v17.0.3"></a>
## [v17.0.3] - 2021-05-28
BUG FIXES:
- Fix AMI filtering when the default platform is provided in `var.workers_group_defaults` ([#1413](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1413))
- Remove duplicated security group rule for EKS private access endpoint ([#1412](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1412))

NOTES:
- In this bug fix, we remove a duplicated security rule introduced during a merge conflict resolution in [[#1274](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1274)](https://github.com/terraform-aws-modules/terraform-aws-eks/pull/1274)


<a name="v17.0.2"></a>
## [v17.0.2] - 2021-05-28
BUG FIXES:
- Don't add tags on network interfaces because it's not supported yet in `terraform-provider-aws` ([#1407](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1407))


<a name="v17.0.1"></a>
## [v17.0.1] - 2021-05-28
BUG FIXES:
- Default `root_volume_type` must be `gp2` ([#1404](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1404))


<a name="v17.0.0"></a>
## [v17.0.0] - 2021-05-28
FEATURES:
- Add ability to use Security Groups as source for private endpoint access ([#1274](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1274))
- Define Root device name for Windows self-managed worker groups ([#1401](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1401))
- Drop random pets from Managed Node Groups ([#1372](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1372))
- Add multiple selectors on the creation of Fargate profile ([#1378](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1378))
- Rename `config_output_path` into `kubeconfig_output_path` for naming consistency ([#1399](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1399))
- Kubeconfig file should not be world or group readable by default ([#1114](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1114))
- Add tags on network interfaces ([#1362](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1362))
- Add instance store volume option for instances with local disk ([#1213](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1213))

BUG FIXES:
- Add back `depends_on` for `data.wait_for_cluster` ([#1389](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1389))

DOCS:
- Clarify about the `cluster_endpoint_private_access_cidrs` usage ([#1400](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1400))
- Add KMS aliases handling to IAM permissions ([#1288](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1288))

BREAKING CHANGES:
- The private endpoint security group rule has been renamed to allow the use of CIDR blocks and Security Groups as source. This will delete the `cluster_private_access` Security Group Rule for existing cluster. Please rename by `aws_security_group_rule.cluster_private_access[0]` into `aws_security_group_rule.cluster_private_access_cidrs_source[0]`.
- We now decided to remove `random_pet` resources in Managed Node Groups (MNG). Those were used to recreate MNG if something change and also simulate the newly added argument `node_group_name_prefix`. But they were causing a lot of troubles. To upgrade the module without recreating your MNG, you will need to explicitly reuse their previous name and set them in your MNG `name` argument. Please see [upgrade docs](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/upgrades.md#upgrade-module-to-v1700-for-managed-node-groups) for more details.
- To support multiple selectors for Fargate profiles, we introduced the `selectors` argument which is a list of map. This will break previous configuration with  a single selector `namespace` and `labels`. You'll need to rewrite your configuration to use the `selectors` argument. See [examples](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/fargate/main.tf) dans [docs](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/modules/fargate/README.md) for details.
- The  variable `config_output_path` is renamed into `kubeconfig_output_path` for naming consistency. Please upgrade your configuration accordingly.

NOTES:
- Since we now search only for Linux or Windows AMI if there is a worker groups for the corresponding plateform, we can now define different default root block device name for each plateform. Use locals `root_block_device_name` and `root_block_device_name_windows` to define your owns.
- The kubeconfig file permission is not world and group readable anymore. The default permission is now `600`. This value can be changed with the variable `var.kubeconfig_file_permission`.


<a name="v16.2.0"></a>
## [v16.2.0] - 2021-05-24
FEATURES:
- Add ability to forcefully update nodes in managed node groups ([#1380](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1380))

BUG FIXES:
- Bump `terraform-provider-http` required version to 2.4.1 to avoid TLS Cert Pool issue on Windows ([#1387](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1387))

DOCS:
- Update license to Apache 2 License ([#1375](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1375))


<a name="v16.1.0"></a>
## [v16.1.0] - 2021-05-19
FEATURES:
- Search for Windows or Linux AMIs only if they are needed ([#1371](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1371))

BUG FIXES:
- Set an ASG's launch template version to an explicit version to automatically trigger instance refresh ([#1370](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1370))
- Add description for private API ingress Security Group Rule ([#1299](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1299))

DOCS:
- Fix cluster autoscaler tags in IRSA example ([#1204](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1204))
- Add Bottlerocket example ([#1296](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1296))

NOTES:
- Set an ASG's launch template version to an explicit version automatically. This will ensure that an instance refresh will be triggered whenever the launch template changes. The default `launch_template_version` is now used to determine the latest or default version of the created launch template for self-managed worker groups.


<a name="v16.0.1"></a>
## [v16.0.1] - 2021-05-19
BUG FIXES:
- Bump `terraform-aws-modules/http` provider version to support darwin arm64 release ([#1369](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1369))

DOCS:
- Use IRSA for Node Termination Handler IAM policy attachement in Instance Refresh example ([#1373](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1373))


<a name="v16.0.0"></a>
## [v16.0.0] - 2021-05-17
FEATURES:
- Add support for Auto Scaling Group Instance Refresh for self-managed worker groups ([#1224](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1224))
- Drop `asg_recreate_on_change` feature to encourage the usage of Instance Refresh for EC2 Auto Scaling ([#1360](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1360))
- Add timeout of 5mn when waiting for cluster ([#1359](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1359))
- Remove dependency on deprecated `hashicorp/template` provider ([#1297](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1297))
- Replace the local-exec script with a http datasource for waiting cluster ([#1339](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1339))

BUG FIXES:
- Remove  provider from required providers ([#1357](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1357))
- Bump AWS provider version to add Warm Pool support ([#1340](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1340))

CI:
- Bump terraform-docs to 0.13 ([#1335](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1335))

BREAKING CHANGES:
- This module used `random_pet` resources to create a random name for the autoscaling group to force the autoscaling group to be re-created when the launch configuration or launch template was changed (if `recreate_asg_when_lc_changes = true` was set), causing the instances to be removed and re-provisioned each time there was an update. Those random_pet resources has been removed and in its place there is now a set of functionality provided by AWS and the Terraform AWS provider - Instance Refresh. We encourage those users to move on Instance Refresh for EC2 Auto Scaling.
- We remove the dependency on the deprecated `hashicorp/template` provider and use the Terraform built in `templatefile` function. This will broke some workflows due to previously being able to pass in the raw contents of a template file for processing. The `templatefile` function requires a template file that exists before running a plan.

NOTES:
- Using the [terraform-aws-modules/http](https://registry.terraform.io/providers/terraform-aws-modules/http/latest) provider is a more platform agnostic way to wait for the cluster availability than using a local-exec. With this change we're able to provision EKS clusters and manage the `aws_auth` configmap while still using the `hashicorp/tfc-agent` docker image.


<a name="v15.2.0"></a>
## [v15.2.0] - 2021-05-04
FEATURES:
- Add tags on additional IAM resources like IAM policies, instance profile, OIDC provider ([#1321](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1321))
- Allow to override cluster and workers egress CIDRs ([#1237](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1237))
- Allow to specify the managed cluster IAM role name ([#1199](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1199))
- Add support for ASG Warm Pools ([#1310](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1310))
- Add support for specifying elastic inference accelerator ([#1176](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1176))
- Create launch template for Managed Node Groups ([#1138](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1138))

BUG FIXES:
- Replace `list` with `tolist` function for working with terraform v0.15.0 ([#1317](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1317))
- Limit cluster_name when creating fargate IAM Role ([#1270](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1270))
- Add mission metadata block for launch configuration ([#1301](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1301))
- Add missing IAM permission for NLB with EIPs ([#1226](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1226))
- Change back the default disk type to `gp2` ([#1208](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1208))

DOCS:
- Update helm instructions for irsa example ([#1251](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1251))


<a name="v15.1.0"></a>
## [v15.1.0] - 2021-04-16
BUG FIXES:
- Fixed list and map usage ([#1307](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1307))


<a name="v15.0.0"></a>
## [v15.0.0] - 2021-04-16
BUG FIXES:
- Updated code and version requirements to work with Terraform 0.15 ([#1165](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1165))


<a name="v14.0.0"></a>
## [v14.0.0] - 2021-01-29
FEATURES:
- Add nitro enclave support for EKS ([#1185](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1185))
- Add support for `service_ipv4_cidr` for the EKS cluster ([#1139](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1139))
- Add the SPOT support for Managed Node Groups ([#1129](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1129))
- Use `gp3` as default as it saves 20% and is more performant ([#1134](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1134))
- Allow the overwrite of subnets for Fargate profiles ([#1117](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1117))
- Add support for throughput parameter for `gp3` volumes ([#1146](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1146))
- Add customizable Auto Scaling Group health check type ([#1118](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1118))
- Add permissions boundary to fargate execution IAM role ([#1108](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1108))

ENHANCEMENTS:
- Dont set -x in userdata to avoid printing sensitive informations in logs ([#1187](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1187))

BUG FIXES:
- Merge tags from Fargate profiles with common tags from cluster ([#1159](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1159))

DOCS:
- Update changelog generation to use custom sort with git-chglog v0.10.0 ([#1202](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1202))
- Bump IRSA example dependencies to versions which work with TF 0.14 ([#1184](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1184))
- Change instance type from `t2` to `t3` in examples ([#1169](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1169))
- Fix typos in README and CONTRIBUTING ([#1167](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1167))
- Make it more obvious that `var.cluster_iam_role_name` will allow reusing an existing IAM Role for the cluster. ([#1133](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1133))
- Fixes typo in variables description ([#1154](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1154))
- Fix a typo in the `aws-auth` section of the README ([#1099](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1099))

BREAKING CHANGES:
- To add add SPOT support for MNG, the `instance_type` is now a list and renamed as `instance_types`. This will probably rebuild existing Managed Node Groups.
- The default root volume type is now `gp3` as it saves 20% and is more performant

NOTES:
- The EKS cluster can be provisioned with both private and public subnets. But Fargate only accepts private ones. This new variable allows to override the subnets to explicitly pass the private subnets to Fargate and work around that issue.


<a name="v13.2.1"></a>
## [v13.2.1] - 2020-11-12
ENHANCEMENTS:
- Tags passed into worker groups should also be excluded from Launch Template tag specification ([#1095](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1095))

BUG FIXES:
- Don’t add empty Roles ARN in aws-auth configmap, specifically when no Fargate profiles are specified ([#1096](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1096))

DOCS:
- Clarify usage of both AWS-Managed Node Groups and Self-Managed Worker Groups ([#1094](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1094))


<a name="v13.2.0"></a>
## [v13.2.0] - 2020-11-07
FEATURES:
- Add EKS Fargate support ([#1067](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1067))
- Tags passed into worker groups override tags from `var.tags` for Autoscaling Groups ([#1092](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1092))

BUG FIXES:
- Change the default `launch_template_id` to `null` for Managed Node Groups ([#1088](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1088))

DOCS:
- Fix IRSA example when deploying cluster-autoscaler from the latest kubernetes/autoscaler helm repo ([#1090](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1090))
- Explain node_groups and worker_groups difference in FAQ ([#1081](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1081))
- Update autoscaler installation in IRSA example ([#1063](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1063))

NOTES:
- Tags that are passed into `var.worker_groups_launch_template` or `var.worker_groups` now override tags passed in via `var.tags` for Autoscaling Groups only. This allow ASG Tags to be overwritten, so that `propagate_at_launch` can be tweaked for a particular key.


<a name="v13.1.0"></a>
## [v13.1.0] - 2020-11-02
FEATURES:
- Add Launch Template support for Managed Node Groups ([#997](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/997))
- Add `cloudwatch_log_group_arn` to outputs ([#1071](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1071))
- Add kubernetes standard labels to avoid manual mistakes on the managed `aws-auth` configmap ([#989](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/989))

BUG FIXES:
- The type of the output `cloudwatch_log_group_name` should be a string instead of a list of strings ([#1061](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1061))
- Use splat syntax to avoid errors during destroy with an empty state ([#1041](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1041))
- Fix cycle error during the destroy phase when we change workers order ([#1043](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1043))
- Set IAM Path for `cluster_elb_sl_role_creation` IAM policy ([#1045](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1045))
- Use the amazon `ImageOwnerAlias` for worker ami owner instead of owner id ([#1038](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1038))

CI:
- Use ubuntu-latest instead of MacOS for docs checks ([#1074](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1074))
- Fix GitHub Actions CI macOS build errors ([#1065](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1065))

NOTES:
- Managed Node Groups now support Launch Templates. The Launch Template it self is not managed by this module, so you have to create it by your self and pass it's id to this module. See docs and [`examples/launch_templates_with_managed_node_groups/`](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/launch_templates_with_managed_node_group) for more details.
- The output `cloudwatch_log_group_name` was incorrectly returning the log group name as a list of strings. As a workaround, people were using `module.eks_cluster.cloudwatch_log_group_name[0]` but that was totally inconsistent with output name. Those users can now use `module.eks_cluster.cloudwatch_log_group_name` directly.
- Keep in mind that changing the order of workers group is a destructive operation. All workers group are destroyed and recreated. If you want to do this safely, you should move then in state with `terraform state mv` until we manage workers groups as maps.


<a name="v13.0.0"></a>
## [v13.0.0] - 2020-10-06
FEATURES:
- Add `load_balancers` parameter to associate a CLB (Classic Load Balancer) to worker groups ASG ([#992](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/992))
- Dynamic Partition for IRSA to support AWS-CN Deployments ([#1028](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1028))
- Add AmazonEKSVPCResourceController to cluster policy to be able to set AWS Security Groups for pod ([#1011](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1011))
- Cluster version is now a required variable. ([#972](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/972))

ENHANCEMENTS:
- Make the `cpu_credits` optional for workers launch template ([#1030](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1030))
- Update the `wait_for_cluster_cmd` logic to use `curl` if `wget` doesn't exist ([#1002](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1002))

BUG FIXES:
- Use customer managed policy instead of inline policy for `cluster_elb_sl_role_creation` ([#1039](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1039))
- More compatibility fixes for Terraform v0.13 and aws v3 ([#976](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/976))
- Create `cluster_private_access` security group rules when it should ([#981](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/981))
- Random_pet with LT workers under 0.13.0 ([#940](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/940))

DOCS:
- Add important notes about the retry logic and the `wget` requirement ([#999](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/999))
- Update README about `cluster_version` variable requirement ([#988](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/988))
- Mixed spot + on-demand instance documentation ([#967](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/967))
- Describe key_name is about AWS EC2 key pairs ([#970](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/970))
- Better documentation of `cluster_id` output blocking ([#955](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/955))

CI:
- Bump terraform pre-commit hook version and re-run terraform-docs with the latest version to fix the CI ([#1033](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1033))
- Fix CI lint job ([#973](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/973))

BREAKING CHANGES:
- Default for `cluster_endpoint_private_access_cidrs` is now `null` instead of `["0.0.0.0/0"]`. It makes the variable required when `cluster_create_endpoint_private_access_sg_rule` is set to `true`. This will force everyone who want to have a private access to set explicitly their allowed subnets for the sake of the principle of least access by default.
- `cluster_version` variable is now required.

NOTES:
- `credit_specification` for worker groups launch template can now be set to `null` so that we can use non burstable EC2 families
- Starting in v12.1.0 the `cluster_id` output depends on the
`wait_for_cluster` null resource. This means that initialisation of the
kubernetes provider will be blocked until the cluster is really ready,
if the module is set to manage the aws_auth ConfigMap and user followed
the typical Usage Example. kubernetes resources in the same plan do not
need to depend on anything explicitly.


<a name="v12.2.0"></a>
## [v12.2.0] - 2020-07-13
FEATURES:
- IMDSv2 metadata configuration in Launch Templates ([#938](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/938))
- Worker launch templates and configurations depend on security group rules and IAM policies ([#933](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/933))
- Add IAM permissions for ELB svc-linked role creation by EKS cluster ([#902](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/902))
- Add a homemade `depends_on` for MNG submodule to ensure ordering of resource creation ([#867](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/867))

BUG FIXES:
- Strip user Name tag from asg_tags [#946](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/946))
- Get `on_demand_allocation_strategy` from `local.workers_group_defaults` when deciding to use `mixed_instances_policy` ([#908](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/908))
- Remove unnecessary conditional in private access security group ([#915](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/915))

DOCS:
- Update required IAM permissions list ([#936](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/936))
- Improve FAQ on how to deploy from Windows ([#927](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/927))
- Autoscaler X.Y version must match ([#928](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/928))

NOTES:
- Addition of the IMDSv2 metadata configuration block to Launch Templates will cause a diff to be generated for existing Launch Templates on first Terraform apply. The defaults match existing behaviour.


<a name="v12.1.0"></a>
## [v12.1.0] - 2020-06-06
FEATURES:
- Add aws_security_group_rule.cluster_https_worker_ingress to output values ([#901](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/901))
- Allow communication between pods on workers and pods using the primary cluster security group (optional) ([#892](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/892))

BUG FIXES:
- Revert removal of templates provider ([#883](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/883))
- Ensure kubeconfig ends with \n ([#880](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/880))
- Work around path bug in aws-iam-authenticator ([#894](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/894))

DOCS:
- Update FAQ ([#891](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/891))

NOTES:
- New variable `worker_create_cluster_primary_security_group_rules` to allow communication between pods on workers and pods using the primary cluster security group (Managed Node Groups or Fargate). It defaults to `false` to avoid potential conflicts with existing security group rules users may have implemented.


<a name="v12.0.0"></a>
## [v12.0.0] - 2020-05-09
FEATURES:
- Create kubeconfig with non-executable permissions ([#864](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/864))
- Change EKS default version to 1.16 ([#857](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/857))

ENHANCEMENTS:
- Remove dependency on external template provider ([#854](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/854))

BUG FIXES:
- Fix Launch Templates error with aws 2.61.0 ([#875](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/875))
- Use splat syntax for cluster name to avoid `(known after apply)` in managed node groups ([#868](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/868))

DOCS:
- Add notes for Kubernetes 1.16 ([#873](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/873))
- Remove useless template provider in examples ([#863](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/863))

BREAKING CHANGES:
- The default `cluster_version` is now 1.16. Kubernetes 1.16 includes a number of deprecated API removals, and you need to ensure your applications and add ons are updated, or workloads could fail after the upgrade is complete. For more information on the API removals, see the [Kubernetes blog post](https://kubernetes.io/blog/2019/07/18/api-deprecations-in-1-16/). For action you may need to take before upgrading, see the steps in the [EKS documentation](https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html). Please set explicitly your `cluster_version` to an older EKS version until your workloads are ready for Kubernetes 1.16.


<a name="v11.1.0"></a>
## [v11.1.0] - 2020-04-23
FEATURES:
- Add support for EC2 principal in assume worker role policy for China ([#827](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/827))

BUG FIXES:
- Add `vpc_config.cluster_security_group` output as primary cluster security group id ([#828](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/828))
- Wrap `local.configmap_roles.groups` with tolist() to avoid panic ([#846](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/846))
- Prevent `coalescelist` null argument error when destroying worker_group_launch_templates ([#842](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/842))


<a name="v11.0.0"></a>
## [v11.0.0] - 2020-03-31
FEATURES:
- Add instance tag specifications to Launch Template ([#822](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/822))
- Add support for additional volumes in launch templates and launch configurations ([#800](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/800))
- Add interpreter option to `wait_for_cluster_cmd` ([#795](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/795))

ENHANCEMENTS:
- Require kubernetes provider >=1.11.1 ([#784](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/784))
- Use `aws_partition` to build IAM policy ARNs ([#820](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/820))
- Generate `aws-auth` configmap's roles from Object. No more string concat. ([#790](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/790))
- Add timeout to default wait_for_cluster_cmd ([#791](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/791))
- Automate changelog management ([#786](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/786))

BUG FIXES:
- Fix destroy failure when talking to EKS endpoint on private network ([#815](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/815))
- Add ip address when manage_aws_auth is true and public_access is false ([#745](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/745))
- Add node_group direct dependency on eks_cluster ([#796](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/796))
- Do not recreate cluster when no SG given ([#798](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/798))
- Create `false` and avoid waiting forever for a non-existent cluster to respond ([#789](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/789))
- Fix git-chglog template to format changelog `Type` nicely ([#803](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/803))
- Fix git-chglog configuration ([#802](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/802))

TESTS:
- Remove unused kitchen test related stuff ([#787](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/787))

CI:
- Restrict sementic PR to validate PR title only ([#804](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/804))


[Unreleased]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v17.20.0...HEAD
[v17.20.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v17.19.0...v17.20.0
[v17.19.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v17.18.0...v17.19.0
[v17.18.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v17.17.0...v17.18.0
[v17.17.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v17.16.0...v17.17.0
[v17.16.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v17.15.0...v17.16.0
[v17.15.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v17.14.0...v17.15.0
[v17.14.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v17.13.0...v17.14.0
[v17.13.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v17.12.0...v17.13.0
[v17.12.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v17.11.0...v17.12.0
[v17.11.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v17.10.0...v17.11.0
[v17.10.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v17.9.0...v17.10.0
[v17.9.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v17.8.0...v17.9.0
[v17.8.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v17.7.0...v17.8.0
[v17.7.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v17.6.0...v17.7.0
[v17.6.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v17.5.0...v17.6.0
[v17.5.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v17.4.0...v17.5.0
[v17.4.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v17.3.0...v17.4.0
[v17.3.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v17.2.0...v17.3.0
[v17.2.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v17.1.0...v17.2.0
[v17.1.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v17.0.3...v17.1.0
[v17.0.3]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v17.0.2...v17.0.3
[v17.0.2]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v17.0.1...v17.0.2
[v17.0.1]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v17.0.0...v17.0.1
[v17.0.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v16.2.0...v17.0.0
[v16.2.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v16.1.0...v16.2.0
[v16.1.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v16.0.1...v16.1.0
[v16.0.1]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v16.0.0...v16.0.1
[v16.0.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v15.2.0...v16.0.0
[v15.2.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v15.1.0...v15.2.0
[v15.1.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v15.0.0...v15.1.0
[v15.0.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v14.0.0...v15.0.0
[v14.0.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v13.2.1...v14.0.0
[v13.2.1]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v13.2.0...v13.2.1
[v13.2.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v13.1.0...v13.2.0
[v13.1.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v13.0.0...v13.1.0
[v13.0.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v12.2.0...v13.0.0
[v12.2.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v12.1.0...v12.2.0
[v12.1.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v12.0.0...v12.1.0
[v12.0.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v11.1.0...v12.0.0
[v11.1.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v11.0.0...v11.1.0
[v11.0.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v10.0.0...v11.0.0
