# Contributing

When contributing to this repository, please first discuss the change you wish to make via issue,
email, or any other method with the owners of this repository before making a change.

Please note we have a code of conduct, please follow it in all your interactions with the project.

## Pull Request Process

1.  Ensure any install or build dependencies are removed before the end of the layer when doing a build.
2.  Update the README.md with details of changes to the interface, this includes new environment variables, exposed ports, useful file locations and container parameters.
3. Once all outstanding comments and checklist items have been addressed, your contribution will be merged! Merged PRs will be included in the next release. The terraform-aws-eks mainteners takes care of updating the CHANGELOG as they merge.

## Checklists for contributions

- [ ] Add [sementics prefix](#semantic-pull-requests) to your PR or Commits (at leats one of your commit groups)
- [ ] CI tests are passing
- [ ] README.md has been updated after any changes to variables and outputs. See https://github.com/terraform-aws-modules/terraform-aws-eks/#doc-generation

## Semantic Pull Requests

To generate changelog, Pull Requests or Commits must have sementic and must follow conventional specs below:

- `feat:` for new features
- `fix:` for bug fixes
- `improvement:` for enhancements
- `docs:` for documentation and examples
- `refactor:` for code refactoring
- `test:` for tests
- `ci:` for CI purpose
- `chore:` for chores stuff

The `chore` prefix skipped during changelog generation. It can be used for `chore: update changelog` commit message by example.

