# MDM_02: Device Compliance Policy in Intune for iOS and Android MDM

**Implementation Effort:** Medium  
**User Impact:** Medium

## Overview

Compliance policies in Microsoft Intune answer a narrow but critical question: is this device allowed to be treated as trusted for access decisions? They are not a substitute for configuration profiles or app protection policies. Instead, they define the security conditions a managed device must meet so Conditional Access can allow or block access to Microsoft 365 and other resources.

A mature Zero Trust design keeps compliance focused on measurable security outcomes such as required OS version, encryption state, device integrity, password state, and mobile threat level. Overloading compliance with unrelated requirements makes user remediation harder and sign-in outcomes less predictable.

## Implementation Guidance

1. Create separate compliance policies by platform and, where needed, by risk tier. iOS/iPadOS and Android should not share a single generic design because the available settings and user experiences differ.
2. Use compliance settings for trust decisions only. Typical settings include minimum operating system version, device integrity or jailbreak/root checks, encryption requirements, password requirements, and device threat level if integrated with Microsoft Defender for Endpoint or another supported MTD provider.
3. Set tenant-wide compliance policy settings intentionally, especially the behavior for devices with no assigned compliance policy and the compliance status validity period. Most enterprises should mark devices with no compliance policy as not compliant unless there is a deliberate exception model.
4. Pair compliance with Conditional Access in the Microsoft Entra admin center. Require the device to be marked as compliant for mobile access to Microsoft 365 workloads that should only be available from managed devices.
5. Publish remediation guidance that matches the policy. If a device is blocked for OS version, encryption, or threat level, users should receive clear next steps and the help desk should be able to identify the exact failing setting quickly.

## Reference

- **[Device compliance policies in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-security/compliance/overview)** — Explains how to define compliance rules in Intune and create policies that evaluate managed devices.
- **[Microsoft Entra Conditional Access: Zero Trust Policy Engine - Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview)** — Explains Conditional Access grant controls, including requiring a device to be marked as compliant.
