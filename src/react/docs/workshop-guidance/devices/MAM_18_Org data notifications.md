# Org Data Notifications

**Implementation Effort:** Low – IT administrators only need to configure this setting within the App Protection Policies in Microsoft Intune.

**User Impact:** Low – Users receive informational prompts or warnings when interacting with organizational data, but no action is required unless policy violations occur.

## Overview

The **Org Data Notifications** feature in Microsoft Intune App Protection Policies (APP) allows administrators to define how users are notified when they interact with organizational data in ways that may be restricted or monitored. These notifications help reinforce data protection policies without blocking productivity.

Examples of notification scenarios include:
- Attempting to copy data from a managed app to an unmanaged app
- Trying to save organizational data to unauthorized storage locations
- Using features like screen capture or third-party keyboards (if restricted)

These notifications are typically non-intrusive and serve to educate users about policy boundaries. They are especially useful in BYOD environments, where users may not be aware of corporate data handling rules.

This setting supports the Zero Trust principle of **assume breach** by increasing user awareness and reducing the likelihood of accidental data leakage. If not configured, users may unknowingly violate data protection policies, increasing the risk of exposure.

## Reference

- [Understand app data protection using Microsoft Intune](https://learn.microsoft.com/en-us/microsoft-365/solutions/apps-protect-data-protection?view=o365-worldwide)  
- [App protection policy settings for Windows – Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy-settings-windows)  
- [Data protection framework using app protection policies – Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-framework)
