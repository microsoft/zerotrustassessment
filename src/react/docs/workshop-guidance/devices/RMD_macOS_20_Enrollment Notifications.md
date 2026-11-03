# Enrollment Notifications

**Implementation Effort:** Low
**User Impact:** Medium — users receive onboarding communications that can reduce confusion or create extra support load.

## Overview
Enrollment notifications are primarily a user-experience and communications feature: they confirm that management has been applied, explain what the user should expect next, and reduce uncertainty during onboarding. In a Zero Trust program, they should reinforce policy expectations without implying that email alone proves device trust.

## Implementation Guidance
1. Verify the exact Intune notification capability currently available for Apple enrollment scenarios, including supported triggers and customization options.
2. Design separate messaging for corporate-owned and personal-device enrollment paths so users receive the right privacy and support explanations.
3. Include practical content in the message: support contact, expected app-install timing, compliance expectations, and what to do if something appears incomplete.
4. Test the full workflow end to end with pilot users and validate message delivery, sender trust, branding, and whether the communication reduces confusion.
5. Review notification content quarterly as enrollment workflows, support links, or privacy statements change.

## Reference
- **[Customize Company Portal and Intune branding - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/configuration/configure-company-portal)** — Explains how to customize Company Portal appearance and other user-facing branding.
- **[Step 5 – Enroll devices in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-enrollment/enroll-devices)** — Summarizes Apple enrollment options and setup considerations for Intune-managed devices.
