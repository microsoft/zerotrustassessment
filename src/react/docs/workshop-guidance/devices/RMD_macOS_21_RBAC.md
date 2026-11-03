# Role-Based Access Control (RBAC)

**Implementation Effort:** Medium
**User Impact:** Low — the impact is on administrators and support teams rather than end users.

## Overview
RBAC in Microsoft Intune is a primary Zero Trust control for administrative actions. For macOS management, it should ensure that only the right teams can read devices, deploy policies, retrieve recovery material, or initiate remote support, and that those permissions are scoped tightly by geography, business unit, or support role.

## Implementation Guidance
1. Map the real administrative personas first, such as Intune service owner, macOS engineer, help desk, app packager, and any recovery-key retrieval approver.
2. Use built-in Intune roles where they already fit the least-privilege requirement and create custom roles only when built-in roles grant too much or do not align well.
3. Apply scope tags and assignment groups deliberately so administrators only see and manage the device sets they own and test with pilot admin accounts.
4. Pair Intune RBAC with Microsoft Entra controls for privileged accounts, including MFA, Conditional Access, and role review processes.
5. Audit administrative actions and role assignments regularly and recertify custom roles, scope tags, and high-impact assignments on a schedule.

## Reference
- **[Role-based access control with Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/fundamentals/role-based-access-control/overview)** — Explains built-in and custom Intune roles for delegating administration.
- **[Use Scope Tags with Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/fundamentals/role-based-access-control/scope-tags)** — Explains how scope tags limit admin visibility and scope in Intune.
- **[Manage emergency access admin accounts - Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/security-emergency-access)** — Provides strategy guidance for protecting privileged admin access with emergency accounts.
