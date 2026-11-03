# Review Provisioning Strategy

**Implementation Effort:** Medium
**User Impact:** Medium — provisioning choices directly affect user setup experience, timing, and first-day actions.

## Overview
A strong macOS provisioning strategy defines how trust is established before users begin work, which policies and apps are required on day one, and which enrollment paths are permitted for each ownership model. In Microsoft Intune, the recommended pattern is to use Automated Device Enrollment for corporate Macs, a deliberately scoped experience for BYOD, and a documented migration path for already-deployed devices.

## Implementation Guidance
1. Map the target-state populations: new corporate Macs, existing corporate Macs moving from another tool, and personal Macs that need limited or conditional access.
2. For corporate devices, use ABM or ASM plus Automated Device Enrollment and define separate ADE profiles where setup behavior differs materially between personas.
3. Identify the minimum day-zero payload: identity prerequisites, certificates, baseline configuration, FileVault, compliance, and the core app set.
4. Use Await Configuration only for essential items that must complete before desktop access; everything else should flow soon after first sign-in.
5. Review provisioning success metrics regularly: enrollment completion, policy delivery time, app readiness, and compliance within the first 24 hours.

## Reference
- **[Set up enrollment for macOS devices - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-enrollment/apple/methods-macos)** — Explains how to prepare and choose macOS enrollment methods for different provisioning scenarios.
- **[Step 5 – Enroll devices in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-enrollment/enroll-devices)** — Covers automated device enrollment for Apple Business Manager-connected Mac provisioning.
- **[Create assignment filters in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/fundamentals/filters/overview)** — Explains assignment filters for targeting apps, policies, and profiles to the right device populations.
