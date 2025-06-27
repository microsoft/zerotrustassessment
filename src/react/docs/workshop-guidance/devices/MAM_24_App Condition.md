# App Condition

**Implementation Effort:** Low  
This setting is part of standard app protection policy configuration and can be applied without infrastructure changes or device enrollment.

**User Impact:** Low  
App conditions are enforced silently in the background and only affect users when conditions are not met, requiring no regular user action.

## Overview

**App Condition** settings in Microsoft Intune App Protection Policies (APP) are part of the **Conditional Launch** feature. These settings define the conditions under which a user can access corporate data within an app. Admins can configure checks such as minimum app version, Max PIN attempts, or Min SDK version. If a condition is not met, actions like blocking access, wiping corporate data, or warning the user can be triggered.

This mechanism ensures that only compliant apps are allowed to access sensitive data, even on unmanaged devices. For example, if a user attempts to access corporate data using an outdated or unapproved app, the policy can block access or prompt the user to update the app.

This feature supports the **Zero Trust principle of "Assume Breach"** by enforcing strict access conditions and reducing the risk of data exposure through non-compliant or compromised apps.

## Reference

- [Wipe data using app protection policy conditional launch actions](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policies-access-actions)
- [App protection policy settings for Windows - Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy-settings-windows)
- [Conditional Access - Require approved app or app protection policy](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-all-users-approved-app-or-app-protection)
