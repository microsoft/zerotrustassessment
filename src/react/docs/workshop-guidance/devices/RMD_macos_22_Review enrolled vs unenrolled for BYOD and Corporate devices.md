# RMD_macos_22_Review enrolled vs unenrolled for BYOD and Corporate devices

**Implementation Effort:** Medium
**User Impact:** High — enrollment strategy changes user experience, support boundaries, and what resources a device can access.

## Overview
A Zero Trust macOS strategy starts by deciding which populations must be fully enrolled, which can use lighter controls, and which should remain unmanaged and receive only limited access. Corporate-owned Macs should generally be enrolled and managed through Microsoft Intune, while personally owned Macs require a deliberate choice between full management, limited management, or web-only access depending on risk, privacy, and business need.

## Implementation Guidance
1. Separate device populations into at least three buckets: corporate-owned Macs that must be fully managed, personal Macs that may be allowed with defined limits, and devices that are not allowed to access sensitive resources.
2. For corporate-owned Macs, use Apple Business Manager plus Automated Device Enrollment and require Intune management, compliance, encryption, and baseline apps before broad access is granted.
3. For personally owned Macs, decide whether the organization allows device enrollment through Company Portal or only browser-based access with strong Conditional Access. Document the privacy boundary for each option; Intune does not support Apple User Enrollment for macOS.
4. Build Conditional Access to match the model: compliant managed Macs for sensitive apps, lighter controls for lower-risk resources if permitted, and explicit blocks for scenarios outside policy.
5. Publish a simple support matrix that explains what IT supports on corporate-owned devices versus personal devices and what data the organization can and cannot manage.

## Reference
- **[Set up enrollment for macOS devices - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-enrollment/apple/methods-macos)** — Describes personal and corporate macOS enrollment methods available in Intune.
- **[Plan Your Microsoft Entra Conditional Access Deployment - Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/conditional-access/plan-conditional-access)** — Covers pilot, rollout, exclusions, and operational planning for Conditional Access.
- **[Step 5 – Enroll devices in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-enrollment/enroll-devices)** — Summarizes user-owned Apple enrollment options and related prerequisites in Intune.
