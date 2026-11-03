# Windows 365: User Settings

**Implementation Effort:** Low  
**User Impact:** Low

## Overview

Windows 365 user settings determine what self-service and privilege options a user receives on their Cloud PC. The most sensitive decision is whether a user should be a local administrator; other settings, such as reset or restore permissions, affect operational independence and support load.

In Zero Trust terms, these settings are a least-privilege decision point. Most users should remain standard users unless there is a documented business need, compensating controls, and a review process for any elevated rights granted.

## Implementation Guidance

1. Inventory the user settings currently available in your Windows 365 tenant and separate them into privilege settings, recovery/self-service settings, and any continuity or disaster-recovery-related settings. Do not assign them casually as a convenience measure.
2. Create dedicated user-setting policies for distinct populations. Standard office users, developers, privileged admins, and shared-use scenarios often need different levels of local control and recovery capability.
3. Default to standard user permissions. Only grant local administrator rights to a narrowly scoped group with an approved justification, and pair that exception with stronger monitoring, application control, and support expectations.
4. Test self-service features such as reset or restore before rollout. Confirm who can invoke them, what the resulting user experience is, and what organizational data or local customizations are affected.
5. Review policy precedence and change governance. If users belong to multiple groups that could receive different user settings, document which assignment model the tenant uses and avoid accidental privilege escalation through overlapping scope.

## Reference

- **[User settings in Windows 365](https://learn.microsoft.com/en-us/windows-365/enterprise/assign-users-as-local-admin)** — Explains Windows 365 user settings, including local administrator assignment options.
- **[Managing Cloud PCs with Microsoft Intune](https://learn.microsoft.com/en-us/windows-365/enterprise/device-management-overview)** — Describes how Cloud PCs are managed through Microsoft Intune.
- **[Learn about using Endpoint Privilege Management with Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/epm/overview)** — Provides least-privilege guidance through Endpoint Privilege Management for Windows.
