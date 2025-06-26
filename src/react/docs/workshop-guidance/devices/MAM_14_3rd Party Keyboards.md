# 3rd Party Keyboards for iOS

**Implementation Effort:** Low  
This setting is a targeted configuration within Microsoft Intune App Protection Policies and can be applied without requiring major infrastructure changes.

**User Impact:** Medium  
Blocking third-party keyboards may affect a subset of users who rely on them for accessibility, language input, or productivity, and they may need to be notified or trained on alternatives.

## Overview

Blocking third-party keyboards on iOS devices is a security control available through Microsoft Intune's App Protection Policies (APP). This setting helps prevent potential data leakage by ensuring that only the system keyboard — which is more trusted and controlled — is used when entering corporate data. Third-party keyboards can pose a risk because they may capture keystrokes or transmit data externally, especially if they are not vetted or managed by the organization.

This control supports the **Zero Trust principle of "Assume Breach"** by minimizing the attack surface and reducing the risk of sensitive data being exposed through untrusted input methods. If not implemented, organizations risk data exfiltration through compromised or malicious keyboard apps.

## Reference

- [Understand app data protection using Microsoft Intune](https://learn.microsoft.com/en-us/microsoft-365/solutions/apps-protect-data-protection?view=o365-worldwide)
- [Data protection framework using app protection policies](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-framework)
- [iOS/iPadOS device settings in Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/configuration/device-restrictions-ios)
