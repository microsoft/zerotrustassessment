# Screen Capture and Google Assistant

**Implementation Effort:** Low  
This is a simple configuration within Android App Protection Policies and does not require infrastructure changes or device enrollment.

**User Impact:** Medium  
Users may be prevented from taking screenshots or using Google Assistant with corporate apps, which could affect their workflows and require communication or support.

## Overview

The **Screen Capture and Google Assistant** setting in Microsoft Intune App Protection Policies (APP) for Android allows administrators to block screen capture, Google Assistant, and Circle to Search from accessing organizational data within managed apps. When this setting is enabled, it also blurs the app preview in the app switcher to prevent data leakage through visual exposure.

This control is particularly useful in BYOD scenarios where users may unintentionally or intentionally try to capture or share sensitive information. Blocking these features ensures that corporate data remains protected even when accessed on personal devices.

This setting supports the **Zero Trust principle of "Assume Breach"** by preventing unauthorized capture or sharing of sensitive data through device-level features that are outside the app’s control.

## Reference

- [Android app protection policy settings - Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy-settings-android)
- [Data protection framework using app protection policies - Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-framework)
