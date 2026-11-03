# MDM_03: Enrollment Restrictions for MDM for iOS and Android in Intune

**Implementation Effort:** Low  
**User Impact:** Low

## Overview

Enrollment restrictions help Microsoft Intune administrators control which devices are allowed into management in the first place. They are useful for blocking unsupported platforms, older operating systems, or device ownership patterns that do not match the organization’s mobile strategy.

These controls reduce operational sprawl, but they are not a full security boundary on their own. A Zero Trust device posture still depends on enrollment choices, compliance, app protection, and Conditional Access after the device appears in Intune.

## Implementation Guidance

1. In the Microsoft Intune admin center, go to Devices > Enrollment > Enrollment restrictions and review the default device type restriction and device limit restriction policies before creating custom ones. Document what should be allowed by default versus only through targeted override groups.
2. Create platform restriction policies that reflect the approved enrollment methods for your tenant. Common examples include blocking Android device administrator, allowing Android Enterprise only, setting minimum OS versions, and blocking personally owned devices for populations that must use corporate-owned hardware.
3. Use user groups to target exceptions deliberately. If an executive or field-worker program needs a different enrollment path, create a higher-priority policy for that group instead of weakening the default policy for everyone.
4. Review device limit restrictions based on business need. A limit that is too high can create unnecessary support noise and inventory sprawl, while a limit that is too low can frustrate legitimate multi-device users.
5. Test with new-user and existing-user scenarios. Confirm that blocked devices fail early with understandable messaging and that approved devices can still complete the intended Android Enterprise or Apple enrollment workflow.

## Reference

- **[Step 5 – Enroll devices in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-enrollment/enroll-devices)** — Explains Intune enrollment restrictions, including device platform and device limit restriction options.
- **[Android device enrollment guide for Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-enrollment/android/guide)** — Explains current Android Enterprise enrollment guidance and notes the retirement of Android device administrator management.
- **[Device enrollment guide for Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-enrollment/guide)** — Helps plan Intune enrollment scenarios across platforms, ownership models, and enrollment methods.
