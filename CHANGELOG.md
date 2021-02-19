# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this
project adheres to [Semantic Versioning](http://semver.org/).

<a name="unreleased"></a>
## [Unreleased]



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


[Unreleased]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v14.0.0...HEAD
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
