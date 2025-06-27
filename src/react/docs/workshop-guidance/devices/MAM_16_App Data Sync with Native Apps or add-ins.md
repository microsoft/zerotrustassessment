# App Data Sync with Native Apps or Add-ins

**Implementation Effort:** Low – IT administrators only need to configure a single setting within the App Protection Policies in Microsoft Intune for Android and iOS/iPadOS.

**User Impact:** Medium – A subset of users may notice that features like calendar sync, contact sharing, or add-ins in managed apps are disabled, which may affect productivity or app integration.

## Overview

The **“Sync policy managed app data with native apps or add-ins”** setting in Microsoft Intune App Protection Policies (APP) controls whether managed apps can share data with the device’s native apps (such as Contacts, Calendar, and widgets) or use add-ins. This setting is available for both **Android** and **iOS/iPadOS** platforms.

When this setting is configured to **Block**:
- Managed apps (like Outlook) cannot sync data to native apps (e.g., syncing calendar events to the native Calendar app or saving contacts to the device).
- Add-ins within managed apps are also disabled, limiting third-party integrations.

When set to **Allow**:
- Managed apps can sync data with native apps and use add-ins, which may improve user experience but increases the risk of data leakage.

This setting supports the Zero Trust principle of **assume breach** by preventing corporate data from being exposed to apps or services outside the organization's control. If not configured properly, sensitive data could be synced to personal apps or accessed by unauthorized add-ins, increasing the risk of data exfiltration.

## Reference

- [Android app protection policy settings – Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy-settings-android)  
- [Understand app data protection using Microsoft Intune](https://learn.microsoft.com/en-us/microsoft-365/solutions/apps-protect-data-protection?view=o365-worldwide)  
- [App protection policies overview – Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy)
