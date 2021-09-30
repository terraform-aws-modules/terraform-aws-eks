# Contributing

When contributing to this repository, please first discuss the change you wish to make via issue,
email, or any other method with the owners of this repository before making a change. 

Please note we have a code of conduct, please follow it in all your interactions over the project.

## Reporting Bugs

This section guides you through submitting a bug report for DNX. Following these guidelines helps maintainers and the community understand your report, reproduce the behavior, and find related reports.

Before creating bug reports, please check this list as you might find out that you don't need to create one. When you are creating a bug report, please [include as many details as possible](#how-do-i-submit-a-good-bug-report). Fill out [the required template, the information it asks for helps us resolve issues faster.


#### How Do I Submit A (Good) Bug Report?

Bugs are tracked as [GitHub issues](https://guides.github.com/features/issues/). Create an issue on the repository and provide the following information by filling in the template.

Explain the problem and include additional details to help maintainers reproduce the problem:

* **Use a clear and descriptive title** for the issue to identify the problem.
* **Describe the exact steps which reproduce the problem** in as many details as possible. For example, start by explaining how you started the module, e.g. which command exactly you used in the terminal.
* **Provide specific examples to demonstrate the steps**. Include links to files or GitHub projects, or copy/pasteable snippets, which you use in those examples. If you're providing snippets in the issue, use [Markdown code blocks](https://docs.github.com/pt/github/writing-on-github/working-with-advanced-formatting/creating-and-highlighting-code-blocks).
* **Describe the behavior you observed after following the steps** and point out what exactly is the problem with that behavior.
* **If the problem wasn't triggered by a specific action**, describe what you were doing before the problem happened and share more information using the guidelines below.

Provide more context by answering these questions:

* **Did the problem start happening recently** (e.g. after updating to a new version of Terraform) or was this always a problem?
* If the problem started happening recently, **can you reproduce the problem in an older version of Terraform?** What's the most recent version in which the problem doesn't happen? You can download older versions of Terraform from [the releases page](https://github.com/hashicorp/terraform/releases).
* **Can you reliably reproduce the issue?** If not, provide details about how often the problem happens and under which conditions it normally happens.
* If the problem is related to working with files (e.g. opening and editing files), **does the problem happen for all files and projects or only some?** Does the problem happen only when working with local or remote files (e.g. on network drives), with files of a specific type (e.g. only JavaScript or Python files), with large files or files with very long lines, or with files in a specific encoding? Is there anything else special about the files you are using?
### Suggesting Enhancements

This section guides you through submitting an enhancement suggestion for DNX modules, including completely new features and minor improvements to existing functionality. Following these guidelines helps maintainers and the community understand your suggestion and find related suggestions.

Before creating enhancement suggestions, please check issues as you might find out that you don't need to create one. When you are creating an enhancement suggestion, please include as many details as possible. Fill in the template, including the steps that you imagine you would take if the feature you're requesting existed.

#### How Do I Submit A (Good) Enhancement Suggestion?

Enhancement suggestions are tracked as [GitHub issues](https://guides.github.com/features/issues/). Create an issue on that repository and provide the following information:

* **Use a clear and descriptive title** for the issue to identify the suggestion.
* **Provide a step-by-step description of the suggested enhancement** in as many details as possible.
* **Provide specific examples to demonstrate the steps**. Include copy/pasteable snippets which you use in those examples, as [Markdown code blocks](https://help.github.com/articles/markdown-basics/#multiple-lines).
* **Describe the current behavior** and **explain which behavior you expected to see instead** and why.
* **Include screenshots and animated GIFs** which help you demonstrate the steps or point out the part of code which the suggestion is related. You can use [this tool](https://www.cockos.com/licecap/) to record GIFs on macOS and Windows, and [this tool](https://github.com/colinkeenan/silentcast) or [this tool](https://gitlab.gnome.org/Archive/byzanz) on Linux.
* **Explain why this enhancement would be useful** to most Terraform users and isn't something that can or should be implemented as a community package.
* **Specify which version of Terraform you're using.** You can get the exact version by running `terraform -v` in your terminal.
* **Specify the name and version of the OS you're using.**


## Pull Request Process

The process described here has several goals:

- Fix problems that are important to users.

1. Update the README.md with details of changes to the interface, this includes new environment variables, exposed ports, useful file locations, and container parameters.
2. Increase the version numbers in any examples files and the README.md to the new version that this
   Pull Request would represent. The versioning scheme we use is [SemVer](http://semver.org/).
3. You may merge the Pull Request in once you have the sign-off of two other developers, or if you do not have permission to do that, you may request the second reviewer to merge it for you.
4. Follow all instructions in [the template](./.github/pull_request_template.md).
5. Follow the [styleguides](https://docs.dnx.one/docs/style-guide/terraform-style-guide.html).
6. After you submit your pull request, verify that all [status checks](https://help.github.com/articles/about-status-checks/) are passing. <details><summary>What if the status checks are failing?</summary>If a status check is failing, and you believe that the failure is unrelated to your change, please leave a comment on the pull request explaining why you believe the failure is unrelated. A maintainer will re-run the status check for you. If we conclude that the failure was a false positive, then we will open an issue to track that problem with our status check suite.</details>

While the prerequisites above must be satisfied prior to have your pull request reviewed, the reviewer(s) may ask you to complete additional design work, tests, or other changes before your pull request can be ultimately accepted.

### Your First Code Contribution

Unsure where to begin contributing to DNX? You can start by looking through these `beginner` and `help-wanted` issues:

* `beginner` - issues that should only require a few lines of code, and a test or two.
* `help-wanted` - issues which should be a bit more involved than `beginner` issues.

Both issue lists are sorted by the total number of comments. While not perfect, the number of comments is a reasonable proxy for the impact a given change will have.