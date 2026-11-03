# Knox Attestation

**Implementation Effort:** Low  
**User Impact:** Low

## Overview

Samsung Knox attestation gives organizations an additional device integrity signal on supported Samsung Android devices. In Microsoft Intune, this signal is most relevant when you want stronger assurance that a device accessing organizational data has not been rooted or tampered with.

This control should be positioned as a targeted enhancement, not as the entire Android trust strategy. Use it together with Android Enterprise enrollment choices, app protection policies, mobile threat defense, and Conditional Access so Samsung devices are protected consistently with the rest of the mobile fleet.

## Implementation Guidance

1. First confirm scope. Knox attestation only applies to supported Samsung devices, so identify whether it is required for all Samsung users or only for high-sensitivity groups such as executives, developers, or regulated business units.
2. In the Microsoft Intune admin center, create or update the Android app protection policy that applies to Samsung users. Review the Conditional launch settings and enable the Samsung Knox attestation-related control where available in your tenant UI.
3. Set a clear action for failure. In most environments, Block access is appropriate immediately, followed by Wipe organizational data after a defined interval if the device does not return to a healthy state. Document the user support process before broad rollout.
4. Pair the policy with Conditional Access and app targeting. Require protected client apps for Exchange Online, SharePoint, and Teams so organizational data is accessed only through apps that can enforce Intune policy.
5. Pilot on representative Samsung models and Android versions. Validate both success and failure behavior, including what users see in Outlook or Teams when attestation fails and how help desk staff can distinguish policy blocks from general sign-in problems.

## Reference

- **[Android App Protection Policy Settings - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/ref-settings-android)** — Details Android app protection policy data protection, access requirements, and conditional launch settings.
- **[Migrate approved client app to application protection policy in Conditional Access - Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/conditional-access/migrate-approved-client-app)** — Explains current Conditional Access guidance for requiring approved client apps or app protection policy with mobile devices.
- **[Android device enrollment guide for Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-enrollment/android/guide)** — Summarizes Android Enterprise enrollment options in Intune, including Samsung Knox Mobile Enrollment guidance.
