# Backup to iCloud

**Implementation Effort:** Low

**User Impact:** Medium

## Overview
For iOS and iPadOS MAM, blocking backup of organizational data to iTunes and iCloud backups reduces the risk that work data is copied into personal backup containers outside organizational governance. This is a common Zero Trust baseline requirement for BYOD and contractor access.

The decision should be based on data sensitivity, legal requirements, and the supported-app experience. In most Microsoft 365 mobile scenarios, blocking personal backup of work data is acceptable because the authoritative data remains in Microsoft 365 rather than only on the device.

## Implementation Guidance
1. In the Microsoft Intune admin center, go to **Apps** > **App protection policies**, open the applicable **iOS/iPadOS** policy, and review the **Data protection** settings.
2. Set **Backup org data to iTunes and iCloud backups** to **Block** unless a business-approved exception exists. This is usually the right default for BYOD and other unmanaged device scenarios.
3. Use separate policy assignments for exception populations rather than allowing personal backup broadly. Capture the justification, business owner, and review date for any exception.
4. Explain the behavior in user guidance: this setting protects work data; it does not prevent users from reinstalling supported Microsoft apps and signing back in to retrieve data from Microsoft 365 services.
5. Validate on test devices by applying the policy to pilot users, confirming the policy is received, and checking any documented app-specific restore behavior from Microsoft Learn.

## Reference
- **[iOS/iPadOS app protection policy settings in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/ref-settings-ios)** — Lists and explains iOS/iPadOS-specific app protection policy settings in Intune.
- **[App Protection Policies Overview - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/overview)** — Explains Intune app protection policies for managed apps and unenrolled devices.
- **[Tutorial - Walkthrough the Microsoft Intune Admin Center - Microsoft Intune](https://learn.microsoft.com/en-us/intune/fundamentals/tutorial-admin-center-walkthrough)** — Shows the App protection policy status area and troubleshooting views for app protection users in Intune.
