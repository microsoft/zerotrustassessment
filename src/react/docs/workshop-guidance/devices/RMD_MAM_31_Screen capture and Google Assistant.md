# Screen Capture and Google Assistant

**Implementation Effort:** Low  
**User Impact:** Medium

## Overview

Android app protection policies in Microsoft Intune can reduce accidental or deliberate data leakage by blocking screen capture and limiting digital assistant access to organizational data inside managed apps. This is especially useful on personally owned devices where the organization does not control the full device but still needs to protect Outlook, Teams, OneDrive, and similar apps.

The control should be applied deliberately. Some business processes depend on screenshots for support or collaboration, so administrators should target higher-sensitivity populations first and document approved alternatives for sharing information.

## Implementation Guidance

1. In the Microsoft Intune admin center, go to Apps > App protection policies and create or edit an Android policy for the users and apps that handle sensitive data. Confirm that the app list includes the Microsoft 365 apps you actually intend to protect.
2. In the Data protection and Conditional launch settings, enable the controls that block screen capture and restrict assistant-style access where supported. Validate whether your tenant UI also mentions app preview blurring, Circle to Search, or similar Android platform behaviors.
3. Separate broad office productivity populations from high-sensitivity groups. Executives, finance, HR, and regulated data handlers often justify stricter controls than general knowledge workers.
4. Pair the app protection policy with Conditional Access so data can be accessed only through protected client apps. If users can fall back to an unmanaged app, the screen-capture restriction will not meaningfully reduce risk.
5. Pilot with Android users who rely on Teams meetings, support workflows, and document sharing. Confirm that required business functions still work and publish user guidance that explains why screenshots are blocked and which approved sharing methods should be used instead.

## Reference

- **[Android App Protection Policy Settings - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/ref-settings-android)** — Details Android app protection policy data protection, access requirements, and conditional launch settings.
- **[App Protection Policies Overview - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/overview)** — Explains the Intune app protection data protection framework and the recommended protection levels for managed apps.
- **[Migrate approved client app to application protection policy in Conditional Access - Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/conditional-access/migrate-approved-client-app)** — Explains current Conditional Access guidance for requiring approved client apps or app protection policy with mobile devices.
