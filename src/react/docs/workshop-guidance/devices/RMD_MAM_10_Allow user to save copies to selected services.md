# Allow User to Save Copies to Selected Services

**Implementation Effort:** Low

**User Impact:** Medium

## Overview
This APP control lets administrators make a limited exception to a broader **block save copies of org data** posture. Rather than allowing users to save work data anywhere, administrators can permit only specific trusted services or app destinations supported by Intune.

Used correctly, this setting helps preserve productivity while maintaining Zero Trust data containment. Used loosely, it becomes an exception path that quietly undermines the broader data transfer strategy.

## Implementation Guidance
1. First confirm the parent control is designed correctly. This setting is most useful when the broader save copies of organizational data behavior is restricted and you need to allow only a small set of approved destinations.
2. In **Apps** > **App protection policies**, edit the relevant Android or iOS/iPadOS policy and review the data protection settings that govern save-as behavior and approved save locations.
3. Allow only destinations that are part of the organization’s managed data path, typically Microsoft OneDrive for Business and SharePoint Online. Avoid broad allowances for local storage or consumer services unless there is a documented exception and compensating control.
4. Test the supported app matrix. Save and open behaviors are not identical across Outlook, Office mobile apps, Edge, and line-of-business apps, so validate the exact workflows the business uses.
5. Publish the approved-save-path standard: for example, users may save to OneDrive for Business or SharePoint Online from managed apps, but not to personal OneDrive, consumer storage apps, or unprotected local destinations.

## Reference
- **[Android app protection policy settings in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/ref-settings-android)** — Lists and explains Android-specific app protection policy settings in Intune.
- **[iOS/iPadOS app protection policy settings in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/ref-settings-ios)** — Lists and explains iOS/iPadOS-specific app protection policy settings in Intune.
- **[App Protection Policies Overview - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/overview)** — Explains Intune app protection policies for managed apps and unenrolled devices.
