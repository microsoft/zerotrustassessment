# Spec Contributor's Guide

This guide outlines the end-to-end process for a Product Manager to create a high-quality Zero Trust (ZT) assessment check specification. It is designed for newcomers to the project, providing clear steps, tool usage, and responsibilities.

As a spec owner, you will create a spec file for each check, fill in key metadata, draft the spec content (using provided template and AI tools), and mark the spec status `Review` so it can be handed off to documentation and development teams. The table below summarizes each step, followed by detailed instructions.

If you are not a member of the official Microsoft Zero Trust Assessment team, please create a new issue in the [ZT Assessment GitHub repository](https://github.com/microsoft/zerotrustassessment/issues/new) with your suggestion for a new assessment check. The team will review and determine next steps.

## Set up GitHub account

If you don't already have a GitHub account, create one at [GitHub Signup](https://github.com/join).

## Clone the repository

Clone the [Zero Trust Assessment GitHub repository](https://github.com/microsoft/zerotrustassessment) to your local machine using Git or GitHub Desktop.

## Authoring the spec

This project includes a 'Spec' agent that can help you draft the spec content using AI assistance. The agent uses a predefined prompt and template to generate a first draft, which you can then refine.

The agent is also integrated with MCP tools for Microsoft Learn and Microsoft Graph to help you research and validate Graph API queries.

To get started, follow these steps:

- Open Chat windows in VS Code from 'View' > 'Chat'
- Select the 'Spec' agent from the list of available agents
- Provide the best practice statement as input to the agent
- Rename the generated file to the appropriate Test ID and pillar folder
  - To get a unique Test ID, browse to [Test Number Generator](https://github.com/microsoft/zerotrustassessment/issues/627) and claim a new Test ID by commenting under the last comment and claiming the next sequence in the thread.

### Manual authoring steps

Copy the [spec-template.md](spec-template.md) to the pillar folder and rename it according to the naming convention: `spec/<pillar>/<TestID>.md`, where `<pillar>` is the relevant pillar (e.g., Identity, Device, Network, Data, Infrastructure) and `<TestID>` is the unique identifier for the assessment.

## Fill out Spec Metadata

Populate work item fields: priority, risk level, user impact, implementation cost, Zero Trust pillar, product, license, etc. 

Refer to the explanations in the [template for guidance](spec-template.md).

Tools/Resources: VSCode, MS Lean MCP, Microsoft Graph MCP, Graph Explorer

## Review and refine

Review the draft, test any Graph queries, ensure clarity and completeness. Update the spec with any corrections or improvements.

Tools/Resources: VSCode, MS Lean MCP, Microsoft Graph MCP, Graph Explorer

## Mark Spec as Completed

Update the Spec Status metadata in the spec doc and change it to “Completed” once final. This triggers docs and dev teams to pick it up.
