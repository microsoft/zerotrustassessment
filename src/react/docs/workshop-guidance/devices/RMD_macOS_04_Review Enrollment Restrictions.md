# Review Enrollment Restrictions

**Implementation Effort:** Medium
**User Impact:** Medium — unsupported or out-of-policy enrollment attempts may be blocked and require clear communication.

## Overview
Enrollment restrictions define who can onboard devices, which platforms are permitted, and how many devices can be enrolled per user. For macOS, they are most effective when paired with a clear decision model for corporate-owned ADE devices, BYOD enrollment, and exception handling.

## Implementation Guidance
1. Review current business scenarios first: corporate-owned Macs through Automated Device Enrollment, personal Macs that require access, and populations that should remain unmanaged.
2. In the Microsoft Intune admin center, review device limit restrictions, device type restrictions, and assignment groups so policies align to the correct user populations.
3. Block enrollment paths that are not part of the target operating model and require corporate assets to arrive through ADE wherever possible.
4. For BYOD, decide whether the organization supports full device enrollment, user enrollment, or no Mac enrollment at all, then pair that decision with Conditional Access.
5. Audit existing enrolled Macs to find devices that entered through outdated or unintended paths and flag them for cleanup or reenrollment.

## Reference
- **[Step 5 – Enroll devices in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-enrollment/enroll-devices)** — Describes device enrollment restrictions and related enrollment controls in Intune.
- **[Set up enrollment for macOS devices - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-enrollment/apple/methods-macos)** — Describes supported enrollment methods for personal and corporate macOS devices.
