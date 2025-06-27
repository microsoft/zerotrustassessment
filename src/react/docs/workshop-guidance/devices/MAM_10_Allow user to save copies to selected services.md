# Allow User to Save Copies to Selected Services

**Implementation Effort:** Low – IT administrators only need to configure this setting within the App Protection Policies for Android and iOS/iPadOS in Microsoft Intune.

**User Impact:** Medium – A subset of users may experience changes in how they can save or export corporate data, depending on which services are allowed or blocked.

## Overview

The **“Allow user to save copies to selected services”** setting in Microsoft Intune App Protection Policies (APP) allows organizations to control where users can save copies of corporate data when the broader **“Save copies of org data”** setting is set to **Block**.

This setting provides a more granular approach by allowing exceptions for specific services, such as:
- **Microsoft OneDrive for Business**
- **SharePoint Online**
- **Local device storage (if explicitly allowed)**
- **Other approved services integrated with Microsoft Intune**

### Platform Support:
- **Android**: Supported for apps like Microsoft Excel, OneNote, PowerPoint, Word, and Edge [1](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy-settings-android).
- **iOS/iPadOS**: Supported for Excel, OneNote, Outlook, PowerPoint, Word, Edge, and some third-party or line-of-business (LOB) apps [2](https://learn.microsoft.com/en-us/mem/intune/apps/app-protection-policy-settings-ios?form=MG0AV3).

By selectively allowing certain services, organizations can balance productivity and security—enabling users to save work to trusted cloud services while blocking personal or unmanaged destinations.

This setting supports the Zero Trust principle of **least privilege access** by ensuring that corporate data is only saved to approved, policy-managed services. If not configured properly, users might save sensitive data to personal storage or unapproved apps, increasing the risk of data leakage.

## Reference

- [Android app protection policy settings - Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy-settings-android)  
- [iOS/iPadOS app protection policy settings - Microsoft Intune](https://learn.microsoft.com/en-us/mem/intune/apps/app-protection-policy-settings-ios?form=MG0AV3)  
