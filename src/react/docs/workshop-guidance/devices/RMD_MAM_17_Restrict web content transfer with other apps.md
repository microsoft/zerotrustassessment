# Restrict Web Content Transfer with Other Apps

**Implementation Effort:** Low

**User Impact:** Medium

## Overview
This APP control determines which browser can open web content launched from a managed app. In many Zero Trust mobile designs, the goal is to keep corporate links inside a policy-managed browser such as Microsoft Edge so that authentication, session handling, and data transfer controls remain inside the managed path.

If links open in any installed browser, the organization loses consistency and may allow corporate content into unmanaged browsing sessions. That makes this control an important companion to the broader APP data transfer settings.

## Implementation Guidance
1. In the applicable Android and iOS/iPadOS app protection policies, review the **Restrict web content transfer with other apps** setting.
2. Use the managed-browser option, for example Microsoft Edge where documented, when the organization wants web content from managed apps to stay inside the protected app ecosystem. Avoid **Any app** unless the business has accepted the broader exposure.
3. Coordinate this setting with app configuration for Microsoft Edge, Conditional Access rules for mobile browser access, and the **Send org data to other apps** setting so the user experience is predictable.
4. Test common user flows from Outlook, Teams, OneDrive, and Office mobile apps: opening SharePoint links, opening document links, single sign-on behavior, and copy and paste restrictions inside the managed browser.

## Reference
- **[iOS/iPadOS App Protection Policy Settings - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/ref-settings-ios)** — Details iOS/iPadOS app protection policy data protection, access requirements, and conditional launch settings.
- **[Android App Protection Policy Settings - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/ref-settings-android)** — Details Android app protection policy data protection, access requirements, and conditional launch settings.
- **[Migrate approved client app to application protection policy in Conditional Access - Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/conditional-access/migrate-approved-client-app)** — Explains current Conditional Access guidance for requiring approved client apps or app protection policy with mobile devices.
- **[Manage Microsoft Edge on iOS and Android With Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/configuration/configure-edge-ios-android)** — Covers deploying and managing Microsoft Edge on mobile with Intune for secure web access and policy integration.
