# Encryption in App Protection Policies

**Implementation Effort:** Low – IT administrators only need to enable encryption settings within the App Protection Policies in Microsoft Intune.

**User Impact:** Low – Encryption is applied silently in the background, with no noticeable impact on user experience or required user action.

## Overview

Encryption in Microsoft Intune App Protection Policies (APP) ensures that corporate data stored by managed apps is protected at rest on mobile devices. This is especially important in BYOD scenarios or on devices that are not enrolled in a Mobile Device Management (MDM) solution.

### Platform-Specific Behavior:

- **Android**: Intune uses **wolfSSL** and **256-bit AES encryption**, integrated with the **Android Keystore system**, to encrypt app data. Encryption is applied synchronously during file I/O operations, ensuring that all content written to device storage is encrypted by default.

- **iOS/iPadOS**: While iOS provides native encryption at the OS level, Intune App Protection Policies ensure that corporate data remains within managed apps and is not transferred to unprotected storage or apps. Encryption is enforced through data containment and access control policies.

This encryption setting supports the Zero Trust principle of **assume breach** by ensuring that even if a device is compromised, corporate data remains encrypted and inaccessible to unauthorized apps or users. If not configured, sensitive data stored by apps like Outlook, Word, or Teams could be exposed through device-level vulnerabilities or unauthorized access.

## Reference

- [App protection policies overview – Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy)  
- [Understand app data protection using Microsoft Intune](https://learn.microsoft.com/en-us/microsoft-365/solutions/apps-protect-data-protection?view=o365-worldwide)  
- [Create and deploy app protection policies – Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policies)
