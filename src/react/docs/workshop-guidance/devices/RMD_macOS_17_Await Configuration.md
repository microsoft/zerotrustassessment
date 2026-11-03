# Await Configuration

**Implementation Effort:** Low
**User Impact:** Low to Medium — users wait longer at setup, but a well-designed flow reduces later issues.

## Overview
Await Configuration holds a newly enrolled Mac at Setup Assistant until essential required items are applied. It is valuable for establishing baseline trust before first use, but it should be limited to the small set of apps and policies that genuinely must be present before the user reaches the desktop.

## Implementation Guidance
1. Use Await Configuration only for Automated Device Enrollment scenarios on corporate-owned Macs and do not assume it applies to manual or personal-device enrollment.
2. Define the required day-zero payload explicitly: identity prerequisites, required certificates, baseline settings, compliance dependencies, and only the smallest set of must-have apps.
3. In the ADE profile, enable Await Configuration and scope required assignments carefully to avoid slow or unreliable setup.
4. Pilot on different network conditions and Mac hardware families to validate timing, app installs, and certificate issuance during setup.
5. Create a break-fix runbook for devices that appear stuck or delayed and measure average completion time so the payload can be tuned.

## Reference
- **[Step 5 – Enroll devices in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-enrollment/enroll-devices)** — Describes Apple automated device enrollment options for macOS devices in Intune.
- **[Set up automated device enrollment (ADE) for iOS/iPadOS - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-enrollment/apple/setup-automated-ios)** — Explains the Await final configuration setting used in Apple automated device enrollment.
- **[Set up automated device enrollment (ADE) for macOS - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-enrollment/apple/setup-automated-macos)** — Explains how to configure Automated Device Enrollment profiles and Await final configuration for macOS.
