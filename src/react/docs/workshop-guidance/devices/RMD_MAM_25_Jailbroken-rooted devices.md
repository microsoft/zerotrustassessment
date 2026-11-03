# Jailbroken/Rooted Devices

**Implementation Effort:** Low

**User Impact:** Low

## Overview
Jailbroken and rooted devices are high-risk because they can bypass built-in platform protections and weaken app-level isolation. Intune APP can use compromise-related checks in supported mobile scenarios to block or wipe organizational data when a device no longer meets the required integrity expectations.

For enrolled corporate devices, device compliance and Conditional Access can also be part of the response. For unmanaged BYOD devices, APP-based conditional launch is often the control that matters most.

## Implementation Guidance
1. Document the control path clearly: for **unenrolled** devices, use the APP conditional launch controls documented by Microsoft for rooted and jailbroken detection and response; for **enrolled** devices, also consider device compliance and Conditional Access as complementary controls.
2. In **Apps** > **App protection policies**, review the Android and iOS/iPadOS **Conditional launch** settings and configure the compromise-related action appropriate for your risk tier, such as block access or wipe organizational data where supported.
3. If Microsoft Defender for Endpoint is integrated, align jailbreak and root response with broader device threat-level handling so administrators are not maintaining separate, contradictory mobile risk models.
4. Test the documentation carefully and avoid claiming that all detection is identical across platforms or that compliance policy alone protects unenrolled BYOD scenarios.

## Reference
- **[Android App Protection Policy Settings - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/ref-settings-android)** — Details Android app protection policy data protection, access requirements, and conditional launch settings.
- **[iOS/iPadOS App Protection Policy Settings - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/ref-settings-ios)** — Details iOS/iPadOS app protection policy data protection, access requirements, and conditional launch settings.
- **[App Protection Policies Overview - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/overview)** — Explains Intune app protection policy capabilities, the data protection framework, access requirements, and conditional launch behaviors.
- **[Migrate approved client app to application protection policy in Conditional Access - Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/conditional-access/migrate-approved-client-app)** — Explains current Conditional Access guidance for requiring approved client apps or app protection policy with mobile devices.
