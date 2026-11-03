# App Data Sync with Native Apps or Add-ins

**Implementation Effort:** Low

**User Impact:** Medium

## Overview
The sync-with-native-apps-or-add-ins control determines whether data from a managed app can move into native mobile apps or app extensions outside the managed boundary. This is highly relevant for contacts, calendar integration, widgets, and add-in scenarios that can quietly expose work data to the personal side of a device.

For Zero Trust programs, the default posture should be driven by data sensitivity and user role. High-sensitivity populations usually need this blocked or tightly constrained; broader populations may allow it only where the business value clearly outweighs the data handling risk.

## Implementation Guidance
1. In **Apps** > **App protection policies**, edit the relevant Android and iOS/iPadOS policies and review the setting that controls syncing policy-managed app data with native apps or add-ins.
2. Set the policy intentionally: **Block** is the safer choice for sensitive populations or BYOD scenarios with stronger containment requirements; **Allow** should be limited to workflows that have been validated and accepted by the business owner.
3. Test the specific integrations in scope, such as Outlook contacts, calendar sync, widget behavior, or supported add-ins. Do not assume that all native integration points behave the same way across apps and platforms.
4. If you allow sync or add-ins for some users, document exactly which apps and integrations are sanctioned and what data categories are considered acceptable for those workflows.

## Reference
- **[Android App Protection Policy Settings - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/ref-settings-android)** — Details Android app protection policy data protection, access requirements, and conditional launch settings.
- **[iOS/iPadOS App Protection Policy Settings - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/ref-settings-ios)** — Details iOS/iPadOS app protection policy data protection, access requirements, and conditional launch settings.
- **[App Protection Policies Overview - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/overview)** — Explains the Intune app protection data protection framework and how policy settings protect organizational data in managed apps.
