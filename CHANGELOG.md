# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this
project adheres to [Semantic Versioning](http://semver.org/).

<a name="unreleased"></a>
## [Unreleased]



<a name="v13.0.0"></a>
## [v13.0.0] - 2020-10-05
BUG FIXES:
- Use customer managed policy instead of inline policy for `cluster_elb_sl_role_creation` ([#1039](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1039))
- More compatibility fixes for Terraform v0.13 and aws v3 ([#976](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/976))
- Create `cluster_private_access` security group rules when it should ([#981](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/981))
- random_pet with LT workers under 0.13.0 ([#940](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/940))

ENHANCEMENTS:
- Make the `cpu_credits` optional for workers launch template ([#1030](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1030))
- update the `wait_for_cluster_cmd` logic to use `curl` if `wget` doesn't exist ([#1002](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1002))

FEATURES:
- Add `load_balancers` parameter to associate a CLB (Classic Load Balancer) to worker groups ASG ([#992](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/992))
- Dynamic Partition for IRSA to support AWS-CN Deployments ([#1028](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1028))
- Add AmazonEKSVPCResourceController to cluster policy to be able to set AWS Security Groups for pod ([#1011](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1011))
- Cluster version is now a required variable. ([#972](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/972))

CI:
- Bump terraform pre-commit hook version and re-run terraform-docs with the latest version to fix the CI ([#1033](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1033))
- fix CI lint job ([#973](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/973))

DOCS:
- Add important notes about the retry logic and the `wget` requirement ([#999](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/999))
- Update README about `cluster_version` variable requirement ([#988](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/988))
- Mixed spot + on-demand instance documentation ([#967](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/967))
- Describe key_name is about AWS EC2 key pairs ([#970](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/970))
- Better documentation of `cluster_id` output blocking ([#955](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/955))

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
DOCS:
- Update required IAM permissions list ([#936](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/936))
- Improve FAQ on how to deploy from Windows ([#927](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/927))
- autoscaler X.Y version must match ([#928](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/928))

FEATURES:
- IMDSv2 metadata configuration in Launch Templates ([#938](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/938))
- worker launch templates and configurations depend on security group rules and IAM policies ([#933](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/933))
- Add IAM permissions for ELB svc-linked role creation by EKS cluster ([#902](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/902))
- Add a homemade `depends_on` for MNG submodule to ensure ordering of resource creation ([#867](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/867))

BUG FIXES:
- Strip user Name tag from asg_tags [#946](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/946))
- Get `on_demand_allocation_strategy` from `local.workers_group_defaults` when deciding to use `mixed_instances_policy` ([#908](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/908))
- remove unnecessary conditional in private access security group ([#915](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/915))

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
BUG FIXES:
- Fix Launch Templates error with aws 2.61.0 ([#875](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/875))
- Use splat syntax for cluster name to avoid `(known after apply)` in managed node groups ([#868](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/868))

DOCS:
- Add notes for Kubernetes 1.16 ([#873](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/873))
- Remove useless template provider in examples ([#863](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/863))

FEATURES:
- Create kubeconfig with non-executable permissions ([#864](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/864))
- Change EKS default version to 1.16 ([#857](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/857))

ENHANCEMENTS:
- Remove dependency on external template provider ([#854](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/854))

BREAKING CHANGES:
- The default `cluster_version` is now 1.16. Kubernetes 1.16 includes a number of deprecated API removals, and you need to ensure your applications and add ons are updated, or workloads could fail after the upgrade is complete. For more information on the API removals, see the [Kubernetes blog post](https://kubernetes.io/blog/2019/07/18/api-deprecations-in-1-16/). For action you may need to take before upgrading, see the steps in the [EKS documentation](https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html). Please set explicitly your `cluster_version` to an older EKS version until your workloads are ready for Kubernetes 1.16.


<a name="v11.1.0"></a>
## [v11.1.0] - 2020-04-23
BUG FIXES:
- Add `vpc_config.cluster_security_group` output as primary cluster security group id ([#828](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/828))
- Wrap `local.configmap_roles.groups` with tolist() to avoid panic ([#846](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/846))
- Prevent `coalescelist` null argument error when destroying worker_group_launch_templates ([#842](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/842))

FEATURES:
- Add support for EC2 principal in assume worker role policy for China ([#827](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/827))


<a name="v11.0.0"></a>
## [v11.0.0] - 2020-03-31
FEATURES:
- Add instance tag specifications to Launch Template ([#822](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/822))
- Add support for additional volumes in launch templates and launch configurations ([#800](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/800))
- Add interpreter option to `wait_for_cluster_cmd` ([#795](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/795))

ENHANCEMENTS:
- Use `aws_partition` to build IAM policy ARNs ([#820](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/820))
- Generate `aws-auth` configmap's roles from Object. No more string concat. ([#790](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/790))
- Add timeout to default wait_for_cluster_cmd ([#791](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/791))
- automate changelog management ([#786](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/786))

BUG FIXES:
- Fix destroy failure when talking to EKS endpoint on private network ([#815](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/815))
- add ip address when manage_aws_auth is true and public_access is false ([#745](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/745))
- Add node_group direct dependency on eks_cluster ([#796](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/796))
- Do not recreate cluster when no SG given ([#798](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/798))
- Create `false` and avoid waiting forever for a non-existent cluster to respond ([#789](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/789))
- fix git-chglog template to format changelog `Type` nicely ([#803](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/803))
- fix git-chglog configuration ([#802](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/802))

CI:
- Restrict sementic PR to validate PR title only ([#804](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/804))

TESTS:
- remove unused kitchen test related stuff ([#787](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/787))


[Unreleased]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v13.0.0...HEAD
[v13.0.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v12.2.0...v13.0.0
[v12.2.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v12.1.0...v12.2.0
[v12.1.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v12.0.0...v12.1.0
[v12.0.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v11.1.0...v12.0.0
[v11.1.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v11.0.0...v11.1.0
[v11.0.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v10.0.0...v11.0.0
