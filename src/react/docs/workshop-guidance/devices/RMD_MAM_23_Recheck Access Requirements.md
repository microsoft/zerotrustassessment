# Recheck Access Requirement

**Implementation Effort:** Low

**User Impact:** Low

## Overview
The **Recheck the access requirements after** setting controls how often a managed app must re-evaluate the user’s access conditions. It complements, but does not replace, inactivity timeout and broader Microsoft Entra session controls.

This setting matters because it limits how long a previously validated app session can continue without being challenged again, which is especially important on shared, unattended, or higher-risk mobile devices.

## Implementation Guidance
1. In **Apps** > **App protection policies**, review the **Access requirements** section for the Android and iOS/iPadOS policies that use app PIN or related access controls.
2. Configure the recheck interval based on the protection tier. More sensitive populations generally justify shorter intervals; general productivity users may need a balance that reduces repeated prompts during normal work.
3. Document the difference between this setting, the app inactivity timeout, and any Microsoft Entra sign-in frequency or Conditional Access session controls so administrators do not create overlapping prompts accidentally.
4. Test with pilot users over a realistic workday and confirm that the recheck cadence is understandable and supportable.

## Reference
- **[App Protection Policies Overview - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/overview)** — Describes Intune app protection access requirements such as PIN, biometric, credential, and recheck controls.
