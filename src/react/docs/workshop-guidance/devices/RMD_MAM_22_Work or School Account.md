# Work or School Account

**Implementation Effort:** Low  
This setting is part of standard app protection policy configurations and does not require infrastructure changes or device enrollment.

**User Impact:** Medium  
Users must sign in with their organizational account, and may need guidance if they are using personal devices or multi-identity apps.

## Overview

In Microsoft Intune App Protection Policies (APP), a **Work or School Account** refers to the Microsoft Entra ID identity used to access corporate resources. These accounts are essential for applying app-level protections to corporate data on both managed and unmanaged devices. Intune APP can distinguish between corporate and personal identities in multi-identity apps (like Outlook), ensuring that protections apply only to work or school data.

Admins can configure policies to prevent data transfer between work/school accounts and personal accounts, enforce encryption, and require authentication (e.g., PIN or biometric) for access. This helps protect sensitive data even on BYOD (Bring Your Own Device) scenarios.

This setting supports the **Zero Trust principle of "Verify Explicitly"** by ensuring that access to corporate data is tied to authenticated organizational identities, and not personal accounts.

## Reference

- [App protection policies overview - Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy)
- [Data protection framework using app protection policies - Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-framework)
- [Troubleshoot user issues for Microsoft Intune app protection policies](https://learn.microsoft.com/en-us/troubleshoot/mem/intune/app-protection-policies/troubleshoot-mam)

