# Work or School Account

**Implementation Effort:** Low

**User Impact:** Medium

## Overview
MAM policy is applied to the user’s organizational identity inside supported apps. That identity boundary is what allows Intune to protect work data differently from personal data in multi-identity app scenarios.

For Zero Trust guidance, the key lesson is that the work or school account is not just a sign-in requirement; it is the anchor that tells the app which data is corporate, which policy applies, and when selective wipe or restricted sharing should take effect.

## Implementation Guidance
1. In the Intune admin center, target app protection policies to the correct **user groups** and verify that the intended users sign in with their Microsoft Entra work account in supported apps.
2. Document which apps in scope are **multi-identity** and which are effectively **work-only**. This matters because the user experience differs when an app can hold both personal and organizational data.
3. Use Conditional Access to ensure targeted cloud resources are accessed through approved apps and the protected work identity context. Without that pairing, users may find alternate access paths that bypass the intended mobile protection model.
4. Test account switching, shared-device sign-out, and selective wipe behavior so the workshop content shows how the work identity is separated from personal content in practice.

## Reference
- **[App Protection Policies Overview - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/overview)** — Explains Intune app protection policy capabilities, the data protection framework, access requirements, and conditional launch behaviors.
- **[Migrate approved client app to application protection policy in Conditional Access - Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/conditional-access/migrate-approved-client-app)** — Explains current Conditional Access guidance for requiring approved client apps or app protection policy with mobile devices.
- **[Tutorial - Walkthrough the Microsoft Intune Admin Center - Microsoft Intune](https://learn.microsoft.com/en-us/intune/fundamentals/tutorial-admin-center-walkthrough)** — Shows where to review app protection policy status and troubleshoot affected users in the Intune admin center.
