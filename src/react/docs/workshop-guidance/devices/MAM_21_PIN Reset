# PIN Reset

**Implementation Effort:** Low  
PIN reset is handled on the user’s device and does not require admin-side configuration or infrastructure changes.

**User Impact:** Low  
Users can reset their PIN directly from the app interface, and no broad communication or training is typically required.

## Overview

In Microsoft Intune App Protection Policies (APP), users are required to set a PIN to access managed apps like Outlook, Teams, and OneDrive. If a user forgets their PIN, there is no admin-side reset option available in the Intune or Azure portals. Instead, users must reset the PIN themselves by either uninstalling and reinstalling the app or triggering a reset through the app interface, depending on the platform and policy configuration.

This approach supports the **Zero Trust principle of "Verify Explicitly"** by ensuring that only the user can reset their authentication method, reducing the risk of unauthorized access. However, if not properly communicated, users may become frustrated or confused when they cannot reset their PIN through IT support.

## Reference

- [How to reset Intune (App protection policy) PIN with MAM setup](https://learn.microsoft.com/en-us/answers/questions/887935/how-to-reset-intune-%28app-protection-policy%29-pin-wi)
- [App protection policies overview - Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy)
- [PIN reset for Windows Hello for Business (not APP-specific)](https://learn.microsoft.com/en-us/windows/security/identity-protection/hello-for-business/pin-reset)
