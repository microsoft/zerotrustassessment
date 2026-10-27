# General FAQs

## What is Zero Trust?

Zero Trust is a security approach based on three principles:

- **Verify explicitly.** Authenticate and authorize access requests using all available signals.
- **Use least privilege access.** Grant only the access needed, for the shortest time required.
- **Assume breach.** Design controls to limit the impact of an attack and support detection and response.

These principles apply across identities, devices, applications, data, infrastructure, and networks. [Learn more about Zero Trust](https://learn.microsoft.com/en-us/security/zero-trust/zero-trust-overview).

## How does the Microsoft Zero Trust Workshop align with NIST?

The Zero Trust Workshop aligns with [Microsoft's Zero Trust Architecture](https://www.microsoft.com/en-us/security/business/zero-trust), which aligns with NIST. One of the main drivers of this workshop was looking at how our Microsoft product landscape maps across the entire NIST architecture.

## Where does the Workshop tool store its data?

The Workshop stores task progress and notes in your browser's local storage on your device. Browser data can be cleared, so do not rely on it as your only backup.

- **Save your progress.** Select **Actions > Export** and choose **JSON Format**. Include the pillars you want to keep.
- **Restore your progress.** Use **Actions > Import** to load a saved JSON file when resuming work or moving to another device.
- **Before resetting or clearing data.** Export and securely store any results you need before resetting a pillar or clearing the site's browser data.

Exported files can contain sensitive information. Store them securely and share them only with authorized stakeholders.

## What permissions do I need for the Microsoft Zero Trust Assessment?

The Zero Trust Assessment app requires **read-only** permissions to read your tenant configuration. See the [ZT Assessment Guide](https://learn.microsoft.com/en-us/security/zero-trust/assessment/get-started) page for more details.

## Is this an official Microsoft product?

No. It is a community project that is maintained by Microsoft employees. The tools are provided as-is and are not supported through any Microsoft support program or service. Please do not contact Microsoft support with any issues or concerns.

## How do I get support?

Search the [existing GitHub issues](https://github.com/microsoft/zerotrustassessment/issues) for a similar problem. If none matches, [open a new issue](https://github.com/microsoft/zerotrustassessment/issues/new/choose) and include:

- The tool you are using and its version, if available.
- Steps to reproduce the problem, including the expected and actual behavior.
- Sanitized error details or screenshots that help explain the problem.

GitHub issues are public. Do not include tenant exports, credentials, tokens, or sensitive configuration. Remove identifying or sensitive information from any error details or screenshots before posting.
