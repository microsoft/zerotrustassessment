# Company Portal Customization

**Implementation Effort:** Low  
**User Impact:** Low

## Overview

Company Portal customization lets administrators brand the Microsoft Intune end-user experience so users can recognize legitimate enrollment prompts, support information, and app-installation workflows. Good branding does not replace technical controls, but it reduces confusion and improves trust during device enrollment and support interactions.

In Zero Trust workshops, this topic is best framed as a user-experience hardening step. A well-configured portal helps users distinguish the organization’s approved enrollment process from phishing or rogue app-installation instructions.

## Implementation Guidance

1. In the Microsoft Intune admin center, go to Tenant administration > Customization and review the existing tenant branding configuration. Standardize the organization name, support contact details, privacy messaging, and corporate website links before changing visual assets.
2. Upload current branding assets such as company logo and color choices that match approved corporate standards. Keep graphics simple and readable on mobile devices; oversized or outdated images create a poor enrollment experience.
3. Add meaningful support information. Include a monitored help desk email address, phone number, or service portal so users know where to go if enrollment fails or if they are unsure whether a prompt is legitimate.
4. Preview the Company Portal experience on iOS, Android, and Windows clients used in your environment. Confirm that branding is consistent and that localization requirements are met if your tenant serves multiple regions or languages.
5. Include the customized portal in user communications and onboarding materials. Show screenshots in training or enrollment guides so users know what the legitimate Intune experience should look like.

## Reference

- **[How to Configure the Intune Company Portal Apps, Company Portal Website, and Intune App - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/configuration/configure-company-portal)** — Shows how to customize Company Portal branding, support, and enrollment-facing settings.
- **[Device enrollment guide for Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-enrollment/guide)** — Provides the main enrollment setup guidance for Microsoft Intune-managed devices.
