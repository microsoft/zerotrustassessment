# SafetyNet / Hardware Backed Key

**Implementation Effort:** Low  
**User Impact:** Low

## Overview

Android device integrity attestation is a key control for BYOD and Mobile Application Management (MAM) scenarios. Google retired the legacy SafetyNet Attestation API and replaced it with the **Google Play Integrity API**, which evaluates whether an Android device is genuine, unmodified, and running a recent security patch level.

For Zero Trust, the goal is to require a trustworthy Android device posture before allowing protected apps to handle organizational data. Hardware-backed evaluation, when available, gives stronger assurance than software-only checks and should be preferred for sensitive use cases.

## Implementation Guidance

1. Review the current Microsoft Intune admin center experience for Android app protection policies. In Apps > App protection policies > Android, inspect the Conditional launch integrity settings and document the exact current labels shown in your tenant, especially where legacy SafetyNet wording may still appear.
2. Design the policy outcome first. Decide which user groups must meet a stronger device integrity check and what happens on failure: Block access immediately, and optionally Wipe organizational data after a short grace period if the device remains untrusted.
3. Use hardware-backed device integrity evaluation where supported by the platform and the Intune control surface. This is the preferred posture for higher-risk groups because it is more resistant to bypass than older, software-oriented checks.
4. Combine integrity checks with app protection requirements and Conditional Access. The protected app should be the only route to data, and a failed device integrity result should prevent access to Exchange Online, SharePoint, Teams, and other targeted services.
5. Run pilot validation on a mix of Android vendors and OS versions. Confirm that supported devices pass, unsupported or tampered devices fail as expected, and that your help desk documentation explains the difference between device integrity failure and ordinary authentication failure.

## Reference

- **[Android App Protection Policy Settings - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/ref-settings-android)** — Details Android app protection policy data protection, access requirements, and conditional launch settings.
- **[Android device compliance settings in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-security/compliance/ref-android-enterprise-settings)** — Explains Google Play Integrity verdict levels and hardware-backed attestation settings in Intune.
- **[Migrate approved client app to application protection policy in Conditional Access - Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/conditional-access/migrate-approved-client-app)** — Explains current Conditional Access guidance for requiring approved client apps or app protection policy with mobile devices.
