# Pull Request

<!--
    Thanks for submitting a Pull Request (PR) to this project.
    Your contribution to this project is greatly appreciated!

    TITLE: Please be descriptive not sensationalist.
    Prepend the title with the [DscResourceName] if your PR is specific to a DSC resource.
    Also prepend with [BREAKING CHANGE] if relevant.
    i.e. [BREAKING CHANGE][xFile] Add security descriptor property

    You may remove this comment block, and the other comment blocks, but please
    keep the headers and the task list.
    Try to keep your PRs atomic: changes grouped in smallest batch affecting a single logical unit.
-->

## Pull Request (PR) description

<!--
    Replace this comment block with a description of your PR to provide context.
    Please be describe the intent and link issue where the problem has been discussed.
    try to link the issue that it fixes by providing the verb and ref: [fix|close #18]

    After the description, please concisely list the changes as per keepachangelog.com
    This **should** duplicate what you've updated in the changelog file.

### Added
- for new features [closes #15]
### Changed
- for changes in existing functionality.
### Deprecated
- for soon-to-be removed features.
### Security
- in case of vulnerabilities.
### Fixed
- for any bug fixes. [fix #52]
### Removed
- for now removed features.
-->

## Task list

<!--
    To aid community reviewers in reviewing and merging your PR, please take
    the time to run through the below checklist and make sure your PR has
    everything updated as required.

    Change to [x] for each task in the task list that applies to your PR.
    For those task that don't apply to you PR, leave those as is.
-->

- [ ] The PR represents a single logical change. i.e. Cosmetic updates should go in different PRs.
- [ ] Added an entry under the Unreleased section of in the CHANGELOG.md as per [format](https://keepachangelog.com/en/1.0.0/).
- [ ] Local clean build passes without issue or fail tests (`build.ps1 -ResolveDependency`).
- [ ] Resource documentation added/updated in README.md.
- [ ] Resource parameter descriptions added/updated in README.md, schema.mof
      and comment-based help.
- [ ] Comment-based help added/updated.
- [ ] Localization strings added/updated in all localization files as appropriate.
- [ ] Examples appropriately added/updated.
- [ ] Unit tests added/updated. See [DSC Resource Testing Guidelines](https://github.com/PowerShell/DscResources/blob/master/TestsGuidelines.md).
- [ ] Integration tests added/updated (where possible). See [DSC Resource Testing Guidelines](https://github.com/PowerShell/DscResources/blob/master/TestsGuidelines.md).
- [ ] New/changed code adheres to [DSC Resource Style Guidelines](https://github.com/PowerShell/DscResources/blob/master/StyleGuidelines.md) and [Best Practices](https://github.com/PowerShell/DscResources/blob/master/BestPractices.md).
