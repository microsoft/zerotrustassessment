# Review Data Protection Framework

**Implementation Effort:** Medium – IT and Security Operations teams must assess organizational risk levels, map users to protection tiers, and configure appropriate App Protection Policies (APP) in Intune.

**User Impact:** High – A large number of non-privileged users will experience changes in app behavior, such as stricter access controls, blocked data sharing, and additional authentication requirements, depending on their assigned protection level.

## Overview

The **Data Protection Framework** in Microsoft Intune is a structured approach to applying **App Protection Policies (APP)** that safeguard organizational data within managed apps—regardless of whether the device is enrolled. This framework helps organizations prevent data leakage and align protection levels with user risk profiles and data sensitivity.

The framework is divided into three levels:

- **Level 1 – Enterprise Basic Protection**: Minimum recommended settings for general enterprise use. Offers baseline protections like PIN requirements and basic data encryption.
- **Level 2 – Enterprise Enhanced Protection**: Designed for users accessing sensitive or confidential data. Adds stricter controls such as blocking data transfer between apps and enforcing biometric access.
- **Level 3 – Enterprise High Protection**: Intended for high-risk users or organizations targeted by advanced threats. Includes the most restrictive settings, such as preventing data backup and requiring device compliance.

When deployed broadly across an organization, this framework significantly impacts users. Many will need to adapt to new app behaviors, such as blocked copy/paste, enforced app PINs, or conditional access prompts. These changes can affect productivity and require user training and support.

This framework supports the Zero Trust principle of **assume breach** by applying layered, risk-based protections that limit data exposure even if a device or app is compromised.

## Reference

- [Data protection framework using app protection policies - Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-framework)  
- [App protection policies overview - Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy)  
- [Use the app protection framework with Microsoft Intune](https://learn.microsoft.com/en-us/microsoft-365/solutions/apps-protect-framework?view=o365-worldwide)
