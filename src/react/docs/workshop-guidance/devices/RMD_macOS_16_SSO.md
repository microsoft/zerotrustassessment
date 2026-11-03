# Single Sign-On (SSO)

**Implementation Effort:** Medium
**User Impact:** Low — when successful, users experience fewer prompts and a smoother sign-in flow.

## Overview
Single sign-on on macOS is now a strategic part of the Microsoft management story because Platform SSO and the Enterprise SSO plug-in improve sign-in quality, reduce password friction, and strengthen device-bound identity. The implementation goal is to choose the minimum SSO components needed for the organization's apps and identity architecture, then test browser, native app, and hybrid resource access end to end.

## Implementation Guidance
1. Decide which scenario is in scope: Microsoft Entra Platform SSO, the Enterprise SSO plug-in, Kerberos integration for hybrid resources, or a combination.
2. Review current OS, Company Portal, and app prerequisites in Microsoft Learn because Platform SSO capabilities change across macOS releases.
3. Deploy the SSO-related configuration profiles to a pilot group first and include any required browser extension or managed settings for Chrome and Edge.
4. Validate sign-in behavior in Safari, Edge, Chrome, Microsoft 365 native apps, and any hybrid line-of-business apps.
5. Document the support model for password changes, lost Touch ID enrollment, account recovery, and reprovisioning.

## Video Walkthrough

<iframe width="560" height="315" src="https://www.youtube.com/embed/blJ9O5jT0UM?si=phmvfKG01fpqn9lT" title="YouTube video player" frameborder="0" allow="accelerometer; fullscreen; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

## Reference
- **[Configure Platform SSO for macOS devices - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-configuration/settings-catalog/configure-platform-sso-macos)** — Explains how to configure Platform SSO for macOS with Microsoft Entra ID in Intune.
- **[Configure macOS Enterprise SSO app extension with MDMs - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-configuration/templates/configure-enterprise-sso-plugin-macos)** — Explains how to deploy the Microsoft Enterprise SSO plug-in configuration to macOS devices.
- **[Platform SSO scenarios for macOS devices - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-configuration/settings-catalog/configure-platform-sso-scenarios-macos)** — Shows common Platform SSO scenarios, including Kerberos SSO to on-premises resources.
