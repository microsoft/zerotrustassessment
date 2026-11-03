# Remote Help

**Implementation Effort:** Medium
**User Impact:** Medium — users must approve sessions and may need support onboarding guidance.

## Overview
Microsoft Intune Remote Help gives support staff a Microsoft-managed remote assistance workflow with identity verification, role-based delegation, and auditability. For macOS, it should be implemented as a controlled support channel rather than an ad hoc convenience tool.

## Implementation Guidance
1. Verify current platform support, licensing, and app requirements for Remote Help on macOS in Microsoft Learn before broad rollout.
2. In the Microsoft Intune admin center, enable Remote Help and assign only the helper permissions required for each support role.
3. Require strong helper authentication through Microsoft Entra, including MFA and Conditional Access for privileged support roles.
4. Deploy the required app components to pilot Macs and test support scenarios, including first-run prompts and privacy approvals.
5. Review Remote Help session logs, Intune audit logs, and abnormal support patterns on a regular cadence.

## Reference
- **[Using Remote Help on Windows to Assist Authenticated Users - Microsoft Intune](https://learn.microsoft.com/en-us/intune/remote-help/start-session)** — Explains how helpers and sharers start and use Remote Help sessions in Intune.
- **[Plan for Remote Help with Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/remote-help/plan)** — Covers prerequisites, licensing, and RBAC planning for Remote Help.
- **[Role-based access control with Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/fundamentals/role-based-access-control/overview)** — Explains built-in and custom Intune roles for delegating administration.
