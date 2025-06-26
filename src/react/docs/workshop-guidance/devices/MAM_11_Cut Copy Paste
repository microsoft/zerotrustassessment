# Cut, Copy, Paste in App Protection Policies

**Implementation Effort:** Low – IT administrators only need to configure this setting within the App Protection Policies in Microsoft Intune.

**User Impact:** Medium – A subset of users may experience changes in how they can move or share content between apps, especially when using personal or unmanaged apps.

## Overview

The **“Restrict cut, copy, and paste between other apps”** setting in Microsoft Intune App Protection Policies (APP) controls how users can transfer data between managed and unmanaged apps. This is a key control for preventing data leakage, especially in BYOD environments or on devices with both personal and work profiles.

### Available Options for Android and iOS:
- **Blocked** – Prevents all cut, copy, and paste actions between managed and unmanaged apps.
- **Policy managed apps** – Allows cut, copy, and paste only between apps that are managed by Intune.
- **Policy managed apps with paste in** – Allows paste from unmanaged apps into managed apps, but blocks copying from managed apps to unmanaged ones.
- **Any app** – No restrictions; users can cut, copy, and paste between any apps [1](https://learn.microsoft.com/en-us/troubleshoot/mem/intune/app-protection-policies/troubleshoot-cut-copy-paste) [2](https://learn.microsoft.com/en-us/answers/questions/50143/app-protection-policy-prevent-copying-from-managed).

#### Additional Control:
- **Cut and copy character limit** – Admins can define a maximum number of characters that can be copied from managed apps, even when restrictions are in place [1](https://learn.microsoft.com/en-us/troubleshoot/mem/intune/app-protection-policies/troubleshoot-cut-copy-paste).

### Available Options for Windows:
- **Any destination and any source** – Org users can paste data from and cut/copy data to any account, document, location, or application.
- **No destination or source** – Org users can't cut, copy, or paste data to or from external accounts, documents, locations or applications from or into the org context. 
**NOTE**: For Microsoft Edge, No destination or source blocks cut, copy, and paste behavior within the web content only. Cut, copy, and paste are disabled from all web content, but not application controls, including the address bar.
This setting supports the Zero Trust principle of **assume breach** by ensuring that sensitive organizational data cannot be exfiltrated via clipboard operations to unmanaged or personal apps. If not configured properly, users may inadvertently copy confidential information from apps like Outlook or Teams into personal apps like WhatsApp or Notes.

## Reference

- [Troubleshoot restricting cut, copy, and paste between applications - Intune](https://learn.microsoft.com/en-us/troubleshoot/mem/intune/app-protection-policies/troubleshoot-cut-copy-paste)  
- [iOS app protection policy settings in Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy-settings-ios#data-protection)
- [Android app protection policy settings in Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy-settings-android)
- [App protection policy settings for Windows - Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy-settings-windows) 