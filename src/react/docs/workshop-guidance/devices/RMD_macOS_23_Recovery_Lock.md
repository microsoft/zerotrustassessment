# RMD-macOS-23 - macOS Recovery Lock Management

**Implementation Effort:** Low – Configured via an Intune Settings Catalog policy or triggered via remote device action.

**User Impact:** Low – Transparent to standard users; prevents unauthorized access to macOS Recovery OS at boot.

## Overview

On company-owned macOS devices (Apple silicon), **Recovery Lock** sets a firmware/recovery OS password that prevents users or attackers with physical access from booting the Mac into macOS Recovery mode, reinstalling macOS, accessing Terminal in recovery, or bypassing Automated Device Enrollment (ADE) remote management.

Introduced in **March 2026 (Service Release 2603)**, Microsoft Intune supports full lifecycle management of macOS Recovery Lock:
- **Settings Catalog Policy:** Enable the Recovery Lock feature and configure an automated **password rotation schedule**.
- **On-Demand Remote Device Action:** Trigger the **Rotate recovery lock password** remote action on any individual macOS device.
- **Audited Password Retrieval:** Authorized admins with the **Remote tasks/View macOS recovery lock password** RBAC permission can view the current Recovery Lock password in the per-setting status report (`Passwords and keys`).

This supports *Assume breach* and physical endpoint security on macOS, providing the Apple silicon equivalent of BIOS/UEFI password protection and pre-boot lockdown on Windows.

## Key Configuration Steps

1. In the Microsoft Intune admin center, create a **macOS Settings Catalog** policy (`Devices > Configuration > Create`).
2. Configure the **Recovery Lock** settings to enable Recovery Lock and define a regular password rotation schedule.
3. Grant the **Remote tasks/View macOS recovery lock password** Intune RBAC permission only to authorized helpdesk/security roles.
4. Use the **Rotate recovery lock password** remote action immediately after any recovery session where the password was disclosed to a user or technician.

## Reference

- [Rotate macOS recovery lock passcode in Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-management/actions/rotate-recovery-lock-passcode)
