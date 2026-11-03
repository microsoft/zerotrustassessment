# Apple Business Manager / Apple School Manager

**Implementation Effort:** Medium
**User Impact:** Low — most work is backend configuration before devices reach users.

## Overview
Apple Business Manager and Apple School Manager provide the device assignment and automated enrollment backbone for corporate-owned Apple devices. When integrated correctly with Microsoft Intune, they support supervised macOS enrollment, non-removable management, and stronger Zero Trust onboarding for corporate assets.

## Implementation Guidance
1. Establish ABM or ASM ownership, including a dedicated admin account, reseller relationships, and a documented annual token renewal process.
2. In the Microsoft Intune admin center, add or validate the Apple enrollment program token, sync devices, and confirm Macs are assigned to the correct MDM server in Apple administration.
3. Create separate Automated Device Enrollment profiles for major corporate scenarios such as standard users, developers, kiosks, or privileged workstations.
4. Require supervision and non-removable management for corporate devices and pair ADE with FileVault, compliance, app deployment, and SSO planning.
5. Review device assignment hygiene regularly so newly purchased Macs do not remain unassigned or linked to the wrong MDM server.

## Reference
- **[Step 5 – Enroll devices in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-enrollment/enroll-devices)** — Describes automated device enrollment for Macs purchased through Apple Business Manager or Apple School Manager.
- **[Set up enrollment for macOS devices - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-enrollment/apple/methods-macos)** — Explains how to configure and choose the supported enrollment methods for macOS devices.
- **[Set up automated device enrollment (ADE) for macOS - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-enrollment/apple/setup-automated-macos)** — Explains how to connect Apple Business Manager with Microsoft Intune for macOS Automated Device Enrollment.
