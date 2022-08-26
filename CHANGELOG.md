# Changelog

All notable changes to this project will be documented in this file.

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

* Add support for specifiying NTP address to use private Amazon Time Sync Service ([#2125](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2125)) ([4543ab4](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/4543ab454bea80b64381b88a631d955a7cfae247))

## [18.25.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.24.1...v18.25.0) (2022-06-28)


### Features

* Add support for creating KMS key for cluster secret encryption ([#2121](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2121)) ([75acb09](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/75acb09ec56c5ce8e5f74ebc7bf15468b272db8a))

### [18.24.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.24.0...v18.24.1) (2022-06-19)


### Bug Fixes

* Remove `modified_at` from ignored changes on EKS addons ([#2114](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2114)) ([5a5a32e](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/5a5a32ed1241ba3cc64abe37b37bcb5ad52d42c4))

## [18.24.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v18.23.0...v18.24.0) (2022-06-18)


### Features

* Add support for specifying conrol plane subnets separate from those used by node groups (data plane) ([#2113](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2113)) ([ebc91bc](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/ebc91bcd37a919a350d872a5b235ccc2a79955a6))

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

* Use the prefix_seperator var for node sg prefix ([#1751](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1751)) ([62879dd](https://github.com/terraform-aws-modules/terraform-aws-eks/commit/62879dd81a69ba010f19ba9ece8392e1730b53e0))

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
