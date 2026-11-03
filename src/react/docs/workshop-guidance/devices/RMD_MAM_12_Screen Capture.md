# Screen Capture

**Implementation Effort:** Medium

**User Impact:** Medium

## Overview
Screen capture controls reduce the risk that users capture sensitive work data outside the intended managed data path. However, organizations should document this carefully because Intune’s protection options differ by platform and are not all pure MAM controls.

For Zero Trust guidance, the key message is that administrators should use the native APP control where it exists, understand platform limitations, and combine MAM with device management or app-specific settings when a platform does not offer equivalent screenshot protection through APP alone.

## Implementation Guidance
1. For **Android**, review the app protection policy setting that blocks screen capture and related assistant or search exposure in supported apps. Configure it in the Android policy under **Apps** > **App protection policies** and test the actual user experience, including app-switcher previews where documented by Microsoft.
2. For **iOS/iPadOS**, do not imply there is a universal MAM-only screenshot block unless Microsoft Learn specifically documents one for the target app and platform combination. If the requirement is strict, document complementary controls such as device management restrictions, sensitivity labeling, or workflow redesign.
3. Apply this control first to populations handling sensitive or regulated data. For broad populations, confirm that support teams understand the productivity impact before enforcing it at scale.
4. Test on physical devices, not only emulators: screenshot, screen recording, app switcher preview, and any assistant or search integrations referenced by Microsoft Learn.

## Reference
- **[Android App Protection Policy Settings - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/ref-settings-android)** — Details Android app protection policy data protection, access requirements, and conditional launch settings.
- **[iOS/iPadOS App Protection Policy Settings - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/ref-settings-ios)** — Details iOS/iPadOS app protection policy data protection, access requirements, and conditional launch settings.
- **[App Protection Policies Overview - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/protection/overview)** — Explains Intune app protection policy capabilities, the data protection framework, access requirements, and conditional launch behaviors.
