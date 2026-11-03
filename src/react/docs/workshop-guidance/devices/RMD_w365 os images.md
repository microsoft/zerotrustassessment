# Windows 365: Operating System Images

**Implementation Effort:** Medium  
**User Impact:** Low

## Overview

Operating system image selection directly affects how secure, supportable, and quickly deployable a Windows 365 environment will be. Most organizations should start with Microsoft-provided gallery images because they are updated regularly and reduce image engineering effort. Custom images are useful when business applications or configuration standards require tighter control.

From a Zero Trust perspective, image choice is about minimizing drift and reducing the number of insecure or obsolete baselines in circulation. The fewer unique images you operate, the easier it is to patch, validate, and govern Cloud PCs consistently.

## Implementation Guidance

1. Prefer gallery images unless you have a documented requirement for a custom image. Gallery images typically provide the fastest path to deployment and reduce the risk of carrying forward unnecessary legacy configuration.
2. If you must use a custom image, build it from a supported Windows base, keep it generalized according to Microsoft guidance, and avoid baking in stale credentials, local admin exceptions, or line-of-business software that should instead be deployed through Intune or other managed packaging.
3. Store and validate custom images using the supported Windows 365 and Azure image requirements. Confirm generation type, supported editions, patch level, and application compatibility before assigning the image to a production provisioning policy.
4. Review image lifecycle monthly. Retire outdated images, track image version ownership, and align custom-image patching with your Windows update and vulnerability-management processes.
5. Pilot each image with a representative user set before broad rollout. Confirm provisioning success, application launch, performance, security baseline application, and enrollment into Intune management.

## Reference

- **[Device images in Windows 365](https://learn.microsoft.com/en-us/windows-365/enterprise/device-images)** — Explains how to evaluate and choose gallery or custom device images for Cloud PCs.
- **[Add or delete custom device images for Windows 365](https://learn.microsoft.com/en-us/windows-365/enterprise/add-device-images)** — Shows how to add and manage custom device images for Windows 365.
- **[Managing Cloud PCs with Microsoft Intune](https://learn.microsoft.com/en-us/windows-365/enterprise/device-management-overview)** — Describes how Cloud PCs are managed through Microsoft Intune.
