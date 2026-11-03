# PIN or Biometric

**Implementation Effort:** Low

**User Impact:** Medium

## Overview
App-level authentication is one of the core MAM protections in Microsoft Intune. Requiring a PIN establishes a work-specific unlock factor inside the managed app, and allowing biometrics can improve usability after the user has met the PIN requirement.

This matters most on BYOD devices, shared family tablets, and other cases where the organization cannot assume the device itself is protected in the way a fully managed corporate endpoint would be.

## Implementation Guidance
1. In **Apps** > **App protection policies**, edit the Android and iOS/iPadOS policies and review the **Access requirements** settings.
2. Enable **Require PIN for access** or the current equivalent UI text and choose supporting values intentionally, such as minimum PIN length and whether simple PINs are allowed, based on your protection tier.
3. If biometrics are allowed, configure the policy so biometric sign-in supplements the app PIN instead of replacing the need for an initial app-specific trust boundary where Microsoft documents that behavior.
4. Coordinate the PIN and biometric settings with timeout, offline grace period, and Conditional Access expectations so the user experience is consistent and not overly repetitive.
5. Pilot the experience with iOS and Android users and capture support guidance for first-run prompts, biometric enrollment changes, and forgotten PIN scenarios.

## Reference
- **[App Protection Policies Overview - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/overview)** — Describes Intune app protection access requirements such as PIN, biometric, credential, and recheck controls.
- **[Android App Protection Policy Settings - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/ref-settings-android)** — Details Android app protection policy data protection, access requirements, and conditional launch settings.
- **[iOS/iPadOS App Protection Policy Settings - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/ref-settings-ios)** — Details iOS/iPadOS app protection policy data protection, access requirements, and conditional launch settings.
