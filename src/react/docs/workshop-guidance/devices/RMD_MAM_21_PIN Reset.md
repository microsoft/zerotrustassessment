# PIN Reset

**Implementation Effort:** Low

**User Impact:** Low

## Overview
Forgotten app PIN scenarios are common in MAM deployments and should be documented operationally, not just mentioned conceptually. The important design point is that APP PIN handling is app-centric and user-centric; administrators do not manage it the same way they manage a device sign-in password.

Clear self-service and help desk procedures ensure support teams know when users can reset their app PIN locally through reauthentication and when a selective wipe is appropriate.

## Implementation Guidance
1. Configure the **Number of tries before PIN reset** (maximum PIN attempts) under **Conditional launch** in the Microsoft Intune admin center (**Apps > App protection policies**).
2. Document the user flow for a forgotten APP PIN based on the current Microsoft Learn guidance for supported apps and platforms. Depending on the app and platform, users may be able to trigger a reset experience in-app after successful reauthentication, or they may need app-data reset or reinstall behavior documented by Microsoft.
3. Document the IT support path separately: support staff can typically validate account status, confirm policy assignment, and use **selective wipe** of organizational app data when appropriate, but they should not treat the APP PIN as a recoverable admin-set secret.
4. Include a test procedure in the workshop: deliberately forget the app PIN on pilot devices, walk through the documented reset path, and confirm that the support script matches the real user experience.

## Reference
- **[Tutorial - Walkthrough the Microsoft Intune Admin Center - Microsoft Intune](https://learn.microsoft.com/en-us/intune/fundamentals/tutorial-admin-center-walkthrough)** — Shows where to review app protection policy status and troubleshoot affected users in the Intune admin center.
- **[App Protection Policies Overview - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/overview)** — Explains Intune app protection policy capabilities, the data protection framework, access requirements, and conditional launch behaviors.
