# Mobile Threat Defense

**Implementation Effort:** Medium  
**User Impact:** Medium

## Overview

Mobile Threat Defense (MTD) adds risk telemetry to Microsoft Intune so administrators can react when a mobile device is rooted, jailbroken, connected to an unsafe network, or running a malicious app. In modern Microsoft deployments, Microsoft Defender for Endpoint is the most common MTD signal source, although supported partner integrations can also be used where justified.

For Zero Trust workshops, the key outcome is not just “turn on MTD,” but to connect mobile risk to access control. Risk signals should feed Intune compliance for enrolled devices and app protection policy conditional launch actions for unenrolled or BYOD scenarios, so users lose access to organizational data until the threat is remediated.

## Implementation Guidance

1. In the Microsoft Intune admin center, confirm your mobile protection architecture by deciding whether enrolled devices will use compliance plus Conditional Access, app protection policies, or both. For most tenants, use both: compliance for managed devices and app protection for BYOD/mobile application management scenarios.
2. Deploy Microsoft Defender for Endpoint for iOS and Android, or validate the supported partner integration you intend to use. Assign the app to pilot users, verify sign-in, and confirm the app reports device risk status back to Microsoft security and Intune services.
3. Create or update device compliance policies so mobile risk level is evaluated. Set a clear maximum allowed risk level, document the remediation path, and pair the policy with a Conditional Access rule that requires the device to be compliant before Microsoft 365 access is granted.
4. For BYOD and unenrolled devices, update Android and iOS app protection policies. In Conditional launch, set a maximum allowed device threat level and choose appropriate actions such as Block access immediately and Wipe organizational data after a grace period if the risk is not resolved.
5. Test end-to-end with a pilot device. Verify that a healthy device can access Outlook or Teams, then simulate or trigger a risk state and confirm access is blocked, the user sees remediation guidance, and access returns only after the device is back within policy.

## Reference

- **[Configure Microsoft Defender for Endpoint with Intune and onboard devices - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-security/microsoft-defender/configure-integration)** — Covers connecting Defender for Endpoint with Intune to protect devices using integrated risk and security signals.
- **[Device compliance policies in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-security/compliance/overview)** — Explains how Intune compliance policies evaluate devices and how administrators create and monitor them.
- **[App Protection Policies Overview - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/overview)** — Summarizes how Intune app protection policies safeguard organizational data on managed and unmanaged devices.
