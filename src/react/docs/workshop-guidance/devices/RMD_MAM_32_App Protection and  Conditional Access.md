# App Protection and Conditional Access

**Implementation Effort:** Low  
**User Impact:** Medium

## Overview

App protection policies and Conditional Access work together to protect Microsoft 365 data on mobile devices without requiring full device management in every case. App protection policies control what happens inside supported apps, while Conditional Access determines whether the user session is allowed based on identity, device, app, and risk conditions.

This combination is central to Zero Trust mobile access. It lets organizations support BYOD while still requiring approved access paths for Exchange Online, SharePoint, Teams, and related services.

## Implementation Guidance

1. Start by defining the supported mobile access path. For most tenants, the standard should be Microsoft 365 mobile apps that can receive Intune app protection policy, not native mail clients or unmanaged third-party apps.
2. In the Microsoft Intune admin center, create app protection policies for iOS/iPadOS and Android. Configure PIN, encryption, selective wipe, data transfer restrictions, and conditional launch settings such as maximum offline time and device threat level.
3. In the Microsoft Entra admin center, create Conditional Access policies that target the cloud apps you need to protect, such as Exchange Online, SharePoint Online, and Microsoft Teams. Use grant controls that require an app protection policy on supported mobile platforms, and add multifactor authentication or sign-in risk controls where appropriate.
4. Exclude emergency access accounts and stage the rollout. Use report-only mode where feasible, monitor sign-in logs for unexpected blocks, and validate that unmanaged clients are denied while protected apps continue to work.
5. Document the user journey. Users should know which apps are required, what enrollment or sign-in steps to expect, and what to do when access is blocked because a device is not meeting app protection or authentication requirements.

## Reference

- **[Migrate approved client app to application protection policy in Conditional Access - Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/conditional-access/migrate-approved-client-app)** — Explains current Conditional Access guidance for requiring approved client apps or app protection policy with mobile devices.
- **[App Protection Policies Overview - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/overview)** — Summarizes Intune app protection policy concepts, platform coverage, and policy behavior.
- **[Plan Your Microsoft Entra Conditional Access Deployment - Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/conditional-access/plan-conditional-access)** — Provides planning guidance for piloting, validating, and rolling out Conditional Access policies safely.
