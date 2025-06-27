# Send Org Data to Other Apps

**Implementation Effort:** Low – IT administrators only need to configure a single setting within the App Protection Policy in Microsoft Intune.

**User Impact:** Medium – A subset of users may experience changes in how they can share or transfer work data between apps, especially if restrictions are applied to unmanaged or personal apps.

## Overview

The **“Send org data to other apps”** setting in Microsoft Intune App Protection Policies (APP) controls how corporate data can be shared from managed apps to other apps on the device. This setting is critical for preventing data leakage, especially in BYOD scenarios or on devices with both personal and work profiles.

The setting offers three main options:
- **All apps** – Allows unrestricted sharing of organizational data to any app.
- **Policy managed apps** – Restricts data sharing to only apps that are managed by Intune and have an APP applied.
- **None** – Blocks all data sharing from managed apps to any other app.

An additional option, **Policy managed apps with Open-In/Share filtering**, refines this control by filtering the iOS or Android share extension to only show apps that support Intune APP [1](https://learn.microsoft.com/en-us/troubleshoot/mem/intune/app-protection-policies/data-transfer-scenarios) [2](https://learn.microsoft.com/en-us/intune/intune-service/apps/data-transfer-between-apps-manage-ios).

This setting supports the Zero Trust principle of **assume breach** by ensuring that corporate data cannot be exfiltrated to unmanaged or potentially insecure apps. If not configured properly, users may unintentionally share sensitive data with personal apps, cloud services, or storage locations outside the organization’s control.

## Reference

- [Common issues when using Intune app protection policies to control data transfer](https://learn.microsoft.com/en-us/troubleshoot/mem/intune/app-protection-policies/data-transfer-scenarios)  
- [Manage transferring data between iOS apps - Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/data-transfer-between-apps-manage-ios)  
- [App protection policy settings for Windows - Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy-settings-windows)
