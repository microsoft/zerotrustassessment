# Jailbroken/Rooted Devices

**Implementation Effort:** Low  
This setting is part of standard app protection and compliance policy configurations and does not require infrastructure changes or device enrollment.

**User Impact:** Low  
Users with jailbroken or rooted devices are silently blocked from accessing corporate data, with no action required from compliant users.

## Overview

Microsoft Intune App Protection Policies (APP) and Compliance Policies can detect when a device is jailbroken (iOS) or rooted (Android). These devices are considered high-risk because they bypass built-in security controls, making them more vulnerable to malware, data leakage, and unauthorized access. When such a device is detected, Intune can automatically block access to corporate data or wipe app data from the device.

This control is enforced regardless of whether the device is enrolled in Intune, making it effective for both corporate and personal (BYOD) scenarios. It is commonly used in combination with Conditional Access to ensure that only healthy, secure devices can access sensitive resources.

This setting supports the **Zero Trust principle of "Assume Breach"** by treating compromised devices as untrusted and preventing them from accessing organizational data.

## Reference

- [App protection policies overview - Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy)
- [iOS app protection policy settings in Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy-settings-ios#data-protection)
- [Android app protection policy settings in Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy-settings-android)