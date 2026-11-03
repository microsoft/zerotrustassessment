# macOS Local Account Management

**Implementation Effort:** Medium
**User Impact:** Low to Medium — users may notice account-type differences or support-driven privilege changes.

## Overview
Local account design on macOS affects privilege exposure, enrollment reliability, and support workflows. The recommended Microsoft Intune pattern is to minimize standing local admin rights, define how the first ADE-created account is handled, and use approved workflows for temporary elevation or support access instead of leaving broad admin access in place.

## Implementation Guidance
1. Define the target model for corporate-owned Macs enrolled through ADE: whether the first user is standard or local admin, when exceptions are allowed, and how privileged workflows are handled.
2. Choose the least-privileged setup that still allows the business workflow to succeed and avoid granting local admin rights broadly just because it is simpler.
3. If temporary or role-based elevation is required, document the approved mechanism and do not rely on permanent hidden admin accounts without strong controls.
4. Use scripts or approved tooling only where necessary and test them carefully because local account modification is high risk.
5. Review local privilege posture regularly, including evidence of who has admin rights and why.

## Video Walkthrough

<iframe width="560" height="315" src="https://www.youtube.com/embed/lSJtY1XOJaA?si=cZSMujY8DkZPnC02" title="YouTube video player" frameborder="0" allow="accelerometer; fullscreen; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

## Reference
- **[Step 5 – Enroll devices in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-enrollment/enroll-devices)** — Describes Apple automated device enrollment options and settings for macOS devices in Intune.
- **[Use Shell Scripts on macOS Devices in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-management/tools/run-shell-scripts-macos)** — Explains how to deploy and run shell scripts on managed macOS devices.
- **[Manage emergency access admin accounts - Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/security-emergency-access)** — Provides privileged access guidance centered on protected break-glass administrator accounts.
