# Windows 365: Conditional Access

**Implementation Effort:** Medium  
Setting up Conditional Access requires IT and security teams to define, test, and deploy policies using Microsoft Entra and Intune, but does not require ongoing user training or infrastructure changes.

**User Impact:** Medium  
Users may be prompted for multifactor authentication or blocked from accessing Cloud PCs based on risk signals, device compliance, or location, which may require communication and support.

## Overview
Conditional Access for Windows 365 allows organizations to enforce access controls based on user identity, device compliance, location, and risk signals. These policies act as \"if-then\" rules---for example, if a user accesses a Cloud PC from an unmanaged device, then they must complete multifactor authentication (MFA). Admins can target policies to the following Microsoft Entra apps:

- Windows 365

- Azure Virtual Desktop

- Microsoft Remote Desktop

- Windows Cloud Login

Conditional Access policies are configured using Microsoft Entra ID and can be managed through Microsoft Intune. These policies help ensure that only trusted users and devices can access Cloud PCs, reducing the risk of unauthorized access. If not implemented, organizations risk exposing sensitive resources to compromised accounts or unmanaged devices.

This feature supports the Zero Trust principle of **\"Verify explicitly\"** by requiring authentication and authorization based on real-time signals such as user risk, device health, and location.

## Reference

- [Set Conditional Access policies for Windows 365](https://learn.microsoft.com/en-us/windows-365/enterprise/set-conditional-access-policies)

- [Conditional Access policies for Windows 365 Link](https://learn.microsoft.com/en-us/windows-365/link/conditional-access-policies)

- [Security overview for Windows 365](https://learn.microsoft.com/en-us/windows-365/enterprise/security-guidelines)
