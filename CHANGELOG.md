# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this
project adheres to [Semantic Versioning](http://semver.org/).

## [[v0.2.0](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v0.1.1...v0.2.0)] - 2018-06-08]

### Changed

- files rendered from dedicated templates to separate out raw code and config from `hcl`
- `workers_ami_id` is now made optional. If not specified, the module will source the latest AWS supported EKS AMI instead.
- added ability to specify extra userdata code to execute after the second to configure and start kube services.

## [[v0.1.1](https://github.com/terraform-aws-modules/terraform-aws-eks/compare/v0.1.0...v0.1.1)] - 2018-06-07]

### Changed

- pre-commit hooks fixed and working.
- made progress on CI, advancing the build to the final `kitchen test` stage before failing.

## [v0.1.0] - 2018-06-07

### Added

- Everything! Initial release of the module.
- added a local variable to do a lookup against for a dynamic value in userdata which was previously static. Kudos to @tanmng for finding and fixing bug #1!
