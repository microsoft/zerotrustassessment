# Review Corporate Enrolled Devices in the Context of Intune App Protection Policies

**Implementation Effort:** Medium

**User Impact:** Medium

## Overview
On corporate-enrolled devices, Microsoft Intune App Protection Policies add a second layer of protection on top of device management. MDM controls the device posture, configuration, and compliance state; MAM controls how organizational data can be used inside supported apps.

This layered model is valuable for Zero Trust because it assumes the device can still be lost, shared, or partially compromised. Even when enrollment and compliance are already in place, app-layer controls such as data transfer restrictions, app PIN requirements, selective wipe, and conditional launch actions reduce the chance of data exfiltration.

## Implementation Guidance
1. Review the existing enrolled-device architecture first: enrollment method, compliance policies, Microsoft Defender for Endpoint integration, and Conditional Access rules. APP should complement those controls rather than duplicate them blindly.
2. Under **Apps** > **App protection policies**, create platform-specific policies for **Android** and **iOS/iPadOS** and target the user groups that use managed corporate devices. If user experience differs materially between frontline, knowledge-worker, and executive populations, define separate policies or assignment filters accordingly.
3. Align MAM controls with the device-management baseline. Typical corporate-managed settings include **Policy managed apps** for data transfer, blocking backup to personal services where supported, requiring PIN or biometrics, and enforcing conditional launch settings such as minimum app version and maximum offline grace period.
4. Where the device is already compliant, avoid overcomplicating the end-user experience by adding conflicting access prompts. Test how PIN, biometrics, and Conditional Access prompts interact across Outlook, Teams, OneDrive, and Office mobile apps.
5. Use **Conditional Access** for cloud access decisions and **app protection policy** for in-app data handling. Document this distinction so administrators know whether a requirement belongs in Entra Conditional Access, Intune device compliance, or Intune app protection.
6. Validate selective wipe and offboarding. Remove a user from policy scope or revoke access and confirm that organizational data is removed from managed apps without requiring a full device wipe.

## Reference
- **[App Protection Policies Overview - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/overview)** — Explains Intune app protection policies for managed apps and unenrolled devices.
- **[Use app-based Conditional Access policies with Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-security/conditional-access-integration/app-based-policies)** — Explains how app-based Conditional Access works with Intune app protection policies.
- **[Tutorial - Walkthrough the Microsoft Intune Admin Center - Microsoft Intune](https://learn.microsoft.com/en-us/intune/fundamentals/tutorial-admin-center-walkthrough)** — Shows the App protection policy status area and troubleshooting views for app protection users in Intune.
