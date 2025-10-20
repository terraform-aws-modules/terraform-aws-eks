# Changelog

All notable changes to this project will be documented in this file.

## [21.6.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v21.5.0...v21.6.0) (2025-10-20)


### Features

* Use `aws_service_principal` data source for deriving IAM service prinicpals ([#3539](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3539)) ([0b0ca66](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/0b0ca6601923e8542f2f692994d5cb0671823c46))

## [21.5.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v21.4.0...v21.5.0) (2025-10-20)


### Features

* Allow for additional policy statements on sqs queue policy ([#3543](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3543)) ([67557e8](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/67557e8fe866dafd318a9c1d79b08bd9615a839b))

## [21.4.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v21.3.2...v21.4.0) (2025-10-14)


### Features

* Allow setting KMS key rotation period ([#3546](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3546)) ([fd490ea](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/fd490ea897117f3c9346c600cceece6b3fead7e7))

## [21.3.2](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v21.3.1...v21.3.2) (2025-10-06)


### Bug Fixes

* Incorporate AWS provider `v6.15` corrections for EKS Auto Mode to support enabling/disabling EKS Auto Mode without affecting non-Auto Mode users ([#3526](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3526)) ([f5f6dae](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/f5f6dae50737137d8709b5fe2f4129a1251eacca))

## [21.3.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v21.3.0...v21.3.1) (2025-09-16)


### Bug Fixes

* Sync Karpenter IAM permissions with upstream ([#3517](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3517)) ([c8bb152](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/c8bb152839c411247321194531eadbd7dcdeced4))

## [21.3.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v21.2.0...v21.3.0) (2025-09-16)


### Features

* Support EKS Auto Mode custom node pools only creation ([#3514](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3514)) ([165d7c8](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/165d7c8c3bb15b260c23bf07fa0443c0d3accd2f))

## [21.2.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v21.1.5...v21.2.0) (2025-09-11)


### Features

* Update Karpenter controller policy and permissions to match upstream project ([#3510](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3510)) ([131db39](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/131db3973f7eaf539c33b73014058a94ac0d0528))

## [21.1.5](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v21.1.4...v21.1.5) (2025-08-26)


### Bug Fixes

* Ensure module created security group is included on any network interfaces created ([#3495](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3495)) ([fa1d422](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/fa1d4221c8fd346927e88d617181fdb75790ecf8))

## [21.1.4](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v21.1.3...v21.1.4) (2025-08-25)


### Bug Fixes

* Ensure module created security group is included on any network interfaces created ([#3493](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3493)) ([e5cff84](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/e5cff842835f2bdede53db843c2b37b3d3534332))

## [21.1.3](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v21.1.2...v21.1.3) (2025-08-24)


### Bug Fixes

* Correct addon timeout lookup/override logic to support global and addon specific settings ([#3492](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3492)) ([b236208](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/b236208d5ce9ff14447f3d8d580b71790c8074e9))

## [21.1.2](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v21.1.1...v21.1.2) (2025-08-24)


### Bug Fixes

* Remediate type mismatch for EFA interfaces and ensure correct (local) definition is used ([#3491](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3491)) ([3959b65](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/3959b65672286c84c03012e12a2e7c8630db6c11))

## [21.1.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v21.1.0...v21.1.1) (2025-08-24)


### Bug Fixes

* Correct metadata options loop condition due to variable definition defaults ([#3490](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3490)) ([b40968a](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/b40968a503f1134adcb986af9b4c7f3f3514b811))

## [21.1.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v21.0.9...v21.1.0) (2025-08-15)


### Features

* Add support for deletion protection functionality in the cluster ([#3475](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3475)) ([83c9cd1](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/83c9cd187a36c10f46472e82a197212e897f7f0d))

## [21.0.9](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v21.0.8...v21.0.9) (2025-08-13)


### Bug Fixes

* Allow disabling instance refresh on self-managed node groups (part deux) ([#3478](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3478)) ([ca8f37e](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/ca8f37e8ce2a15d0b216ac30e431fa4ac03fc8bc))

## [21.0.8](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v21.0.7...v21.0.8) (2025-08-07)


### Bug Fixes

* Allow disabling instance refresh on self-managed node groups ([#3473](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3473)) ([6a887ad](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/6a887ad38686299c27333a83eb62310ed3106684))

## [21.0.7](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v21.0.6...v21.0.7) (2025-08-02)


### Bug Fixes

* Correct access policy logic to support not providing a policy to associate ([#3464](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3464)) ([39be61d](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/39be61d70232ba156fbf92ef90243b93fe5a9eee))

## [21.0.6](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v21.0.5...v21.0.6) (2025-07-30)


### Bug Fixes

* Allow `instance_requirements` to be set in self-managed node groups ([#3455](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3455)) ([5322bf7](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/5322bf72fbbff4afb6a02ae283b21419d9de5b17))

## [21.0.5](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v21.0.4...v21.0.5) (2025-07-29)


### Bug Fixes

* Correct addon logic lookup to pull latest addon version ([#3449](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3449)) ([55d7fa2](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/55d7fa23a356f518ae7b73ec2ddb0ab5947f9a42))

## [21.0.4](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v21.0.3...v21.0.4) (2025-07-25)


### Bug Fixes

* Correct encryption configuration enable logic; avoid creating Auto Mode policy when Auto Mode is not enabled ([#3439](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3439)) ([6b8a3d9](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/6b8a3d94777346d79a64ccd8287c96b525348013))

## [21.0.3](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v21.0.2...v21.0.3) (2025-07-24)


### Bug Fixes

* Correct variable defaults for `ami_id` and `kubernetes_version` ([#3437](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3437)) ([8807e0b](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/8807e0bb55fdc49ed894b5b51c14131526dbfb91))

## [21.0.2](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v21.0.1...v21.0.2) (2025-07-24)


### Bug Fixes

* Move `encryption_config` default for `resources` out of type definition and to default variable value to allow disabling encryption ([#3436](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3436)) ([b37368f](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/b37368fdbc608a026f9c17952d964467f5e44e8a))

## [21.0.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v21.0.0...v21.0.1) (2025-07-24)


### Bug Fixes

* Correct logic to try to use module created IAM role before falli… ([#3433](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3433)) ([97d4ebb](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/97d4ebbe68a23aa431a534fd7ed56a76f9b37801))

## [21.0.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.37.2...v21.0.0) (2025-07-23)


### ⚠ BREAKING CHANGES

* Upgrade min AWS provider and Terraform versions to `6.0` and `1.5.7` respectively (#3412)

### Features

* Upgrade min AWS provider and Terraform versions to `6.0` and `1.5.7` respectively ([#3412](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3412)) ([416515a](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/416515a0da1ca96c539977d6460e2bc02f10b4d4))

## [20.37.2](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.37.1...v20.37.2) (2025-07-17)


### Bug Fixes

* Allow for both `amazonaws.com.cn` and `amazonaws.com` conditions in PassRole as required for AWS CN ([#3422](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3422)) ([83b68fd](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/83b68fda2b0ea818fc980ab847dd8255a2d18334))

## [20.37.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.37.0...v20.37.1) (2025-06-18)


### Bug Fixes

* Restrict AWS provider max version due to v6 provider breaking changes ([#3384](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3384)) ([681a868](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/681a868d624878474fd9f92d1b04d3fec0120db7))

## [20.37.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.36.1...v20.37.0) (2025-06-09)


### Features

* Add AL2023 ARM64 NVIDIA variants ([#3369](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3369)) ([715d42b](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/715d42bf146791cad911b0b6979c5ce67bc0d2f6))

## [20.36.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.36.0...v20.36.1) (2025-06-09)


### Bug Fixes

* Ensure `additional_cluster_dns_ips` is passed through from root module ([#3376](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3376)) ([7a83b1b](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/7a83b1b3db9c7475fe6ec46d1c300c0a18f19b2a))

## [20.36.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.35.0...v20.36.0) (2025-04-18)


### Features

* Add support for cluster `force_update_version` ([#3345](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3345)) ([207d73f](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/207d73fbaa5eebe6e98b94e95b83fd0a5a13c307))

## [20.35.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.34.0...v20.35.0) (2025-03-29)


### Features

* Default to not changing autoscaling schedule values at the scheduled time ([#3322](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3322)) ([abf76f6](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/abf76f60144fe645bbf500d98505377fd4a9da79))

## [20.34.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.33.1...v20.34.0) (2025-03-07)


### Features

* Add capacity reservation permissions to Karpenter IAM policy ([#3318](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3318)) ([770ee99](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/770ee99d9c4b61c509d9988eac62de4db113af91))

## [20.33.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.33.0...v20.33.1) (2025-01-22)


### Bug Fixes

* Allow `"EC2"` access entry type for EKS Auto Mode custom node pools ([#3281](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3281)) ([3e2ea83](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/3e2ea83267d7532cb66fa4de7f0d2a944b43c3d5))

## [20.33.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.32.0...v20.33.0) (2025-01-17)


### Features

* Add node repair config to managed node group ([#3271](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3271)) ([edd7ef3](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/edd7ef36dd0f6b6801275cbecbb6780f03fc7aed)), closes [terraform-aws-modules/terraform-aws-eks#3249](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3249)

## [20.32.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.31.6...v20.32.0) (2025-01-17)


### Features

* Add Bottlerocket FIPS image variants ([#3275](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3275)) ([d876ac4](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/d876ac4ef1bb45e4f078d0928630033b659c9aa0))

## [20.31.6](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.31.5...v20.31.6) (2024-12-20)


### Bug Fixes

* Revert changes to disabling auto mode [#3253](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3253) ([#3255](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3255)) ([1ac67b8](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/1ac67b8a60e336285c4dca03e550dfc78d64acce))

## [20.31.5](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.31.4...v20.31.5) (2024-12-20)


### Bug Fixes

* Correct Auto Mode disable ([#3253](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3253)) ([2a6a57a](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/2a6a57a9bb1c6563608985bbdbfb7f47eec971df))

## [20.31.4](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.31.3...v20.31.4) (2024-12-14)


### Bug Fixes

* Auto Mode custom tag policy should apply to cluster role, not node role ([#3242](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3242)) ([a07013a](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/a07013a1f4d4d56b56eb2e6265a6f38041a4540b))

## [20.31.3](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.31.2...v20.31.3) (2024-12-12)


### Bug Fixes

* Update min provider version to remediate cluster replacement when enabling EKS Auto Mode ([#3240](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3240)) ([012e51c](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/012e51c05551da48a7f380d4a7b75880b0c24fe1))

## [20.31.2](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.31.1...v20.31.2) (2024-12-12)


### Bug Fixes

* Avoid trying to attach the node role when Auto Mode nodepools are not specified ([#3239](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3239)) ([ce34f1d](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/ce34f1db3f7824167d9a766e6c90dee3a6dcf1c3))

## [20.31.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.31.0...v20.31.1) (2024-12-09)


### Bug Fixes

* Create EKS Auto Mode role when Auto Mode is enabled, regardless of built-in node pool use ([#3234](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3234)) ([e2846be](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/e2846be8b110e59d36d6f868b74531a6d8ca4987))

## [20.31.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.30.1...v20.31.0) (2024-12-04)


### Features

* Add support for EKS Auto Mode and EKS Hybrid nodes ([#3225](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3225)) ([3b974d3](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/3b974d33ad79e142566dd7bcb4bf10472cc91899))

## [20.30.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.30.0...v20.30.1) (2024-11-26)


### Bug Fixes

* Coalesce local `resolve_conflicts_on_create_default` value to a boolean since default is `null` ([#3221](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3221)) ([35388bb](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/35388bb8c4cfa0c351427c133490b914b9944b07))

## [20.30.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.29.0...v20.30.0) (2024-11-26)


### Features

* Improve addon dependency chain and decrease time to provision addons (due to retries) ([#3218](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3218)) ([ab2207d](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/ab2207d50949079d5dd97c976c6f7a8f5b668f0c))

## [20.29.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.28.0...v20.29.0) (2024-11-08)


### Features

* Add support for pod identity association on EKS addons ([#3203](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3203)) ([a224334](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/a224334fc8000dc8728971dff8adad46ceb7a8a1))

## [20.28.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.27.0...v20.28.0) (2024-11-02)


### Features

* Add support for creating `efa-only` network interfaces ([#3196](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3196)) ([c6da22c](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/c6da22c78f60a8643a6c76f97c93724f4e1f4e5a))

## [20.27.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.26.1...v20.27.0) (2024-11-01)


### Features

* Add support for zonal shift ([#3195](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3195)) ([1b0ac83](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/1b0ac832647dcf0425aedba119fa8276008cbe28))

## [20.26.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.26.0...v20.26.1) (2024-10-27)


### Bug Fixes

* Use dynamic partition data source to determine DNS suffix for Karpenter EC2 pass role permission ([#3193](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3193)) ([dea6c44](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/dea6c44b459a546b1386563dfd497bc9d766bfe1))

## [20.26.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.25.0...v20.26.0) (2024-10-12)


### Features

* Add support for `desired_capacity_type` (named `desired_size_type`) on self-managed node group ([#3166](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3166)) ([6974a5e](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/6974a5e1582a4ed2d8b1f9a07cdacd156ba5ffef))

## [20.25.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.24.3...v20.25.0) (2024-10-12)


### Features

* Add support for newly released AL2023 accelerated AMI types ([#3177](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3177)) ([b2a8617](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/b2a8617794a782107399b26c1ff4503e0ea5ec3a))


### Bug Fixes

* Update CI workflow versions to latest ([#3176](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3176)) ([eb78240](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/eb78240617993845a2a85056655b16302ea9a02c))

## [20.24.3](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.24.2...v20.24.3) (2024-10-03)


### Bug Fixes

* Add `primary_ipv6` parameter to self-managed-node-group ([#3169](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3169)) ([fef6555](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/fef655585b33d717c1665bf8151f0573a17dedc2))

## [20.24.2](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.24.1...v20.24.2) (2024-09-21)


### Bug Fixes

* Remove deprecated `inline_policy` from cluster role ([#3163](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3163)) ([8b90872](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/8b90872983b9c349ff2e0a71678d687dc32ed626))

## [20.24.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.24.0...v20.24.1) (2024-09-16)


### Bug Fixes

* Correct Karpenter EC2 service principal DNS suffix in non-commercial regions ([#3157](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3157)) ([47ab3eb](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/47ab3eb884ab243a99322998445127ea6802fcaf))

## [20.24.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.23.0...v20.24.0) (2024-08-19)


### Features

* Add support for Karpenter v1 controller IAM role permissions ([#3126](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3126)) ([e317651](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/e31765153570631c1978e11cfd1d28e5fc349d8f))

## [20.23.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.22.1...v20.23.0) (2024-08-09)


### Features

* Add new output values for OIDC issuer URL and provider that are dual-stack compatible ([#3120](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3120)) ([72668ac](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/72668ac04a2879fd3294e6059238b4aed57278fa))

## [20.22.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.22.0...v20.22.1) (2024-08-09)


### Bug Fixes

* Eliminates null check on tag values to fix for_each error about unknown *keys* ([#3119](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3119)) ([6124a08](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/6124a08578d6c6bca1851df4c82cb7e2126e460a)), closes [#3118](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3118) [#2760](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2760) [#2681](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2681) [#2337](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2337)

## [20.22.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.21.0...v20.22.0) (2024-08-05)


### Features

* Enable update in place for node groups with cluster placement group strategy ([#3045](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3045)) ([75db486](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/75db486530459a04ce6eb2e4ed44b29d062de1b3))

## [20.21.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.20.0...v20.21.0) (2024-08-05)


### Features

* Add support for `upgrade_policy` ([#3112](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3112)) ([e12ab7a](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/e12ab7a5de4ac82968aaede419752ce2bbb6a93d))

## [20.20.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.19.0...v20.20.0) (2024-07-19)


### Features

* Enable support for ignore_failed_scaling_activities ([#3104](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3104)) ([532226e](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/532226e64e61328b25426cabc27e4009e085154f))

## [20.19.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.18.0...v20.19.0) (2024-07-15)


### Features

* Pass the `primary_ipv6` argument to the AWS provider. ([#3098](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3098)) ([e1bb8b6](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/e1bb8b66617299c6d9972139b1f9355322e7801e))

## [20.18.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.17.2...v20.18.0) (2024-07-15)


### Features

* Support `bootstrap_self_managed_addons` ([#3099](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3099)) ([af88e7d](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/af88e7d2f835b3dfde242157ba3dd98b749bbc0b))

## [20.17.2](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.17.1...v20.17.2) (2024-07-05)


### Bug Fixes

* Revert [#3058](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3058) - fix: Invoke aws_iam_session_context data source only when required ([#3092](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3092)) ([93ffdfc](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/93ffdfc6fa380cb0b73df7380e7e62302ebb1a98))

## [20.17.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.17.0...v20.17.1) (2024-07-05)


### Bug Fixes

* Invoke `aws_iam_session_context` data source only when required ([#3058](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3058)) ([f02df92](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/f02df92b66a9776a689a2baf39e7474f3b703d89))

## [20.17.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.16.0...v20.17.0) (2024-07-05)


### Features

* Add support for ML capacity block reservations with EKS managed node group(s) ([#3091](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3091)) ([ae3379e](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/ae3379e92429ed842f1c1017fd6ee59ec9f297d4))

## [20.16.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.15.0...v20.16.0) (2024-07-02)


### Features

* Add support for custom IAM role policy ([#3087](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3087)) ([1604c6c](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/1604c6cdc8cedcd47b7357c5068dc11d0ed1d7e5))

## [20.15.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.14.0...v20.15.0) (2024-06-27)


### Features

* Deny HTTP on Karpenter SQS policy ([#3080](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3080)) ([f6e071c](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/f6e071cd99faa56b988b63051b22df260e929b03))

## [20.14.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.13.1...v20.14.0) (2024-06-13)


### Features

* Require users to supply OS via `ami_type` and not via `platform` which is unable to distinquish between the number of variants supported today ([#3068](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3068)) ([ef657bf](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/ef657bfcb51296841f14cf514ffefb1066f810ee))

## [20.13.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.13.0...v20.13.1) (2024-06-04)


### Bug Fixes

* Correct syntax for correctly ignoring `bootstrap_cluster_creator_admin_permissions` and not all of `access_config` ([#3056](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3056)) ([1e31929](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/1e319290445a6eb50b53dfb89c9ae9f2949d38d7))

## [20.13.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.12.0...v20.13.0) (2024-05-31)


### Features

* Starting with `1.30`, do not use the cluster OIDC issuer URL by default in the identity provider config ([#3055](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3055)) ([00f076a](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/00f076ada4cd78c5c34b8be6e8eba44b628b629a))

## [20.12.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.11.1...v20.12.0) (2024-05-28)


### Features

* Support additional cluster DNS IPs with Bottlerocket based AMIs ([#3051](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3051)) ([541dbb2](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/541dbb29f12bb763a34b32acdaea9cea12d7f543))

## [20.11.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.11.0...v20.11.1) (2024-05-21)


### Bug Fixes

* Ignore changes to `bootstrap_cluster_creator_admin_permissions` which is disabled by default  ([#3042](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3042)) ([c65d308](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/c65d3085037d9c1c87f4fd3a5be1ca1d732dbf7a))

## [20.11.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.10.0...v20.11.0) (2024-05-16)


### Features

* Add `SourceArn` condition to Fargate profile trust policy ([#3039](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3039)) ([a070d7b](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/a070d7b2bd92866b91e0963a0f819eec9839ed03))

## [20.10.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.9.0...v20.10.0) (2024-05-09)


### Features

* Add support for Pod Identity assocation on Karpenter sub-module ([#3031](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3031)) ([cfcaf27](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/cfcaf27ac78278916ebf3d51dc64a20fe0d7bf01))

## [20.9.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.8.5...v20.9.0) (2024-05-08)


### Features

* Propagate `ami_type` to self-managed node group; allow using `ami_type` only ([#3030](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3030)) ([74d3918](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/74d39187d855932dd976da6180eda42dcfe09873))

## [20.8.5](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.8.4...v20.8.5) (2024-04-08)


### Bug Fixes

* Forces cluster outputs to wait until access entries are complete ([#3000](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3000)) ([e2a39c0](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/e2a39c0f261d776e4e18a650aa9068429c4f5ef4))

## [20.8.4](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.8.3...v20.8.4) (2024-03-21)


### Bug Fixes

* Pass nodeadm user data variables from root module down to nodegroup sub-modules ([#2981](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2981)) ([84effa0](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/84effa0e30f64ba2fceb7f89c2a822e92f1ee1ea))

## [20.8.3](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.8.2...v20.8.3) (2024-03-12)


### Bug Fixes

* Ensure the correct service CIDR and IP family is used in the rendered user data ([#2963](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2963)) ([aeb9f0c](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/aeb9f0c990b259320a6c3e5ff93be3f064bb9238))

## [20.8.2](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.8.1...v20.8.2) (2024-03-11)


### Bug Fixes

* Ensure a default `ip_family` value is provided to guarantee a CNI policy is attached to nodes ([#2967](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2967)) ([29dcca3](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/29dcca335d80e248c57b8efa2c36aaef2e1b1bd2))

## [20.8.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.8.0...v20.8.1) (2024-03-10)


### Bug Fixes

* Do not attach policy if Karpenter node role is not created by module ([#2964](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2964)) ([3ad19d7](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/3ad19d7435f34600e4872fd131e155583e498cd9))

## [20.8.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.7.0...v20.8.0) (2024-03-10)


### Features

* Replace the use of `toset()` with static keys for node IAM role policy attachment ([#2962](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2962)) ([57f5130](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/57f5130132ca11fd3e478a61a8fc082a929540c2))

## [20.7.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.6.0...v20.7.0) (2024-03-09)


### Features

* Add supprot for creating placement group for managed node group ([#2959](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2959)) ([3031631](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/30316312f33fe7fd09faf86fdb1b01ab2a377b2a))

## [20.6.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.5.3...v20.6.0) (2024-03-09)


### Features

* Add support for tracking latest AMI release version on managed nodegroups ([#2951](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2951)) ([393da7e](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/393da7ec0ed158cf783356ab10959d91430c1d80))

## [20.5.3](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.5.2...v20.5.3) (2024-03-08)


### Bug Fixes

* Update AWS provider version to support `AL2023_*` AMI types; ensure AL2023 user data receives cluster service CIDR ([#2960](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2960)) ([dfe4114](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/dfe41141c2385db783d97494792c8f2e227cfc7c))

## [20.5.2](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.5.1...v20.5.2) (2024-03-07)


### Bug Fixes

* Use the `launch_template_tags` on the launch template ([#2957](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2957)) ([0ed32d7](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/0ed32d7b291513f34775ca85b0aa33da085d09fa))

## [20.5.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.5.0...v20.5.1) (2024-03-07)


### Bug Fixes

* Update CI workflow versions to remove deprecated runtime warnings ([#2956](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2956)) ([d14cc92](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/d14cc925c450451b023407d05a2516d7682d1617))

## [20.5.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.4.0...v20.5.0) (2024-03-01)


### Features

* Add support for AL2023 `nodeadm` user data ([#2942](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2942)) ([7c99bb1](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/7c99bb19cdbf1eb4f4543f9b8e6d29c3a6734a55))

## [20.4.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.3.0...v20.4.0) (2024-02-23)


### Features

* Add support for enabling EFA resources ([#2936](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2936)) ([7f472ec](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/7f472ec660049d4ca85de039cb3015c1b1d12fb8))

## [20.3.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.2.2...v20.3.0) (2024-02-21)


### Features

* Add support for addon and identity provider custom tags ([#2938](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2938)) ([f6255c4](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/f6255c49e47d44bd62bb2b4e1e448ac80ceb2b3a))

### [20.2.2](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.2.1...v20.2.2) (2024-02-21)


### Bug Fixes

* Replace Karpenter SQS policy dynamic service princpal DNS suffixes with static `amazonaws.com` ([#2941](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2941)) ([081c762](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/081c7624a5a4f2b039370ae8eb9ee8e445d01c48))

### [20.2.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.2.0...v20.2.1) (2024-02-08)


### Bug Fixes

* Karpenter `enable_spot_termination = false` should not result in an error ([#2907](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2907)) ([671fc6e](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/671fc6e627d957ada47ef3f33068d715e79d25d6))

## [20.2.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.1.1...v20.2.0) (2024-02-06)


### Features

* Allow enable/disable of EKS pod identity for the Karpenter controller ([#2902](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2902)) ([cc6919d](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/cc6919de811f3972815d4ca26e5e0c8f64c2b894))

### [20.1.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.1.0...v20.1.1) (2024-02-06)


### Bug Fixes

* Update access entries `kubernetes_groups` default value to `null` ([#2897](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2897)) ([1e32e6a](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/1e32e6a9f8a389b1a4969dde697d34ba4e3c85ac))

## [20.1.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.0.1...v20.1.0) (2024-02-06)


### Features

* Add output for `access_policy_associations` ([#2904](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2904)) ([0d2a4c2](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/0d2a4c2af3d7c8593226bbccbf8753950e741b15))

### [20.0.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v20.0.0...v20.0.1) (2024-02-03)


### Bug Fixes

* Correct cluster access entry to create multiple policy associations per access entry ([#2892](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2892)) ([4177913](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/417791374cf72dfb673105359463398eb4a75d6e))

## [20.0.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.21.0...v20.0.0) (2024-02-02)


### ⚠ BREAKING CHANGES

* Replace the use of `aws-auth` configmap with EKS cluster access entry (#2858)

### Features

* Replace the use of `aws-auth` configmap with EKS cluster access entry ([#2858](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2858)) ([6b40bdb](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/6b40bdbb1d283d9259f43b03d24dca99cc1eceff))

## [19.21.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.20.0...v19.21.0) (2023-12-11)


### Features

* Add tags for CloudWatch log group only ([#2841](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2841)) ([4c5c97b](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/4c5c97b5d404a4e46945e3b6228d469743669937))

## [19.20.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.19.1...v19.20.0) (2023-11-14)


### Features

* Allow OIDC root CA thumbprint to be included/excluded ([#2778](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2778)) ([091c680](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/091c68051d9cbf24644121a24c715307f00c44b3))

### [19.19.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.19.0...v19.19.1) (2023-11-10)


### Bug Fixes

* Remove additional conditional on Karpenter instance profile creation to support upgrading ([#2812](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2812)) ([c36c8dc](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/c36c8dc825aa09e2ded20ff675905aa8857853cf))

## [19.19.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.18.0...v19.19.0) (2023-11-04)


### Features

* Update KMS module to avoid calling data sources when `create_kms_key = false` ([#2804](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2804)) ([0732bea](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/0732bea85f46fd2629705f9ee5f87cb695ee95e5))

## [19.18.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.17.4...v19.18.0) (2023-11-01)


### Features

* Add Karpenter v1beta1 compatibility ([#2800](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2800)) ([aec2bab](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/aec2bab1d8da89b65b84d11fef77cbc969fccc91))

### [19.17.4](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.17.3...v19.17.4) (2023-10-30)


### Bug Fixes

* Updating license_specification result type ([#2798](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2798)) ([ba0ebeb](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/ba0ebeb11a64a6400a3666165509975d5cdfea43))

### [19.17.3](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.17.2...v19.17.3) (2023-10-30)


### Bug Fixes

* Correct key used on `license_configuration_arn` ([#2796](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2796)) ([bd4bda2](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/bd4bda266e23635c7ca09b6e9d307b29ef6b8579))

### [19.17.2](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.17.1...v19.17.2) (2023-10-10)


### Bug Fixes

* Karpenter node IAM role policies variable should be a map of strings, not list ([#2771](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2771)) ([f4766e5](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/f4766e5c27f060e8c7f5950cf82d1fe59c3231af))

### [19.17.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.17.0...v19.17.1) (2023-10-06)


### Bug Fixes

* Only include CA thumbprint in OIDC provider list ([#2769](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2769)) ([7e5de15](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/7e5de1566c7e1330c05c5e6c51f5ab4690001915)), closes [#2732](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2732) [#32847](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/32847)

## [19.17.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.16.0...v19.17.0) (2023-10-06)


### Features

* Add support for `allowed_instance_types` on self-managed nodegroup ASG ([#2757](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2757)) ([feee18d](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/feee18dd423b1e76f8a5119206f23306e5879b26))

## [19.16.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.15.4...v19.16.0) (2023-08-03)


### Features

* Add `node_iam_role_arns` local variable to check for Windows platform on EKS managed nodegroups ([#2477](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2477)) ([adb47f4](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/adb47f46dc53b1a0c18691a59dc58401c327c0be))

### [19.15.4](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.15.3...v19.15.4) (2023-07-27)


### Bug Fixes

* Use `coalesce` when desired default value is not `null` ([#2696](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2696)) ([c86f8d4](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/c86f8d4db3236e7dae59ef9142da4d7e496138c8))

### [19.15.3](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.15.2...v19.15.3) (2023-06-09)


### Bug Fixes

* Snapshot permissions issue for Karpenter submodule ([#2649](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2649)) ([6217d0e](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/6217d0eaab4c864ec4d40a31538e78a7fbcee5e3))

### [19.15.2](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.15.1...v19.15.2) (2023-05-30)


### Bug Fixes

* Ensure `isra_tag_values` can be tried before defaulting to `cluster_name` on Karpenter module ([#2631](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2631)) ([6c56e2a](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/6c56e2ad20057a5672526b5484df96806598a4e2))

### [19.15.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.15.0...v19.15.1) (2023-05-24)


### Bug Fixes

* Revert changes to ignore `role_last_used` ([#2629](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2629)) ([e23139a](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/e23139ad2da0c31c8aa644ae0516ba9ee2a66399))

## [19.15.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.14.0...v19.15.0) (2023-05-24)


### Features

* Ignore changes to *.aws_iam_role.*.role_last_used ([#2628](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2628)) ([f8ea3d0](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/f8ea3d08adbc4abfb18a77ad44e30b93cd05c050))

## [19.14.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.13.1...v19.14.0) (2023-05-17)


### Features

* Add irsa_tag_values variable ([#2584](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2584)) ([aa3bdf1](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/aa3bdf1c19747bca7067c6e49c071ae80a9ca5e5))

### [19.13.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.13.0...v19.13.1) (2023-04-18)


### Bug Fixes

* SQS queue encryption types selection ([#2575](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2575)) ([969c7a7](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/969c7a7c4340c8ed327d18f86c5e00e18190a48b))

## [19.13.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.12.0...v19.13.0) (2023-04-12)


### Features

* Add support for allowed_instance_type ([#2552](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2552)) ([54417d2](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/54417d244c06b459b399e84433343af6e9934bb3))

## [19.12.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.11.0...v19.12.0) (2023-03-31)


### Features

* Add Autoscaling schedule for EKS managed node group ([#2504](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2504)) ([4a2523c](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/4a2523cddd4498f3ece5aee2eedf618dd701eb59))

## [19.11.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.10.3...v19.11.0) (2023-03-28)


### Features

* Add optional list of policy ARNs for attachment to Karpenter IRSA ([#2537](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2537)) ([bd387d6](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/bd387d69fac5a431a426e12de786ab80aea112a6))

### [19.10.3](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.10.2...v19.10.3) (2023-03-23)


### Bug Fixes

* Add `aws_eks_addons.before_compute` to the `cluster_addons` output ([#2533](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2533)) ([f977d83](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/f977d83500ac529b09918d4e78aa8887749a8cd1))

### [19.10.2](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.10.1...v19.10.2) (2023-03-23)


### Bug Fixes

* Add Name tag for EKS cloudwatch log group ([#2500](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2500)) ([e64a490](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/e64a490d8db4ebf495f42c542a40d7d763005873))

### [19.10.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.10.0...v19.10.1) (2023-03-17)


### Bug Fixes

* Return correct status for mng ([#2524](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2524)) ([e257daf](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/e257dafe94e11384caf210d9ff21c4d3e078cb17))

## [19.10.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.9.0...v19.10.0) (2023-02-17)


### Features

* Allow setting custom IRSA policy name for karpenter ([#2480](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2480)) ([8954ff7](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/8954ff7bb433358ba99b77248e3aae377d3a580b))

## [19.9.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.8.0...v19.9.0) (2023-02-17)


### Features

* Add support for enabling addons before data plane compute is created ([#2478](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2478)) ([78027f3](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/78027f37e43c79748cd7528d3803122cb8072ed7))

## [19.8.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.7.0...v19.8.0) (2023-02-15)


### Features

* Add auto discovery permission of cluster endpoint to Karpenter role ([#2451](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2451)) ([c4a4b8a](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/c4a4b8afe3d1e89117573e9e04aea08871a069dc))

## [19.7.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.6.0...v19.7.0) (2023-02-07)


### Features

* Allow to pass prefix for rule names ([#2437](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2437)) ([68fe60f](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/68fe60f1c4e975d7f6f2c22ae891a32fd80a0156))

## [19.6.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.5.1...v19.6.0) (2023-01-28)


### Features

* Add prometheus-adapter port 6443 to recommended sec groups ([#2399](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2399)) ([059dc0c](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/059dc0c67c2aebbf2c9a2f0a05856a823dd1b5a0))

### [19.5.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.5.0...v19.5.1) (2023-01-05)


### Bug Fixes

* AMI lookup should only happen when launch template is created ([#2386](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2386)) ([3834935](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/383493538748f1df844d40068cdde62579b79476))

## [19.5.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.4.3...v19.5.0) (2023-01-05)


### Features

* Ignore changes to labels and annotations on on `aws-auth` ConfigMap ([#2380](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2380)) ([5015b42](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/5015b429e656d927fb66f214c998713c6fc84755))

### [19.4.3](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.4.2...v19.4.3) (2023-01-05)


### Bug Fixes

* Use a version for  to avoid GitHub API rate limiting on CI workflows ([#2376](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2376)) ([460e43d](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/460e43db77244ad3ca2e62514de712fb0cc2cd7a))

### [19.4.2](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.4.1...v19.4.2) (2022-12-20)


### Bug Fixes

* Drop spot-instances-request from tag_specifications ([#2363](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2363)) ([e391a99](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/e391a99a7bd8209618fdb65cc09460673fbaf1bc))

### [19.4.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.4.0...v19.4.1) (2022-12-20)


### Bug Fixes

* Correct `eks_managed_*` to `self_managed_*` for `tag_specification` argument ([#2364](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2364)) ([df7c57c](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/df7c57c199d9e9f54d9ed18fb7c1e3a47ad732ed))

## [19.4.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.3.1...v19.4.0) (2022-12-19)


### Features

* Allow configuring which tags are passed on launch template tag specifications ([#2360](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2360)) ([094ed1d](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/094ed1d5e461552a0a76bc019c36690fe0fc2dd5))

### [19.3.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.3.0...v19.3.1) (2022-12-18)


### Bug Fixes

* Correct map name for security group rule 4443/tcp ([#2354](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2354)) ([13a9542](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/13a9542dadd29fa75fd76c2adcee9dd17dcffda4))

## [19.3.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.2.0...v19.3.0) (2022-12-18)


### Features

* Add additional port for `metrics-server` to recommended rules ([#2353](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2353)) ([5a270b7](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/5a270b7bf8de8c5846e91d72ffd9f594cbd8b921))

## [19.2.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.1.1...v19.2.0) (2022-12-18)


### Features

* Ensure all supported resources are tagged under `tag_specifications` on launch templates ([#2352](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2352)) ([0751a0c](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/0751a0ca04d6303015e8a9c2f917956ea00d184b))

### [19.1.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.1.0...v19.1.1) (2022-12-17)


### Bug Fixes

* Use IAM session context data source to resolve the identities role when using `assumed_role` ([#2347](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2347)) ([71b8eca](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/71b8ecaa87db89c454b2c9446ff3d7675e4dc5a7))

## [19.1.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.0.4...v19.1.0) (2022-12-16)


### Features

* Add support for addon `configuration_values` ([#2345](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2345)) ([3b62f6c](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/3b62f6c31604490fc19184e626e73873b296ecd1))

### [19.0.4](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.0.3...v19.0.4) (2022-12-07)


### Bug Fixes

* Ensure that custom KMS key is not created if encryption is not enabled, support computed values in cluster name ([#2328](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2328)) ([b83f6d9](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/b83f6d98bfbca548012ea74e792fe14f04f0e6dc))

### [19.0.3](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.0.2...v19.0.3) (2022-12-07)


### Bug Fixes

* Invalid value for "replace" parameter: argument must not be null. ([#2322](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2322)) ([9adc475](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/9adc475bc1f1a201648e37b26cefe9bdf6b3a2f7))

### [19.0.2](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.0.1...v19.0.2) (2022-12-06)


### Bug Fixes

* `public_access_cidrs` require a value even if public endpoint is disabled ([#2320](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2320)) ([3f6d915](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/3f6d915eef6672440df8c82468c31ed2bc2fce54))

### [19.0.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v19.0.0...v19.0.1) (2022-12-06)


### Bug Fixes

* Call to lookup() closed too early, breaks sg rule creation in cluster sg if custom source sg is defined. ([#2319](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2319)) ([7bc4a27](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/7bc4a2743f0cdf9c8556a2c067eeb82436aafb41))

## [19.0.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.31.2...v19.0.0) (2022-12-05)


### ⚠ BREAKING CHANGES

* Add support for Outposts, remove node security group, add support for addon `preserve` and `most_recent` configurations (#2250)

### Features

* Add support for Outposts, remove node security group, add support for addon `preserve` and `most_recent` configurations ([#2250](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2250)) ([b2e97ca](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/b2e97ca3dcbcd76063f1c932aa5199b4f49a2aa1))

### [18.31.2](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.31.1...v18.31.2) (2022-11-23)


### Bug Fixes

* Ensure that `var.create` is tied to all resources correctly ([#2308](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2308)) ([3fb28b3](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/3fb28b357f4fc9144340f94abe9dd520e89f49e2))

### [18.31.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.31.0...v18.31.1) (2022-11-22)


### Bug Fixes

* Include all certificate fingerprints in the OIDC provider thumbprint list ([#2307](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2307)) ([7436178](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/7436178cc1a720a066c73f1de23b04b3c24ae608))

## [18.31.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.30.3...v18.31.0) (2022-11-21)


### Features

* New Karpenter sub-module for easily enabling Karpenter on EKS ([#2303](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2303)) ([f24de33](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/f24de3326d3c12ce61fbaefe1e3dbe7418d8bc85))

### [18.30.3](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.30.2...v18.30.3) (2022-11-07)


### Bug Fixes

* Update CI configuration files to use latest version ([#2293](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2293)) ([364c60d](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/364c60d572e85676adca8f6e62679de7d9551271))

### [18.30.2](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.30.1...v18.30.2) (2022-10-14)


### Bug Fixes

* Disable creation of cluster security group rules that map to node security group when `create_node_security_group` = `false` ([#2274](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2274)) ([28ccece](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/28ccecefe22d81a3a7febbbc3efc17c6590f88e1))

### [18.30.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.30.0...v18.30.1) (2022-10-11)


### Bug Fixes

* Update CloudWatch log group creation deny policy to use wildcard ([#2267](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2267)) ([ac4d549](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/ac4d549629aa64bbd92f80486bef904a9098e0fa))

## [18.30.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.29.1...v18.30.0) (2022-09-29)


### Features

* Add output for cluster TLS certificate SHA1 fingerprint and provider tags to cluster primary security group ([#2249](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2249)) ([a74e980](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/a74e98017b5dc7ed396cf26bfaf98ff7951c9e2e))

### [18.29.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.29.0...v18.29.1) (2022-09-26)


### Bug Fixes

* Set `image_id` to come from the launch template instead of data source for self-managed node groups ([#2239](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2239)) ([c5944e5](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/c5944e5fb6ea07429ef79f5fe5592e7111567e1e))

## [18.29.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.28.0...v18.29.0) (2022-08-26)


### Features

* Allow TLS provider to use versions 3.0+ (i.e. - `>= 3.0`) ([#2211](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2211)) ([f576a6f](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/f576a6f9ea523c94a7bb5420d5ab3ed8c7d3fec7))

## [18.28.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.27.1...v18.28.0) (2022-08-17)


### Features

* Add output for launch template name, and correct variable type value ([#2205](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2205)) ([0a52d69](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/0a52d690d54a7c39fd4e0d46db36d200f7ef679e))

### [18.27.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.27.0...v18.27.1) (2022-08-09)


### Bug Fixes

* Remove empty `""` from node group names output when node group creation is disabled ([#2197](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2197)) ([d2f162b](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/d2f162b190596756f1bc9d8f8061e68329c3e5c4))

## [18.27.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.26.6...v18.27.0) (2022-08-09)


### Features

* Default to clusters OIDC issuer URL for `aws_eks_identity_provider_config` ([#2190](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2190)) ([93065fa](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/93065fabdf508267b399f677d561f18fd6d7b7f0))

### [18.26.6](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.26.5...v18.26.6) (2022-07-22)


### Bug Fixes

* Pin TLS provider version to 3.x versions only ([#2174](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2174)) ([d990ea8](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/d990ea8aff682315828d7c177a309c71541e023c))

### [18.26.5](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.26.4...v18.26.5) (2022-07-20)


### Bug Fixes

* Bump kms module to 1.0.2 to fix malformed policy document when not specifying key_owners ([#2163](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2163)) ([0fd1ab1](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/0fd1ab1db9b752e58211428e3c19f62655e5f97d))

### [18.26.4](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.26.3...v18.26.4) (2022-07-20)


### Bug Fixes

* Use partition data source on VPC CNI IPv6 policy ([#2161](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2161)) ([f2d67ff](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/f2d67ffa97cc0f9827f75673b1cd263e3a5062b6))

### [18.26.3](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.26.2...v18.26.3) (2022-07-05)


### Bug Fixes

* Correct Fargate profiles additional IAM role policies default type to match variable ([#2143](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2143)) ([c4e6d28](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/c4e6d28fc064435f6f05c6c57d7fff8576d9fbba))

### [18.26.2](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.26.1...v18.26.2) (2022-07-01)


### Bug Fixes

* Correct variable types to improve dynamic check correctness ([#2133](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2133)) ([2d7701c](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/2d7701c3b0f2c6dcc10f31fc1f703bfde31b2c5b))

### [18.26.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.26.0...v18.26.1) (2022-06-29)


### Bug Fixes

* Update KMS module version which aligns on module version requirements ([#2127](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2127)) ([bc04cd3](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/bc04cd3a0a4286566ea56b20d9314115c6e489ab))

## [18.26.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.25.0...v18.26.0) (2022-06-28)


### Features

* Add support for specifying NTP address to use private Amazon Time Sync Service ([#2125](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2125)) ([4543ab4](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/4543ab454bea80b64381b88a631d955a7cfae247))

## [18.25.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.24.1...v18.25.0) (2022-06-28)


### Features

* Add support for creating KMS key for cluster secret encryption ([#2121](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2121)) ([75acb09](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/75acb09ec56c5ce8e5f74ebc7bf15468b272db8a))

### [18.24.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.24.0...v18.24.1) (2022-06-19)


### Bug Fixes

* Remove `modified_at` from ignored changes on EKS addons ([#2114](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2114)) ([5a5a32e](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/5a5a32ed1241ba3cc64abe37b37bcb5ad52d42c4))

## [18.24.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.23.0...v18.24.0) (2022-06-18)


### Features

* Add support for specifying control plane subnets separate from those used by node groups (data plane) ([#2113](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2113)) ([ebc91bc](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/ebc91bcd37a919a350d872a5b235ccc2a79955a6))

## [18.23.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.22.0...v18.23.0) (2022-06-02)


### Features

* Add `autoscaling_group_tags` variable to self-managed-node-groups ([#2084](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2084)) ([8584dcb](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/8584dcb2e0c9061828505c36a8ed8eb6ced02053))

## [18.22.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.21.0...v18.22.0) (2022-06-02)


### Features

* Apply `distinct()` on role arns to ensure no duplicated roles in aws-auth configmap ([#2097](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2097)) ([3feb369](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/3feb36927f92fb72ab0cfc25a3ab67465872f4bf))

## [18.21.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.20.5...v18.21.0) (2022-05-12)


### Features

* Add `create_autoscaling_group` option and extra outputs ([#2067](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2067)) ([58420b9](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/58420b92a0838aa2e17b156b174893b349083a2b))

### [18.20.5](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.20.4...v18.20.5) (2022-04-21)


### Bug Fixes

* Add conditional variable to allow users to opt out of tagging cluster primary security group ([#2034](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2034)) ([51e4182](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/51e418216f210647b69bbd06e569a061c2f0e3c1))

### [18.20.4](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.20.3...v18.20.4) (2022-04-20)


### Bug Fixes

* Correct DNS suffix for OIDC provider ([#2026](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2026)) ([5da692d](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/5da692df67cae313711e94216949d1105da6a87f))

### [18.20.3](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.20.2...v18.20.3) (2022-04-20)


### Bug Fixes

* Add `compact()` to `aws_auth_configmap_yaml` for when node groups are set to `create = false` ([#2029](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2029)) ([c173ba2](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/c173ba2d62d228729fe6c68f713af6dbe15e7233))

### [18.20.2](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.20.1...v18.20.2) (2022-04-12)


### Bug Fixes

* Avoid re-naming the primary security group through a `Name` tag and leave to the EKS service to manage ([#2010](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2010)) ([b5ae5da](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/b5ae5daa39f8380dc21c9ef1daff22242930692e))

### [18.20.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.20.0...v18.20.1) (2022-04-09)


### Bug Fixes

* iam_role_user_name_prefix type as an bool ([#2000](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2000)) ([c576aad](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/c576aadce968d09f3295fc06f0766cc9e2a35e29))

## [18.20.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.19.0...v18.20.0) (2022-04-09)


### Features

* Add support for managing `aws-auth` configmap using new `kubernetes_config_map_v1_data` resource ([#1999](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1999)) ([da3d54c](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/da3d54cde70adfd8b5d2770805b17d526923113e))

## [18.19.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.18.0...v18.19.0) (2022-04-04)


### Features

* Add `create_before_destroy` lifecycle hook to security groups created ([#1985](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1985)) ([6db89f8](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/6db89f8f20a58ae5cfbab5541ff7e499ddf971b8))

## [18.18.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.17.1...v18.18.0) (2022-04-03)


### Features

* Add support for allowing EFA network interfaces ([#1980](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1980)) ([523144e](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/523144e1d7d4f64ccf30656078fd10d7cd63a444))

### [18.17.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.17.0...v18.17.1) (2022-04-02)


### Bug Fixes

* Correct `capacity_reservation_target` within launch templates of both EKS and self managed node groups ([#1979](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1979)) ([381144e](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/381144e3bb604b3086ceea537a6052a6179ce5b3))

## [18.17.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.16.0...v18.17.0) (2022-03-30)


### Features

* Add back in CloudWatch log group create deny policy to cluster IAM role ([#1974](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1974)) ([98e137f](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/98e137fad990d51a31d86e908ea593e933fc22a9))

## [18.16.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.15.0...v18.16.0) (2022-03-29)


### Features

* Support default_tags in aws_autoscaling_group ([#1973](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1973)) ([7a9458a](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/7a9458af52ddf1f6180324e845b1e8a26fd5c1f5))

## [18.15.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.14.1...v18.15.0) (2022-03-25)


### Features

* Update TLS provider and remove unnecessary cloud init version requirements ([#1966](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1966)) ([0269d38](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/0269d38fcae2b1ca566427159d33910fe96299a7))

### [18.14.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.14.0...v18.14.1) (2022-03-24)


### Bug Fixes

* Default to cluster version for EKS and self managed node groups when a `cluster_version` is not specified ([#1963](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1963)) ([fd3a3e9](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/fd3a3e9a96d9a8fa9b22446e2ac8c36cdf68c5fc))

## [18.14.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.13.0...v18.14.0) (2022-03-24)


### Features

* Add tags to EKS created cluster security group to match rest of module tagging scheme ([#1957](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1957)) ([9371a29](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/9371a2943b13cc2d9ceb34aef14ec2ccee1cb721))

## [18.13.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.12.0...v18.13.0) (2022-03-23)


### Features

* Allow users to selectively attach the EKS created cluster primary security group to nodes ([#1952](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1952)) ([e21db83](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/e21db83d8ff3cd1d3f49acc611931e8917d0b6f8))

## [18.12.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.11.0...v18.12.0) (2022-03-22)


### Features

* Add outputs for autoscaling group names created to aid in autoscaling group tagging ([#1953](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1953)) ([8b03b7b](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/8b03b7b85ef80db5de766827ef65b700317c68e6))

## [18.11.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.10.2...v18.11.0) (2022-03-18)


### Features

* Allow users to specify default launch template name in node groups ([#1946](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1946)) ([a9d2cc8](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/a9d2cc8246128fc7f426f0b4596c6799ecf94d8a))

### [18.10.2](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.10.1...v18.10.2) (2022-03-17)


### Bug Fixes

* Sub-modules output the correct eks worker iam arn when workers utilize custom iam role ([#1912](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1912)) ([06a3469](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/06a3469d203fc4344d5f94564762432b5cfd2043))

### [18.10.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.10.0...v18.10.1) (2022-03-15)


### Bug Fixes

* Compact result of cluster security group to avoid disruptive updates when no security groups are supplied ([#1934](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1934)) ([5935670](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/5935670503bba3405b53e49ddd88a6451f534d4a))

## [18.10.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.9.0...v18.10.0) (2022-03-12)


### Features

* Made it clear that we stand with Ukraine ([fad350d](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/fad350d5bf36a7e39aa3840926b4c9968e9f594c))

## [18.9.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.8.1...v18.9.0) (2022-03-09)


### Features

* Add variables to allow users to control attributes on `cluster_encryption` IAM policy ([#1928](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1928)) ([2df1572](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/2df1572b8a031fbd31a845cc5c61f015ec387f56))

### [18.8.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.8.0...v18.8.1) (2022-03-02)


### Bug Fixes

* Ensure that cluster encryption policy resources are only relevant when creating the IAM role ([#1917](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1917)) ([0fefca7](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/0fefca76f2258cee565359e36a4851978602f36d))

## [18.8.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.7.3...v18.8.0) (2022-03-02)


### Features

* Add additional IAM policy to allow cluster role to use KMS key provided for cluster encryption ([#1915](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1915)) ([7644952](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/7644952131a466ca22ba5b3e62cd988e01eff716))

### [18.7.3](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.7.2...v18.7.3) (2022-03-02)


### Bug Fixes

* Add support for overriding DNS suffix for cluster IAM role service principal endpoint ([#1905](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1905)) ([9af0c24](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/9af0c2495a1fe7a02411ac436f48f6d9ca8b359f))

### [18.7.2](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.7.1...v18.7.2) (2022-02-16)


### Bug Fixes

* Update examples to show integration and usage of new IRSA submodule ([#1882](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1882)) ([8de02b9](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/8de02b9ff4690d1bbefb86d3441662b16abb03dd))

### [18.7.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.7.0...v18.7.1) (2022-02-15)


### Bug Fixes

* Add missing quotes to block_duration_minutes ([#1881](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1881)) ([8bc6488](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/8bc6488d559d603b539bc1a9c4eb8c57c529b25e))

## [18.7.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.6.1...v18.7.0) (2022-02-15)


### Features

* Add variable to provide additional OIDC thumbprints ([#1865](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1865)) ([3fc9f2d](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/3fc9f2d69c32a2536aaee45adbe0c3449d7fc986))

### [18.6.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.6.0...v18.6.1) (2022-02-15)


### Bug Fixes

* Update autoscaling group `tags` -> `tag` to support v4 of AWS provider ([#1866](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1866)) ([74ad4b0](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/74ad4b09b7bbee857c833cb92afe07499356831d))

## [18.6.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.5.1...v18.6.0) (2022-02-11)


### Features

* Add additional output for OIDC provider (issuer URL without leading `https://`) ([#1870](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1870)) ([d3b6847](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/d3b68479dea49076a36e0c39e8c41407f270dcad))

### [18.5.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.5.0...v18.5.1) (2022-02-09)


### Bug Fixes

* Use existing node security group when one is provided ([#1861](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1861)) ([c821ba7](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/c821ba78ca924273d17e9c3b15eae05dd7fb9c94))

## [18.5.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.4.1...v18.5.0) (2022-02-08)


### Features

* Allow conditional creation of node groups to be set within node group definitions ([#1848](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1848)) ([665f468](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/665f468c1f4839836b1cb5fa5f18ebba17696288))

### [18.4.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.4.0...v18.4.1) (2022-02-07)


### Bug Fixes

* Add node group dependency for EKS addons resource creation ([#1840](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1840)) ([2515e0e](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/2515e0e561509d026fd0d4725ab0bd864e7340f9))

## [18.4.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.3.1...v18.4.0) (2022-02-06)


### Features

* enable IRSA by default ([#1849](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1849)) ([21c3802](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/21c3802dea52bf51ab99c322fcfdce554086a794))

### [18.3.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.3.0...v18.3.1) (2022-02-04)


### Bug Fixes

* The `block_duration_minutes` attribute under launch template `spot_options` is not a required ([#1847](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1847)) ([ccc4747](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/ccc4747122b29ac35975e3c89edaa6ee28a86e4a))

## [18.3.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.2.7...v18.3.0) (2022-02-03)


### Features

* Add launch_template_tags variable for additional launch template tags ([#1835](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1835)) ([9186def](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/9186defcf6ef72502131cffb8b781e1591d2139e))

### [18.2.7](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.2.6...v18.2.7) (2022-02-02)


### Bug Fixes

* Don't tag self managed node security group with kubernetes.io/cluster tag ([#1774](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1774)) ([a638e4a](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/a638e4a754c15ab230cfb0e91de026e038ca4e26))

### [18.2.6](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.2.5...v18.2.6) (2022-02-01)


### Bug Fixes

* Wrong rolearn in aws_auth_configmap_yaml ([#1820](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1820)) ([776009d](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/776009d74b16e97974534668ca01a950d660166a))

### [18.2.5](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.2.4...v18.2.5) (2022-02-01)


### Bug Fixes

* Correct issue where custom launch template is not used when EKS managed node group is used externally ([#1824](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1824)) ([e16b3c4](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/e16b3c4cbd5f139d54467965f690e79f8e68b76b))

### [18.2.4](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.2.3...v18.2.4) (2022-01-30)


### Bug Fixes

* add missing `launch_template_use_name_prefix` parameter to the root module ([#1818](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1818)) ([d6888b5](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/d6888b5eb6748a065063b0679f228f9fbbf93284))

### [18.2.3](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.2.2...v18.2.3) (2022-01-24)


### Bug Fixes

* Add missing `mixed_instances_policy` parameter to the root module ([#1808](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1808)) ([4af77f2](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/4af77f244a558ec66db6561488a5d8cd0c0f1aed))

### [18.2.2](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.2.1...v18.2.2) (2022-01-22)


### Bug Fixes

* Attributes in timeouts are erroneously reversed ([#1804](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1804)) ([f8fe584](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/f8fe584d5b50cc4009ac6c34e3bbb33a4e282f2e))

### [18.2.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.2.0...v18.2.1) (2022-01-18)


### Bug Fixes

* Change `instance_metadata_tags` to default to `null`/`disabled` due to tag key pattern conflict ([#1788](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1788)) ([8e4dfa2](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/8e4dfa2be5c60e98a9b20a8ae716c5c446fe935c))

## [18.2.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.1.0...v18.2.0) (2022-01-14)


### Features

* Add `instance_metadata_tags` attribute to launch templates ([#1781](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1781)) ([85bb1a0](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/85bb1a00b6111845141a8c07a9459bbd160d7ed3))

## [18.1.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.0.6...v18.1.0) (2022-01-14)


### Features

* Add support for networking `ip_family` which enables support for IPV6 ([#1759](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1759)) ([314192e](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/314192e2ebc5faaf5f027a7d868cd36c4844aee1))

### [18.0.6](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.0.5...v18.0.6) (2022-01-11)


### Bug Fixes

* Correct remote access variable for security groups and add example for additional IAM policies ([#1766](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1766)) ([f54bd30](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/f54bd3047ba18179766641e347fe9f4fa60ff11b))

### [18.0.5](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.0.4...v18.0.5) (2022-01-08)


### Bug Fixes

* Use the prefix_separator var for node sg prefix ([#1751](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1751)) ([62879dd](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/62879dd81a69ba010f19ba9ece8392e1730b53e0))

### [18.0.4](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.0.3...v18.0.4) (2022-01-07)


### Bug Fixes

* Not to iterate over remote_access object in dynamic block ([#1743](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1743)) ([86b3c33](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/86b3c339a772e76239f97a9bb1f710199d1bd04a))

### [18.0.3](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.0.2...v18.0.3) (2022-01-06)


### Bug Fixes

* Remove trailing hyphen from cluster security group and iam role name prefix ([#1745](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1745)) ([7089c71](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/7089c71e64dbae281435629e19d647ae6952f9ac))

### [18.0.2](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.0.1...v18.0.2) (2022-01-06)


### Bug Fixes

* Change variable "node_security_group_additional_rules" from type map(any) to any ([#1747](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1747)) ([8921827](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/89218279d4439110439ca4cb8ac94575ab92b042))

### [18.0.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.0.0...v18.0.1) (2022-01-06)


### Bug Fixes

* Correct conditional map for cluster security group additional rules ([#1738](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1738)) ([a2c7caa](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/a2c7caac9f01ef167994d8b62afb5f997d0fac66))

## [18.0.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v17.24.0...v18.0.0) (2022-01-05)


### ⚠ BREAKING CHANGES

* Removed support for launch configuration and replace `count` with `for_each` (#1680)

### Features

* Removed support for launch configuration and replace `count` with `for_each` ([#1680](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1680)) ([ee9f0c6](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/ee9f0c646a45ca9baa6174a036d1e09bcccb87b1))


### Bug Fixes

* Update preset rule on semantic-release to use conventional commits ([#1736](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1736)) ([be86c0b](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/be86c0b898c34943e898e2ecd4994bb7904663ff))

# [17.24.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v17.23.0...v17.24.0) (2021-11-22)


### Bug Fixes

* Added Deny for CreateLogGroup action in EKS cluster role ([#1594](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1594)) ([6959b9b](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/6959b9bae32309357bc97a85a1f09c7b590c8a6d))
* update CI/CD process to enable auto-release workflow ([#1698](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1698)) ([b876ff9](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/b876ff95136fbb419cbb33feaa8f354a053047e0))


### Features

* Add ability to define custom timeout for fargate profiles ([#1614](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1614)) ([b7539dc](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/b7539dc220f6b5fe199d67569b6f3619ec00fdf0))
* Removed ng_depends_on variable and related hack ([#1672](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1672)) ([56e93d7](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/56e93d77de58f311f1d1d7051f40bf77e7b03524))

<a name="v17.23.0"></a>
## [v17.23.0] - 2021-11-02
FEATURES:
- Added support for client.authentication.k8s.io/v1beta1 ([#1550](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1550))
- Improve managed node group bootstrap revisited ([#1577](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1577))

BUG FIXES:
- Fixed variable reference for snapshot_id ([#1634](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1634))


<a name="v17.22.0"></a>
## [v17.22.0] - 2021-10-14
BUG FIXES:
- MNG cluster datasource errors ([#1639](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1639))


<a name="v17.21.0"></a>
## [v17.21.0] - 2021-10-12
FEATURES:
- Fix custom AMI bootstrap ([#1580](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1580))
- Enable throughput & iops configs for managed node_groups ([#1584](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1584))
- Allow snapshot_id to be specified for additional_ebs_volumes ([#1431](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1431))
- Allow interface_type to be specified in worker_groups_launch_template ([#1439](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1439))

BUG FIXES:
- Rebuild examples ([#1625](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1625))
- Bug with data source in managed groups submodule ([#1633](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1633))
- Fixed launch_templates_with_managed_node_group example ([#1599](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1599))

DOCS:
- Update iam-permissions.md ([#1613](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1613))
- Updated iam-permissions.md ([#1612](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1612))
- Updated faq about desired count of instances in node and worker groups ([#1604](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1604))
- Update faq about endpoints ([#1603](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1603))
- Fix broken URL in README ([#1602](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1602))
- Remove `asg_recreate_on_change` in faq ([#1596](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1596))


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
- Since we now search only for Linux or Windows AMI if there is a worker groups for the corresponding platform, we can now define different default root block device name for each platform. Use locals `root_block_device_name` and `root_block_device_name_windows` to define your owns.
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
- Use IRSA for Node Termination Handler IAM policy attachment in Instance Refresh example ([#1373](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1373))


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
- Don't set -x in userdata to avoid printing sensitive information in logs ([#1187](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1187))

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
`wait_for_cluster` null resource. This means that initialization of the
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
- Restrict semantic PR to validate PR title only ([#804](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/804))


[Unreleased]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v17.23.0...HEAD
[v17.23.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v17.22.0...v17.23.0
[v17.22.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v17.21.0...v17.22.0
[v17.21.0]: https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v17.20.0...v17.21.0
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
