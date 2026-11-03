# Backup to Android Backup Services

**Implementation Effort:** Low

**User Impact:** Medium

## Overview
On Android, the Intune app protection control for backup to Android backup services helps prevent organizational data from being copied into personal or consumer-controlled backup stores. For most Zero Trust designs, blocking backup of organizational data is the safer default unless there is a documented business requirement and compensating controls.

This setting matters most in BYOD and mixed-use scenarios because personal cloud backup destinations are outside the organization’s control and may conflict with retention, residency, or incident-response requirements.

## Implementation Guidance
1. In the Microsoft Intune admin center, go to **Apps** > **App protection policies**, open the relevant **Android** policy, and review the **Data protection** settings.
2. Set **Backup org data to Android backup services** to **Block** for users who access organizational data from unmanaged or personally owned devices, unless a documented exception has been approved.
3. If different business units have different retention or recovery requirements, create separate Android policy assignments rather than weakening the default policy for everyone.
4. Communicate the user impact clearly: users may still reinstall the app and rehydrate data from Microsoft 365 services, but work data stored only inside the app should not be expected to survive through personal Android backup services.
5. After deployment, test with supported managed apps to confirm the policy is received, verify that backup and restore behavior matches expectation, and document any app-specific exceptions or limitations called out by Microsoft Learn.

## Reference
- **[Android app protection policy settings in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/ref-settings-android)** — Lists and explains Android-specific app protection policy settings in Intune.
- **[App Protection Policies Overview - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/overview)** — Explains Intune app protection policies for managed apps and unenrolled devices.
- **[Tutorial - Walkthrough the Microsoft Intune Admin Center - Microsoft Intune](https://learn.microsoft.com/en-us/intune/fundamentals/tutorial-admin-center-walkthrough)** — Shows the App protection policy status area and troubleshooting views for app protection users in Intune.
