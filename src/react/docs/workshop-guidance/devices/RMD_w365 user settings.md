# Windows 365: User Settings

**Implementation Effort:** Low – Admins only need to configure settings in the Intune admin center and assign them to user groups.

**User Impact:** Low - Settings are applied automatically; users are not required to take action or be notified unless they use optional features like reset or restore.

---

## Overview

Windows 365 User Settings allow IT administrators to control user-level
permissions and self-service capabilities for Cloud PCs. These include
enabling local administrator rights, allowing users to reset or restore
their Cloud PCs, and configuring cross-region disaster recovery.
Settings are assigned to user groups and take effect at the next
sign-in. If a user belongs to multiple policies, the most recently
created policy takes precedence. These settings do not apply to Windows
365 Frontline Cloud PCs in shared mode.

Improper configuration may lead to users having excessive privileges or
lacking recovery options, which can affect security and productivity.
This capability supports the Zero Trust principle of **"Use least
privilege access"**, by allowing admins to selectively grant elevated
rights and recovery tools only to specific users or groups.

## Reference

* [User settings in Windows
  365](https://learn.microsoft.com/en-us/windows-365/enterprise/assign-users-as-local-admin)
