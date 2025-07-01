# Mobile Threat Defense

**Implementation Effort:** Medium  
Integrating a Mobile Threat Defense (MTD) solution requires coordination with a third-party provider, policy configuration, and testing across platforms.

**User Impact:** Medium  
Users may be prompted to install an MTD app and grant permissions, and access to corporate data may be restricted if threats are detected.

## Overview

**Mobile Threat Defense (MTD)** is a security integration in Microsoft Intune that allows organizations to assess the risk level of mobile and Windows devices using threat intelligence from third-party vendors. Supported MTD partners include Microsoft Defender for Endpoint, Lookout, Zimperium, Check Point, and others. Once integrated, Intune can use threat signals from these partners to enforce app protection policies—such as blocking access or wiping corporate data—based on the device's threat level.

Admins can configure the **maximum allowed threat level** (e.g., Secured, Low, Medium, High) in the Conditional Launch section of the policy. If a device exceeds the allowed threat level, Intune can take actions like blocking access to corporate data or selectively wiping it from the app.

This feature supports the **Zero Trust principle of "Assume Breach"** by continuously evaluating device health and dynamically enforcing access controls based on real-time threat intelligence.

## Reference

- [Create Mobile Threat Defense app protection policy with Intune](https://learn.microsoft.com/en-us/intune/intune-service/protect/mtd-app-protection-policy)
- [Mobile Threat Defense with Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/protect/mobile-threat-defense)
- [Create and deploy app protection policies - Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policies)
