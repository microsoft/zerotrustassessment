# Send Org Data to Other Apps

**Implementation Effort:** Low

**User Impact:** Medium

## Overview
The **Send org data to other apps** setting is one of the most important APP controls because it governs whether work data can leave a managed app and which destinations are allowed. In Zero Trust terms, this is a primary containment boundary for mobile productivity apps.

Most organizations should not leave this set to **All apps**. The usual decision is between **Policy managed apps** for balanced productivity and **None** for higher-sensitivity populations where data must not be handed off to any other mobile app.

## Implementation Guidance
1. Edit the relevant Android or iOS/iPadOS app protection policy in the Microsoft Intune admin center and review the **Data protection** section.
2. Select the setting value deliberately: **Policy managed apps** is a common enterprise baseline; **Policy managed apps with Open-In and Share filtering** is useful where supported and where the goal is to present only approved apps in sharing menus; **None** is appropriate for highly sensitive populations; **All apps** should generally be treated as an exception, not a default.
3. Coordinate this setting with **Restrict web content transfer with other apps**, **Allow user to save copies to selected services**, and the approved browser and storage app strategy so the user experience is consistent.
4. Document the list of supported Microsoft and line-of-business apps that are expected to participate in APP data transfer. If a required app is not APP-capable, decide whether to onboard it properly or redesign the workflow instead of weakening the policy broadly.
5. Pilot the experience end to end: share from Outlook to Teams, OneDrive, Word, and an unmanaged personal app; verify the policy blocks or allows exactly what the business expects.

## Reference
- **[Android app protection policy settings in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/ref-settings-android)** — Lists and explains Android-specific app protection policy settings in Intune.
- **[iOS/iPadOS app protection policy settings in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/ref-settings-ios)** — Lists and explains iOS/iPadOS-specific app protection policy settings in Intune.
- **[App Protection Policies Overview - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/overview)** — Explains Intune app protection policies for managed apps and unenrolled devices.
- **[Troubleshoot data transfer with Intune app protection policies - Microsoft Intune](https://learn.microsoft.com/en-us/troubleshoot/mem/intune/app-protection-policies/troubleshoot-data-transfer)** — Troubleshoots cross-app data transfer behavior under Intune app protection policies.
