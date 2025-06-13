# MDM_02: Device Compliance Policy in Intune for iOS and Android MDM

**Implementation Effort:** Medium  
IT teams must define, configure, and maintain platform-specific compliance policies and integrate them with Conditional Access for enforcement.

**User Impact:** Medium  
Users may be required to update device settings, install security apps, or take corrective actions to maintain compliance.

---

## Overview

Device Compliance Policies in Microsoft Intune are rule sets that define the conditions a device must meet to be considered secure and compliant. These policies are essential for protecting organizational data and are often used in conjunction with Microsoft Entra Conditional Access to restrict access from non-compliant devices.

### Key Capabilities

- **Platform-Specific Rules**: Separate compliance settings for Android and iOS, such as OS version requirements, password policies, and threat protection levels.
- **Noncompliance Actions**: Trigger alerts, send emails, or remotely wipe data if a device falls out of compliance.
- **Conditional Access Integration**: Only compliant devices can access corporate resources like Microsoft 365 or internal apps.

### Android Compliance Examples

- Require minimum OS version  
- Block rooted devices  
- Enforce password complexity  
- Restrict specific apps  

### iOS Compliance Examples

- Block jailbroken devices  
- Require email configuration  
- Set threat level thresholds  
- Enforce password expiration  

### Compliance Policy Settings

These are tenant-wide configurations that determine how Intune handles devices without assigned policies:
- **Mark devices with no compliance policy as**: Compliant or Not Compliant  
- **Compliance status validity period**: Defines how long a device remains compliant without rechecking  

### Zero Trust Fit

This aligns with the **"Verify explicitly"** principle. By continuously evaluating device health and compliance, organizations ensure that only secure, trusted devices can access sensitive resources.

---

## Reference

- [Device compliance policies in Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/protect/device-compliance-get-started)  
- [Android Enterprise compliance settings](https://learn.microsoft.com/en-us/intune/intune-service/protect/compliance-policy-create-android-for-work)  
- [iOS/iPadOS compliance settings](https://learn.microsoft.com/en-us/intune/intune-service/protect/compliance-policy-create-ios)
