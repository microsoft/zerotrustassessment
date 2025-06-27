# Time Out

**Implementation Effort:** Low  
This setting is configured within existing Intune App Protection Policies and does not require infrastructure changes or device enrollment.

**User Impact:** Low  
This setting operates in the background and does not require users to take action beyond reauthenticating after inactivity, which is a standard security expectation.

## Overview

The **Time Out** setting in Microsoft Intune App Protection Policies (APP) defines how long a user can remain inactive before being required to reauthenticate using a PIN or biometric method. This helps prevent unauthorized access to corporate data if a device is left unattended. Admins can configure the timeout duration to balance security and user convenience, typically ranging from a few minutes to several hours.

This setting supports the **Zero Trust principle of "Assume Breach"** by limiting the window of opportunity for unauthorized access in case a device is lost, stolen, or left unattended. Without a timeout policy, sensitive data in corporate apps could remain accessible indefinitely, increasing the risk of data leakage.

## Reference

- [Create and deploy app protection policies - Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policies)
- [Understand app protection policy delivery and timing](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy-delivery)
