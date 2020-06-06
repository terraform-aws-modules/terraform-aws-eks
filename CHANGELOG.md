# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this
project adheres to [Semantic Versioning](http://semver.org/).

<a name="unreleased"></a>
## [Unreleased]



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


[Unreleased]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v12.1.0...HEAD
[v12.1.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v12.0.0...v12.1.0
[v12.0.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v11.1.0...v12.0.0
[v11.1.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v11.0.0...v11.1.0
[v11.0.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v10.0.0...v11.0.0
