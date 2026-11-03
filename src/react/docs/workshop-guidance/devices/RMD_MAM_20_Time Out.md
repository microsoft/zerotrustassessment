# Time Out

**Implementation Effort:** Low

**User Impact:** Low

## Overview
The APP timeout control limits how long a managed app can remain idle before the user must re-authenticate to regain access to organizational data. It reduces the risk of unattended-device exposure without requiring the organization to manage the whole device.

Timeout should not be chosen in isolation. It works with PIN and biometric settings, offline grace period, and the broader session design enforced by Microsoft Entra ID and Conditional Access.

## Implementation Guidance
1. Open the relevant Android and iOS/iPadOS app protection policies in the Intune admin center and review the **Access requirements** settings.
2. Configure the app inactivity timeout according to user risk and data sensitivity. Shorter values are usually appropriate for high-risk users and regulated workloads; broader user populations may tolerate a slightly longer interval to reduce friction.
3. Test the experience in the apps your organization standardizes on, especially Outlook, Teams, OneDrive, and Office mobile apps. Confirm when the prompt appears and whether it requires PIN or biometric re-entry.
4. Document the rationale for the chosen timeout so administrators understand why the organization selected that value instead of treating it as an arbitrary number.

## Reference
- **[App Protection Policies Overview - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/overview)** — Describes Intune app protection access requirements such as PIN, biometric, credential, and recheck controls.
