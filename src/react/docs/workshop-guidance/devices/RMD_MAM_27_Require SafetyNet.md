# Require SafetyNet

**Implementation Effort:** Medium

**User Impact:** Low

## Overview
Android device integrity checks are essential for protecting organizational data on unmanaged (BYOD) and managed Android devices. Google replaced the legacy SafetyNet Attestation API with the **Google Play Integrity API**, which Microsoft Intune uses in App Protection Policy (APP) conditional launch and Android device compliance evaluations.

From a Zero Trust perspective, the point is to prevent access from tampered or untrustworthy Android environments without relying on outdated terminology or retired APIs.

## Implementation Guidance
1. In the Microsoft Intune admin center, open your Android app protection policy (**Apps > App protection policies**) and configure **Play Integrity verdict** under **Conditional launch > Device conditions**.
2. Choose **Basic integrity**, **Device integrity**, or **Strong integrity** based on your user risk tier, and pair the check with **Min OS version** and **Min patch version** settings.
3. If the organization uses Microsoft Defender for Endpoint or other supported mobile risk integrations, align Android integrity enforcement with those signals and the APP **Conditional launch** design instead of treating SafetyNet as a standalone checkbox.
4. Test the scenario on current Android versions and supported devices, and document any prerequisites such as Google Play services availability or other platform dependencies called out by Microsoft.

## Reference
- **[Android App Protection Policy Settings - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/ref-settings-android)** — Details Android app protection policy data protection, access requirements, and conditional launch settings.
- **[Configure Microsoft Defender for Endpoint with Intune and onboard devices - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-security/microsoft-defender/configure-integration)** — Explains how Defender for Endpoint integrates with Intune app protection and threat-based controls.
- **[App Protection Policies Overview - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/overview)** — Explains Intune app protection policy capabilities, the data protection framework, access requirements, and conditional launch behaviors.
