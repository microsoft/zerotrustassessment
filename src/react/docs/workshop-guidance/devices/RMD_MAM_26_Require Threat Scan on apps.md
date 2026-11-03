# Require Threat Scan on Apps

**Implementation Effort:** Medium

**User Impact:** Low

## Overview
Threat-based mobile access control in Intune APP relies on integration with a supported Mobile Threat Defense provider, most commonly Microsoft Defender for Endpoint. APP then uses the resulting risk signal in conditional launch to determine whether organizational data should remain accessible.

This is a strong Zero Trust pattern because it evaluates more than user identity alone. The app session can respond to real device risk conditions even on BYOD scenarios where the device is not fully managed.

## Implementation Guidance
1. Integrate the chosen MTD platform with Intune according to Microsoft Learn. In Microsoft-focused deployments, that usually means onboarding mobile devices to **Microsoft Defender for Endpoint** and confirming the connector or integration path expected by Intune.
2. In the relevant Android and iOS/iPadOS app protection policies, review **Conditional launch** and set the **maximum allowed device threat level** or current equivalent control name based on the organization’s risk tolerance.
3. Define the remediation action when the threat level is exceeded, such as **block access** or **wipe organizational data** where appropriate and supported.
4. Test with pilot devices so administrators can see how long risk evaluation takes, what message users receive, and how remediation occurs after the threat condition is cleared.

## Reference
- **[Configure Microsoft Defender for Endpoint with Intune and onboard devices - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-security/microsoft-defender/configure-integration)** — Explains how Defender for Endpoint integrates with Intune app protection and threat-based controls.
- **[App Protection Policies Overview - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/overview)** — Explains Intune app protection policy capabilities, the data protection framework, access requirements, and conditional launch behaviors.
