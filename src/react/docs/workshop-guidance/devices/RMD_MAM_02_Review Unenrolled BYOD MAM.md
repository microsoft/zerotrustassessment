# Review Unenrolled BYOD MAM in the Context of Intune App Protection Policies

**Implementation Effort:** Medium

**User Impact:** High

## Overview
Unenrolled BYOD MAM is the core Intune pattern for protecting corporate data on personal mobile devices without requiring full device enrollment. Users sign in to supported apps with their Microsoft Entra work account, and Intune applies app protection policy to the work identity inside the app.

This model is well suited to organizations that need strong data protection but want to minimize privacy concerns and enrollment friction for personally owned devices. The tradeoff is that protection is limited to supported apps and app-layer controls; it is not a substitute for device compliance on corporate-owned or regulated endpoints.

## Implementation Guidance
1. In the Microsoft Intune admin center, create platform-specific app protection policies for **Android** and **iOS/iPadOS** under **Apps** > **App protection policies**.
2. Target **user groups** that represent BYOD users. Avoid mixing unenrolled BYOD users and fully managed corporate device users in the same policy unless the experience has been intentionally designed and tested.
3. Configure baseline BYOD controls: **Send org data to other apps = Policy managed apps**, require a **PIN** for access, allow **biometrics** if permitted by policy, block **backup** to personal cloud services where supported, and set **conditional launch** actions for offline grace period, jailbroken/rooted devices, minimum app version, and threat signals if Microsoft Defender for Endpoint or another supported mobile threat defense solution is integrated.
4. Create or review the relevant **Conditional Access** policies so Exchange Online, SharePoint Online, and other targeted resources require an approved client app and or app protection policy for mobile access.
5. Document end-user prerequisites by platform. For example, some Android MAM scenarios rely on Company Portal presence even when the device is not enrolled, and some scenarios depend on Microsoft Edge or Defender for Endpoint when you use related controls.
6. Pilot with a small user group and test common flows: Outlook sign-in, opening SharePoint links, copy/paste to unmanaged apps, saving files, selective wipe, and re-authentication after inactivity.

## Reference
- **[App Protection Policies Overview - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/overview)** — Explains Intune app protection policies for managed apps and unenrolled devices.
- **[Use app-based Conditional Access policies with Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-security/conditional-access-integration/app-based-policies)** — Explains how app-based Conditional Access works with Intune app protection policies.
- **[Android app protection policy settings in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/ref-settings-android)** — Lists and explains Android-specific app protection policy settings in Intune.
- **[iOS/iPadOS app protection policy settings in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/ref-settings-ios)** — Lists and explains iOS/iPadOS-specific app protection policy settings in Intune.
