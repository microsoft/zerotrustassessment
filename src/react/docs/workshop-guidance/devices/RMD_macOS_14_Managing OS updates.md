# Managing OS Updates

**Implementation Effort:** Medium
**User Impact:** Medium — users will see update prompts, deadlines, and possible restarts depending on policy choice.

## Overview
Keeping Macs current is a core Zero Trust requirement because unsupported or unpatched devices quickly undermine compliance and access policy. In Microsoft Intune, update management should be based on supported Apple update controls for the macOS versions in scope, with clear pilot rings, user communication, and escalation paths for devices that repeatedly miss deadlines.

## Implementation Guidance
1. Inventory macOS versions currently in use and decide which remain in internal support so you know which update-management features apply.
2. Create pilot, broad, and exception rings for macOS updates and keep sensitive or business-critical devices separate.
3. Use the supported Intune update-management method for the device's OS level and review current Microsoft Learn guidance before publication.
4. Set deadlines and user communications that balance security urgency with realistic user workflows.
5. Measure compliance using update reporting and broader device posture and document how emergency Apple security releases are expedited.

## Reference
- **[Configure Update Policies for Apple Devices - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-updates/apple/)** — Explains how to configure Apple software update policies, including for macOS devices.
- **[Device compliance policies in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-security/compliance/overview)** — Describes compliance policy settings, supported actions, and platform coverage including macOS.
