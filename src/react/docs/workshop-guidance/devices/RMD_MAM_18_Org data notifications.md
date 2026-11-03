# Org Data Notifications

**Implementation Effort:** Medium

**User Impact:** Low

## Overview
Notification exposure is an often-overlooked mobile data leakage path. Even if APP blocks copy and paste and file export, sensitive data can still surface in lock-screen notifications, notification previews, or assistant integrations if administrators do not review the relevant controls.

Notification protection should be configured as an integral part of your overall mobile data containment design rather than treated as an optional convenience setting.

## Implementation Guidance
1. Review the current Microsoft Learn documentation for **Android** and **iOS/iPadOS** app protection policy settings to confirm which notification-related controls are available per platform and in which supported apps.
2. Where Intune APP offers an organizational data notifications or equivalent control, configure it deliberately for users handling sensitive data so notification content does not expose work data on lock screens or through personal-device previews.
3. Combine APP settings with app-specific notification controls and, where applicable, device-management settings for managed corporate devices. Some notification privacy requirements cannot be solved by APP alone.
4. Test on real devices with the actual apps in scope: Outlook mail previews, Teams notifications, lock-screen behavior, wearable integrations, and assistant or search surfaces where documented by Microsoft.

## Reference
- **[Android App Protection Policy Settings - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/ref-settings-android)** — Details Android app protection policy data protection, access requirements, and conditional launch settings.
- **[iOS/iPadOS App Protection Policy Settings - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/ref-settings-ios)** — Details iOS/iPadOS app protection policy data protection, access requirements, and conditional launch settings.
- **[App Protection Policies Overview - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/overview)** — Explains the Intune app protection data protection framework and how policy settings protect organizational data in managed apps.
