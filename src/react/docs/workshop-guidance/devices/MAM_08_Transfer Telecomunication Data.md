# Transfer Telecommunication Data

**Implementation Effort:** Low – IT administrators only need to configure a single setting within the App Protection Policies in Microsoft Intune for Android and iOS/iPadOS.

**User Impact:** Medium – A subset of users may experience changes in how they initiate calls or messages from managed apps, especially if redirection to personal apps is blocked.

## Overview

The **“Transfer telecommunication data to”** setting in Microsoft Intune App Protection Policies (APP) controls how managed apps handle actions like tapping a phone number or email address. This setting determines whether telecommunication data — such as phone numbers or email links — can be passed to unmanaged apps (e.g., the native Phone or Messages app) or must stay within the managed app ecosystem.

### Platform-Specific Behavior

- **Android**: This setting controls whether data like phone numbers or SMS links can be transferred to unmanaged dialer or messaging apps. Options include:
  - **Any app** – Allows redirection to any app.
  - **Policy managed apps** – Restricts redirection to apps that are managed by Intune.
  - **None** – Blocks all redirection of telecommunication data [1](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy).

- **iOS/iPadOS**: Similar behavior applies. For example, tapping a phone number in Outlook can be restricted to only open in managed apps like Microsoft Teams, rather than the native Phone app [2](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-framework).

This setting supports the Zero Trust principle of **assume breach** by preventing sensitive communication data from being exposed to unmanaged or personal apps. If not configured properly, users could inadvertently initiate calls or messages using personal apps, potentially leaking sensitive contact information or metadata.

## Reference

- [App protection policy settings for Android - Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy-settings-android)  
- [App protection policy settings for iOS/iPadOS - Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy-settings-ios)
