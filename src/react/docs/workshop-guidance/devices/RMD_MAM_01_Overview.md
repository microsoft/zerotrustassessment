# MAM Overview

**Implementation Effort:** Medium

**User Impact:** Medium

## Overview
Microsoft Intune Mobile Application Management (MAM) protects organizational data inside apps, even when the device is not enrolled in Intune. In practice, that means administrators can require a work account, app PIN or biometrics, encryption, approved data transfer paths, and conditional launch checks for apps such as Outlook, Teams, OneDrive, and the Microsoft 365 apps.

In a Zero Trust architecture, MAM serves as the app-layer control set that complements Microsoft Entra Conditional Access, strong authentication, and, where appropriate, MDM device enrollment. MAM is particularly important for BYOD access because it lets the organization protect corporate data without taking full management control of a personal device.

## Implementation Guidance
1. In the Microsoft Intune admin center, go to **Apps** > **App protection policies** and create separate policies for **Android** and **iOS/iPadOS**. If you also use Windows app protection, document that separately because available controls differ by platform.
2. Create a pilot assignment strategy based on **user groups**, not device groups. Start with IT/security pilot users, then high-value mobile users, then the broader BYOD population.
3. Configure the baseline controls most organizations expect in a Zero Trust deployment: require a work or school account, require an app PIN, allow biometric use after the PIN is established, encrypt organizational data, restrict data transfer to policy-managed apps, and block backup to personal cloud services where supported.
4. Use **Conditional Access** to require either an approved client app or an app protection policy for targeted cloud apps such as Exchange Online and SharePoint Online, so the policy is part of the access path rather than an optional client setting.
5. Publish a supported-app list and user instructions. For unmanaged BYOD users, call out whether they need Company Portal, Microsoft Defender for Endpoint, Microsoft Edge, or only the managed app itself based on the scenarios you enable.
6. Validate the design with test cases: sign in from an unmanaged personal device, confirm the app receives policy, verify copy/paste restrictions, verify save/open restrictions, and verify selective wipe behavior when the user is removed from scope or loses access.

## Video Walkthrough

<iframe width="560" height="315" src="https://www.youtube.com/embed/VWPLn1nel8g?si=21Yr1a17dSMhq8h8" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

## Reference
- **[App Protection Policies Overview - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/overview)** — Explains Intune app protection policies for managed apps and unenrolled devices.
- **[Use app-based Conditional Access policies with Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-security/conditional-access-integration/app-based-policies)** — Explains how app-based Conditional Access works with Intune app protection policies.
- **[Tutorial - Walkthrough the Microsoft Intune Admin Center - Microsoft Intune](https://learn.microsoft.com/en-us/intune/fundamentals/tutorial-admin-center-walkthrough)** — Shows the App protection policy status area and troubleshooting views for app protection users in Intune.
