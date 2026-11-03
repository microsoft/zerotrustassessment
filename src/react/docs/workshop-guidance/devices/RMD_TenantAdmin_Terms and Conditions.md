# Terms and Conditions

**Implementation Effort:** Low  
**User Impact:** Low

## Overview

Microsoft offers more than one way to present legal, acceptable-use, or consent text to users, and the right choice depends on the point in the user journey you want to control. Intune Terms and Conditions are tied primarily to device enrollment experiences, while Microsoft Entra Terms of Use can be enforced during sign-in and paired with Conditional Access for broader coverage.

For most modern Zero Trust programs, Entra Terms of Use is the stronger strategic control because it is not limited to device enrollment and can require reacceptance when policy text changes. Intune Terms and Conditions can still be useful when you specifically want an enrollment-time acknowledgement.

## Implementation Guidance

1. Decide whether your requirement is enrollment-specific, sign-in-specific, or both. Use Intune Terms and Conditions if the goal is to present a device-management notice during enrollment; use Entra Terms of Use when you need broader access governance across Microsoft 365 and other integrated applications.
2. For Intune Terms and Conditions, create the text in the Microsoft Intune admin center, assign it to the intended user groups, and test the enrollment flow on each platform where the prompt should appear. Keep the language aligned with your legal and HR review process.
3. For Entra Terms of Use, configure the terms artifact in the Microsoft Entra admin center and attach it to a Conditional Access policy that targets the required applications and users. Decide whether reacceptance is required after updates and whether guest users are in scope.
4. Coordinate end-user communications before rollout. Users should understand why they are being asked to accept terms, whether the change affects existing devices, and whom to contact if acceptance fails or they are blocked unexpectedly.
5. Maintain version control for the approved text and schedule a regular review with legal, privacy, and compliance stakeholders so obsolete language does not remain active indefinitely.

## Reference

- **[Step 5 – Enroll devices in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-enrollment/enroll-devices)** — Covers creating an Intune terms and conditions policy for device enrollment.
- **[Set Up Microsoft Entra Terms of Use with Conditional Access - Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/conditional-access/terms-of-use)** — Explains how to create and use Microsoft Entra Terms of Use with Conditional Access.
- **[Require Terms of Use at sign-in to Microsoft Admin Portals - Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-all-users-require-terms-of-use)** — Shows how to require acceptance of terms of use through Conditional Access.
