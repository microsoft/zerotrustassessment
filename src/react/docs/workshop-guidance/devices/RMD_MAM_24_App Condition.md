# App Condition

**Implementation Effort:** Medium

**User Impact:** Low

## Overview
In Intune APP, conditional launch settings define what the app should check before continuing to allow access to organizational data and what action should follow if a condition is not met. This is the runtime enforcement layer that turns policy into active protective behavior.

Conditional launch checks address distinct risk categories across your mobile estate: app and OS version hygiene, device integrity and root/jailbreak detection, Mobile Threat Defense risk signals, and offline grace intervals.

## Implementation Guidance
1. In the Microsoft Intune admin center, open the relevant Android and iOS/iPadOS app protection policies and review the **Conditional launch** settings.
2. Configure the checks that match your risk model, such as **max PIN attempts**, **offline grace period**, **minimum app version**, **minimum OS version** where supported, **jailbroken and rooted device response**, and **device threat level** when Microsoft Defender for Endpoint or another supported MTD solution is integrated.
3. For each check, define the action intentionally: **warn**, **block access**, or **wipe organizational data** as supported. Higher-risk conditions usually justify block or wipe; lower-risk hygiene conditions may start with warn during pilot rollout.
4. Test each condition deliberately in a lab or pilot so support teams know what the user sees and what remediation path is expected.

## Reference
- **[App Protection Policies Overview - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/overview)** — Covers conditional launch actions, including selective wipe behavior when app protection conditions are no longer met.
- **[Android App Protection Policy Settings - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/ref-settings-android)** — Details Android app protection policy data protection, access requirements, and conditional launch settings.
- **[iOS/iPadOS App Protection Policy Settings - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/ref-settings-ios)** — Details iOS/iPadOS app protection policy data protection, access requirements, and conditional launch settings.
