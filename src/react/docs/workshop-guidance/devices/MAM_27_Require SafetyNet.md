# Require SafetyNet

**Implementation Effort:** Low  
This setting is a built-in configuration option within Intune App Protection Policies for Android and does not require infrastructure changes.

**User Impact:** Low  
Users are not impacted unless their device fails the SafetyNet check, in which case access to corporate data is blocked.

## Overview

The **Require SafetyNet** setting in Microsoft Intune App Protection Policies (APP) is used to verify the integrity of Android devices before allowing access to corporate data. SafetyNet is a Google Play service that checks whether a device is rooted, tampered with, or running a custom ROM. When enabled, Intune uses SafetyNet to assess the device's security posture and can block access or wipe corporate data if the device fails the check.

This setting is especially useful in BYOD scenarios where devices are not enrolled in Intune but still need to meet minimum security standards. It ensures that only trusted, unmodified Android environments can access sensitive organizational resources.

This feature supports the **Zero Trust principle of "Assume Breach"** by treating potentially compromised devices as untrusted and enforcing strict access controls based on real-time integrity checks.

## Reference

- [App protection policies overview - Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy)
- [Data protection framework using app protection policies - Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-framework)
- [Conditional Access - Require approved app or app protection policy](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-all-users-approved-app-or-app-protection)
