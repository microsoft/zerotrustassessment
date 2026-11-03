# Transfer Telecommunication Data

**Implementation Effort:** Low

**User Impact:** Medium

## Overview
The telecommunication transfer control in Intune APP governs whether a managed app can hand communication actions such as dialing, texting, or launching communication-related links to other apps. In Zero Trust terms, it prevents a managed work context from silently handing identifiers or workflow context to unmanaged consumer apps.

Because the exact behavior is platform- and app-dependent, administrators should treat this as a scenario setting that must be validated in the apps their users actually rely on, rather than assuming the same behavior across Outlook, Teams, or third-party apps.

## Implementation Guidance
1. Open the relevant Android and iOS/iPadOS app protection policies in **Apps** > **App protection policies** and review the telecommunication or data transfer controls documented for that platform.
2. Choose the most restrictive value that still supports business workflows. A common pattern is to prefer policy-managed destinations when the organization standardizes on managed communication apps, and to avoid **Any app** unless there is a documented need.
3. Test common user actions on each platform: tapping a phone number, tapping an SMS link, tapping an email-style action, and launching communication from Outlook or other managed apps. Confirm whether the action stays in a managed app ecosystem or escapes to an unmanaged app.
4. Where business workflows require native dialer or messaging integration, document the exception and the associated risk, especially for executive assistants, field workers, or contact-center scenarios.
5. Pair this setting review with **Send org data to other apps** so the organization has one coherent story for what may leave a managed app and through which channels.

## Reference
- **[Android app protection policy settings in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/ref-settings-android)** — Lists and explains Android-specific app protection policy settings in Intune.
- **[iOS/iPadOS app protection policy settings in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/ref-settings-ios)** — Lists and explains iOS/iPadOS-specific app protection policy settings in Intune.
- **[App Protection Policies Overview - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/overview)** — Explains Intune app protection policies for managed apps and unenrolled devices.
