# Review Unenrolled BYOD MAM in the Context of Intune App Protection Policies

**Implementation Effort:** Medium – IT and Security Operations teams must configure app protection policies, define app configuration profiles, and maintain ongoing support for BYOD users.

**User Impact:** High – A large number of non-privileged users with personal (BYOD) devices must follow new app usage rules, install or update apps, and adapt to new access and security behaviors.

## Overview

Mobile Application Management (MAM) for unenrolled devices in Microsoft Intune allows organizations to protect corporate data at the app level without requiring full device enrollment. This is especially useful in Bring Your Own Device (BYOD) scenarios, where users access corporate resources like Outlook or Teams from personal devices.

MAM uses **App Protection Policies (APP)** to enforce controls such as:
- Requiring PINs to access apps
- Blocking copy/paste between managed and unmanaged apps
- Encrypting app data at rest

These policies apply only to supported apps and do not affect the rest of the device. MAM is available on Android and iOS/iPadOS.

When deployed across a large workforce, especially in hybrid or remote environments, the user impact becomes high. Many users must:
- Install the Company Portal or Microsoft Intune app
- Accept new terms of use
- Learn how to use protected apps differently (e.g., no copy/paste)
- Contact support for setup or troubleshooting

This approach supports the Zero Trust principle of **least privilege access** by ensuring that only approved apps can access corporate data, and that data remains protected even if the device is unmanaged. Without MAM, organizations risk data leakage from personal devices that access sensitive content without any policy enforcement.

## Reference

- [Mobile Application Management (MAM) for unenrolled devices in Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/deployment-guide-enrollment-mamwe)  
- [App protection policies overview - Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy)  
- [MAM and Android Enterprise personally owned devices](https://learn.microsoft.com/en-us/intune/intune-service/apps/android-deployment-scenarios-app-protection-work-profiles)
