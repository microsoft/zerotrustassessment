# Require Threat Scan on Apps

**Implementation Effort:** Low  
Once a Mobile Threat Defense (MTD) solution is integrated, enabling threat scan checks in app protection policies is a simple configuration step.

**User Impact:** Low  
Threat scans run in the background and only affect users if a threat is detected, requiring no regular user action.

## Overview

The **Require Threat Scan on Apps** setting in Microsoft Intune App Protection Policies (APP) is implemented through integration with a Mobile Threat Defense (MTD) solution such as Microsoft Defender for Endpoint, Lookout, or Zimperium. This configuration allows Intune to assess the risk level of a device or app based on threat intelligence and behavioral analysis. If a threat is detected—such as malware, network attacks, or risky app behavior—Intune can block access to corporate data or wipe it from the app.

This setting is part of a broader conditional access and app protection strategy, ensuring that only secure, threat-free environments can access sensitive organizational data. It is especially useful in BYOD scenarios where the device is not enrolled but still needs to meet security standards.

This feature supports the **Zero Trust principle of "Assume Breach"** by continuously evaluating the security posture of the app and device, and dynamically enforcing access controls based on real-time threat intelligence.

## Reference

- [Create Mobile Threat Defense app protection policy with Intune](https://learn.microsoft.com/en-us/intune/intune-service/protect/mtd-app-protection-policy)
- [Data protection framework using app protection policies - Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-framework)
- [Create and deploy app protection policies - Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policies)
