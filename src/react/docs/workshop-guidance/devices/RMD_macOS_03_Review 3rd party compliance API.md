# Review 3rd Party Compliance API Connectors (PDM/PCM)

**Implementation Effort:** Medium
**User Impact:** Low — users are usually unaware of the backend signal flow unless access is blocked.

## Overview
Third-party compliance integrations are useful only when macOS devices are managed outside Microsoft Intune or when a supported partner supplies posture signals that the organization chooses to trust for access decisions. The governance task is to minimize parallel management, use supported partner APIs, and keep access decisions understandable and supportable.

## Implementation Guidance
1. Inventory macOS populations that are not managed directly by Intune and identify whether each population is intentionally third-party managed or simply outside target-state onboarding.
2. Validate that the partner solution supports current Microsoft Intune and Microsoft Entra integration patterns for partner device or partner compliance scenarios.
3. Define what signal the partner contributes and make sure support teams know how that status appears in Intune and Microsoft Entra workflows.
4. Pilot the integration with a small device set and verify that devices appear correctly in Intune and that Conditional Access behaves as expected.
5. Review quarterly whether the organization should reduce reliance on third-party compliance connectors by moving more Macs to native Intune management.

## Reference
- **[Jamf Managed Device Compliance with Microsoft Entra ID - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-security/compliance/jamf-entra-id)** — Covers partner compliance management for Jamf-managed Macs and how compliance signals integrate with Microsoft Entra.
- **[Microsoft Entra Conditional Access: Zero Trust Policy Engine - Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview)** — Explains Conditional Access grant controls, including requiring devices to be marked compliant.
- **[Set up enrollment for macOS devices - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-enrollment/apple/methods-macos)** — Describes how macOS devices are enrolled into Intune across user-owned and corporate-owned scenarios.
