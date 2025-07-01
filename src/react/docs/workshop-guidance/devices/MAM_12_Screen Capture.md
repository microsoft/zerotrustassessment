# Screen Capture

**Implementation Effort:** Low – IT administrators only need to configure a setting within the App Protection Policy or device restriction policy, depending on the platform.

**User Impact:** Medium – A subset of users may be unable to take screenshots or record screens in managed apps, which could affect workflows involving note-taking or sharing information.

## Overview

The **screen capture control** in Microsoft Intune helps prevent sensitive organizational data from being exfiltrated via screenshots or screen recordings. This is especially important in BYOD and mobile-first environments where users may unintentionally or intentionally capture and share corporate data.


### Platform-Specific Behavior:

- **Android**: Select Block to block screen capture, block Circle to Search, and block Google Assistant accessing org data on the device when using this app. Choosing Block will also blur the App-switcher preview image when using this app with a work or school account.
Note: Google Assistant may be accessible to users for scenarios that don't access org data.


This setting supports the Zero Trust principle of **assume breach** by reducing the risk of sensitive data being leaked through visual capture methods. If not configured, users may capture and share confidential information from apps like Outlook, Teams, or OneDrive, bypassing other data protection controls.

## Reference

- [iOS/iPadOS app protection policy settings – Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy-settings-ios) 
- [Android app protection policy settings in Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy-settings-android)