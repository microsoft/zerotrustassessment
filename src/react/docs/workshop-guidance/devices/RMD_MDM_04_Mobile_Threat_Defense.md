# MDM_04: Mobile Threat Defense for iOS and Android MDM in Intune

**Implementation Effort:** Medium  
**User Impact:** Medium

## Overview

For managed mobile devices, Mobile Threat Defense should be treated as an input to trust, not just as a reporting feature. Microsoft Intune can use device risk telemetry from Microsoft Defender for Endpoint or supported partner integrations to decide whether an enrolled device remains compliant and therefore whether it can continue to access organizational resources.

A strong workshop design ties mobile threat signals to enforcement. Administrators should know which risk levels trigger noncompliance, how Conditional Access responds, and how users recover when a threat is remediated.

## Implementation Guidance

1. Decide whether Microsoft Defender for Endpoint will be your strategic mobile threat provider or whether a supported third-party integration is required. Standardize on one primary operating model where possible to simplify support and reporting.
2. Deploy the MTD app to enrolled iOS and Android devices and validate tenant integration. Confirm that device risk information is flowing before you build policies that depend on it.
3. Create compliance policies for enrolled devices that include the appropriate device threat level condition. Keep the threshold aligned to business risk; highly sensitive populations may justify blocking at lower risk levels than the general workforce.
4. Create Conditional Access policies that require compliant devices for the protected cloud apps. A device that exceeds the accepted threat level should lose access until the threat is resolved and compliance status updates successfully.
5. Monitor pilot users carefully. Review Defender or partner alerts, Intune compliance reports, Entra sign-in logs, and user support tickets so you can tune thresholds before enforcing at scale.

## Reference

- **[Configure Microsoft Defender for Endpoint with Intune and onboard devices - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-security/microsoft-defender/configure-integration)** — Explains how to integrate Defender for Endpoint with Intune and onboard devices.
- **[Device compliance policies in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-security/compliance/overview)** — Provides the Intune compliance policy concepts and setup guidance for managed devices.
- **[Use Conditional Access with Microsoft Intune compliance policies - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-security/conditional-access-integration/overview)** — Explains how Intune compliance policies integrate with Conditional Access.
